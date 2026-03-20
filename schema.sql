-- ══════════════════════════════════════════════════════════
--  BURPEE CHALLENGE – Supabase Schema
--  Einmal im Supabase SQL Editor ausführen
-- ══════════════════════════════════════════════════════════

-- 1) Teilnehmer / Rangliste
create table if not exists profiles (
  name           text primary key,
  completed_days int  not null default 0,
  updated_at     timestamptz   default now()
);

-- 2) Abgeschlossene Tage pro Person
create table if not exists day_completions (
  name         text not null references profiles(name) on delete cascade,
  day          int  not null check (day between 1 and 30),
  completed_at timestamptz default now(),
  primary key (name, day)
);

-- 3) Motivation Wall
create table if not exists wall_posts (
  id         bigserial   primary key,
  name       text        not null references profiles(name) on delete cascade,
  message    text        not null,
  day        int         not null default 1,
  reactions  jsonb       not null default '{}',
  created_at timestamptz default now()
);

-- ── Row Level Security (öffentlich lesbar & schreibbar) ──────────
alter table profiles       enable row level security;
alter table day_completions enable row level security;
alter table wall_posts      enable row level security;

-- profiles
create policy "public read profiles"    on profiles for select using (true);
create policy "public insert profiles"  on profiles for insert with check (true);
create policy "public update profiles"  on profiles for update using (true);

-- day_completions
create policy "public read completions"   on day_completions for select using (true);
create policy "public insert completions" on day_completions for insert with check (true);
create policy "public delete completions" on day_completions for delete using (true);

-- wall_posts
create policy "public read wall"    on wall_posts for select using (true);
create policy "public insert wall"  on wall_posts for insert with check (true);
create policy "public update wall"  on wall_posts for update using (true);

-- ── Realtime aktivieren ──────────────────────────────────────────
alter publication supabase_realtime add table profiles;
alter publication supabase_realtime add table wall_posts;
