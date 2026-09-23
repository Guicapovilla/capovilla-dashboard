-- ============================================================
-- Libera edição das metas (valor_alvo) direto pelo metas.html
--
-- A tabela `metas` já existe (criada pela pipeline analytics-capovilla).
-- Este script só garante que o anon key do dashboard pode ler e
-- escrever nela — mesmo modelo de acesso das outras tabelas do
-- dashboard (conteudos, ideias, tarefas).
--
-- Como usar: cole o CONTEÚDO deste arquivo (não o nome dele!) no
-- SQL Editor do Supabase → Run. Rodar de novo é seguro.
-- ============================================================

alter table public.metas enable row level security;

drop policy if exists "metas_anon_all" on public.metas;
create policy "metas_anon_all" on public.metas
  for all using (true) with check (true);

notify pgrst, 'reload schema';
