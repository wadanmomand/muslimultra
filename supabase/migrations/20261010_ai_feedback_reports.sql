-- ==============================================================================
-- Muslim Ultra - AI Feedback Reports Schema (v2.7 Trust Upgrades)
-- Migration: 20261010_ai_feedback_reports.sql
-- Note: Run this SQL in the Supabase Dashboard SQL Editor.
-- ==============================================================================

create table if not exists public.ai_feedback_reports (
  id uuid primary key default gen_random_uuid(),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  query_hash text,
  feedback_type text not null, -- 'helpful', 'wrong_citation', 'religious_error'
  comment text,
  app_version text default 'v2.7'
);

-- Enable Row Level Security
alter table public.ai_feedback_reports enable row level security;

-- RLS Policy: Anonymous and Authenticated users may INSERT only (no select, update, delete)
drop policy if exists "Anon and Authenticated can insert feedback reports" on public.ai_feedback_reports;
create policy "Anon and Authenticated can insert feedback reports"
  on public.ai_feedback_reports for insert
  to anon, authenticated
  with check (true);
