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

## Status

Phase 0–1 selesai:

- scaffold Vite React TypeScript
- konfigurasi proxy `/api` ke backend lokal
- tema gelap dan komponen dasar
- API client dengan Bearer token
- login PT + penolakan role klien
- protected route, logout, dan redirect otomatis saat 401
- layout dashboard responsif
- halaman placeholder Dashboard dan Notifikasi

Fase berikutnya: daftar klien, detail progres, review AI, approve/override,
generate plan, dan notifikasi.

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

Buka `http://localhost:5173`.

Vite mem-proxy `/api` ke `http://localhost:3000`, jadi frontend cukup memanggil
`/api/...`.

## Akun demo

- Username: `pt_demo`
- Password: `demo12345`

Akun klien (`klien_demo`) akan ditolak karena dashboard ini hanya untuk role PT.

## Perintah

```bash
npm run dev
npm run lint
npm run build
npm run preview
```

## Struktur

```text
src/
  api/          API client, auth request
  auth/         AuthProvider, context, protected route
  components/   Layout dan komponen UI
  pages/        Login, Dashboard, Notifikasi
  types/        Tipe respons API
  utils/        Helper error
```

## Catatan keamanan

- Jangan menaruh API key Gemini di frontend.
- Jangan memanggil endpoint internal AI dari web.
- Token disimpan di `localStorage` untuk kebutuhan demo kuliah. Untuk produksi,
  gunakan cookie `httpOnly` dan hardening tambahan.
