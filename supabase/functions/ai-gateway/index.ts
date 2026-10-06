// ==============================================================================
// Muslim Ultra - Deen Companion AI Gateway (Supabase Deno Edge Function)
// Spec: PHASE1_SPEC.md v2.0 §3 (M3), §5 (AI Architecture), §6 (Unit Economics)
// ==============================================================================

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const DAILY_FREE_CAP = 20;

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
    const { data: rateData, error: rateError } = await supabaseClient
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

    // 3. RAG Retrieval: embed the query, fetch trusted corpus matches via pgvector
    const openAiKey = Deno.env.get("OPENAI_API_KEY") || Deno.env.get("GEMINI_API_KEY") || "";

    // Fallback if external API key is not yet configured on Supabase
    if (!openAiKey) {
      return new Response(
        JSON.stringify({
          answer: `[Deen Companion RAG Gateway Ready]\nTo enable full live LLM generations, add OPENAI_API_KEY or GEMINI_API_KEY as a secret in your Supabase Edge Function settings.\n\nQuery received: "${query}"`,
          citations: ["Quran 2:152", "Sahih al-Bukhari 1"],
          cached: false,
          remaining_turns: remainingTurns,
          footer: "Note: Deen Companion is an educational tool. For formal legal rulings (Fatawa) on personal situations, please consult a qualified Islamic scholar.",
        }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 4. RAG retrieval: embed the query and pull trusted corpus matches (best-effort)
    let ragContext = "";
    try {
      const embResp = await fetch("https://api.openai.com/v1/embeddings", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${openAiKey}`,
        },
        body: JSON.stringify({ model: "text-embedding-3-small", input: query, dimensions: 768 }),
      });
      const embJson = await embResp.json();
      const embedding: number[] | undefined = embJson.data?.[0]?.embedding;
      if (embedding && embedding.length === 768) {
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

    // 5. OpenAI / Gemini Call with Grounded Prompt
    const systemPrompt = `You are Deen Companion, an authentic Islamic AI assistant for Muslim Ultra.
Trusted corpus context (prefer these sources; cite their references verbatim when used):
${ragContext || "(no corpus matches above threshold)"}
Strict Grounding Rules:
1. Every factual Islamic claim MUST carry an inline citation in brackets, e.g. [Quran 2:152] or [Sahih al-Bukhari 54].
2. ZERO fabrication: Never invent or attribute unverified hadiths. If a detail is not authentic or verified in classical sources, decline politely.
3. Fiqh & Ikhtilaf: Whenever there is recognized scholarly disagreement between Madhabs (Hanafi, Shafi'i, Maliki, Hanbali), label the views clearly (e.g. [Hanafi: ...], [Shafi'i/Hanbali: ...]).
4. Conciseness: Provide a clear, short answer under 120 words by default.
5. Mandatory Disclaimer: If the question touches upon religious law, purity, or rulings, append this footer at the end:
"Note: Deen Companion is an educational tool. For formal legal rulings (Fatawa) on personal situations, please consult a qualified Islamic scholar."
Language requested: ${language}.`;

    const apiResponse = await fetch("https://api.openai.com/v1/chat/completions", {
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
        max_tokens: explainMore ? 450 : 220,
      }),
    });

    const completion = await apiResponse.json();
    const generated = completion.choices?.[0]?.message?.content;
    const answerText = generated ?? "Unable to generate answer.";

    // Parse citations from bracket tags [Quran ...], [Sahih ...]
    const citationMatches = (generated ?? "").match(/\[(Quran|Sahih|Sunan|Hisn|Musnad)[^\]]+\]/g) || [];
    const citations = Array.from(new Set(citationMatches.map((c: string) => c.replace(/\[|\]/g, ""))));

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
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
