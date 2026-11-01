# HealthMaxxing — REST API Endpoint List

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
| POST | `/api/clients/me/profile` | Isi profil pertama kali (saat data kosong) | `{ birth_date, gender, height_cm, weight_current, weight_target, allergies, activity_level }` | `client_profiles` |
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
| GET | `/api/clients/me/workout-plans/current` | Ambil workout plan minggu ini + daftar latihan | — | `workout_plans`, `workout_plan_items`, `exercise_reference` |
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

## 10. Internal — Trigger AI (backend-only, TIDAK dipanggil langsung dari Mobile/Web)

| Method | Path | Deskripsi | Body Request | Tabel |
|---|---|---|---|---|
| POST | `/api/internal/ai/generate-weekly-plan` | Backend manggil Gemini API, generate plan baru dari histori klien | `{ client_id }` (dipanggil scheduler/cron, bukan user) | `ai_analysis_results`, `workout_plans`, `meal_plans`, `targets` |

> Catatan penting (sesuai requirement keamanan): endpoint kategori 10 ini yang manggil Gemini API. Mobile dan Web **tidak pernah** manggil AI provider secara langsung — semua lewat backend, supaya API key aman dan bisa divalidasi/sanitasi dulu sebelum dan sesudah AI diproses.

---

## Ringkasan alur per fitur

- **Klien buka Home Screen** → app manggil 3 endpoint: `targets/current`, `daily-logs/today`, `notifications` — buat isi progress bar dan insight.
- **Klien centang checklist latihan** → app manggil `PATCH /workout-plan-items/:id`.
- **PT buka dashboard** → web manggil `pt/clients?status=active`, lalu pas klik satu klien manggil `pt/clients/:id/progress` buat render grafik.
- **PT override plan karena klien cedera** → web manggil `PATCH /pt/ai-analysis/:id/override` dengan JSON baru hasil edit manual PT.
