-- ============================================================
-- Comissão de afiliado (YouTube Shopping) — lançamento manual
-- mensal a partir do relatório de receita do YouTube Studio
-- (a YouTube Analytics API não expõe esse dado, só a UI do Studio).
--
-- Como usar: cole o CONTEÚDO deste arquivo (não o nome dele!) no
-- SQL Editor do Supabase → Run. Rodar de novo é seguro.
-- ============================================================

create table if not exists public.comissao_afiliado (
  mes text primary key,                          -- 'YYYY-MM'
  comissao_estimada numeric not null default 0,
  comissao_extornada numeric not null default 0,
  atualizado_em timestamptz not null default now()
);

alter table public.comissao_afiliado enable row level security;

drop policy if exists "comissao_afiliado_anon_all" on public.comissao_afiliado;
create policy "comissao_afiliado_anon_all" on public.comissao_afiliado
  for all using (true) with check (true);

notify pgrst, 'reload schema';
