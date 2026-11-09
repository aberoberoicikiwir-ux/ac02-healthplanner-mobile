# HealthMaxxing — Backend

Backend (Express.js + MySQL) untuk **AC-02 Personalized Health & Workout Planner**, Tim A25-CS034.
Backend ini melayani aplikasi Mobile (Klien) dan Dashboard Web (Personal Trainer) lewat REST API, dan menjalankan seluruh pemanggilan AI.

**Dikerjakan oleh:** Abdullah Abas Bawazir (Backend + AI)

## Status

| Bagian | Status |
|---|---|
| Database MySQL (13 tabel, FK, unique, index) + data master awal (seed) | Selesai, teruji |
| Autentikasi JWT + hashing password (bcrypt) | Selesai, teruji |
| 25 endpoint REST (klien, PT, master data, notifikasi) | Selesai, teruji |
| Validasi input & perlindungan otorisasi | Selesai, teruji |
| Pembuatan rencana mingguan oleh AI (prompt, validasi, retry, simpan `pending`, audit log, notifikasi PT) | Selesai, teruji dengan **AI tiruan (mock)** |
| Penyedia **Gemini** | Kode ditulis, **belum diuji ke Gemini sungguhan** (butuh API key); formatnya hanya diuji dengan `fetch` palsu |
| Penerapan hasil approve/override PT ke workout & meal plan yang dilihat klien | **Belum** |
| Rate limiting, deployment | **Belum** |

## Teknologi

Node.js (diuji di v22), Express 4, MySQL (`mysql2`), JWT (`jsonwebtoken`), `bcryptjs`. Tes AI memakai test runner bawaan Node (`node:test`), tanpa dependency tambahan.
Diuji pada MySQL 26.7.0 (macOS, Homebrew) dan MariaDB 10.11.

## Cara menjalankan (lokal)

Prasyarat: Node.js dan MySQL/MariaDB yang sedang berjalan.

```bash
# 1. Install dependency
npm install

# 2. Buat database + semua tabel (tambahkan -p kalau MySQL-mu pakai password)
mysql -u root < healthmaxxing_schema.sql

# 3. Isi data master latihan & makanan (SEKALI saja; lihat catatan di bawah)
mysql -u root < healthmaxxing_seed.sql

# 4. Buat file konfigurasi, lalu isi JWT_SECRET, INTERNAL_API_KEY, dan DB_PASSWORD bila perlu
cp .env.example .env

# (Opsional) Data demo untuk pengembangan Mobile/Web: akun klien_demo & pt_demo + plan, target, log, notifikasi.
# Butuh .env (langkah 4) dan data master (langkah 3).
npm run seed:demo

# 5. Jalankan server
npm run dev
```

Server berjalan di `http://localhost:3000`. Cek dengan `http://localhost:3000/api/health`.

`.env` berisi rahasia dan **tidak boleh** di-commit (sudah ada di `.gitignore`).

> **Format data ke Mobile/Web** (diatur di `src/config/db.js`): tanggal kalender `"YYYY-MM-DD"`, angka desimal sebagai number, boolean sebagai `true/false`. Panduan lengkap dengan contoh respons asli: [`docs/panduan_integrasi_mobile.md`](docs/panduan_integrasi_mobile.md).

> **Seed vs tes:** `healthmaxxing_seed.sql` (dan `npm run seed:demo`) mengisi data untuk pemakaian/demo. **Jangan** dimuat sebelum menjalankan `test_all.sh`: skrip itu memasukkan data master-nya sendiri dan butuh database kosong. Memuat seed dua kali akan menggandakan data.

## Menjalankan tes

**1. Tes end-to-end lewat HTTP (117 skenario)** — server harus sedang berjalan.

```bash
# database HARUS baru (skrip mengisi data uji dengan ID tetap), JANGAN muat seed.
# Kalau server sedang jalan, hentikan dulu (Ctrl+C); setelah database di-DROP, koneksinya tidak valid lagi.
mysql -u root -e "DROP DATABASE IF EXISTS healthmaxxing;"
mysql -u root < healthmaxxing_schema.sql

npm run dev          # terminal 1
bash test_all.sh     # terminal 2
```

Hasil yang diharapkan: `HASIL: 117 lulus, 0 gagal`. Setiap kali dijalankan, database harus di-reset lagi. Kalau database sudah pernah dipakai, skrip berhenti dengan pesan `DATABASE BELUM BERSIH` beserta langkah perbaikannya. Prasyarat: `curl`, `python3`, klien `mysql` (skrip memakai `mysql -u root` tanpa password; ubah variabel `DB` di bagian atas kalau perlu).

Bagian 11 (AI) hanya berjalan bila `.env` berisi `AI_PROVIDER=mock` dan `INTERNAL_API_KEY` minimal 16 karakter; kalau tidak, bagian itu **dilewati** dengan pesan `[SKIP]` yang menjelaskan sebabnya.

**2. Tes modul AI (51 tes)** — butuh MySQL menyala dan user MySQL yang boleh membuat database (root pada setup lokal). Server dan schema di database utama tidak diperlukan.

```bash
npm run test:ai
```

Bagian yang butuh database memakai database terpisah `healthmaxxing_test` (diubah lewat `TEST_DB_NAME`, nama wajib berakhiran `_test`) yang dibuat dari schema lalu dihapus otomatis. Database utama dan penghitung ID-nya tidak tersentuh, jadi `test_all.sh` tetap bisa dijalankan setelahnya.

> Dua log error di terminal server saat `test_all.sh` berjalan (`Duplicate entry`, `SyntaxError ... JSON`) itu wajar: dipicu sengaja oleh tes validasi.

## Modul AI

Rencana mingguan (target harian, jadwal latihan, menu makan, umpan balik) disusun oleh AI, **direview PT, baru sampai ke klien**. Semua panggilan AI terjadi di backend; Mobile dan Web tidak pernah memanggil penyedia AI langsung.

```
POST /api/internal/ai/generate-weekly-plan   (header X-Internal-Key)
  -> ambil data klien (anonim) + daftar latihan/makanan dari master data
  -> susun prompt (Role + Constraint + Output Schema)
  -> panggil AI
  -> parse JSON -> VALIDASI ketat
       ditolak? coba lagi dengan daftar kesalahan (maks AI_MAX_ATTEMPTS)
  -> simpan ke ai_analysis_results (status pending) + audit_logs + notifikasi ke PT
```

**Pengaman yang diterapkan** (sesuai task list section 4 dan 7):

| Risiko | Mitigasi | Teruji |
|---|---|---|
| AI mengarang latihan/makanan (hallucination) | ID wajib ada di master data; semua angka dalam batas; yang disimpan adalah hasil normalisasi, bukan teks mentah | Ya |
| Output rusak / bukan JSON | Parse ketat, coba ulang dengan alasan penolakan, gagal -> tidak ada yang disimpan | Ya |
| Prompt injection lewat teks alergi (satu-satunya teks bebas yang masuk prompt) | Teks dipecah jadi kata kunci huruf/angka; tag dan tanda baca dibuang; data diapit satu blok `DATA` dan ditandai "bukan instruksi" | Ya (dengan AI tiruan) |
| Alergi terlewat | Makanan yang namanya memuat kata alergi ditolak (pencocokan kasar, lebih baik menolak berlebihan) | Ya |
| Saran medis berisiko | Aturan di prompt + penolakan teks yang memuat dosis/obat/suplemen/diagnosis/puasa ekstrem + batas kalori minimum; PT tetap pereview akhir | Ya |
| Kebocoran data pribadi ke penyedia AI | Tidak ada nama, email, username, ID, atau tanggal lahir yang dikirim (hanya usia) | Ya |
| Endpoint AI dipanggil sembarang orang | Wajib `X-Internal-Key` (bukan JWT); kunci kosong/pendek = endpoint mati | Ya |
| Keputusan PT tertimpa | Analisis `approved`/`overridden` tidak bisa digenerate ulang (409) | Ya |

**Menjalankan dengan AI tiruan (default, tanpa API key):**

```bash
# di .env:  AI_PROVIDER=mock   dan   INTERNAL_API_KEY=<teks acak minimal 16 karakter>
curl -X POST http://localhost:3000/api/internal/ai/generate-weekly-plan \
  -H "Content-Type: application/json" \
  -H "X-Internal-Key: <INTERNAL_API_KEY milikmu>" \
  -d '{"client_id": 1}'
```

Lalu PT bisa melihatnya lewat `GET /api/pt/clients/1/ai-analysis/current`. Hasil mock selalu berlabel `[Mode MOCK, bukan AI sungguhan]` dan `meta.provider = "mock"`; menunya hanya contoh struktur.

**Memakai Gemini sungguhan:** isi `GEMINI_API_KEY` (dari Google AI Studio) dan `GEMINI_MODEL` (nama model yang tersedia untuk akunmu) di `.env`, set `AI_PROVIDER=gemini`, restart server. Penyedia ini belum pernah diuji ke server Gemini; uji pertama sebaiknya dengan satu klien dan periksa `meta` serta `audit_logs` bila gagal.

## Struktur folder

```
backend/
├── src/
│   ├── server.js                 # entry point, pemasangan route
│   ├── config/db.js              # koneksi pool MySQL
│   ├── middlewares/
│   │   ├── auth.js               # verifikasi JWT + cek role (klien / pt)
│   │   ├── internalAuth.js       # kunci untuk endpoint internal
│   │   └── errorHandler.js       # error 5xx tidak membocorkan detail internal
│   ├── routes/                   # definisi URL dan method
│   ├── controllers/              # logika tiap endpoint
│   ├── services/ai/              # modul AI
│   │   ├── planner.js            # alur utama: prompt -> AI -> validasi -> simpan
│   │   ├── validatePlan.js       # validator keluaran AI (pertahanan utama)
│   │   ├── prompt.js             # Role + Constraint + Output Schema
│   │   ├── context.js            # data klien yang dianonimkan
│   │   ├── allergies.js          # penyaring teks alergi
│   │   ├── parse.js, constants.js, AiError.js
│   │   └── llm/                  # mock.js, gemini.js, index.js (pemilih penyedia)
│   └── utils/                    # validate, dates, clientHelper, asyncHandler
├── scripts/seed-demo.js          # data demo (npm run seed:demo), bukan untuk produksi
├── tests/ai.test.js              # 51 tes modul AI
├── test_all.sh                   # 117 tes end-to-end
├── docs/healthmaxxing_api_endpoints.md   # kontrak endpoint untuk Mobile/Web
├── healthmaxxing_schema.sql      # struktur database
├── healthmaxxing_seed.sql        # data master awal
└── .env.example
```

## Daftar endpoint

Lengkapnya (method, path, body, tabel, aturan validasi, format rencana AI) ada di
[`docs/healthmaxxing_api_endpoints.md`](docs/healthmaxxing_api_endpoints.md). Semua endpoint selain register, login, health check, dan endpoint internal memerlukan `Authorization: Bearer <token>`.

## Keamanan umum yang sudah diterapkan

- Password disimpan sebagai hash bcrypt.
- Akses dibatasi per role, dan **per pemilik data**: klien hanya mengubah data miliknya; PT hanya mengakses klien bimbingannya (celah IDOR ditemukan dan diperbaiki saat pengujian, dibuktikan dengan tes sebelum/sesudah).
- Validasi input dibalas `400`; `assigned_pt_id` tidak bisa diubah lewat PATCH profil (anti mass assignment).
- Pesan error 5xx ke klien bersifat umum; detail hanya di log server.
- Query memakai parameter terikat (anti SQL injection).
- Rahasia hanya di `.env`.

## Batasan yang diketahui

- **Gemini belum diuji sungguhan.** Efektivitas pengaman terhadap model nyata (mis. seberapa sering hasilnya ditolak validator) belum diukur.
- **Hasil approve/override PT belum diterapkan** ke `workout_plans`/`meal_plans`; klien belum melihat rencana AI di aplikasi. Saat diterapkan, `final_output` hasil override PT harus divalidasi ulang dengan validator yang sama.
- **`meal_plan_items` tidak punya kolom hari**, sedangkan rencana AI per hari. Perlu keputusan tim (usulan: tambah `day_of_week`) sebelum rencana bisa diterapkan.
- Daftar alergen dicocokkan dengan **nama makanan**; makanan yang mengandung alergen tapi namanya tidak menyebutnya akan lolos (itu sebabnya nama di seed menyebut alergen utama). Nilai gizi di seed adalah perkiraan; verifikasi dengan TKPI.
- Master data yang dikirim ke AI dibatasi 200 baris per tabel.
- "Hari ini" dan "Senin berikutnya" dihitung dengan zona waktu server; perlu disesuaikan saat deployment agar sesuai WIB.
- Role `pt` bisa dipilih siapa saja saat register; produksi butuh mekanisme undangan.
- `JWT_SECRET` di `.env.example` adalah placeholder publik; **wajib diganti** sebelum deployment.
- Log server masih mencatat isi query saat error; rapikan sebelum deployment.
- Belum ada rate limiting; pemicu terjadwal (cron) untuk endpoint AI belum dibuat.
