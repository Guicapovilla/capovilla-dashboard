-- ============================================================
-- Setup da tabela `tarefas` — Central de Conteúdo Capovilla
--
-- Como usar: cole o CONTEÚDO deste arquivo (não o nome dele!) no
-- SQL Editor do Supabase → Run. Rodar de novo é seguro.
-- ============================================================

create table if not exists public.tarefas (
  id uuid primary key default gen_random_uuid(),
  titulo text not null default '',
  descricao text default '',
  status text not null default 'backlog', -- backlog | fazer | fazendo | concluido
  conteudo_id uuid references public.conteudos(id) on delete set null, -- vínculo opcional a um vídeo, só organizacional
  prazo date,
  ordem double precision not null default 0, -- posição dentro da coluna (drag & drop)
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists tarefas_status_idx on public.tarefas(status);
create index if not exists tarefas_conteudo_idx on public.tarefas(conteudo_id);
create index if not exists tarefas_prazo_idx on public.tarefas(prazo);

-- Mesmo modelo de acesso das outras tabelas do dashboard.
alter table public.tarefas enable row level security;

drop policy if exists "tarefas_anon_all" on public.tarefas;
create policy "tarefas_anon_all" on public.tarefas
  for all using (true) with check (true);

notify pgrst, 'reload schema';
