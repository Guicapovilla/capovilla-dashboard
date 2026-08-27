/**
 * Radar de concorrentes — coleta vídeos novos dos canais cadastrados no dashboard.
 *
 * Roda no GitHub Actions (.github/workflows/radar-concorrentes.yml).
 * Lê os canais da tabela `radar_canais`, resolve os que ainda não têm channel_id,
 * busca os uploads recentes de cada um e grava em `radar_videos`.
 *
 * Variáveis de ambiente necessárias:
 *   YOUTUBE_API_KEY     — chave da YouTube Data API v3
 *   SUPABASE_URL        — https://xxxx.supabase.co
 *   SUPABASE_KEY        — chave publishable/anon do projeto
 */

const YOUTUBE_API_KEY = process.env.YOUTUBE_API_KEY;
const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_KEY = process.env.SUPABASE_KEY;

if (!YOUTUBE_API_KEY || !SUPABASE_URL || !SUPABASE_KEY) {
  console.error('Faltam variáveis de ambiente: YOUTUBE_API_KEY, SUPABASE_URL, SUPABASE_KEY');
  process.exit(1);
}

// Quantos uploads recentes olhar por canal em cada rodada.
const MAX_POR_CANAL = 15;

// ============================================================
// Supabase (REST direto, sem dependências)
// ============================================================
const sbHeaders = {
  apikey: SUPABASE_KEY,
  Authorization: `Bearer ${SUPABASE_KEY}`,
  'Content-Type': 'application/json',
};

async function sbGet(path) {
  const r = await fetch(`${SUPABASE_URL}/rest/v1/${path}`, { headers: sbHeaders });
  if (!r.ok) throw new Error(`Supabase GET ${path}: ${r.status} ${await r.text()}`);
  return r.json();
}

async function sbUpsert(table, rows, onConflict) {
  if (!rows.length) return;
  const url = `${SUPABASE_URL}/rest/v1/${table}?on_conflict=${onConflict}`;
  const r = await fetch(url, {
    method: 'POST',
    headers: { ...sbHeaders, Prefer: 'resolution=merge-duplicates,return=minimal' },
    body: JSON.stringify(rows),
  });
  if (!r.ok) throw new Error(`Supabase upsert ${table}: ${r.status} ${await r.text()}`);
}

async function sbPatch(table, filtro, campos) {
  const r = await fetch(`${SUPABASE_URL}/rest/v1/${table}?${filtro}`, {
    method: 'PATCH',
    headers: { ...sbHeaders, Prefer: 'return=minimal' },
    body: JSON.stringify(campos),
  });
  if (!r.ok) throw new Error(`Supabase patch ${table}: ${r.status} ${await r.text()}`);
}

// ============================================================
// YouTube Data API
// ============================================================
async function yt(endpoint, params) {
  const qs = new URLSearchParams({ ...params, key: YOUTUBE_API_KEY });
  const r = await fetch(`https://www.googleapis.com/youtube/v3/${endpoint}?${qs}`);
  const body = await r.json();
  if (!r.ok) {
    const motivo = body?.error?.message || `HTTP ${r.status}`;
    throw new Error(`YouTube ${endpoint}: ${motivo}`);
  }
  return body;
}

/**
 * Descobre o channel_id a partir do que o usuário colou.
 * Aceita: UCxxxx, @handle, youtube.com/@handle, /channel/UCxxx, /c/nome, /user/nome, ou só o nome.
 */
async function resolverCanal(entrada) {
  const txt = (entrada || '').trim();
  if (!txt) throw new Error('entrada vazia');

  // 1. já é um channel id
  const idDireto = txt.match(/(UC[\w-]{22})/);
  if (idDireto) return idDireto[1];

  // 2. handle (@nome), inclusive dentro de uma URL
  const handle = txt.match(/@([\w.\-]+)/);
  if (handle) {
    const r = await yt('channels', { part: 'id', forHandle: '@' + handle[1] });
    if (r.items?.length) return r.items[0].id;
  }

  // 3. /user/nome (legado)
  const user = txt.match(/\/user\/([\w.\-]+)/);
  if (user) {
    const r = await yt('channels', { part: 'id', forUsername: user[1] });
    if (r.items?.length) return r.items[0].id;
  }

  // 4. último recurso: busca pelo nome (/c/nome ou texto solto)
  const termo = (txt.match(/\/c\/([\w.\-]+)/)?.[1] || txt).replace(/https?:\/\/\S*?youtube\.com\/?/i, '').trim();
  if (termo) {
    const r = await yt('search', { part: 'snippet', type: 'channel', q: termo, maxResults: '1' });
    const achado = r.items?.[0]?.id?.channelId || r.items?.[0]?.snippet?.channelId;
    if (achado) return achado;
  }

  throw new Error(`não encontrei um canal para "${txt}"`);
}

// ISO 8601 (PT1M30S) -> segundos
function duracaoEmSegundos(iso) {
  const m = /^P(?:([\d.]+)D)?T?(?:([\d.]+)H)?(?:([\d.]+)M)?(?:([\d.]+)S)?$/.exec(iso || '');
  if (!m) return 0;
  const [, d, h, min, s] = m.map(v => (v ? parseFloat(v) : 0));
  return d * 86400 + h * 3600 + min * 60 + s;
}

// ============================================================
// Rotina principal
// ============================================================
async function main() {
  const canais = await sbGet('radar_canais?ativo=eq.true&select=*');
  if (!canais.length) {
    console.log('Nenhum canal cadastrado. Nada a fazer.');
    return;
  }
  console.log(`${canais.length} canal(is) ativo(s).`);

  let totalVideos = 0;

  for (const canal of canais) {
    try {
      let { channel_id, uploads_playlist, nome, avatar } = canal;

      // Resolve dados do canal se ainda não temos (primeira vez, ou canal recém-cadastrado)
      if (!channel_id || !uploads_playlist) {
        if (!channel_id) channel_id = await resolverCanal(canal.entrada);
        const info = await yt('channels', { part: 'snippet,contentDetails', id: channel_id });
        const item = info.items?.[0];
        if (!item) throw new Error(`canal ${channel_id} não retornou dados`);
        uploads_playlist = item.contentDetails?.relatedPlaylists?.uploads;
        nome = item.snippet?.title || nome;
        avatar = item.snippet?.thumbnails?.default?.url || avatar;

        await sbPatch('radar_canais', `id=eq.${canal.id}`, {
          channel_id, uploads_playlist, nome, avatar, erro: null,
          updated_at: new Date().toISOString(),
        });
        console.log(`Canal resolvido: ${nome} (${channel_id})`);
      }

      // Uploads recentes
      const playlist = await yt('playlistItems', {
        part: 'snippet,contentDetails',
        playlistId: uploads_playlist,
        maxResults: String(MAX_POR_CANAL),
      });
      const ids = (playlist.items || []).map(i => i.contentDetails?.videoId).filter(Boolean);
      if (!ids.length) {
        console.log(`${nome}: sem uploads.`);
        continue;
      }

      // Estatísticas dos vídeos
      const detalhes = await yt('videos', {
        part: 'snippet,statistics,contentDetails',
        id: ids.join(','),
      });

      const linhas = (detalhes.items || []).map(v => {
        const dur = v.contentDetails?.duration || '';
        const th = v.snippet?.thumbnails || {};
        return {
          video_id: v.id,
          canal_id: canal.id,
          channel_id,
          canal_nome: nome,
          titulo: v.snippet?.title || '',
          descricao: (v.snippet?.description || '').slice(0, 2000),
          thumb: (th.maxres || th.standard || th.high || th.medium || th.default || {}).url || '',
          url: `https://www.youtube.com/watch?v=${v.id}`,
          publicado_em: v.snippet?.publishedAt || null,
          views: Number(v.statistics?.viewCount || 0),
          likes: Number(v.statistics?.likeCount || 0),
          comentarios: Number(v.statistics?.commentCount || 0),
          duracao: dur,
          is_short: duracaoEmSegundos(dur) > 0 && duracaoEmSegundos(dur) <= 180,
          updated_at: new Date().toISOString(),
        };
      });

      // `visto`/`descartado` não são enviados: o merge preserva o que já existe na linha
      await sbUpsert('radar_videos', linhas, 'video_id');
      await sbPatch('radar_canais', `id=eq.${canal.id}`, { ultima_checagem: new Date().toISOString() });

      totalVideos += linhas.length;
      console.log(`${nome}: ${linhas.length} vídeo(s) sincronizado(s).`);
    } catch (err) {
      console.error(`Erro no canal "${canal.entrada}": ${err.message}`);
      // registra o erro pra aparecer no dashboard, mas segue pros outros canais
      try {
        await sbPatch('radar_canais', `id=eq.${canal.id}`, {
          erro: err.message.slice(0, 300),
          ultima_checagem: new Date().toISOString(),
        });
      } catch (e) { /* não deixa falha de log derrubar a rodada */ }
    }
  }

  console.log(`Pronto. ${totalVideos} vídeo(s) no total.`);
}

main().catch(err => {
  console.error('Falha geral:', err);
  process.exit(1);
});
