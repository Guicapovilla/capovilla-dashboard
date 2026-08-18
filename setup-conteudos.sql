-- ============================================================
-- Setup da tabela `conteudos` — Central de Conteúdo Capovilla
--
-- Como usar: cole este arquivo inteiro no SQL Editor do Supabase
-- (https://supabase.com/dashboard → seu projeto → SQL Editor → Run)
-- e recarregue o dashboard. O aviso amarelo some e os dados
-- passam a sincronizar entre dispositivos.
-- ============================================================

create table if not exists public.conteudos (
  id uuid primary key default gen_random_uuid(),
  titulo text not null default '',
  descricao text default '',
  script text default '',
  notas text default '',
  thumb text default '',                -- URL ou data-URI (jpeg redimensionado pelo app)
  status text not null default 'ideia', -- ideia | roteiro | gravacao | edicao | publicado
  tipo text not null default 'longo',   -- longo | short
  data_gravacao date,
  data_publicacao date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Mesmo modelo de acesso das tabelas existentes do dashboard:
-- chave publishable (anon) pode ler e escrever.
alter table public.conteudos enable row level security;

drop policy if exists "conteudos_anon_all" on public.conteudos;
create policy "conteudos_anon_all" on public.conteudos
  for all
  using (true)
  with check (true);
