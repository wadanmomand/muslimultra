// ==============================================================================
// Muslim Ultra - Muslim AI Gateway (Supabase Deno Edge Function)
// Spec: PHASE1_SPEC.md v2.0 §3 (M3), §5 (AI Architecture), §6 (Unit Economics)
// v1.1: dual-provider (OpenAI primary / Gemini) — AI_PROVIDER secret selects.
// ==============================================================================

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const DAILY_FREE_CAP = 20;

// AI_PROVIDER: "openai" | "gemini" — selects primary, other key is fallback.
// GEMINI_MODEL: comma-separated fallback list (first working model wins).
const AI_PROVIDER = (Deno.env.get("AI_PROVIDER") || "openai").toLowerCase();
const GEMINI_MODELS = (Deno.env.get("GEMINI_MODEL") ||
  "gemini-3.6-flash,gemini-3.5-flash,gemini-3.5-flash-lite")
  .split(",").map((s) => s.trim()).filter(Boolean);
const GEMINI_EMBED_MODEL = "gemini-embedding-001"; // + outputDimensionality 768

interface ChatRequest {
  user_id?: string;
  query: string;
  language?: string; // 'en' | 'ar' | 'ur'
  explain_more?: boolean;
}

// SHA-256 Hash Helper for Cache Key
async function sha256(message: string): Promise<string> {
  const msgBuffer = new TextEncoder().encode(message.trim().toLowerCase());
  const hashBuffer = await crypto.subtle.digest("SHA-256", msgBuffer);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map((b) => b.toString(16).padStart(2, "0")).join("");
}

function providerOrder(): Array<"gemini" | "openai"> {
  return AI_PROVIDER === "gemini" ? ["gemini", "openai"] : ["openai", "gemini"];
}

// Embed text to a 768-dim vector. Tries primary provider, falls back to secondary.
async function embedText(text: string): Promise<number[] | null> {
  const openAiKey = Deno.env.get("OPENAI_API_KEY") || "";
  const geminiKey = Deno.env.get("GEMINI_API_KEY") || "";
  for (const p of providerOrder()) {
    try {
      if (p === "gemini" && geminiKey) {
        const r = await fetch(
          `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_EMBED_MODEL}:embedContent`,
          {
            method: "POST",
            headers: { "Content-Type": "application/json", "x-goog-api-key": geminiKey },
            body: JSON.stringify({
              content: { parts: [{ text }] },
              outputDimensionality: 768,
            }),
          }
        );
        if (!r.ok) continue;
        const j = await r.json();
        const v: number[] | undefined = j.embedding?.values;
        if (v && v.length === 768) return v;
      } else if (p === "openai" && openAiKey) {
        const r = await fetch("https://api.openai.com/v1/embeddings", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${openAiKey}`,
          },
          body: JSON.stringify({ model: "text-embedding-3-small", input: text, dimensions: 768 }),
        });
        if (!r.ok) continue;
        const j = await r.json();
        const v: number[] | undefined = j.data?.[0]?.embedding;
        if (v && v.length === 768) return v;
      }
    } catch { /* try next provider */ }
  }
  return null;
}

// Generate a grounded answer. Tries primary provider, falls back to secondary.
async function generateAnswer(
  systemPrompt: string,
  query: string,
  maxTokens: number
): Promise<string | null> {
  const openAiKey = Deno.env.get("OPENAI_API_KEY") || "";
  const geminiKey = Deno.env.get("GEMINI_API_KEY") || "";
  for (const p of providerOrder()) {
    try {
      if (p === "gemini" && geminiKey) {
        for (const model of GEMINI_MODELS) {
          try {
            const r = await fetch(
              `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent`,
              {
                method: "POST",
                headers: { "Content-Type": "application/json", "x-goog-api-key": geminiKey },
                body: JSON.stringify({
                  systemInstruction: { parts: [{ text: systemPrompt }] },
                  contents: [{ role: "user", parts: [{ text: query }] }],
                  // Thinking disabled: flash "thinking" tokens share the output
                  // budget and were truncating non-English answers mid-sentence.
                  generationConfig: {
                    temperature: 0.2,
                    maxOutputTokens: maxTokens,
                    thinkingConfig: { thinkingBudget: 0 },
                  },
                }),
              }
            );
            if (!r.ok) continue;
            const j = await r.json();
            const t: string | undefined = j.candidates?.[0]?.content?.parts?.[0]?.text;
            if (t) return t;
          } catch { /* try next model */ }
        }
      } else if (p === "openai" && openAiKey) {
        const r = await fetch("https://api.openai.com/v1/chat/completions", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${openAiKey}`,
          },
          body: JSON.stringify({
            model: "gpt-4o-mini",
            messages: [
              { role: "system", content: systemPrompt },
              { role: "user", content: query },
            ],
            temperature: 0.2,
            max_tokens: maxTokens,
          }),
        });
        if (!r.ok) continue;
        const j = await r.json();
        const t: string | undefined = j.choices?.[0]?.message?.content;
        if (t) return t;
      }
    } catch { /* try next provider */ }
  }
  return null;
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
    );

    const body: ChatRequest = await req.json();
    const query = body.query?.trim();
    const userId = body.user_id || "anonymous_user";
    const language = body.language || "en";
    const explainMore = body.explain_more || false;

    if (!query) {
      return new Response(JSON.stringify({ error: "Query cannot be empty" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 1. Rate Limiting Check (20 msgs / day / user)
    const today = new Date().toISOString().split("T")[0];
    const { data: rateData } = await supabaseClient
      .from("user_rate_limits")
      .select("message_count")
      .eq("user_id", userId)
      .eq("usage_date", today)
      .maybeSingle();

    const currentCount = rateData?.message_count ?? 0;
    if (currentCount >= DAILY_FREE_CAP) {
      return new Response(
        JSON.stringify({
          error: "Daily free cap reached (20 messages/day). Resets at midnight.",
          limit_reached: true,
          remaining_turns: 0,
        }),
        {
          status: 429,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Increment user rate limit counter
    await supabaseClient.from("user_rate_limits").upsert({
      user_id: userId,
      usage_date: today,
      message_count: currentCount + 1,
    });

    const remainingTurns = Math.max(0, DAILY_FREE_CAP - (currentCount + 1));

    // 2. Response Cache Lookup (Target 30%+ cache hits on common questions)
    const cacheKey = await sha256(`${language}:${explainMore ? "long" : "short"}:${query}`);
    const { data: cachedResponse } = await supabaseClient
      .from("ai_response_cache")
      .select("response_text, citations")
      .eq("query_hash", cacheKey)
      .gt("expires_at", new Date().toISOString())
      .maybeSingle();

    if (cachedResponse) {
      // Cache Hit ($0 LLM cost)
      try {
        await supabaseClient.rpc("increment_cache_hit", { q_hash: cacheKey });
      } catch { /* hit counting is best-effort */ }

      return new Response(
        JSON.stringify({
          answer: cachedResponse.response_text,
          citations: cachedResponse.citations,
          cached: true,
          remaining_turns: remainingTurns,
        }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 3. Check any AI provider key is configured
    const hasAnyKey = Deno.env.get("OPENAI_API_KEY") || Deno.env.get("GEMINI_API_KEY");

    // Fallback if no provider key is configured on Supabase
    if (!hasAnyKey) {
      return new Response(
        JSON.stringify({
          answer: `[Muslim AI RAG Gateway Ready]\nTo enable full live LLM generations, add OPENAI_API_KEY or GEMINI_API_KEY as a secret in your Supabase Edge Function settings.\n\nQuery received: "${query}"`,
          citations: [],
          cached: false,
          remaining_turns: remainingTurns,
          footer: "Note: Muslim AI is an educational tool. For formal legal rulings (Fatawa) on personal situations, please consult a qualified Islamic scholar.",
        }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 4. RAG retrieval: embed the query and pull trusted corpus matches (best-effort)
    let ragContext = "";
    try {
      const embedding = await embedText(query);
      if (embedding) {
        const { data: matches } = await supabaseClient.rpc("match_corpus_documents", {
          query_embedding: `[${embedding.join(",")}]`,
          match_threshold: 0.55,
          match_count: 4,
        });
        if (matches && (matches as unknown[]).length > 0) {
          ragContext = (matches as Array<{ reference: string; content_english: string }>)
            .map((m) => `[${m.reference}] ${m.content_english}`)
            .join("\n");
        }
      }
    } catch { /* RAG is best-effort; fall back to prompt-only grounding */ }

    // 5. Grounded generation with provider fallback
    const systemPrompt = `You are Muslim AI, an authentic Islamic AI assistant for Muslim Ultra.
Trusted corpus context (prefer these sources; cite their references verbatim when used):
${ragContext || "(no corpus matches above threshold)"}
Strict Grounding Rules:
1. Every factual Islamic claim MUST carry an inline citation in brackets, e.g. [Quran 2:152] or [Sahih al-Bukhari 54].
2. ZERO fabrication: Never invent or attribute unverified hadiths. If a detail is not authentic or verified in classical sources, decline politely.
3. Fiqh & Ikhtilaf: Whenever there is recognized scholarly disagreement between Madhabs (Hanafi, Shafi'i, Maliki, Hanbali), label the views clearly (e.g. [Hanafi: ...], [Shafi'i/Hanbali: ...]).
4. Conciseness: Provide a clear, short answer under 120 words by default.
5. Mandatory Disclaimer: If the question touches upon religious law, purity, or rulings, append this footer at the end:
"Note: Muslim AI is an educational tool. For formal legal rulings (Fatawa) on personal situations, please consult a qualified Islamic scholar."
Language requested: ${language}.`;

    // Note: Gemini flash models "think" — thinking tokens share the output
    // budget, so caps must leave room for reasoning + the visible answer.
    const generated = await generateAnswer(
      systemPrompt,
      query,
      explainMore ? 2500 : 1200
    );
    const answerText = generated ?? "Unable to generate answer.";

    // Parse citations from bracket tags, Latin or Arabic script, e.g.
    // [Quran 2:152], [Sahih al-Bukhari 54], [صحيح البخاري 8، صحيح مسلم 16].
    // Brackets holding multiple refs (separated by ; ، or ", " before a new
    // source name) are split into individual citations.
    const rawMatches =
      (generated ?? "").match(
        /\[[^\]]*(?:Quran|Sahih|Sunan|Hisn|Musnad|Muwatta|قرآن|صحيح|سنن|حصن|مسند|موطأ)[^\]]*\]/g
      ) || [];
    const citations = Array.from(
      new Set(
        rawMatches.flatMap((c) =>
          c
            .replace(/\[|\]/g, "")
            .split(/[;،]|,(?=\s*[A-Za-z\u0600-\u06FF])/)
            .map((s) => s.trim())
            .filter(Boolean)
        )
      )
    );

    // Cache the newly generated response (never cache upstream failures)
    if (generated) {
      try {
        await supabaseClient.from("ai_response_cache").insert({
          query_hash: cacheKey,
          query_text: query,
          language: language,
          response_text: answerText,
          citations: citations,
          is_short_answer: !explainMore,
        });
      } catch { /* caching is best-effort */ }
    }

    return new Response(
      JSON.stringify({
        answer: answerText,
        citations: citations,
        cached: false,
        remaining_turns: remainingTurns,
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (err) {
    return new Response(JSON.stringify({ error: (err as Error).message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
