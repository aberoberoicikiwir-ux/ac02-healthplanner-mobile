# AC-02 Health & Workout Planner — Mobile App (Flutter)

Bagian mobile app dari capstone AC-02 Personalized Health & Workout Planner, tim A25-CS034 (Kelompok 8).

## Desain Figma

[Healthmaxxing - Health care app](https://www.figma.com/design/kWUcsjUwTxv1BS9xlygtWZ/Healthmaxxing---Health-care-app?node-id=1-131&p=f&t=PybvtPKitXQORiRx-0)

## Cara Setup Project

1. Pastikan Flutter SDK sudah terpasang (`flutter --version`).
2. Clone repository:
   ```
   git clone https://github.com/aberoberoicikiwir-ux/ac02-healthplanner-mobile.git
   cd ac02-healthplanner-mobile/mobile_app
   ```
3. Pasang dependency:
   ```
   flutter pub get
   ```
4. (Jika `app_database.g.dart` belum ada) generate kode Drift:
   ```
   dart run build_runner build
   ```

## Cara Menjalankan Aplikasi

1. Nyalakan emulator Android (atau hubungkan device fisik).
2. Dari folder `mobile_app`, jalankan:
   ```
   flutter run
   ```
3. Login dengan username dan password apa saja (autentikasi masih tiruan).

## Fitur yang Sudah Diimplementasikan

- Login dengan status login yang tersimpan aman (tidak perlu login ulang saat app dibuka lagi)
- Health Profile check & form input (berat, target, alergi)
- Bottom Navigation 4 tab: Today's Target, Progres, Insight AI, Profil
- Workout Plan: tambah latihan (tombol +), tandai selesai, hapus latihan buatan sendiri (geser ke kiri), sinkronisasi, dan tarik-ke-bawah untuk refresh
- Penanda perubahan yang belum tersinkron (ikon awan) dan tombol Sinkronkan
- Meal Plan, Profil (pengaturan akun, logout)

## Task 9: Local Storage & Data Persistence

Data dipisahkan ke penyimpanan yang sesuai dengan jenisnya:

| Jenis data | Penyimpanan | Isi di aplikasi ini | File |
|---|---|---|---|
| Data terstruktur | **Drift** (SQLite) | Daftar latihan, status selesai, status sinkron | `lib/data/local/app_database.dart` |
| Pengaturan (kecil, tidak sensitif) | **shared_preferences** | Switch notifikasi, simulasi offline | `lib/data/local/settings_service.dart` |
| Rahasia | **flutter_secure_storage** | Access token dan username | `lib/data/local/secure_storage_service.dart` |

Token **tidak** disimpan di shared_preferences.

### Penerapan di Drift

- **Offline-first**: UI selalu membaca dari database lokal, bukan langsung dari API. Setiap perubahan ditulis ke database lebih dulu, lalu dikirim ke server saat online.
- **Penanda cache**: kolom `lastFetched` (UTC milliseconds) mencatat kapan data terakhir diambil dari server.
- **Penanda sinkronisasi**: kolom `synced` (`false` = ada perubahan lokal yang belum dikirim) dan `updatedAt` (UTC milliseconds).
- **Stream reaktif**: `watchAllWorkouts()` memakai `.watch()`, sehingga UI otomatis diperbarui saat database berubah.
- **Database transaction**: `upsertServerWorkouts()` dan `markSynced()` membungkus penulisan banyak baris dalam satu `transaction` (atomic).
- **Migrasi schema**: `schemaVersion` naik dari 1 ke 2. `onUpgrade` menambah kolom `updatedAt` dan `synced` tanpa menghapus data pengguna.
- **CRUD reaktif**: tambah (tombol +), ubah (Tandai Selesai), hapus (geser ke kiri, hanya latihan buatan sendiri).

### Alur data

```
UI (Consumer) <-- WorkoutProvider <-- .watch() stream <-- Drift (sumber kebenaran)
                                                              ^
              tulis lokal dulu (synced = false)               |
                                                              |
              Sinkronkan: kirim yang belum synced --> FakeApiService (server)
                          lalu tandai synced = true (transaction)
                          lalu ambil data terbaru dari server (transaction)
```

### Kesesuaian dengan materi Pertemuan 9

| Materi (slide) | Implementasi |
|---|---|
| Memilih penyimpanan menurut jenis data (6) | Drift, shared_preferences, flutter_secure_storage |
| shared_preferences untuk pengaturan (8-9, 12) | Notifikasi dan simulasi offline; token tidak di sini |
| flutter_secure_storage, hapus saat logout (10-11) | Token dan username terenkripsi, dihapus saat logout |
| Schema Drift dengan `synced` dan `updated_at` UTC millis (18) | `workout_entries` |
| Query reaktif `.watch()` (19) | `watchAllWorkouts()` |
| Transaksi atomik dan `markSynced` (21-22) | `upsertServerWorkouts()`, `markSynced()` |
| Migrasi schema (23) | `schemaVersion` 1 ke 2 |
| Offline-first (24-26) | Tulis lokal dulu, sinkron lewat tombol Sinkronkan |
| CRUD reaktif (29) | Tambah, ubah, hapus |

### Global State (Provider)

`WorkoutProvider` membaca dari stream Drift. Menekan "Tandai Selesai" di halaman detail langsung terlihat di layar Workout Plan (centang) dan Today's Target ("X / Y latihan"). `AuthProvider` menyimpan status login dan `SettingsProvider` menyimpan pengaturan.

## Struktur Folder

```
lib/
├── data/
│   ├── local/          # Drift, shared_preferences, secure storage
│   ├── remote/         # Sumber data dari server (saat ini API tiruan)
│   └── repositories/   # Penghubung API dan database
├── models/             # Model data
├── providers/          # State management (Provider)
├── screens/            # Tampilan (UI)
└── main.dart
```

## Catatan tentang Backend

Backend (Express.js + MySQL + AI) dikerjakan terpisah di folder `backend/` dan belum selesai. Untuk sementara, data berasal dari `FakeApiService` yang meniru perilaku API asli (ada jeda jaringan, bisa gagal). Saat backend siap, cukup mengganti isi `lib/data/remote/fake_api_service.dart` dengan pemanggilan HTTP; database, repository, provider, dan tampilan tidak perlu diubah.

Untuk mendemonstrasikan mode offline, nyalakan **Simulasi offline (demo)** di tab Profil, lalu tarik layar Workout Plan ke bawah. Pesan gagal sinkron muncul, tetapi data tetap tampil dari database lokal.

## Tampilan Aplikasi (Hasil Slicing)

| Login | Today's Target | Workout Plan |
|---|---|---|
| ![Login](screenshots/01_login.png) | ![Target](screenshots/02_target.png) | ![Workout Plan](screenshots/03_workout_plan.png) |

| Detail Latihan | Mode Offline | Profil |
|---|---|---|
| ![Detail](screenshots/04_detail_push_up.png) | ![Offline](screenshots/05_workout_plan_offline.png) | ![Profil](screenshots/06_profil.png) |

### Sinkronisasi dan CRUD

| Tambah latihan (belum tersinkron) | Setelah Sinkronkan | Offline dengan perubahan tertunda |
|---|---|---|
| ![Tambah](screenshots/07_tambah_belum_sinkron.png) | ![Sinkron](screenshots/08_setelah_sinkron.png) | ![Tertunda](screenshots/09_offline_perubahan_tertunda.png) |
