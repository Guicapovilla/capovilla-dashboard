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
  status text not null default 'ideia', -- ideia | roteiro | gravacao | edicao | agendado | publicado
  tipo text not null default 'longo',   -- longo | short
  categoria text,                       -- viral | monetizacao | null (só usado quando status = ideia)
  brolls jsonb not null default '[]'::jsonb, -- [{id, texto, feito}] — checklist de b-rolls
  data_gravacao date,
  data_publicacao date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Migrações pra quem já tinha a tabela antes desses campos existirem
-- (rodar este arquivo de novo é seguro, não duplica nada).
alter table public.conteudos add column if not exists categoria text;
alter table public.conteudos add column if not exists brolls jsonb not null default '[]'::jsonb;

-- Mesmo modelo de acesso das tabelas existentes do dashboard:
-- chave publishable (anon) pode ler e escrever.
alter table public.conteudos enable row level security;

drop policy if exists "conteudos_anon_all" on public.conteudos;
create policy "conteudos_anon_all" on public.conteudos
  for all
  using (true)
  with check (true);
