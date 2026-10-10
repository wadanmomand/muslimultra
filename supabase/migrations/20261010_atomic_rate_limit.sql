-- ==============================================================================
-- Muslim Ultra - Atomic Rate Limiting Function (Security S4)
-- Migration: 20261010_atomic_rate_limit.sql
-- ==============================================================================

-- 1. Ensure user_rate_limits table exists with primary key on (user_id, usage_date)
create table if not exists public.user_rate_limits (
  user_id text not null,
  usage_date date not null default current_date,
  message_count integer not null default 1,
  primary key (user_id, usage_date)
);

-- 2. Atomic check and increment function (prevents parallel request race conditions)
create or replace function public.check_and_increment_rate_limit(
  p_user_id text,
  p_cap int default 20
)
returns int
language plpgsql
security definer
as $$
declare
  v_count int;
begin
  insert into public.user_rate_limits (user_id, usage_date, message_count)
  values (p_user_id, current_date, 1)
  on conflict (user_id, usage_date)
  do update set message_count = user_rate_limits.message_count + 1
  returning message_count into v_count;

  return v_count;
end;
$$;
