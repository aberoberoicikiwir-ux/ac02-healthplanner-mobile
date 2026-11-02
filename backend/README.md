# HealthMaxxing — Backend

Backend (Express.js + MySQL) untuk **AC-02 Personalized Health & Workout Planner**, Tim A25-CS034.
Backend ini melayani aplikasi Mobile (Klien) dan Dashboard Web (Personal Trainer) lewat REST API.

**Dikerjakan oleh:** Abdullah Abas Bawazir (Backend + AI)

## Status

| Bagian | Status |
|---|---|
| Database MySQL (13 tabel, FK, unique, index) | Selesai, teruji |
| Autentikasi JWT + hashing password (bcrypt) | Selesai, teruji |
| 25 endpoint REST (klien, PT, master data, notifikasi) | Selesai, teruji |
| Validasi input & perlindungan otorisasi | Selesai, teruji |
| Integrasi AI (Gemini API) | **Belum** |
| Penerapan hasil approve/override PT ke workout & meal plan klien | **Belum** (menunggu format output AI) |
| Filter prompt injection, rate limiting, anonimisasi data | **Belum** |
| Deployment | **Belum** |

## Teknologi

Node.js, Express 4, MySQL (`mysql2`), JWT (`jsonwebtoken`), `bcryptjs`.
Diuji pada MySQL 26.7.0 (macOS, Homebrew) dan MariaDB 10.11.

## Cara menjalankan (lokal)

Prasyarat: Node.js dan MySQL/MariaDB yang sedang berjalan.

```bash
# 1. Install dependency
npm install

# 2. Buat database + semua tabel (tambahkan -p kalau MySQL-mu pakai password)
mysql -u root < healthmaxxing_schema.sql

# 3. Buat file konfigurasi, lalu isi DB_PASSWORD dan JWT_SECRET
cp .env.example .env

# 4. Jalankan server
npm run dev
```

Server berjalan di `http://localhost:3000`. Cek dengan membuka `http://localhost:3000/api/health`.

`.env` berisi rahasia dan **tidak boleh** di-commit (sudah ada di `.gitignore`). `JWT_SECRET` wajib diganti dengan teks acak yang panjang.

## Menjalankan tes otomatis

`test_all.sh` menjalankan **79 skenario** terhadap server yang sedang berjalan: alur normal, input tidak valid, dan percobaan mengakses data milik pengguna lain.

Prasyarat tambahan: `curl`, `python3`, dan klien `mysql` (skrip memakai `mysql -u root` tanpa password; ubah variabel `DB` di bagian atas skrip kalau perlu).

```bash
# Skrip mengisi data uji sendiri, jadi database HARUS kosong/baru:
mysql -u root -e "DROP DATABASE IF EXISTS healthmaxxing;"
mysql -u root < healthmaxxing_schema.sql

# Terminal 1
npm run dev

# Terminal 2
bash test_all.sh
```

Hasil yang diharapkan: `HASIL: 79 lulus, 0 gagal`.

> **Peringatan:** jangan jalankan tes di database yang berisi data yang ingin dipertahankan. Dua log error di terminal server (`Duplicate entry`, `SyntaxError ... JSON`) saat tes berjalan itu wajar: itu dipicu sengaja oleh tes validasi.

## Struktur folder

```
backend/
├── src/
│   ├── server.js                 # entry point, pemasangan route
│   ├── config/db.js              # koneksi pool MySQL
│   ├── middlewares/
│   │   ├── auth.js               # verifikasi JWT + cek role (klien / pt)
│   │   └── errorHandler.js       # error 5xx tidak membocorkan detail internal
│   ├── routes/                   # definisi URL dan method
│   ├── controllers/              # logika tiap endpoint (query ke database)
│   └── utils/
│       ├── validate.js           # aturan validasi input
│       ├── clientHelper.js       # mencari client_id dari user yang login
│       └── asyncHandler.js       # penangkap error async
├── docs/healthmaxxing_api_endpoints.md   # daftar endpoint (kontrak dengan Mobile/Web)
├── healthmaxxing_schema.sql      # struktur database
├── test_all.sh                   # 79 tes otomatis
└── .env.example
```

Alur satu request: `route` → `middleware` (cek token dan role) → `controller` (validasi lalu query database) → respons JSON.

## Daftar endpoint

Lengkapnya (method, path, body, tabel yang disentuh, aturan validasi) ada di
[`docs/healthmaxxing_api_endpoints.md`](docs/healthmaxxing_api_endpoints.md). Ringkasannya:

| Kelompok | Contoh |
|---|---|
| Auth | `POST /api/auth/register`, `/login`, `/logout` |
| Profil klien | `GET/POST/PATCH /api/clients/me/profile`, `POST /api/clients/me/pt` |
| Target & log harian | `GET /api/clients/me/targets/current`, `PUT /api/clients/me/daily-logs/today` |
| Workout & meal plan | `GET /api/clients/me/workout-plans/current`, `PATCH /api/workout-plan-items/:id` |
| Notifikasi | `GET /api/users/me/notifications` |
| Dashboard PT | `GET /api/pt/clients`, `/api/pt/clients/:id/progress`, `PATCH /api/pt/ai-analysis/:id/approve` |
| Master data | `GET /api/exercises`, `/api/foods` |

Semua endpoint selain register, login, dan health check memerlukan header `Authorization: Bearer <token>`.

## Keamanan yang sudah diterapkan

- Password disimpan sebagai hash bcrypt, bukan teks asli.
- Akses dibatasi per role: klien tidak dapat memanggil endpoint PT (403).
- **Otorisasi per pemilik data:** klien hanya dapat mengubah checklist dan notifikasi miliknya; PT hanya dapat melihat, menyetujui, atau meng-override data klien bimbingannya. Ditemukan dan diperbaiki saat pengujian (celah IDOR), dibuktikan dengan tes sebelum dan sesudah perbaikan.
- Validasi input (tipe, rentang, enum, format tanggal) dibalas `400`, bukan error server.
- Field sensitif seperti `assigned_pt_id` tidak dapat diubah lewat PATCH profil (mencegah mass assignment).
- Pesan error 5xx ke klien bersifat umum; detail lengkap hanya di log server.
- Query memakai parameter terikat (bukan penggabungan string) untuk mencegah SQL injection.
- Rahasia (`JWT_SECRET`, kelak API key Gemini) hanya di `.env`.

## Batasan yang diketahui

- Endpoint AI (`POST /api/internal/ai/generate-weekly-plan`) ada di dokumen kontrak tetapi **belum dibuat**.
- Approve/override PT baru tersimpan di `ai_analysis_results`; belum diterapkan ke `workout_plans` dan `meal_plans` yang dilihat klien.
- "Hari ini" dihitung memakai zona waktu server database; perlu disesuaikan saat deployment agar sesuai WIB.
- Role `pt` dapat dipilih siapa saja saat register. Untuk produksi perlu mekanisme undangan.
- Log server masih mencatat isi query saat terjadi error; perlu dirapikan sebelum deployment.
- Belum ada rate limiting.
