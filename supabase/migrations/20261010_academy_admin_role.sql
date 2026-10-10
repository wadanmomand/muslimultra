-- ==============================================================================
-- Muslim Ultra - Academy Admin Role & RLS Protection (Security S3)
-- Migration: 20261010_academy_admin_role.sql
-- ==============================================================================

-- 1. Create admin_users table for strictly authorized administrators
create table if not exists public.admin_users (
  user_id uuid primary key,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS on admin_users (no public access policies)
alter table public.admin_users enable row level security;

-- Seed known admin user if already present in auth.users
insert into public.admin_users (user_id)
select id from auth.users where email = 'usmanbjr14@gmail.com'
on conflict (user_id) do nothing;

-- 2. Update Programs Policies
drop policy if exists "Public can view active programs" on public.programs;
create policy "Public can view active programs"
  on public.programs for select
  to anon, authenticated
  using (is_active = true or exists (select 1 from public.admin_users where user_id = auth.uid()));

drop policy if exists "Admins have full access to programs" on public.programs;
create policy "Admins have full access to programs"
  on public.programs for all
  to authenticated
  using (exists (select 1 from public.admin_users where user_id = auth.uid()))
  with check (exists (select 1 from public.admin_users where user_id = auth.uid()));

-- 3. Update Teachers Policies
drop policy if exists "Public can view active teachers" on public.teachers;
create policy "Public can view active teachers"
  on public.teachers for select
  to anon, authenticated
  using (is_active = true or exists (select 1 from public.admin_users where user_id = auth.uid()));

drop policy if exists "Admins have full access to teachers" on public.teachers;
create policy "Admins have full access to teachers"
  on public.teachers for all
  to authenticated
  using (exists (select 1 from public.admin_users where user_id = auth.uid()))
  with check (exists (select 1 from public.admin_users where user_id = auth.uid()));

-- 4. Update Trial Bookings Policies
drop policy if exists "Only authenticated admins can view and manage trial bookings" on public.trial_bookings;
create policy "Only authenticated admins can view and manage trial bookings"
  on public.trial_bookings for all
  to authenticated
  using (exists (select 1 from public.admin_users where user_id = auth.uid()))
  with check (exists (select 1 from public.admin_users where user_id = auth.uid()));

-- 5. Update Contact Messages Policies
drop policy if exists "Only authenticated admins can view and manage contact messages" on public.contact_messages;
create policy "Only authenticated admins can view and manage contact messages"
  on public.contact_messages for all
  to authenticated
  using (exists (select 1 from public.admin_users where user_id = auth.uid()))
  with check (exists (select 1 from public.admin_users where user_id = auth.uid()));

-- 6. Update Announcements Policies
drop policy if exists "Public can view active announcements" on public.announcements;
create policy "Public can view active announcements"
  on public.announcements for select
  to anon, authenticated
  using (is_active = true or exists (select 1 from public.admin_users where user_id = auth.uid()));

drop policy if exists "Admins have full access to announcements" on public.announcements;
create policy "Admins have full access to announcements"
  on public.announcements for all
  to authenticated
  using (exists (select 1 from public.admin_users where user_id = auth.uid()))
  with check (exists (select 1 from public.admin_users where user_id = auth.uid()));

-- 7. Update FAQs Policies
drop policy if exists "Public can view active faqs" on public.faqs;
create policy "Public can view active faqs"
  on public.faqs for select
  to anon, authenticated
  using (is_active = true or exists (select 1 from public.admin_users where user_id = auth.uid()));

drop policy if exists "Admins have full access to faqs" on public.faqs;
create policy "Admins have full access to faqs"
  on public.faqs for all
  to authenticated
  using (exists (select 1 from public.admin_users where user_id = auth.uid()))
  with check (exists (select 1 from public.admin_users where user_id = auth.uid()));
