-- Planning Excess : schéma Supabase
-- Projet : App sport (ref mrqxkncxksncidkpwlib), schéma public.
-- Appliqué le 21 novembre 2026 (migration « excess_planning_tables »).

create table public.excess_posts (
  id text primary key default gen_random_uuid()::text,
  owner uuid not null default auth.uid() references auth.users(id) on delete cascade,
  title text not null,
  type text not null default 'autre' check (type in ('souvenir','enchainement','classement','continuum','autre')),
  status text not null default 'pret' check (status in ('idee','pret','programme','publie')),
  date date,
  time text,                 -- 'HH:MM', heure belge
  duration integer,          -- secondes
  views integer,             -- vues TikTok (source Metricool)
  tiktok text default '',
  hashtags text default '',
  yt_title text default '',
  yt_desc text default '',
  insta text default '',
  updated_at timestamptz not null default now()
);
create index excess_posts_owner_idx on public.excess_posts(owner);

create table public.excess_meta (
  owner uuid primary key default auth.uid() references auth.users(id) on delete cascade,
  last_sync timestamptz      -- dernière mise à jour des vues depuis Metricool
);

-- Sécurité : chaque compte ne voit et ne modifie que ses propres lignes.
alter table public.excess_posts enable row level security;
alter table public.excess_meta enable row level security;
create policy "excess_posts own rows" on public.excess_posts for all to authenticated
  using (owner = (select auth.uid())) with check (owner = (select auth.uid()));
create policy "excess_meta own row" on public.excess_meta for all to authenticated
  using (owner = (select auth.uid())) with check (owner = (select auth.uid()));
revoke all on public.excess_posts, public.excess_meta from anon;
grant select, insert, update, delete on public.excess_posts, public.excess_meta to authenticated;

-- updated_at automatique
create or replace function public.excess_touch() returns trigger language plpgsql set search_path = '' as $$
begin new.updated_at = now(); return new; end $$;
create trigger excess_posts_touch before update on public.excess_posts
  for each row execute function public.excess_touch();

-- Mise à jour en direct de l'app
alter publication supabase_realtime add table public.excess_posts;
