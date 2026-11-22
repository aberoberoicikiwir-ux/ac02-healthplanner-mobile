# Healthmaxxing Web Dashboard (PT)

Dashboard web untuk **Personal Trainer (PT)** pada proyek capstone AC-02
Personalized Health & Workout Planner.

Web ini hanya memanggil REST API backend. Web **tidak** mengakses database atau
Gemini secara langsung, dan tidak memakai endpoint internal AI.

## Stack

- React + Vite + TypeScript
- React Router
- TanStack Query
- Tailwind CSS
- Recharts
- lucide-react
- sonner
- Vitest

## Status

Dashboard PT sudah mencakup alur utama:

- login PT + penolakan role klien
- protected route, logout, dan redirect otomatis saat 401
- daftar klien aktif + pencarian
- ringkasan klien, status rencana, dan antrean review
- detail klien + health profile
- grafik berat badan dan langkah harian
- riwayat log harian
- review rencana AI
- approve rencana
- override terstruktur untuk feedback, target, workout, dan meal
- generate rencana AI
- notifikasi PT + tandai dibaca
- validasi editor mengikuti aturan backend

## Prasyarat

1. MySQL menyala.
2. Backend berjalan di `http://localhost:3000`.
3. Data demo sudah di-seed:

```bash
cd ../backend
npm run seed:demo
npm run dev
```

## Menjalankan

```bash
cd web_dashboard
npm install
npm run dev
```

Buka `http://127.0.0.1:5173`.

Vite mem-proxy `/api` ke `http://localhost:3000`, jadi frontend cukup memanggil
`/api/...`.

## Akun demo

- Username: `pt_demo`
- Password: `demo12345`

Akun klien (`klien_demo`) akan ditolak karena dashboard ini hanya untuk role PT.

## Route

| Route | Fungsi |
|---|---|
| `/login` | Login PT |
| `/` | Dashboard daftar klien |
| `/clients/:clientId` | Detail klien dan progres |
| `/clients/:clientId/review` | Review, approve, override rencana |
| `/notifications` | Notifikasi PT |

## Perintah

```bash
npm run dev
npm run lint
npm run test
npm run build
npm run preview
```

## Struktur

```text
src/
  api/          API client, PT, master data, notifikasi
  auth/         AuthProvider, context, protected route
  components/   Layout, chart, plan viewer/editor, dialog
  pages/        Login, Dashboard, Detail Klien, Review, Notifikasi
  types/        Tipe respons API
  utils/        Tanggal, validasi plan, error
```

## Catatan

- Grafik progres memakai data `weight_kg` dan `steps` dari endpoint progres.
- Rencana aktif ditampilkan dari `final_output ?? ai_output`.
- Belum ada endpoint global pending review; dashboard mengambil analysis terbaru
  per klien.
- Jangan menaruh API key Gemini di frontend.
- Jangan memanggil endpoint internal AI dari web.
- Token disimpan di `localStorage` untuk kebutuhan demo kuliah. Untuk produksi,
  gunakan cookie `httpOnly` dan hardening tambahan.
