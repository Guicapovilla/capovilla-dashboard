-- ============================================================
-- Comissão de afiliado (YouTube Shopping) — lançamento manual
-- mensal a partir do relatório de receita do YouTube Studio
-- (Studio → Ganhos → Programa de afiliados).
--
-- A YouTube Analytics API não expõe métricas de comissão de
-- afiliado/shopping (só estimatedRevenue, estimatedAdRevenue etc.,
-- que é o que já alimenta a "Receita" automática das metas) — por
-- isso esses dois valores (total e estornado) precisam ser digitados.
--
-- Como usar: cole o CONTEÚDO deste arquivo (não o nome dele!) no
-- SQL Editor do Supabase → Run. Rodar de novo é seguro.
-- ============================================================

create table if not exists public.comissao_afiliado (
  mes text primary key,                          -- 'YYYY-MM'
  comissao_total numeric not null default 0,
  comissao_estornada numeric not null default 0,
  atualizado_em timestamptz not null default now()
);

alter table public.comissao_afiliado enable row level security;

drop policy if exists "comissao_afiliado_anon_all" on public.comissao_afiliado;
create policy "comissao_afiliado_anon_all" on public.comissao_afiliado
  for all using (true) with check (true);

notify pgrst, 'reload schema';
