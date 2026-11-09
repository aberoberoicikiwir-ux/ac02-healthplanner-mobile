# HealthMaxxing — REST API Endpoint List

> Contoh respons asli, format data, alur klien baru, dan cara menjalankan backend dari emulator: lihat [`panduan_integrasi_mobile.md`](panduan_integrasi_mobile.md).

Dokumen ini jadi kontrak antara Backend, Mobile (Flutter), dan Web Dashboard (PT).
Base URL: `https://api.healthmaxxing.app` (sesuaikan pas deploy)
Semua response dalam format JSON. Endpoint yang butuh login harus kirim header:
`Authorization: Bearer <JWT_TOKEN>`

---

## 1. Auth (dipakai Mobile & Web)

| Method | Path | Deskripsi | Body Request | Tabel |
|---|---|---|---|---|
| POST | `/api/auth/register` | Daftar akun baru (klien atau PT) | `{ name, email, username, password, role }` | `users` |
| POST | `/api/auth/login` | Login, dapat JWT token | `{ username, password }` | `users` |
| POST | `/api/auth/logout` | Logout (invalidate token/session) | — | — |

---

## 2. Health Profile (Mobile — Klien)

| Method | Path | Deskripsi | Body Request | Tabel |
|---|---|---|---|---|
| GET | `/api/clients/me/profile` | Ambil data profil kesehatan sendiri | — | `client_profiles` |
| POST | `/api/clients/me/profile` | Isi profil pertama kali (saat data kosong). **Wajib hanya `weight_current` dan `weight_target`; field lain opsional** | `{ weight_current*, weight_target*, allergies, birth_date, gender, height_cm, activity_level }` (`*` = wajib) | `client_profiles` |
| PATCH | `/api/clients/me/profile` | Update sebagian data profil | `{ weight_current, allergies, ... }` | `client_profiles` |

---

## 3. Today's Target & Daily Logs (Mobile — Klien)

| Method | Path | Deskripsi | Body Request | Tabel |
|---|---|---|---|---|
| GET | `/api/clients/me/targets/current` | Ambil target minggu ini (steps, air, kalori) | — | `targets` |
| GET | `/api/clients/me/daily-logs/today` | Ambil log aktual hari ini | — | `daily_logs` |
| PUT | `/api/clients/me/daily-logs/today` | Sync/update data harian (steps dari pedometer, air, dll) | `{ steps, water_liters, weight_kg }` | `daily_logs` |
| GET | `/api/clients/me/daily-logs?from=&to=` | Ambil histori log (buat grafik) | — | `daily_logs` |

---

## 4. Workout Plan (Mobile — Klien)

| Method | Path | Deskripsi | Body Request | Tabel |
|---|---|---|---|---|
| GET | `/api/clients/me/workout-plans/current` | Ambil workout plan dengan `week_start_date` terbaru + daftar latihan. 404 bila belum ada | — | `workout_plans`, `workout_plan_items`, `exercise_reference` |
| PATCH | `/api/workout-plan-items/:itemId` | Update checklist "latihan selesai" | `{ is_completed: true }` | `workout_plan_items` |

---

## 5. Meal Plan (Mobile — Klien)

| Method | Path | Deskripsi | Body Request | Tabel |
|---|---|---|---|---|
| GET | `/api/clients/me/meal-plans/current` | Ambil meal plan minggu ini + daftar menu | — | `meal_plans`, `meal_plan_items`, `food_reference` |
| PATCH | `/api/meal-plan-items/:itemId` | Update checklist "makanan dimakan" | `{ is_completed: true }` | `meal_plan_items` |

---

## 6. Notifikasi (Mobile — Klien, bisa juga PT)

| Method | Path | Deskripsi | Body Request | Tabel |
|---|---|---|---|---|
| GET | `/api/users/me/notifications` | Ambil daftar notifikasi/insight AI | — | `notifications` |
| PATCH | `/api/notifications/:id/read` | Tandai notifikasi sudah dibaca | — | `notifications` |

---

## 7. Dashboard PT — Daftar & Detail Klien (Web)

| Method | Path | Deskripsi | Body Request | Tabel |
|---|---|---|---|---|
| GET | `/api/pt/clients?status=active` | Daftar klien aktif milik PT ini | — | `client_profiles`, `users` |
| GET | `/api/pt/clients/:clientId` | Detail profil satu klien | — | `client_profiles` |
| GET | `/api/pt/clients/:clientId/progress?from=&to=` | Data grafik berat badan & langkah harian | — | `daily_logs` |

---

## 8. Dashboard PT — Review Weekly Plan AI (Web)

| Method | Path | Deskripsi | Body Request | Tabel |
|---|---|---|---|---|
| GET | `/api/pt/clients/:clientId/ai-analysis/current` | Ambil hasil analisis AI minggu ini (buat direview) | — | `ai_analysis_results` |
| PATCH | `/api/pt/ai-analysis/:analysisId/approve` | PT setuju rencana AI apa adanya | — | `ai_analysis_results` |
| PATCH | `/api/pt/ai-analysis/:analysisId/override` | PT override manual (misal karena klien cedera) | `{ final_output: {...json...} }` | `ai_analysis_results`, `workout_plans`, `meal_plans` |

---

## 9. Master Data (dipakai internal / dropdown di Mobile & Web)

| Method | Path | Deskripsi | Body Request | Tabel |
|---|---|---|---|---|
| GET | `/api/exercises` | Daftar referensi latihan | — | `exercise_reference` |
| GET | `/api/foods` | Daftar referensi makanan | — | `food_reference` |

---

## 10. Internal — Trigger AI (backend-only, TIDAK dipanggil dari Mobile/Web)

| Method | Path | Deskripsi | Body Request | Tabel |
|---|---|---|---|---|
| POST | `/api/internal/ai/generate-weekly-plan` | Menyusun rencana mingguan lewat AI, memvalidasinya, lalu menyimpannya sebagai `pending` untuk direview PT | `{ client_id, week_start_date? }` | `ai_analysis_results`, `audit_logs`, `notifications` |

**Autentikasi:** header `X-Internal-Key: <INTERNAL_API_KEY dari .env>`, **bukan** JWT pengguna. Kalau `INTERNAL_API_KEY` kosong atau kurang dari 16 karakter, endpoint ini mati (503), bukan terbuka.

**Body:** `client_id` (bilangan bulat, wajib). `week_start_date` (`YYYY-MM-DD`, opsional) harus hari **Senin**, tidak lebih awal dari minggu ini, dan maksimal 8 minggu ke depan. Default: Senin berikutnya (setelah hari ini).

**Balasan:**

| Status | Arti |
|---|---|
| 201 | Rencana baru dibuat, status `pending` |
| 200 | Sudah ada rencana `pending` untuk minggu itu; diperbarui (tidak menggandakan baris) |
| 400 | Body tidak valid |
| 401 | Kunci internal salah atau tidak ada |
| 404 | Klien tidak ditemukan |
| 409 | Klien nonaktif, atau analisis minggu itu sudah `approved`/`overridden` (tidak boleh ditimpa) |
| 422 | Profil klien belum lengkap, atau data master latihan/makanan kosong |
| 502 | AI gagal merespons, atau hasilnya tidak lolos validasi setelah percobaan ulang (`details` berisi alasannya) |
| 503 | `INTERNAL_API_KEY` belum dikonfigurasi |

**Alur:** data klien (anonim) -> prompt -> panggil AI -> parse JSON -> **validasi ketat** -> bila ditolak, coba lagi dengan daftar kesalahan (maks `AI_MAX_ATTEMPTS`) -> simpan `pending` + catat `audit_logs` + notifikasi untuk PT. Rencana **tidak pernah** sampai ke klien sebelum PT menyetujuinya.

**Format rencana** (disimpan di `ai_analysis_results.ai_output`):

```json
{
  "feedback": "Teks ramah untuk klien (20-600 karakter, tanpa tautan/saran medis)",
  "targets": { "steps": 8000, "water_liters": 2.0, "calories": 1700 },
  "workout": [ { "day": "mon", "exercise_id": 1, "sets": 3, "reps": 10 } ],
  "meals":   [ { "day": "mon", "meal_type": "breakfast", "food_id": 1 } ],
  "meta": { "provider": "mock", "model": "mock-v1", "attempts": 1, "generated_at": "...", "warnings": [], "allergy_keywords": [] }
}
```

- `day`: `mon`..`sun`. `meal_type`: `breakfast`, `lunch`, `dinner`, `snack`.
- `exercise_id` dan `food_id` **harus** ada di tabel master (AI tidak boleh mengarang).
- Latihan kategori `strength`: `sets` 1-6, `reps` 1-30. Kategori `cardio`/`flexibility`: `sets` = 1 dan **`reps` = durasi dalam menit** (5-90). Mobile perlu menampilkannya sebagai "menit" (endpoint workout sudah mengembalikan `category`).
- Setiap hari wajib ada `breakfast`, `lunch`, `dinner`; latihan maksimal 6 hari per minggu.
- `meta.warnings`: masalah kualitas yang tidak menolak rencana (mis. kalori menu menyimpang >40% dari target); PT yang menilai.
- Sampai approve/override diterapkan ke tabel rencana (belum dibuat), klien belum melihat rencana ini di aplikasi.

> Mobile dan Web **tidak pernah** memanggil penyedia AI langsung. Semua lewat backend, supaya API key aman dan input/output bisa disaring.

---

## Ringkasan alur per fitur

- **Klien buka Home Screen** → app manggil 3 endpoint: `targets/current`, `daily-logs/today`, `notifications` — buat isi progress bar dan insight.
- **Klien centang checklist latihan** → app manggil `PATCH /workout-plan-items/:id`.
- **PT buka dashboard** → web manggil `pt/clients?status=active`, lalu pas klik satu klien manggil `pt/clients/:id/progress` buat render grafik.
- **PT override plan karena klien cedera** → web manggil `PATCH /pt/ai-analysis/:id/override` dengan JSON baru hasil edit manual PT.
