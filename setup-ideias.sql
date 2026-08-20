-- ============================================================
-- Setup das tabelas de Ideias — Banco de Ideias Capovilla
--
-- Como usar: cole este arquivo inteiro no SQL Editor do Supabase
-- (https://supabase.com/dashboard → seu projeto → SQL Editor → Run)
-- e recarregue ideias.html. O aviso amarelo some e os dados
-- passam a sincronizar entre dispositivos.
-- ============================================================

create table if not exists public.ideia_pastas (
  id uuid primary key default gen_random_uuid(),
  nome text not null,
  cor text not null default 'amber', -- amber | violet | info | success | teal | danger | muted
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.ideias (
  id uuid primary key default gen_random_uuid(),
  pasta_id uuid references public.ideia_pastas(id) on delete set null,
  titulo text not null,
  nota text default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists ideias_pasta_id_idx on public.ideias(pasta_id);

-- Mesmo modelo de acesso das outras tabelas do dashboard:
-- chave publishable (anon) pode ler e escrever.
alter table public.ideia_pastas enable row level security;
alter table public.ideias enable row level security;

drop policy if exists "ideia_pastas_anon_all" on public.ideia_pastas;
create policy "ideia_pastas_anon_all" on public.ideia_pastas
  for all using (true) with check (true);

drop policy if exists "ideias_anon_all" on public.ideias;
create policy "ideias_anon_all" on public.ideias
  for all using (true) with check (true);
