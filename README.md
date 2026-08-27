# Capovilla Dashboard

## Central de Conteúdo (novo)

Sistema simples de gestão de conteúdo do canal, em um único arquivo: [`conteudo.html`](conteudo.html). Fica ao lado do dashboard existente, sem substituir nada — há um link "Conteúdo" na barra lateral das páginas antigas, e um botão "Dashboard" para voltar.

### O que tem

- **Calendário** — mostra em cada dia o que **gravar** (🎬 âmbar) e o que **publicar** (🚀 azul). Publicado fica verde, atrasado fica vermelho. Clicar num dia cria um conteúdo novo já com a data de publicação preenchida.
- **Card de conteúdo** — abre num painel lateral com tudo em um lugar: thumbnail (cole com Ctrl+V, arraste ou clique), título, etapa (Ideia → Roteiro → Gravação → Edição → Publicado), formato (longo/short), datas de gravação e publicação, descrição, script e notas. Salva sozinho enquanto você digita, e os botões **copiar** levam descrição/script direto pro YouTube Studio.
- **Listas "A gravar" / "A publicar"** — as próximas datas, em ordem, com aviso de atraso.
- **Ideias** — terceiro bloco da coluna lateral, ao lado de "A gravar"/"A publicar": rascunhos sem data nem compromisso, organizados em pastas configuráveis (nome + cor — console, tema, o que fizer sentido). Campo de adicionar rápido sempre visível; clicar numa ideia abre editar (título, nota, pasta); botão ⚙️ no título da seção abre "Pastas de ideias" pra criar/renomear/trocar cor/excluir. Cada ideia tem um botão **→** que a transforma em conteúdo com 1 clique: cria o card na Biblioteca (status Ideia, título e nota já preenchidos) e abre o drawer na hora pra você agendar — usa os mesmos componentes do resto da página (`.card`, `.mini-item`, `.chip`, `.modal`, drawer).
- **Biblioteca** — todos os conteúdos com busca e abas: **Geral** (pipeline em produção, com sub-abas por etapa) e **💡 Ideia** (com sub-abas 🔥 Vídeos Virais / 💰 Monetização). Arraste um card pro calendário e ele pergunta se aquele dia é gravação ou publicação.
- **Radar de concorrentes** — vídeos novos dos canais que você acompanha, coletados automaticamente (ver seção abaixo).
- **Backup / Importar** — exporta e importa tudo em JSON.

### Onde os dados ficam

O app tenta usar as tabelas `conteudos`, `ideia_pastas` e `ideias` no Supabase (mesmo projeto já configurado no dashboard). Se alguma ainda não existir, ele funciona normalmente salvando no navegador (localStorage) e mostra um aviso.

**Para sincronizar entre dispositivos:** cole o conteúdo de [`setup-conteudos.sql`](setup-conteudos.sql) e [`setup-ideias.sql`](setup-ideias.sql) no SQL Editor do Supabase, rode os dois, e recarregue a página. Se você já tinha dados locais, use **Backup** no navegador antigo e **Importar** depois que as tabelas existirem.

## Radar de concorrentes

Acompanha os canais que você cadastrar e lista os vídeos novos deles pra curadoria — com botão pra virar ideia sua em 1 clique, marcar como visto ou descartar.

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

## Dashboard original

`index.html`, `sugestoes.html`, `cronograma.html`, `briefing.html` e `configuracoes.html` continuam exatamente como estavam — sugestões com IA, briefing, configurações, aprendizado de métricas etc. Nada foi alterado neles além do novo item "Conteúdo" na navegação lateral.
