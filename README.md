<div align="center">
  <a href="#">
    <img src="https://readme-typing-svg.demolab.com?font=Fira+Code&weight=600&size=40&pause=1000&color=B33232&center=true&vCenter=true&width=800&height=100&lines=Seven+Caffee;Aplikasi+Mobile+Karyawan;Staff+Management+System" alt="Typing SVG" />
  </a>

  <p align="center">
    <strong>Aplikasi mobile khusus karyawan Seven Caffee untuk manajemen kehadiran, scanning meja, dan monitoring pesanan real-time, dibangun menggunakan Flutter.</strong>
  </p>

  <p align="center">
    <img src="https://img.shields.io/badge/version-v1.0.0--beta-blue.svg?style=for-the-badge" alt="Version">
    <br>
    <img src="https://img.shields.io/badge/flutter-%2302569B.svg?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
    <img src="https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
    <img src="https://img.shields.io/badge/provider-%23FF9800.svg?style=for-the-badge&logo=dart&logoColor=white" alt="Provider">
    <img src="https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Android">
    <img src="https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white" alt="iOS">
    <img src="https://img.shields.io/badge/license-MIT-green?style=for-the-badge" alt="License">
    <br>
    <img src="https://komarev.com/ghpvc/?username=seven-caffee-staff&label=Kunjungan+Proyek&color=0e75b6&style=flat-square" alt="Views">
  </p>
</div>

<hr>

## 📖 Tentang Proyek

**Seven Caffee Staff Mobile** adalah aplikasi mobile khusus untuk karyawan/staff Seven Caffee yang dirancang untuk meningkatkan efisiensi operasional kafe. Aplikasi ini memberikan solusi terintegrasi untuk **manajemen kehadiran**, **scanning meja kosong**, **denah interaktif**, serta **monitoring pesanan real-time**. Dengan interface yang user-friendly dan integrasi seamless dengan backend Seven Caffee, aplikasi ini membantu staff bekerja lebih efisien dan terorganisir.

Karyawan dapat memanfaatkan fitur-fitur seperti:

- Clock in/out otomatis untuk tracking kehadiran
- Scanning produk untuk meja kosong via QR Code (PCD Scanner)
- Denah meja interaktif untuk visualisasi ruangan
- Monitoring list pesanan dan status real-time
- Notifikasi update pesanan langsung ke staff
- Profil karyawan dan manajemen akun personal

> **📱 Mobile Staff Repository (Flutter)**: Aplikasi mobile untuk karyawan/staff  
> **🌐 Web Repository**: [Seven Caffee Web (Backend Laravel + Frontend Web)](https://github.com/ivan-4k/proyek3-vianos-creative-compound)

---

## 📑 Daftar Isi

- [Tentang Proyek](#-tentang-proyek)
- [Status Proyek](#-status-proyek)
- [Fitur Utama](#-fitur-utama)
- [Teknologi yang Digunakan](#-teknologi-yang-digunakan-tech-stack)
- [Struktur Folder](#-struktur-folder)
- [Persyaratan Sistem](#-persyaratan-sistem)
- [Cara Memulai & Instalasi](#-cara-memulai--instalasi)
- [Konfigurasi API Backend](#-konfigurasi-api-backend)
- [Panduan Penggunaan Dasar](#-panduan-penggunaan-dasar)
- [Pemecahan Masalah (Troubleshooting)](#-pemecahan-masalah-troubleshooting)
- [Roadmap Proyek](#-roadmap-proyek)
- [Tim Pengembang](#-tim-pengembang)
- [Lisensi](#-lisensi)
- [Referensi & Link Penting](#-referensi--link-penting)

---

## 🏷️ Status Proyek

Saat ini proyek mobile staff berada dalam fase **Beta (v1.0.0-beta)**. Fitur-fitur inti untuk manajemen kehadiran, scanning meja, dan monitoring pesanan telah dikembangkan dan dapat digunakan. Beberapa optimasi dan fitur tambahan akan terus dikembangkan (Lihat [Roadmap](#-roadmap-proyek)).

---

## ✨ Fitur Utama

### 👨‍💼 Fitur Karyawan (Staff)

#### Autentikasi & Profil

- **Login dengan Verifikasi**: Sistem autentikasi dengan email & password (khusus staff)
- **Lupa Password**: Fitur reset password via email
- **Reset Password**: Ubah password dengan verifikasi email
- **Profil Karyawan**: Lihat informasi profil, data personal, dan posisi jabatan
- **Manajemen Akun**: Update data profil, ubah password, dan logout

#### Kehadiran (Attendance)

- **Clock In**: Pencatatan waktu masuk kerja dengan timestamp akurat
- **Clock Out**: Pencatatan waktu keluar kerja
- **Riwayat Kehadiran**: Lihat history clock in/out untuk bulan berjalan
- **Status Kehadiran**: Indikator visual apakah staff sedang masuk atau belum
- **Auto-timestamp**: Sistem otomatis merekam waktu dengan akurasi server

#### Scanning & Manajemen Meja

- **QR Code Scanner (PCD)**: Scanning QR code untuk scan meja yang kosong
- **Deteksi Meja Kosong**: Sistem scanning untuk menandai meja yang siap digunakan
- **Input Manual**: Opsi input manual jika scanning tidak berfungsi
- **History Scanning**: Riwayat scanning dengan waktu dan meja yang ditandai

#### Denah Meja Interaktif

- **Visualisasi Layout Kafe**: Denah interaktif menampilkan tata letak meja kafe
- **Status Meja Real-time**: Tampilan status meja (kosong, terisi, reserved, maintenance)
- **Tap Meja**: Klik meja untuk melihat detail dan informasi pelanggan
- **Update Status**: Update status meja dari aplikasi (kosong, sedang makan, dibersihkan)
- **Color Coding**: Warna berbeda untuk status meja yang berbeda (memudahkan identifikasi)

#### Monitoring Pesanan

- **List Pesanan Real-time**: Daftar pesanan yang masuk dengan status update otomatis
- **Detail Pesanan**: Lihat detail lengkap pesanan (menu, jumlah, catatan khusus, meja)
- **Status Progress**: Update status pesanan (pending → preparing → ready → served)
- **Notifikasi Pesanan**: Alert otomatis untuk pesanan baru atau urgent
- **Sorting & Filter**: Filter pesanan berdasarkan status, meja, atau waktu
- **Queue Management**: Visualisasi antrian pesanan untuk kitchen/bar

#### Notifikasi

- **Real-time Alerts**: Notifikasi instan untuk pesanan baru atau penting
- **Push Notifications**: Alert yang masuk bahkan saat aplikasi ditutup
- **Notification History**: Lihat riwayat notifikasi yang telah diterima
- **Notifikasi Sistem**: Informasi penting dari management/admin

---

## 💻 Teknologi yang Digunakan (Tech Stack)

### Framework & Language

- **Flutter**: Framework UI cross-platform (v3.10.7+)
- **Dart**: Bahasa pemrograman untuk Flutter
- **Material Design 3**: Design system modern dan responsive

### State Management & Architecture

- **Provider**: State management yang lightweight dan powerful
- **Pattern**: MVVM-like architecture dengan clean separation of concerns

### Networking & API

- **Dio**: HTTP client untuk komunikasi dengan backend API
- **REST API**: Integrasi dengan Laravel backend Seven Caffee

### Camera & Scanning

- **QR Code Scanner**: Library untuk scanning QR code/barcode
- **Camera Plugin**: Akses kamera device untuk scanning

### Localization & Utilities

- **Intl**: Dukungan untuk internationalization dan localization
- **Cupertino Icons**: Icon set untuk iOS style elements
- **Local Storage**: SharedPreferences untuk caching data lokal

### Development Tools

- **Flutter Analyzer**: Code quality dan linting
- **Flutter DevTools**: Debugging dan profiling tools
- **Hot Reload/Hot Restart**: Fast development cycle

### Target Platforms

- **Android**: Minimum SDK 21+ (Android 5.0+)
- **iOS**: Minimum deployment target iOS 12.0+

---

## 📂 Struktur Folder

Aplikasi mobile mengikuti struktur direktori yang terorganisir dan scalable:

```
proyek3_mobile/
├── android/                    # Konfigurasi & build Android
│   ├── app/
│   │   └── src/               # Source code native Android
│   └── gradle/                # Gradle configuration
│
├── ios/                        # Konfigurasi & build iOS
│   ├── Runner/                # Native iOS project files
│   └── Runner.xcworkspace/    # Xcode workspace
│
├── lib/                        # Source code aplikasi (Dart)
│   ├── main.dart              # Entry point aplikasi
│   │
│   ├── models/                # Data models
│   │   ├── user_model.dart    # User/staff data model
│   │   ├── order_model.dart   # Order & order items
│   │   ├── notification_model.dart  # Notification data
│   │   └── attendance_model.dart    # Attendance/clock in-out
│   │
│   ├── pages/                 # UI screens/pages
│   │   ├── menu/              # Menu & navigation
│   │   ├── profile/           # Staff profile & settings
│   │   ├── notification/      # Notification screens
│   │   └── absensi/           # Attendance & clock in-out
│   │
│   ├── start/                 # Authentication screens
│   │   ├── login.dart         # Login page
│   │   ├── forgot.dart        # Forgot password
│   │   ├── reset.dart         # Reset password
│   │   └── start.dart         # Onboarding/splash screen
│   │
│   ├── widgets/               # Reusable UI components
│   │   ├── app.dart           # Root app widget
│   │   ├── bottom_navbar.dart # Bottom navigation bar
│   │   ├── menu_row.dart      # Menu item row widget
│   │   ├── kategori.dart      # Category widget
│   │   ├── info_card.dart     # Info/card display widget
│   │   └── total_card.dart    # Total/summary card
│   │
│   ├── services/               # Business logic & API calls
│   │   ├── api_service.dart    # HTTP client & API integration
│   │   ├── auth_service.dart   # Authentication logic
│   │   └── camera_service.dart # QR code scanning
│   │
│   ├── providers/                      # Provider state management
│   │   ├── user_provider.dart          # User/staff state
│   │   ├── order_provider.dart         # Order state
│   │   ├── attendance_provider.dart    # Attendance state
│   │   └── notification_provider.dart  # Notifications state
│   │
│   ├── utils/                 # Utility functions & constants
│   │   ├── constants.dart     # App constants & API URLs
│   │   ├── validators.dart    # Input validators
│   │   └── theme.dart         # Theme & styling
│   │
│   └── localization/          # Multi-language support (optional)
│       └── app_localizations.dart
│
├── assets/                    # Static resources
│   ├── images/                # Image assets
│   ├── fonts/                 # Custom fonts
│   └── deco/                  # Decorative assets
│
├── build/                     # Build output (generated)
├── test/                      # Unit & widget tests
├── pubspec.yaml               # Package dependencies & metadata
├── analysis_options.yaml      # Linter rules & analysis config
└── README.md                  # This file
```

---

## ⚙️ Persyaratan Sistem

Pastikan sistem Anda memenuhi spesifikasi minimum berikut untuk development:

### Windows / macOS / Linux

- **Flutter SDK**: `3.10.7` atau lebih tinggi
- **Dart SDK**: `3.10.7` atau lebih tinggi (included dalam Flutter SDK)
- **Git**: Versi terbaru untuk version control
- **Android Studio** (untuk Android development):
  - Android SDK API Level 31+
  - Android Emulator atau physical device
- **Xcode** (untuk iOS development di macOS):
  - Versi 13.0 atau lebih tinggi
  - iOS Deployment Target: 12.0+
  - CocoaPods untuk dependency management

### Hardware Requirements

- **RAM**: Minimum 4 GB (recommended 8 GB)
- **Storage**: Minimal 5 GB free space untuk SDK dan build cache
- **Network**: Internet connection untuk downloading SDK, packages, dan emulator
- **Camera**: Device dengan camera untuk QR code scanning

### Target Devices

- **Android**: API Level 21 (Android 5.0) atau lebih tinggi
- **iOS**: iOS 12.0 atau lebih tinggi

---

## 🚀 Cara Memulai & Instalasi

### 1. Prerequisites

Pastikan Flutter SDK sudah terinstall di sistem Anda:

```bash
flutter --version
```

Jika belum terinstall, ikuti panduan official di: [Flutter Get Started](https://flutter.dev/docs/get-started/install)

### 2. Clone Repository

```bash
git clone https://github.com/ivan-4k/proyek3-mobile.git
cd proyek3-mobile
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Konfigurasi Environment & Backend URL

Edit file `lib/utils/constants.dart` dan atur URL backend API:

```dart
class ApiConstants {
  static const String baseUrl = 'http://YOUR_BACKEND_URL/api';
  // Contoh: static const String baseUrl = 'http://192.168.1.100:8000/api';
}
```

> **Untuk Development Local**: Jika backend Laravel berjalan di localhost:8000, gunakan IP address lokal komputer Anda (bukan localhost) agar emulator/device bisa terhubung.

### 5. Run Aplikasi

#### Untuk Android Emulator:

```bash
flutter run
```

#### Untuk iOS Simulator (macOS):

```bash
flutter run -d iPhone
```

#### Untuk Physical Device:

```bash
flutter run
```

Flutter akan secara otomatis mendeteksi device yang terhubung.

### 6. Troubleshooting Setup

Jika ada error saat instalasi, jalankan:

```bash
flutter clean
flutter pub get
flutter run
```

Untuk melihat info lengkap tentang development environment:

```bash
flutter doctor
```

---

## 🔌 Konfigurasi API Backend

Aplikasi mobile staff berkomunikasi dengan backend Seven Caffee (Laravel). Pastikan backend sudah running sebelum menjalankan aplikasi mobile.

### Backend URL Configuration

Edit `lib/utils/constants.dart`:

```dart
class ApiConstants {
  // Development
  static const String baseUrl = 'http://192.168.x.x:8000/api';

  // Production
  // static const String baseUrl = 'https://yourdomain.com/api';

  // Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String clockInEndpoint = '/staff/clock-in';
  static const String clockOutEndpoint = '/staff/clock-out';
  static const String ordersEndpoint = '/staff/orders';
  static const String tablesEndpoint = '/staff/tables';
  // ... endpoint lainnya
}
```

### API Endpoints yang Digunakan

- `POST /auth/login` - Staff login
- `POST /auth/forgot-password` - Request reset password
- `POST /auth/reset-password` - Reset password dengan token
- `POST /staff/clock-in` - Pencatatan clock in
- `POST /staff/clock-out` - Pencatatan clock out
- `GET /staff/attendance` - Riwayat kehadiran
- `POST /staff/scan-table` - Scanning meja via QR code
- `GET /staff/tables` - Daftar meja & status
- `PUT /staff/tables/{id}` - Update status meja
- `GET /staff/orders` - List pesanan
- `PUT /staff/orders/{id}` - Update status pesanan
- `GET /notifications` - Get staff notifications
- `GET /profile` - Get staff profile
- `POST /profile/update` - Update staff profile

> **Catatan**: Untuk daftar lengkap API endpoints, lihat dokumentasi backend di repository Seven Caffee web.

---

## 📖 Panduan Penggunaan Dasar

### Untuk Karyawan/Staff

1. **Login ke Aplikasi**:
   - Buka aplikasi Seven Caffee Staff
   - Masukkan email karyawan dan password
   - Jika lupa password, klik "Lupa Password" untuk reset

2. **Clock In Saat Masuk Kerja**:
   - Setelah login, klik tombol "Clock In" di halaman utama
   - Sistem akan merekam waktu masuk Anda secara otomatis
   - Status akan berubah menjadi "Masuk Kerja"

3. **Lihat Denah Meja**:
   - Buka menu "Denah Meja" untuk melihat layout interaktif ruangan
   - Lihat status meja (kosong, terisi, atau dalam pembersihan)
   - Tap meja untuk melihat detail atau update statusnya

4. **Scanning Meja Kosong (QR Code)**:
   - Klik menu "Scan Meja"
   - Arahkan kamera ke QR code yang ada di meja
   - Sistem akan menandai meja tersebut sebagai kosong/siap digunakan
   - Atau input manual nomor meja jika scanning gagal

5. **Monitor Pesanan Real-time**:
   - Buka halaman "Pesanan" untuk melihat list pesanan terbaru
   - Lihat detail pesanan (menu, meja, waktu pesan)
   - Update status pesanan saat sedang disiapkan atau sudah siap
   - Perhatikan notifikasi untuk pesanan baru yang masuk

6. **Terima Notifikasi**:
   - Notifikasi akan muncul otomatis untuk pesanan baru atau update penting
   - Buka halaman "Notifikasi" untuk melihat history notifikasi
   - Setiap notifikasi bisa di-tap untuk detail lebih lanjut

7. **Profil & Pengaturan**:
   - Buka "Profil" untuk melihat data personal Anda
   - Update password atau data profil dari sini
   - Logout saat selesai bekerja

8. **Clock Out Saat Pulang**:
   - Sebelum meninggalkan, klik tombol "Clock Out"
   - Sistem akan merekam waktu keluar Anda
   - Status akan berubah menjadi "Sudah Pulang"

---

## 🛠️ Pemecahan Masalah (Troubleshooting)

### 1. Error: `Could not get the Dart SDK`

**Penyebab**: Flutter SDK belum terinstall atau path tidak benar  
**Solusi**:

```bash
flutter clean
flutter pub get
# Pastikan Flutter SDK sudah di-add ke PATH environment variable
```

### 2. Error: `Gradle task assembleDebug failed` (Android)

**Penyebab**: Masalah dengan Android build configuration  
**Solusi**:

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### 3. Error: `Cannot connect to backend API`

**Penyebab**: URL backend salah atau backend tidak running  
**Solusi**:

- Pastikan backend Laravel sudah running: `php artisan serve`
- Gunakan IP address lokal bukan localhost (contoh: 192.168.x.x)
- Check firewall dan pastikan port 8000 (atau port lain) terbuka
- Edit `lib/utils/constants.dart` dengan URL yang benar

### 4. Error: `Camera permission denied`

**Penyebab**: Aplikasi tidak memiliki izin mengakses kamera  
**Solusi**:

- Buka Settings → Apps → Seven Caffee Staff → Permissions
- Aktifkan Camera permission
- Restart aplikasi

### 5. Error: `QR Code Scanner not working`

**Penyebab**: Library scanner error atau kamera tidak kompatibel  
**Solusi**:

```bash
flutter clean
flutter pub get
flutter run
# Jika masih error, gunakan input manual untuk nomor meja
```

### 6. Error: `The application could not be installed on the device`

**Penyebab**: Device storage penuh atau app versi lama masih terinstall  
**Solusi**:

```bash
flutter install --uninstall-only
flutter run
# Atau uninstall manual dari device/emulator kemudian jalankan flutter run
```

---

## 🗺️ Roadmap Proyek

### Fase Saat Ini (v1.0.0 - Staff App)

✅ Fitur-fitur staff telah dikembangkan (Clock in/out, Scanning, Denah, Pesanan, Notifikasi)

### Fase Berikutnya (v2.0+)

#### Staff App Enhancement

- [ ] **Biometric Authentication**: Login dengan fingerprint/face recognition
- [ ] **Offline Mode**: Support untuk mode offline dengan sync otomatis
- [ ] **Performance Metrics**: Dashboard performa staff & KPI tracking
- [ ] **Shift Management**: Manajemen shift dan jadwal kerja
- [ ] **Task Management**: Daftar tugas harian untuk staff
- [ ] **Receipt Printer Integration**: Cetak struk langsung dari aplikasi
- [ ] **Multi-device Support**: Sync data antar device yang berbeda

#### Customer App (Aplikasi Pelanggan - Fase Mendatang)

- [ ] **Customer Mobile App**: Aplikasi terpisah untuk pelanggan/pembeli
- [ ] **Menu Ordering**: Pemesanan menu online
- [ ] **AI Recommendations**: Rekomendasi menu berbasis AI
- [ ] **Loyalty Program**: Program poin dan reward
- [ ] **Social Features**: Share menu & referral program
- [ ] **Payment Integration**: Pembayaran online via e-wallet/kartu kredit

---

## 👥 Tim Pengembang

Proyek ini dikembangkan secara kolaboratif oleh tim kreatif kami. Jika Anda memiliki pertanyaan, saran, atau peluang diskusi, silakan kunjungi profil GitHub kami:

- [Ivan](https://github.com/ivan-4k)
- [Rifky](https://github.com/rifkyprasetya)
- [Tino](https://github.com/TinoNurcahya)
- [Andika](https://github.com/dikarajadirot)

---

## 📝 Lisensi

Aplikasi ini didistribusikan di bawah **Lisensi MIT**. Lihat file `LICENSE` untuk detail lebih lanjut.

---

## 🔗 Referensi & Link Penting

- **Mobile Repository (Staff)**: https://github.com/ivan-4k/proyek3-mobile
- **Backend + Web Repository**: https://github.com/ivan-4k/proyek3-vianos-creative-compound

---

<div align="center">
  <i>Dikembangkan dengan ❤️ untuk Seven Caffee Staff</i>
</div>
