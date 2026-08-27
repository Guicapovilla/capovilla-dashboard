-- ============================================================
-- Setup do Radar de Concorrentes — Central de Conteúdo Capovilla
--
-- Como usar: cole o CONTEÚDO deste arquivo (não o nome dele!) no
-- SQL Editor do Supabase → Run. Rodar de novo é seguro.
-- ============================================================

-- Canais que você cadastra pelo dashboard.
-- Você só informa a URL/@handle; o robô do GitHub Actions resolve
-- channel_id, nome e avatar na primeira rodada.
create table if not exists public.radar_canais (
  id uuid primary key default gen_random_uuid(),
  entrada text not null,          -- o que você colou: @handle, URL do canal, etc.
  channel_id text,                -- resolvido pelo robô (UC...)
  nome text,                      -- resolvido pelo robô
  avatar text,                    -- resolvido pelo robô
  uploads_playlist text,          -- playlist de uploads, resolvida pelo robô
  ativo boolean not null default true,
  erro text,                      -- se o robô não conseguiu resolver, explica aqui
  ultima_checagem timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Vídeos encontrados nos canais acompanhados.
create table if not exists public.radar_videos (
  video_id text primary key,      -- id do vídeo no YouTube
  canal_id uuid references public.radar_canais(id) on delete cascade,
  channel_id text,
  canal_nome text,
  titulo text not null default '',
  descricao text default '',
  thumb text default '',
  url text default '',
  publicado_em timestamptz,
  views bigint default 0,
  likes bigint default 0,
  comentarios bigint default 0,
  duracao text default '',        -- ISO 8601 (PT12M34S)
  is_short boolean default false,
  visto boolean not null default false,   -- você já revisou esse vídeo?
  descartado boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists radar_videos_publicado_idx on public.radar_videos(publicado_em desc);
create index if not exists radar_videos_canal_idx on public.radar_videos(canal_id);

-- Migrações seguras pra quem já tinha versão anterior das tabelas
alter table public.radar_canais add column if not exists erro text;
alter table public.radar_canais add column if not exists uploads_playlist text;
alter table public.radar_videos add column if not exists is_short boolean default false;

-- Mesmo modelo de acesso das outras tabelas do dashboard.
alter table public.radar_canais enable row level security;
alter table public.radar_videos enable row level security;

drop policy if exists "radar_canais_anon_all" on public.radar_canais;
create policy "radar_canais_anon_all" on public.radar_canais
  for all using (true) with check (true);

drop policy if exists "radar_videos_anon_all" on public.radar_videos;
create policy "radar_videos_anon_all" on public.radar_videos
  for all using (true) with check (true);
