<div align="center">
  <a href="#">
    <img src="https://readme-typing-svg.demolab.com?font=Fira+Code&weight=600&size=40&pause=1000&color=C67C4E&center=true&vCenter=true&width=800&height=100&lines=Seven+Caffee;Aplikasi+Mobile+Karyawan;Staff+Management+System" alt="Typing SVG" />
  </a>

  <p align="center">
    <strong>Aplikasi mobile khusus karyawan Seven Caffee — manajemen kehadiran, monitoring pesanan, scan QR meja, dan sinkronisasi real-time dengan backend Laravel.</strong>
  </p>

  <p align="center">
    <img src="https://img.shields.io/badge/version-v1.0.0-brightgreen.svg?style=for-the-badge" alt="Version">
    <br>
    <img src="https://img.shields.io/badge/flutter-%2302569B.svg?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
    <img src="https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
    <img src="https://img.shields.io/badge/provider-%23FF9800.svg?style=for-the-badge&logo=dart&logoColor=white" alt="Provider">
    <img src="https://img.shields.io/badge/Laravel_Sanctum-FF2D20?style=for-the-badge&logo=laravel&logoColor=white" alt="Sanctum">
    <img src="https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Android">
    <img src="https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white" alt="iOS">
    <br>
    <img src="https://img.shields.io/badge/status-production--ready-success?style=flat-square" alt="Status">
    <img src="https://img.shields.io/badge/license-MIT-green?style=flat-square" alt="License">
  </p>
</div>

<hr>

## 📖 Tentang Proyek

**Seven Caffee Staff Mobile** adalah aplikasi Flutter yang dirancang khusus untuk karyawan/staff Seven Caffee. Aplikasi ini terhubung penuh ke backend Laravel melalui REST API dengan autentikasi **Laravel Sanctum (Bearer Token)**, mencakup manajemen kehadiran, monitoring & pemrosesan pesanan, scan QR meja, dan notifikasi real-time.

> **📱 Mobile Staff Repository (Flutter)**: Aplikasi mobile untuk karyawan/staff
> **🌐 Web Repository**: [Seven Caffee Web (Backend Laravel + Frontend Web)](https://github.com/ivan-4k/proyek3-vianos-creative-compound)

---

## 📑 Daftar Isi

- [Tentang Proyek](#-tentang-proyek)
- [Status Proyek](#%EF%B8%8F-status-proyek)
- [Arsitektur & Alur Data](#-arsitektur--alur-data)
- [Fitur Utama](#-fitur-utama)
- [Teknologi yang Digunakan](#-teknologi-yang-digunakan)
- [Struktur Folder](#-struktur-folder)
- [Persyaratan Sistem](#%EF%B8%8F-persyaratan-sistem)
- [Cara Memulai & Instalasi](#-cara-memulai--instalasi)
- [Konfigurasi API Backend](#-konfigurasi-api-backend)
- [API Endpoints yang Digunakan](#-api-endpoints-yang-digunakan)
- [Panduan Penggunaan](#-panduan-penggunaan)
- [Pemecahan Masalah](#%EF%B8%8F-pemecahan-masalah-troubleshooting)
- [Upgrade Kamera QR Scanner](#-upgrade-kamera-qr-scanner)
- [Roadmap Proyek](#%EF%B8%8F-roadmap-proyek)
- [Tim Pengembang](#-tim-pengembang)
- [Lisensi](#-lisensi)

---

## 🏷️ Status Proyek

| Komponen | Status |
|---|---|
| Autentikasi (Login/Logout/Token) | ✅ Production Ready |
| Absensi (Clock In/Out) | ✅ Production Ready |
| Monitoring Pesanan | ✅ Production Ready |
| Notifikasi | ✅ Production Ready |
| Profil Staff | ✅ Production Ready |
| Manajemen Meja (Scan & Daftar) | ✅ Ready |
| Kamera QR Scanner | 🔧 Siap Upgrade (`mobile_scanner`) |
| Forgot / Reset Password | ✅ Production Ready |

---

## 🏗 Arsitektur & Alur Data

```
┌─────────────────────────────────────────────────────────┐
│                   Flutter App (Mobile)                   │
│                                                          │
│  ┌──────────┐    ┌──────────────┐     ┌─────────────────┐ │
│  │   Pages  │──▶│  Providers    │──▶│    Services      │  │
│  │  (UI)    │◀──│ (State Mgmt)  │◀──│  (API Calls)     │  │
│  └──────────┘    └──────────────┘     └────────┬────────┘  │
│                                             │             │
│                 ┌───────────────────────────▼──────────┐ │
│                 │         ApiService (HTTP Client)      │ │
│                 │  GET / POST / PUT / DELETE            │ │
│                 │  + Bearer Token (Sanctum)             │ │
│                 └───────────────────────────┬──────────┘ │
└─────────────────────────────────────────────┼───────────┘
                                              │ REST API
                              ┌───────────────▼───────────┐
                              │   Laravel Backend         │
                              │   + Sanctum Auth          │
                              │   + MySQL Database        │
                              └───────────────────────────┘
```

**Alur Autentikasi:**
1. Staff login → `POST /api/auth/login`
2. Backend mengembalikan Bearer Token
3. Token disimpan di `SharedPreferences`
4. Setiap request berikutnya menyertakan header `Authorization: Bearer {token}`
5. Saat logout → `POST /api/auth/logout` → token dihapus dari lokal

---

## ✨ Fitur Utama

### 🔐 Autentikasi & Profil

| Fitur | Endpoint |
|---|---|
| Login dengan email & password | `POST /auth/login` |
| Auto-login jika token masih valid | SharedPreferences check |
| Logout (invalidate token server) | `POST /auth/logout` |
| Lupa password (kirim link via email) | `POST /auth/forgot-password` |
| Reset password dengan token | `POST /auth/reset-password` |
| Lihat profil staff | `GET /auth/me` |
| Update nama & nomor HP | `PUT /profile/update` |
| Ganti password | `POST /auth/change-password` |

### 🕐 Kehadiran (Attendance)

| Fitur | Keterangan |
|---|---|
| Clock In | Rekam waktu masuk, update status real-time |
| Clock Out | Rekam waktu keluar dengan konfirmasi dialog |
| Today Status | Fetch status hari ini saat halaman dibuka |
| Riwayat Kehadiran | Filter by tanggal, tampil di list |
| Timer live | Countdown jam kerja berjalan |
| Status badge | "Belum Clock In / Sedang Bekerja / Selesai Bekerja" |

### 📋 Monitoring Pesanan (Orders)

| Fitur | Keterangan |
|---|---|
| Daftar pesanan dari API | Paginated, infinite scroll |
| Tab filter status | Semua / Pending / Proses / Siap / Selesai |
| Status badge berwarna | Warna berbeda per status pesanan |
| Queue number badge | Tampil `#A-001` jika ada |
| Tombol ubah status | Proses → Siap → Selesai langsung dari card |
| Pull-to-refresh | Swipe down untuk refresh data |
| Detail pesanan | Nama pelanggan, meja, items, total harga |

### 🔔 Notifikasi

| Fitur | Keterangan |
|---|---|
| Fetch notifikasi dari API | Load saat halaman dibuka |
| Pull-to-refresh | Refresh daftar notifikasi |
| Unread count badge | Tampil di tombol "Tandai Semua Dibaca" |
| Tap = mark as read | Card unread berwarna berbeda (orange border) |
| Mark all as read | Satu tombol untuk semua |
| Delete notifikasi | Tombol hapus per item |
| Auto grouping | Today / Yesterday / tanggal spesifik |

### 👤 Profil Staff

| Fitur | Keterangan |
|---|---|
| Data dari API + cache lokal | Tampil cepat dari cache, refresh dari server |
| Role badge | STAFF / ADMIN dari data API |
| Edit nama | Update ke server via API |
| Edit nomor HP | Update ke server via API |
| Ganti password | Dialog dengan 3 field + error handling |
| Logout via API | Token diinvalidasi di server |
| Pull-to-refresh | Refresh profil dari API |

### 📷 Manajemen Meja (Scan & Denah)

| Fitur | Keterangan |
|---|---|
| Dual-Mode View | Tab toggle antara "Scan QR" dan "Daftar Meja" |
| Daftar Meja (Grid) | Tampilan seluruh meja beserta status warna (Hijau/Oranye/Biru/Merah) |
| Tap to Edit | Tap meja dari grid untuk ubah status secara langsung (tanpa scan) |
| Animated pulse area | Area scanner dengan glow animation untuk mode Scan |
| Manual input QR | Input kode QR jika tanpa kamera (fallback) |
| Fetch info meja | `POST /staff/scan-table` atau `GET /staff/tables` |
| Ubah status meja | Kosong / Terisi / Reservasi / Maintenance langsung dari aplikasi |

---

## 💻 Teknologi yang Digunakan

| Teknologi | Versi | Fungsi |
|---|---|---|
| **Flutter** | SDK ^3.10.7 | Framework UI cross-platform |
| **Dart** | ^3.10.7 | Bahasa pemrograman |
| **provider** | ^6.1.2 | State management |
| **http** | ^1.2.2 | HTTP client untuk REST API |
| **shared_preferences** | ^2.3.3 | Penyimpanan token & cache lokal |
| **intl** | ^0.20.2 | Format tanggal & waktu |
| **cupertino_icons** | ^1.0.8 | Icon set iOS style |
| **flutter_launcher_icons** | ^0.14.4 | Custom app icon generator |
| **Laravel Sanctum** | - | Autentikasi Bearer Token di backend |

### Font
- **Sora** (Thin 100 — ExtraBold 800) — tersedia di `assets/fonts/`

---

## 📂 Struktur Folder

```
proyek3_mobile/
├── lib/
│   ├── main.dart                        # Entry point aplikasi
│   │
│   ├── config/
│   │   ├── app_config.dart              # ⚙️ Base URL API (edit di sini!)
│   │   └── api_endpoints.dart           # Rute API terpusat (tidak ada hardcode)
│   │
│   ├── constants/                       # Design tokens
│   │   ├── app_colors.dart              # Warna utama, text, status
│   │   ├── app_text_styles.dart         # Tipografi font
│   │   └── app_dimensions.dart          # Padding, margin, ukuran standar
│   │
│   ├── models/                          # Data models dengan fromJson
│   │   ├── user_model.dart              # Staff data (id, name, email, phone, role)
│   │   ├── order_model.dart             # OrderModel + MenuItemModel
│   │   ├── notification_model.dart      # NotificationModel + auto grouping
│   │   └── attendance_model.dart        # AttendanceModel (clock in/out)
│   │
│   ├── services/                        # Layer API calls
│   │   ├── api_service.dart             # HTTP Client terpusat (GET/POST/PUT/DELETE)
│   │   ├── auth_service.dart            # Login, Logout, Me, ChangePassword
│   │   ├── storage_service.dart         # Token & user info di SharedPreferences
│   │   ├── attendance_service.dart      # Clock In, Clock Out, Today, History
│   │   ├── order_service.dart           # Get Orders, Detail, Update Status
│   │   ├── notification_service.dart    # Get, Mark Read, Mark All, Delete
│   │   └── profile_service.dart         # Update Profile, Forgot/Reset Password, QR Scan
│   │
│   ├── providers/                       # State Management (Global)
│   │   ├── auth_provider.dart           # Mengatur logic login & user session
│   │   ├── attendance_provider.dart     # Mengatur clock in, clock out, histori
│   │   ├── notification_provider.dart   # Mengatur daftar notifikasi & baca
│   │   ├── order_provider.dart          # Mengatur pesanan dan statusnya
│   │   └── profile_provider.dart        # Mengatur profil staff & cache lokal
│   │
│   ├── pages/
│   │   ├── absensi/
│   │   │   └── absensi.dart             # Beranda, Clock In/Out + Riwayat
│   │   ├── menu/
│   │   │   ├── order_page.dart          # Daftar pesanan + tab filter + ubah status
│   │   │   └── menu_page.dart           # Detail pesanan satu order
│   │   ├── notification/
│   │   │   └── notification_page.dart   # Notifikasi + mark read
│   │   ├── profile/
│   │   │   └── profile_screen.dart      # Profil + ganti password
│   │   └── scan/
│   │       └── scan_page.dart           # Manajemen Meja: Scan QR & Daftar Grid + ubah status
│   │
│   ├── start/                           # Auth screens
│   │   ├── login.dart                   # Login + auto-login
│   │   ├── forgot.dart                  # Forgot password
│   │   ├── reset.dart                   # Reset password dengan token
│   │   └── start.dart                   # Splash screen
│   │
│   └── widgets/
│       ├── app.dart                     # Root widget + MultiProvider + Routes
│       ├── bottom_navbar.dart           # Bottom navigation bar
│       ├── menu_row.dart
│       ├── kategori.dart
│       ├── info_card.dart
│       ├── total_card.dart
│       └── shared/                      # Widget yang dipakai berulang
│           ├── loading_widget.dart
│           ├── error_widget.dart
│           └── empty_state_widget.dart
│
├── assets/
│   ├── images/splash_bg.png
│   ├── deco/banner.png
│   ├── fonts/                           # Sora font family (100–800)
│   └── icon.png
│
├── pubspec.yaml
├── analysis_options.yaml
├── docs/
│   ├── API_ENDPOINTS.md                 # Dokumentasi lengkap semua endpoint
│   └── SETUP_DEVELOPMENT.md             # Panduan setup development
└── README.md
```

---

## ⚙️ Persyaratan Sistem

| Item | Minimum |
|---|---|
| Flutter SDK | 3.10.7+ |
| Dart SDK | 3.10.7+ (termasuk dalam Flutter) |
| Android | API Level 21+ (Android 5.0+) |
| iOS | iOS 12.0+ |
| RAM Dev Machine | 4 GB (rekomendasi 8 GB) |
| Storage | 5 GB free (SDK + build cache) |
| Backend | Laravel + Sanctum running & accessible |

---

## 🚀 Cara Memulai & Instalasi

### 1. Clone Repository

```bash
git clone https://github.com/ivan-4k/proyek3-mobile.git
cd proyek3-mobile
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Konfigurasi Base URL API

Edit file **`lib/config/app_config.dart`**:

```dart
class AppConfig {
  // Untuk Android Emulator (AVD):
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Untuk device fisik (ganti dengan IP LAN komputer kamu):
  // static const String baseUrl = 'http://192.168.1.xxx:8000/api';

  // Production:
  // static const String baseUrl = 'https://yourdomain.com/api';
}
```

> ⚠️ **Penting**: Jangan gunakan `localhost` atau `127.0.0.1` karena emulator/device tidak bisa menjangkaunya. Gunakan IP LAN lokal komputer kamu.

### 4. Jalankan Backend Laravel

Pastikan backend sudah berjalan sebelum menjalankan aplikasi:

```bash
# Di folder backend Laravel
php artisan serve --host=0.0.0.0 --port=8080

# Pastikan juga CORS sudah dikonfigurasi untuk menerima request dari device/emulator
```

### 5. Jalankan Aplikasi

```bash
# Otomatis deteksi device/emulator yang tersedia
flutter run

# Atau pilih device spesifik
flutter run -d <device-id>

# Cek device yang tersedia
flutter devices
```

### 6. Build APK (Opsional)

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release
```

---

## 🔌 Konfigurasi API Backend

### Autentikasi

Semua request (kecuali login, forgot password, dan reset password) memerlukan header:

```http
Authorization: Bearer {access_token}
Content-Type: application/json
Accept: application/json
```

Token otomatis diambil dari `SharedPreferences` oleh `ApiService` dan disertakan di setiap request.

### Format Response Standar

```json
{
  "success": true,
  "message": "Deskripsi operasi",
  "data": { }
}
```

```json
{
  "success": false,
  "message": "Pesan error",
  "errors": { }
}
```

---

## 📡 API Endpoints yang Digunakan

### Authentication
| Method | Endpoint | Fungsi |
|---|---|---|
| POST | `/auth/login` | Login staff |
| POST | `/auth/logout` | Logout + invalidate token |
| GET | `/auth/me` | Ambil data user aktif |
| POST | `/auth/forgot-password` | Kirim link reset ke email |
| POST | `/auth/reset-password` | Reset password dengan token |
| POST | `/auth/change-password` | Ganti password (login required) |

### Profile
| Method | Endpoint | Fungsi |
|---|---|---|
| PUT | `/profile/update` | Update nama & nomor HP |

### Attendance
| Method | Endpoint | Fungsi |
|---|---|---|
| POST | `/attendance/clock-in` | Clock in |
| POST | `/attendance/clock-out` | Clock out |
| GET | `/attendance/today` | Status absensi hari ini |
| GET | `/attendance/history` | Riwayat absensi |

### Orders
| Method | Endpoint | Fungsi |
|---|---|---|
| GET | `/orders` | Daftar pesanan (paginated, filter status) |
| GET | `/orders/{id}` | Detail pesanan |
| PUT | `/orders/{id}/status` | Update status pesanan |

### Notifications
| Method | Endpoint | Fungsi |
|---|---|---|
| GET | `/notifications` | Daftar notifikasi |
| POST | `/notifications/{id}/read` | Mark as read |
| POST | `/notifications/read-all` | Mark semua as read |
| DELETE | `/notifications/{id}` | Hapus notifikasi |
| GET | `/notifications/unread-count` | Jumlah notif belum dibaca |

### Tables & QR
| Method | Endpoint | Fungsi |
|---|---|---|
| POST | `/staff/scan-table` | Scan QR meja |
| GET | `/staff/tables` | Daftar semua meja |
| PUT | `/staff/tables/{id}` | Update status meja |

> 📄 Untuk dokumentasi lengkap dengan contoh request/response, lihat file [`API_ENDPOINTS.md`](./docs/API_ENDPOINTS.md)

---

## 📖 Panduan Penggunaan

### Alur Kerja Staff Harian

```
1. Buka Aplikasi
   └── Auto-login jika token masih valid
       └── Jika tidak ada token → halaman Login

2. Login
   └── Masukkan email & password staff
       ├── Sukses → halaman Absensi (Home)
       └── Gagal → tampil pesan error

3. Clock In (awal shift)
   └── Tap tombol "Clock In"
       └── Sistem merekam waktu + update status badge

4. Monitor Pesanan (selama shift)
   └── Buka tab "Order Pelanggan"
       ├── Filter: Semua / Pending / Proses / Siap / Selesai
       └── Ubah status pesanan dari card langsung

5. Manajemen Meja (Jika ada meja baru terisi/kosong)
   └── Buka tab "Meja"
       ├── Mode Daftar: Lihat denah kotak, tap meja, ubah status
       └── Mode Scan: Arahkan kamera ke QR / input kode meja manual

6. Cek Notifikasi
   └── Buka tab "Notifikasi"
       ├── Tap untuk mark as read
       └── "Tandai Semua Dibaca" untuk bulk action

7. Clock Out (akhir shift)
   └── Tap "Clock Out" → konfirmasi dialog
       └── Sistem merekam waktu keluar

8. Logout
   └── Profile → Logout
       └── Token diinvalidasi di server + lokal dihapus
```

---

## 🛠️ Pemecahan Masalah (Troubleshooting)

### 1. Error: `Cannot connect to API` / Timeout

```
Penyebab: IP atau URL backend salah, backend belum running
```

**Solusi:**
- Pastikan backend berjalan: `php artisan serve`
- Edit `lib/config/app_config.dart` dengan IP yang benar
- Emulator Android: gunakan `10.0.2.2` bukan `localhost`
- Device fisik: gunakan IP LAN komputer (`192.168.x.x`)
- Pastikan port 8000 tidak diblokir firewall

### 2. Error: `401 Unauthenticated`

```
Penyebab: Token expired atau tidak valid
```

**Solusi:**
- Logout dari aplikasi dan login ulang
- Atau hapus data aplikasi dari Settings device → buka ulang aplikasi

### 3. Error saat `flutter pub get`

```bash
flutter clean
flutter pub cache repair
flutter pub get
```

### 4. Error: `Gradle task assembleDebug failed`

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### 5. Error: `Could not find package "http"`

```bash
flutter pub get
# Pastikan pubspec.yaml sudah punya:
# http: ^1.2.2
# shared_preferences: ^2.3.3
```

### 6. Aplikasi crash saat buka halaman

Jalankan di debug mode dan cek console:
```bash
flutter run --debug
# Lihat output flutter logs untuk pesan error
```

---

## 📷 Upgrade Kamera QR Scanner

Saat ini halaman Scan menggunakan **manual input** QR code. Untuk mengaktifkan kamera scanner sungguhan:

### Langkah Upgrade

**1. Tambahkan package:**
```bash
flutter pub add mobile_scanner
```

**2. Tambahkan permission di `android/app/src/main/AndroidManifest.xml`:**
```xml
<uses-permission android:name="android.permission.CAMERA" />
```

**3. Tambahkan permission di `ios/Runner/Info.plist`:**
```xml
<key>NSCameraUsageDescription</key>
<string>Dibutuhkan untuk scan QR code meja</string>
```

**4. Di `scan_page.dart`**, replace area scanner dengan:
```dart
import 'package:mobile_scanner/mobile_scanner.dart';

// Ganti widget animasi dengan:
MobileScanner(
  onDetect: (capture) {
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue != null) {
      _scanQrCode(barcode!.rawValue!);
    }
  },
)
```

---

## 🗺️ Roadmap Proyek

### ✅ v1.0.0 — Selesai

- [x] Autentikasi Sanctum (Login, Logout, Auto-login)
- [x] Absensi real-time (Clock In/Out + History)
- [x] Monitoring Pesanan dengan filter tab & update status
- [x] Notifikasi (mark read, delete, mark all)
- [x] Profil staff + ganti password
- [x] Forgot & Reset Password via email
- [x] Manajemen Meja (Scan QR & Daftar Denah/Grid) + update status meja
- [x] State management dengan Provider
- [x] Token persistence (SharedPreferences)
- [x] Error handling & loading state di semua halaman

### 🔧 v1.1.0 — Planned

- [ ] Aktivasi kamera QR scanner (`mobile_scanner`)
- [ ] Push notifications (FCM)
- [ ] Denah meja interaktif (visual floor plan 2D)
- [ ] Offline mode + background sync
- [ ] Biometric login (fingerprint/face)

### 🚀 v2.0.0 — Future

- [ ] Dashboard performa staff & KPI
- [ ] Manajemen shift & jadwal kerja
- [ ] Integrasi printer struk
- [ ] Customer mobile app (aplikasi terpisah)

---

## 👥 Tim Pengembang

Proyek ini dikembangkan secara kolaboratif oleh:

| Nama | GitHub |
|---|---|
| Ivan | [@ivan-4k](https://github.com/ivan-4k) |
| Rifky | [@rifkyprasetya](https://github.com/rifkyprasetya) |
| Tino | [@TinoNurcahya](https://github.com/TinoNurcahya) |
| Andika | [@dikarajadirot](https://github.com/dikarajadirot) |

---

## 📝 Lisensi

Aplikasi ini didistribusikan di bawah **Lisensi MIT**. Lihat file `LICENSE` untuk detail lebih lanjut.

---

## 🔗 Referensi & Link Penting

| Resource | Link |
|---|---|
| Mobile Repository (Flutter) | https://github.com/ivan-4k/proyek3-mobile |
| Backend + Web Repository | https://github.com/ivan-4k/proyek3-vianos-creative-compound |
| Dokumentasi API Lengkap | [API_ENDPOINTS.md](./docs/API_ENDPOINTS.md) |
| Panduan Setup Development | [SETUP_DEVELOPMENT.md](./docs/SETUP_DEVELOPMENT.md) |
| Flutter Official Docs | https://flutter.dev/docs |
| Provider Package | https://pub.dev/packages/provider |
| Laravel Sanctum | https://laravel.com/docs/sanctum |

---

<div align="center">
  <i>Dikembangkan dengan ❤️ untuk Seven Caffee Staff — v1.0.0</i>
</div>
