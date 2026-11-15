'use strict';

// Demo end-to-end tanpa dashboard web: PT menyetujui rencana AI klien demo, lalu klien melihat hasilnya.
//
// Prasyarat: server berjalan (npm run dev) dan data demo ada (npm run seed:demo).
// Jalankan:  npm run demo:approve
// (alamat server lain:  BASE_URL=http://192.168.1.5:3000/api npm run demo:approve)

const BASE = process.env.BASE_URL || 'http://localhost:3000/api';

if (typeof fetch !== 'function') {
  console.error('Node.js kamu terlalu lama (butuh versi 18 ke atas). Cek dengan: node --version');
  process.exit(1);
}

async function call(method, path, { token, body } = {}) {
  const res = await fetch(BASE + path, {
    method,
    headers: { 'Content-Type': 'application/json', ...(token ? { Authorization: `Bearer ${token}` } : {}) },
    body: body ? JSON.stringify(body) : undefined,
  });
  let data = null;
  try {
    data = await res.json();
  } catch {
    /* balasan tanpa body */
  }
  return { status: res.status, data };
}

async function login(username, password) {
  const r = await call('POST', '/auth/login', { body: { username, password } });
  if (r.status !== 200) throw new Error(`Login ${username} gagal (${r.status}): ${r.data && r.data.message}. Sudah menjalankan "npm run seed:demo"?`);
  return r.data.token;
}

const step = (n, text) => console.log(`\n[${n}] ${text}`);
const ok = (text) => console.log(`    OK  ${text}`);

async function main() {
  console.log(`Server: ${BASE}`);

  step(1, 'Login sebagai PT (pt_demo)');
  const ptToken = await login('pt_demo', 'demo12345');
  ok('token diterima');

  step(2, 'Cari klien bimbingan');
  const list = await call('GET', '/pt/clients?status=active', { token: ptToken });
  if (list.status !== 200 || !Array.isArray(list.data) || list.data.length === 0) {
    throw new Error('PT belum punya klien aktif. Jalankan "npm run seed:demo" dulu.');
  }
  const client = list.data.find((c) => c.name === 'Klien Demo') || list.data[0];
  ok(`klien: ${client.name} (client_id ${client.client_id})`);

  step(3, 'Ambil rencana AI terbaru untuk direview');
  const cur = await call('GET', `/pt/clients/${client.client_id}/ai-analysis/current`, { token: ptToken });
  if (cur.status !== 200) throw new Error(`Belum ada rencana AI (${cur.status}): ${cur.data && cur.data.message}`);
  const analysis = cur.data;
  ok(`analysis_id ${analysis.analysis_id}, minggu ${String(analysis.week_start_date).slice(0, 10)}, status "${analysis.status}"`);

  if (analysis.status !== 'pending') {
    console.log(`\nRencana ini sudah berstatus "${analysis.status}", jadi tidak disetujui lagi (backend menolak dengan 409).`);
    console.log('Untuk mengulang dari awal: reset database, jalankan seed:demo lagi.');
  } else {
    step(4, 'PT menyetujui rencana (approve) -> backend menerapkannya ke klien');
    const ap = await call('PATCH', `/pt/ai-analysis/${analysis.analysis_id}/approve`, { token: ptToken });
    if (ap.status !== 200) throw new Error(`Approve gagal (${ap.status}): ${ap.data && ap.data.message} ${JSON.stringify((ap.data && ap.data.details) || [])}`);
    ok(`${ap.data.message} workout_plan_id ${ap.data.workout_plan_id}, ${ap.data.workout_items} item latihan, ${ap.data.meal_items} item menu`);
  }

  step(5, 'Login sebagai klien (klien_demo) dan lihat rencana seperti di aplikasi');
  const kToken = await login('klien_demo', 'demo12345');

  const w = await call('GET', '/clients/me/workout-plans/current', { token: kToken });
  if (w.status !== 200) throw new Error(`Workout plan belum ada (${w.status}): ${w.data && w.data.message}`);
  ok(`workout plan minggu ${w.data.week_start_date}: ${w.data.items.length} latihan, status "${w.data.status}"`);
  const first = w.data.items[0];
  if (first) ok(`contoh: ${first.day_of_week} - ${first.exercise_name} (${first.category}), sets ${first.sets}, reps ${first.reps}`);

  const m = await call('GET', '/clients/me/meal-plans/current', { token: kToken });
  if (m.status !== 200) throw new Error(`Meal plan belum ada (${m.status}): ${m.data && m.data.message}`);
  const withDay = m.data.items.filter((i) => i.day_of_week).length;
  ok(`meal plan minggu ${m.data.week_start_date}: ${m.data.items.length} item menu, ${withDay} di antaranya punya hari`);

  const n = await call('GET', '/users/me/notifications', { token: kToken });
  if (n.status === 200 && Array.isArray(n.data) && n.data.length > 0) {
    const insight = n.data.find((x) => x.type === 'ai_insight');
    if (insight) ok(`notifikasi insight: "${insight.title}"`);
  }

  console.log('\nSelesai. Rencana yang disetujui PT sekarang terlihat oleh klien.');
}

main().catch((e) => {
  const refused = e && (e.code === 'ECONNREFUSED' || (e.cause && e.cause.code === 'ECONNREFUSED'));
  console.error(`\nGAGAL: ${refused ? `server tidak bisa dihubungi di ${BASE}. Sudah menjalankan "npm run dev"?` : e.message}`);
  process.exit(1);
});
