-- ==============================================================================
-- Muslim Ultra - Quran Academy & Admin Panel Schema (Mission W2)
-- Migration: 20261007_quran_academy_and_admin_schema.sql
-- ==============================================================================

-- 1. Programs Table (Quran & Islamic Studies Offerings)
create table if not exists public.programs (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  slug text unique not null,
  description text not null,
  monthly_fee text not null,
  duration text default '30-45 mins / session',
  schedule_flexibility text default 'Flexible 1-on-1 Timing',
  is_active boolean default true,
  display_order integer default 0,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 2. Teachers Table (Certified Instructors)
create table if not exists public.teachers (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  qualification text not null,
  experience text not null,
  photo_url text,
  bio text,
  is_active boolean default true,
  display_order integer default 0,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 3. Trial Bookings Table (Prospective Students Booking Free Trial)
create table if not exists public.trial_bookings (
  id uuid primary key default gen_random_uuid(),
  student_name text not null,
  contact_info text not null, -- Phone / WhatsApp / Email
  program_id uuid references public.programs(id) on delete set null,
  program_title text,
  preferred_time text,
  status text default 'new', -- 'new', 'contacted', 'enrolled', 'cancelled'
  notes text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 4. Contact Messages Table (Support Page Inquiries)
create table if not exists public.contact_messages (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  email text not null,
  message text not null,
  is_read boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 5. Announcements Table (Top Banner on Website)
create table if not exists public.announcements (
  id uuid primary key default gen_random_uuid(),
  message text not null,
  link_url text,
  is_active boolean default true,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 6. FAQs Table
create table if not exists public.faqs (
  id uuid primary key default gen_random_uuid(),
  question text not null,
  answer text not null,
  category text default 'general', -- 'academy', 'app', 'general'
  is_active boolean default true,
  display_order integer default 0,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- ==============================================================================
-- Row Level Security (RLS) Policies
-- Security Requirement C4:
-- Public (anon):
--   - SELECT active rows from programs, teachers, announcements, faqs
--   - INSERT only into trial_bookings, contact_messages
--   - NO SELECT / UPDATE / DELETE on trial_bookings or contact_messages
-- Authenticated (Admin):
--   - FULL CRUD on all tables
-- ==============================================================================

alter table public.programs enable row level security;
alter table public.teachers enable row level security;
alter table public.trial_bookings enable row level security;
alter table public.contact_messages enable row level security;
alter table public.announcements enable row level security;
alter table public.faqs enable row level security;

-- 1. Programs Policies
create policy "Public can view active programs"
  on public.programs for select
  to anon, authenticated
  using (is_active = true or auth.role() = 'authenticated');

create policy "Admins have full access to programs"
  on public.programs for all
  to authenticated
  using (true)
  with check (true);

-- 2. Teachers Policies
create policy "Public can view active teachers"
  on public.teachers for select
  to anon, authenticated
  using (is_active = true or auth.role() = 'authenticated');

create policy "Admins have full access to teachers"
  on public.teachers for all
  to authenticated
  using (true)
  with check (true);

-- 3. Trial Bookings Policies
create policy "Public can insert trial bookings"
  on public.trial_bookings for insert
  to anon, authenticated
  with check (true);

create policy "Only authenticated admins can view and manage trial bookings"
  on public.trial_bookings for all
  to authenticated
  using (true)
  with check (true);

-- 4. Contact Messages Policies
create policy "Public can insert contact messages"
  on public.contact_messages for insert
  to anon, authenticated
  with check (true);

create policy "Only authenticated admins can view and manage contact messages"
  on public.contact_messages for all
  to authenticated
  using (true)
  with check (true);

-- 5. Announcements Policies
create policy "Public can view active announcements"
  on public.announcements for select
  to anon, authenticated
  using (is_active = true or auth.role() = 'authenticated');

create policy "Admins have full access to announcements"
  on public.announcements for all
  to authenticated
  using (true)
  with check (true);

-- 6. FAQs Policies
create policy "Public can view active faqs"
  on public.faqs for select
  to anon, authenticated
  using (is_active = true or auth.role() = 'authenticated');

create policy "Admins have full access to faqs"
  on public.faqs for all
  to authenticated
  using (true)
  with check (true);

-- ==============================================================================
-- Initial Seed Data
-- ==============================================================================

insert into public.programs (title, slug, description, monthly_fee, duration, display_order)
values
  (
    'Noorani Qaida & Basic Nazra',
    'noorani-qaida-nazra',
    'Ideal for beginners and children. Learn Arabic alphabet phonetics, correct articulation (Makharij), and smooth Quranic reading from scratch.',
    '$35 / month',
    '30 mins / 3 days a week',
    1
  ),
  (
    'Hifz-ul-Quran (Memorization)',
    'hifz-ul-quran',
    'Structured memorization program guided by certified Huffaz with daily revision (Sabaq, Sabaqi, Manzil) and personalized progress tracking.',
    '$65 / month',
    '45 mins / 5 days a week',
    2
  ),
  (
    'Tajweed & Tarteel Rules',
    'tajweed-tarteel',
    'Master the rules of Noon Sakinah, Meem Sakinah, Madd, Ghunnah, and Waqf to recite the Holy Quran with authentic melody and precision.',
    '$45 / month',
    '30 mins / 4 days a week',
    3
  ),
  (
    'Quran Translation & Tafseer',
    'translation-tafseer',
    'Word-by-word Arabic grammatical breakdown, thematic study of Surahs, and scholarly classical Tafseer explanations.',
    '$50 / month',
    '40 mins / 3 days a week',
    4
  ),
  (
    'Kids Islamic Studies & Duas',
    'kids-islamic-studies',
    'Engaging curriculum covering daily Sunnah duas from Hisn al-Muslim, basic Fiqh of Taharah/Salah, Seerah of the Prophet ﷺ, and Islamic manners.',
    '$40 / month',
    '30 mins / 3 days a week',
    5
  )
on conflict (slug) do nothing;

insert into public.teachers (name, qualification, experience, photo_url, bio, display_order)
values
  (
    'Qari Muhammad Abdullah',
    'Ijazah in Hafs ''an ''Asim, Al-Azhar Certified',
    '8+ Years Online Teaching',
    'https://images.unsplash.com/photo-1544717305-2782549b5136?w=200&h=200&fit=crop&crop=faces',
    'Specializes in Tajweed rectification, beginner Qaida phonetics, and youth engagement.',
    1
  ),
  (
    'Ustadh Hafiz Bilal Ahmed',
    'Hafiz-ul-Quran & Wifaq-ul-Madaris Al-Almiyah Graduate',
    '10+ Years Hifz Mentorship',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop&crop=faces',
    'Dedicated Hifz mentor with over 40+ students who completed full Quran memorization under his guidance.',
    2
  ),
  (
    'Ustadha Fatima Zahra',
    'MA Islamic Studies & Qirat Specialization',
    '6+ Years Teaching Female & Children',
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&h=200&fit=crop&crop=faces',
    'Expert in interactive kids learning, Tajweed for sisters, and daily Sunnah supplications.',
    3
  )
on conflict do nothing;

insert into public.announcements (message, link_url, is_active)
values
  (
    '🌟 Free 3-Day Trial Classes now open for online Quran & Tajweed sessions! Book your slot today.',
    'academy.html#trial-booking',
    true
  )
on conflict do nothing;
