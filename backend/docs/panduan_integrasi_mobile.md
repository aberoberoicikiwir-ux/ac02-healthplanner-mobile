# Panduan Integrasi Mobile ↔ Backend

Dokumen ini melengkapi `healthmaxxing_api_endpoints.md` (daftar endpoint). Semua contoh respons di bawah adalah **keluaran asli server** (bukan karangan), diambil dengan akun demo. ID dan tanggal di contoh akan berbeda di komputermu.

## 1. Menjalankan backend untuk tes dari emulator

Backend belum di-deploy; harus dijalankan di laptop (milik developer backend atau milikmu sendiri).

```bash
cd backend
npm install
cp .env.example .env            # isi JWT_SECRET; DB_PASSWORD kosong bila MySQL tanpa password
mysql -u root < healthmaxxing_schema.sql
mysql -u root < healthmaxxing_seed.sql     # data master latihan & makanan
npm run seed:demo               # akun + data demo (lihat bagian 2)
npm run dev                     # http://localhost:3000
```

Alamat dasar (Base URL) dari aplikasi:

| Dijalankan di | Base URL |
|---|---|
| iOS Simulator | `http://localhost:3000/api` |
| Android Emulator | `http://10.0.2.2:3000/api` |
| HP fisik (satu Wi-Fi dengan laptop) | `http://<IP-LAN-laptop>:3000/api` |

Server mendengarkan semua antarmuka jaringan, dan CORS terbuka. Kalau koneksi ditolak:
- **Android 9+** memblokir HTTP polos secara default. Untuk build debug, izinkan cleartext (`android:usesCleartextTraffic="true"` di manifest debug, atau network security config).
- **iOS** bisa menolak HTTP ke alamat jaringan lokal. Bila terjadi, tambahkan pengecualian jaringan lokal (`NSAllowsLocalNetworking`) di `Info.plist` untuk build debug.
- HP fisik: pastikan firewall laptop mengizinkan koneksi masuk ke port 3000.

## 2. Akun demo

`npm run seed:demo` membuat (dan bisa diulang untuk membuat ulang) data berikut. **Jangan** dipakai di database produksi.

| Akun | Username | Password | Isi |
|---|---|---|---|
| Klien | `klien_demo` | `demo12345` | profil lengkap, target & workout plan & meal plan minggu ini, log 7 hari, 2 notifikasi |
| PT | `pt_demo` | `demo12345` | membimbing `klien_demo`; ada rencana AI (tiruan) yang menunggu review |

Karena akun dibuat ulang tiap skrip dijalankan, **ID (`client_id`, `item_id`, dst.) berubah**. Jangan menulis ID secara tetap di kode atau tes; ambil dari respons.

## 3. Aturan format data (berlaku di semua endpoint)

| Jenis | Format | Contoh |
|---|---|---|
| Tanggal kalender (`birth_date`, `week_start_date`, `log_date`) | string `"YYYY-MM-DD"`, tanpa jam dan zona waktu | `"2026-11-02"` |
| Waktu kejadian (`created_at`, `updated_at`) | ISO 8601 UTC | `"2026-11-05T18:48:00.000Z"` |
| Angka (`height_cm`, `weight_current`, `water_liters`, `calories`, ...) | number | `160.5`, `65` |
| Boolean (`is_completed`, `is_read`) | `true` / `false` | `true` |
| Field opsional yang kosong | `null` | `"gender": null` |
| Error | `{ "message": "..." }` dengan status HTTP yang sesuai | lihat bagian 6 |

`day_of_week`: `mon`..`sun`. `meal_type`: `breakfast`, `lunch`, `dinner`, `snack`.

**Latihan berdurasi:** untuk latihan berkategori `cardio` atau `flexibility`, `sets` selalu `1` dan **`reps` adalah durasi dalam menit** (tampilkan sebagai "20 menit"). Untuk `strength`, `reps` adalah jumlah pengulangan. Field `category` ada di setiap item workout.

## 4. Autentikasi

- Token JWT berlaku **7 hari** (diatur `JWT_EXPIRES_IN`, default `7d`). **Tidak ada refresh token.**
- Payload token hanya `user_id`, `role`, `iat`, `exp`. Tidak ada nama atau data lain.
- Saat token habis atau tidak valid, server membalas **401** `Token tidak valid atau sudah kedaluwarsa.` Pesannya sama untuk token kedaluwarsa maupun palsu, jadi aplikasi cukup memperlakukan **401 apa pun (selain di layar login) sebagai "login ulang"**.
- Simpan token di penyimpanan aman perangkat. Kirim di setiap request: `Authorization: Bearer <token>`.
- Logout hanya menghapus token di sisi aplikasi; server tidak menyimpan sesi.

### `POST /api/auth/login`

```json
// body: { "username": "klien_demo", "password": "demo12345" }
// 200
{
  "message": "Login berhasil.",
  "token": "eyJhbGciOiJIUzI1NiIsInR5c...(dipotong)",
  "user": { "user_id": 4, "name": "Klien Demo", "role": "klien" }
}
```

Login **tidak** memberi tahu apakah profil sudah diisi. Cek dengan `GET /clients/me/profile` (bagian 5).

## 5. Alur klien baru dan contoh respons

### Langkah 1 — cek profil: `GET /api/clients/me/profile`

Belum diisi → **404** (sinyal untuk menampilkan form profil):
```json
{ "message": "Profil belum diisi." }
```

### Langkah 2 — isi profil pertama kali: `POST /api/clients/me/profile`

**Hanya `weight_current` dan `weight_target` yang wajib.** Field lain opsional. Form yang berisi berat, target, dan alergi sudah cukup (diuji):

```json
// body
{ "weight_current": 65, "weight_target": 58, "allergies": "kacang" }
// 201
{ "message": "Profil berhasil dibuat.", "client_id": 1 }
```

| Field | Wajib? | Aturan |
|---|---|---|
| `weight_current`, `weight_target` | **Ya** | angka 20–400 (kg) |
| `allergies` | Tidak | teks, maks 500 karakter. Tulis bebas ("kacang, udang"); dipecah jadi kata kunci untuk memfilter menu |
| `birth_date` | Tidak | `YYYY-MM-DD`, bukan tanggal masa depan |
| `gender` | Tidak | `male` / `female` |
| `height_cm` | Tidak | angka 50–260 |
| `activity_level` | Tidak | `sedentary` / `light` / `moderate` / `active` / `very_active` |

Isi dua kali → **409**. Untuk melengkapi atau mengubah belakangan, pakai `PATCH /clients/me/profile` dengan field yang berubah saja.

> Saran: field opsional sebaiknya tetap dikumpulkan nanti (mis. layar "lengkapi profil"), karena rencana AI lebih akurat dengan usia, gender, tinggi, dan tingkat aktivitas. Tanpa itu AI memakai asumsi umum dan batas kalori minimum yang lebih konservatif.

### `GET /api/clients/me/profile` (setelah terisi lengkap)

```json
{
  "client_id": 1,
  "user_id": 1,
  "assigned_pt_id": null,
  "birth_date": "1999-03-02",
  "gender": "female",
  "height_cm": 160.5,
  "weight_current": 65,
  "weight_target": 58,
  "allergies": "kacang",
  "activity_level": "moderate",
  "status": "active",
  "created_at": "2026-11-05T18:46:23.000Z",
  "updated_at": "2026-11-05T18:46:23.000Z"
}
```

Field yang belum diisi bernilai `null`. `assigned_pt_id` diisi lewat `POST /clients/me/pt` `{ "pt_username": "pt_demo" }`.

### Langkah 3 — workout plan: `GET /api/clients/me/workout-plans/current`

**Belum ada plan → 404** (bukan array kosong), sebagai keadaan kosong yang wajar:
```json
{ "message": "Belum ada workout plan." }
```
Klien tanpa profil juga 404, dengan pesan `Profil klien belum ada.`

Ada plan → 200:
```json
{
  "plan_id": 1,
  "client_id": 1,
  "week_start_date": "2026-11-02",
  "status": "approved",
  "created_at": "2026-11-05T18:46:23.000Z",
  "updated_at": "2026-11-05T18:46:23.000Z",
  "items": [
    { "item_id": 1, "day_of_week": "mon", "sets": 3, "reps": 10, "is_completed": true,
      "exercise_id": 1, "exercise_name": "Push up", "category": "strength", "calories_per_unit": null },
    { "item_id": 3, "day_of_week": "wed", "sets": 1, "reps": 20, "is_completed": false,
      "exercise_id": 11, "exercise_name": "Jalan cepat", "category": "cardio", "calories_per_unit": null }
  ]
}
```
(`reps: 20` pada item `cardio` berarti **20 menit**.)

Catatan: endpoint ini mengembalikan plan dengan **`week_start_date` terbaru**, bukan harus "minggu ini". Tampilkan `week_start_date` dari respons.

Centang latihan: `PATCH /api/workout-plan-items/:itemId` dengan `{ "is_completed": true }` → 200 `{ "message": "Checklist latihan berhasil diupdate." }`. Item milik klien lain → 404.

### Meal plan: `GET /api/clients/me/meal-plans/current`

Pola sama seperti workout (404 bila belum ada). Bentuk item:
```json
{ "item_id": 7, "meal_type": "breakfast", "is_completed": true,
  "food_id": 1, "food_name": "Nasi putih (1 piring, 150 g)",
  "calories": 195, "protein_g": 4, "carbs_g": 42, "fat_g": 0.4 }
```
Centang: `PATCH /api/meal-plan-items/:itemId` `{ "is_completed": true }`.

> Menu saat ini **belum punya informasi hari** (tidak ada `day_of_week` pada item meal), jadi daftar menunya berlaku untuk satu minggu tanpa pembagian hari. Ini keterbatasan skema yang sedang dibahas tim backend.

### Target hari ini: `GET /api/clients/me/targets/current` dan `GET /api/clients/me/daily-logs/today`

```json
// targets/current — belum ada target: 200 dengan body `null`
{ "target_id": 2, "client_id": 2, "week_start_date": "2026-11-02",
  "target_steps": 8000, "target_water_liters": 2, "target_calories": 1800,
  "source": "manual", "created_at": "2026-11-05T18:48:00.000Z" }

// daily-logs/today — belum ada log hari ini: 200 dengan body `null`
{ "log_id": 14, "client_id": 2, "log_date": "2026-11-06", "weight_kg": 64.8,
  "steps": 4300, "water_liters": 0.8, "calories_burned": 172,
  "created_at": "2026-11-05T18:48:00.000Z" }
```

Sinkron pedometer: `PUT /api/clients/me/daily-logs/today` dengan field yang berubah saja, mis. `{ "steps": 5000 }`. **Sync parsial aman**: field yang tidak dikirim tidak menimpa nilai yang sudah ada. Balasannya hanya `{ "message": "Log harian berhasil disinkronkan." }` (tidak mengembalikan log); panggil GET lagi bila perlu. Batas: `steps` 0–200000 (bulat), `water_liters` 0–20, `weight_kg` 20–400.

> "Hari ini" ditentukan oleh jam server database, bukan jam HP.

### Notifikasi: `GET /api/users/me/notifications`

```json
[ { "notification_id": 4, "user_id": 4, "type": "ai_insight",
    "title": "Langkahmu meningkat",
    "message": "Rata-rata langkahmu minggu ini naik dibanding minggu lalu. Pertahankan!",
    "is_read": false, "created_at": "2026-11-05T18:48:00.000Z" } ]
```
`type`: `ai_insight`, `reminder`, `system`. Tandai dibaca: `PATCH /api/notifications/:id/read`.

## 6. Format error

| Status | Kapan | Contoh `message` |
|---|---|---|
| 400 | input tidak valid | `"steps harus antara 0 dan 200000."` |
| 401 | tanpa token / token tidak valid / login salah | `"Token tidak ditemukan. Silakan login."`, `"Token tidak valid atau sudah kedaluwarsa."`, `"Username atau password salah."` |
| 403 | role tidak sesuai, atau (untuk PT) data klien bukan bimbingannya | `"Kamu tidak punya akses ke resource ini."`, `"Klien/analisis ini bukan bimbinganmu."` |
| 404 | data tidak ada, atau bukan milik pengguna | `"Belum ada workout plan."` |
| 409 | bentrok (profil sudah ada, username dipakai) | `"Profil sudah pernah diisi. Gunakan PATCH untuk update."` |
| 500 | error server | `"Terjadi kesalahan pada server."` |

`message` pada kasus normal berupa teks Bahasa Indonesia yang aman ditampilkan. Pengecualian: body JSON yang rusak menghasilkan 400 dengan pesan teknis berbahasa Inggris (mis. `Expected property name or '}' in JSON...`). Itu hanya terjadi bila aplikasi mengirim JSON tidak valid (bug aplikasi), jadi jangan tampilkan `message` mentah ke pengguna untuk 400 yang tidak terduga; pakai pesan umum buatan aplikasi.

## 7. Status data rencana (penting untuk tim Mobile)

Saat ini **belum ada yang membuat workout plan / meal plan secara otomatis** untuk klien sungguhan:

1. Setelah `POST /clients/me/profile`, **tidak ada plan yang dibuat**. Pembuatan rencana AI dipicu lewat endpoint internal (belum ada jadwal otomatis), dan hasilnya menunggu persetujuan PT.
2. Langkah "setelah PT menyetujui, rencana muncul di aplikasi klien" **belum dibuat** (sedang dikerjakan).

Akibatnya klien baru akan terus menerima 404 di `workout-plans/current` dan `meal-plans/current`. **Tangani sebagai keadaan kosong** ("Rencana mingguanmu sedang disiapkan"), dan gunakan akun `klien_demo` untuk membangun layar yang berisi data.

Fitur tombol "+" (klien menambah latihan sendiri) **belum punya endpoint**; sementara simpan secara lokal di aplikasi.
