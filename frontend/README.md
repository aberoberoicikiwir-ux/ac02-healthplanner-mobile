# Healthmaxxing Frontend (Next.js)

Frontend dashboard PT untuk proyek PBL HEALTHMAXXING, dibangun dengan **Next.js App Router**.

## Stack

- Next.js 16 App Router
- React Server Components
- Server Actions
- React Query
- Tailwind CSS
- Recharts
- Joi (validasi query di backend)

## Menjalankan

1. Pastikan MySQL dan backend Express berjalan.
2. Salin environment:

```bash
cp .env.example .env.local
```

3. Install dan jalankan:

```bash
npm install
npm run dev
```

Buka `http://localhost:3001`.

## Akun Demo

- `pt_demo` / `demo12345`

Akun klien ditolak.

## Route

| Route | Render | Fungsi |
|---|---|---|
| `/login` | Dynamic | Login PT lewat Server Action |
| `/` | Dynamic | Dashboard, search/pagination via React Query |
| `/clients/[id]` | Dynamic | Detail klien, profil, grafik progres |
| `/clients/[id]/review` | Dynamic | Review, approve, override rencana |
| `/notifications` | Dynamic | Notifikasi PT |

Semua halaman memakai `force-dynamic` secara efektif karena membaca cookie sesi dan data terbaru dari API.

## Materi PWF yang Diterapkan

- App Router dan Server Components
- Server Actions + `useActionState` + `useFormStatus`
- Data fetching dari Express lewat `lib/` server-only
- Cookie httpOnly untuk sesi
- `loading.tsx`, `error.tsx`, `not-found.tsx`
- `next/font`
- CSS variables
- Responsif 360/768/1280
- Pagination offset + search + whitelist sort di backend
- Joi untuk validasi `req.query`
- React Query: debounce, URL filter, `keepPreviousData`, prefetch

## Struktur

```text
app/
  (dashboard)/
    layout.tsx
    page.tsx
    clients/[id]/page.tsx
    clients/[id]/review/page.tsx
    notifications/page.tsx
  login/
  api/pt/clients/route.ts
components/
lib/
types/
middleware.ts
```

## Catatan

- Frontend hanya memanggil REST API Express.
- Tidak ada API key AI di frontend.
- Folder `web_dashboard/` (Vite lama) sudah dihapus dari repo.

## Screenshots

### Login
![Login](/screenshots/login.png)

### Dashboard
![Dashboard](/screenshots/dashboard.png)

### Detail Klien
![Detail Klien](/screenshots/client-detail.png)

### Review Rencana
![Review Rencana](/screenshots/review-plan.png)

### Notifikasi
![Notifikasi](/screenshots/notifications.png)
