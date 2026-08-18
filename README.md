# Capovilla · Central de Conteúdo

Sistema simples de gestão de conteúdo do canal, em um único arquivo (`index.html`).

## O que tem

- **Calendário** — mostra em cada dia o que **gravar** (🎬 âmbar) e o que **publicar** (🚀 azul). Publicado fica verde, atrasado fica vermelho. Clicar num dia cria um conteúdo novo já com a data de publicação preenchida.
- **Card de conteúdo** — abre num painel lateral com tudo em um lugar: thumbnail (cole com Ctrl+V, arraste ou clique), título, etapa (Ideia → Roteiro → Gravação → Edição → Publicado), formato (longo/short), datas de gravação e publicação, descrição, script e notas. Salva sozinho enquanto você digita, e os botões **copiar** levam descrição/script direto pro YouTube Studio.
- **Listas "A gravar" / "A publicar"** — as próximas datas, em ordem, com aviso de atraso.
- **Biblioteca** — todos os conteúdos com busca e filtro por etapa.
- **Backup / Importar** — exporta e importa tudo em JSON.

## Onde os dados ficam

O app tenta usar a tabela `conteudos` no Supabase (mesmo projeto já configurado no dashboard). Se a tabela ainda não existir, ele funciona normalmente salvando no navegador (localStorage) e mostra um aviso.

**Para sincronizar entre dispositivos:** cole o conteúdo de [`setup-conteudos.sql`](setup-conteudos.sql) no SQL Editor do Supabase, rode, e recarregue a página. Se você já tinha dados locais, use **Backup** no navegador antigo e **Importar** depois que a tabela existir.

## Histórico

A versão anterior do dashboard (sugestões com IA, briefing, configurações, métricas etc.) foi removida nesta reformulação, mas continua disponível no histórico do git caso alguma parte precise voltar.
