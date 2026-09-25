# Capovilla Dashboard

Sistema enxuto em três páginas HTML estáticas (sem build, sem backend próprio — só Supabase). Cada uma navega para as outras pela barra do topo.

- [`conteudo.html`](conteudo.html) — **Conteúdo**
- [`tarefas.html`](tarefas.html) — **Tarefas**
- [`metas.html`](metas.html) — **Metas**

## Conteúdo

Gestão de conteúdo do canal: calendário, card de conteúdo, ideias, biblioteca e radar de concorrentes.

- **Calendário** — mostra em cada dia o que **gravar** (🎬 âmbar) e o que **publicar** (🚀 azul). Publicado fica verde, atrasado fica vermelho. Clicar num dia cria um conteúdo novo já com a data de publicação preenchida.
- **Card de conteúdo** — abre num painel lateral com tudo em um lugar: thumbnail (cole com Ctrl+V, arraste ou clique), título, etapa (Ideia → Roteiro → Gravação → Edição → Publicado), formato (longo/short), datas de gravação e publicação, descrição, script e notas. Salva sozinho enquanto você digita, e os botões **copiar** levam descrição/script direto pro YouTube Studio.
- **Listas "A gravar" / "A publicar"** — as próximas datas, em ordem, com aviso de atraso.
- **Ideias** — rascunhos sem data nem compromisso, organizados em pastas configuráveis (nome + cor). Cada ideia tem um botão **→** que a transforma em conteúdo com 1 clique.
- **Biblioteca** — todos os conteúdos com busca e abas: **Geral** (pipeline em produção, com sub-abas por etapa) e **💡 Ideia**.
- **Radar de concorrentes** — vídeos novos dos canais que você acompanha, coletados automaticamente (ver seção abaixo).
- **Backup / Importar** — exporta e importa tudo em JSON.

### Onde os dados ficam

O app tenta usar as tabelas `conteudos`, `ideia_pastas` e `ideias` no Supabase. Se alguma ainda não existir, ele funciona normalmente salvando no navegador (localStorage) e mostra um aviso.

**Para sincronizar entre dispositivos:** cole o conteúdo de [`setup-conteudos.sql`](setup-conteudos.sql) e [`setup-ideias.sql`](setup-ideias.sql) no SQL Editor do Supabase, rode os dois, e recarregue a página.

## Tarefas

Quadro kanban simples ([`tarefas.html`](tarefas.html)). Usa a tabela `tarefas` no Supabase (rode [`setup-tarefas.sql`](setup-tarefas.sql) uma vez) ou cai em localStorage se ela não existir.

## Metas

[`metas.html`](metas.html) lê direto do Supabase e mostra:

- **Metas do trimestre** e **metas do ano** — receita, inscritos novos e vídeos longos publicados, com barra de progresso e ritmo (no ritmo / levemente atrás / muito atrás) comparado ao tempo já decorrido do período.
- **Timeline de faturamento** — receita diária dos últimos 28 dias.
- **Últimos 28 dias** — views, receita e média por dia.
- **Visão geral do canal** — inscritos, views totais e vídeos publicados.
- **Top vídeos por receita** — top 5 da última coleta.
- **Comissão de afiliado (YouTube Shopping)** — comissão total e estornada por mês, lançadas manualmente (a YouTube Analytics API não tem métrica pra isso — só `estimatedRevenue`, que é o que já vira a "Receita" automática). O líquido calculado é comparado com a receita automática do mesmo mês pra conferência.

Os números vêm das tabelas `metas`, `channel_metricas`, `videos` e `videos_metricas`, alimentadas pela coleta diária do repositório [`analytics-capovilla`](https://github.com/Guicapovilla/analytics-capovilla) (GitHub Actions, roda todo dia às 10h UTC). Receita e vídeos longos publicados são recalculados direto no Supabase a cada carregamento da página (sempre atual); inscritos novos vêm do valor já calculado pelo coletor via YouTube Analytics API.

**Editar os alvos:** botão "Editar" ao lado de "Metas do trimestre" / "Metas do ano" abre um formulário pra ajustar receita, inscritos e vídeos-alvo — salva direto no Supabase, sem mexer em nada além do alvo (o realizado continua vindo só da coleta automática). Sem meta cadastrada ainda pro período, aparece um botão "Cadastrar metas" no lugar. Isso escreve na tabela com a mesma anon key já usada pra ler — rode [`setup-metas.sql`](setup-metas.sql) uma vez no SQL Editor do Supabase pra liberar a escrita.

**Lançar comissão de afiliado:** botão "Lançar mês" na seção "Comissão de afiliado" abre um formulário com mês, comissão total e comissão estornada (tirados de Studio → Ganhos → Programa de afiliados). Rode [`setup-comissao-afiliado.sql`](setup-comissao-afiliado.sql) uma vez no SQL Editor do Supabase pra criar a tabela e liberar a escrita.

## Radar de concorrentes

Acompanha os canais que você cadastrar e lista os vídeos novos deles pra curadoria — com botão pra virar ideia sua em 1 clique, marcar como visto ou descartar. Faz parte de [`conteudo.html`](conteudo.html).

Você cadastra os canais **pelo próprio dashboard** (engrenagem ao lado do título "Radar de concorrentes"): cola o `@handle` ou o link, e o robô resolve nome, avatar e ID sozinho na coleta seguinte. A coleta roda no GitHub Actions 3x por dia ([`.github/workflows/radar-concorrentes.yml`](.github/workflows/radar-concorrentes.yml) → [`scripts/radar.mjs`](scripts/radar.mjs)) — nada roda no navegador, e a chave da API nunca vai pro front.

### Como ligar (uma vez só)

1. **Tabelas:** rode [`setup-radar.sql`](setup-radar.sql) no SQL Editor do Supabase.
2. **Chave da YouTube Data API:** em [console.cloud.google.com](https://console.cloud.google.com) → crie/selecione um projeto → *APIs e serviços* → ative a **YouTube Data API v3** → *Credenciais* → **Criar credenciais → Chave de API**. É gratuito; a cota padrão (10.000 unidades/dia) sobra — cada coleta gasta ~3 unidades por canal.
3. **Secrets no GitHub:** no repositório → *Settings* → *Secrets and variables* → *Actions* → **New repository secret**, crie três:
   - `YOUTUBE_API_KEY` — a chave do passo 2
   - `SUPABASE_URL` — `https://ryspohcflrxjwwghvvqc.supabase.co`
   - `SUPABASE_KEY` — a mesma chave publishable já usada no dashboard
4. **Primeira coleta:** aba *Actions* → *Radar de concorrentes* → **Run workflow** (ou espere o próximo horário).

Se um canal não for encontrado, o erro aparece no próprio dashboard, ao lado do canal, sem travar os outros.
