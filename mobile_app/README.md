# AC-02 Health & Workout Planner — Mobile App (Flutter)

Bagian mobile app dari capstone AC-02 Personalized Health & Workout Planner, tim A25-CS034.

## Cara Setup Project

1. Pastikan Flutter SDK sudah terinstall (`flutter --version` untuk cek).
2. Clone repository:

git clone https://github.com/aberoberoicikiwir-ux/ac02-healthplanner-mobile.git
cd ac02-healthplanner-mobile/mobile_app

3. Install dependencies:

flutter pub get


## Cara Menjalankan Aplikasi

1. Nyalakan emulator Android (atau hubungkan device fisik).
2. Jalankan:

flutter run


## Fitur yang Sudah Diimplementasikan

- Login screen (autentikasi sederhana)
- Health Profile check & form input (berat, target, alergi)
- Bottom Navigation Bar 4 tab: Today's Target, Progres, Insight AI, Profil
- Workout Plan (katalog 3 latihan) dengan navigasi ke halaman detail (`Navigator.push`)
- Halaman detail latihan (StatefulWidget) dengan tombol interaktif "Tandai Selesai" yang mendemonstrasikan konsep Event & State
- Meal Plan (daftar menu makanan)

## Catatan tentang Database (MySQL)

Project pada tahap ini masih murni frontend (Flutter), belum terhubung ke backend/database. Integrasi MySQL, REST API, dan AI (Gemini) akan ditambahkan pada fase backend sesuai roadmap capstone di README.md root repository.

Save (Ctrl+S), lalu di terminal (posisi bebas, root atau mobile_app, git tetap ketemu):

git add .
git commit -m "Add Task 5: workout detail screen with event & state, update mobile_app README"
git push