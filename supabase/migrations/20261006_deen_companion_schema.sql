-- ==============================================================================
-- Muslim Ultra - Deen Companion AI Gateway & RAG Schema (Spec §3 M3, §5, §6)
-- ==============================================================================

-- 1. Enable pgvector extension for semantic similarity search
create extension if not exists vector;

-- 2. Trusted Corpus Documents Table (Starter: Juz 30 + 40 Duas + 100 FAQs)
create table if not exists public.corpus_documents (
  id uuid primary key default gen_random_uuid(),
  collection text not null, -- 'quran_juz30', 'duas_hisnul_muslim', 'faqs_corpus', 'hadith_core'
  reference text not null,  -- e.g. 'Quran 112:1', 'Sahih al-Bukhari 54', 'Hisn al-Muslim 12'
  content_arabic text,
  content_english text not null,
  content_urdu text,
  embedding vector(768),    -- Compatible with standard 768-dim embeddings (e.g. text-embedding-3-small)
  metadata jsonb default '{}'::jsonb,
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- Index for fast vector similarity search using IVFFlat or HNSW cosine distance
create index if not exists corpus_documents_embedding_idx 
  on public.corpus_documents 
  using hnsw (embedding vector_cosine_ops);

-- 3. Response Cache Table (Targeting 30%+ cache hits on common questions)
create table if not exists public.ai_response_cache (
  query_hash text primary key, -- SHA-256 of lowercase normalized prompt
  query_text text not null,
  language text not null default 'en',
  response_text text not null,
  citations jsonb not null default '[]'::jsonb,
  is_short_answer boolean default true,
  hit_count integer default 1,
  created_at timestamp with time zone default timezone('utc'::text, now()),
  expires_at timestamp with time zone default (timezone('utc'::text, now()) + interval '14 days')
);

create index if not exists ai_response_cache_expires_idx on public.ai_response_cache (expires_at);

-- 4. User Rate Limits Table (20 messages / day / user free cap)
create table if not exists public.user_rate_limits (
  user_id text not null,
  usage_date date not null default current_date,
  message_count integer not null default 1,
  primary key (user_id, usage_date)
);

-- 5. Semantic Vector Match Function
create or replace function public.match_corpus_documents (
  query_embedding vector(768),
  match_threshold float default 0.65,
  match_count int default 4,
  filter_collection text default null
)
returns table (
  id uuid,
  collection text,
  reference text,
  content_arabic text,
  content_english text,
  content_urdu text,
  similarity float
)
language plpgsql
as $$
begin
  return query
  select
    cd.id,
    cd.collection,
    cd.reference,
    cd.content_arabic,
    cd.content_english,
    cd.content_urdu,
    1 - (cd.embedding <=> query_embedding) as similarity
  from public.corpus_documents cd
  where (filter_collection is null or cd.collection = filter_collection)
    and 1 - (cd.embedding <=> query_embedding) > match_threshold
  order by cd.embedding <=> query_embedding
  limit match_count;
end;
$$;

-- 6. Increment Cache Hit RPC Function
create or replace function public.increment_cache_hit(q_hash text)
returns void 
language plpgsql 
security definer 
as $$
begin
  update public.ai_response_cache 
  set hit_count = hit_count + 1 
  where query_hash = q_hash;
end;
$$;
