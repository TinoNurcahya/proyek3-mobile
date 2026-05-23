# 📋 Catatan Perbaikan & Best Practices
> **Project**: `proyek3-mobile` — Flutter Staff App  
> **Backend**: Laravel (proyek3-vianos-creative-compound)  
> **Dibuat**: 2026-05-19  
> **Status**: 🔄 Dalam Proses

---

## ✅ Yang Sudah Baik (Jangan Diubah)

| Komponen | Keterangan |
|---|---|
| Struktur folder `models/`, `services/`, `pages/`, `widgets/` | Sudah terpisah dengan rapi |
| `ApiService` terpusat | Semua HTTP call lewat satu file |
| Error handling try-catch di setiap method HTTP | GET, POST, PUT, DELETE sudah handle SocketException |
| Timeout 15 detik di setiap request | Mencegah app hang |
| `UserModel` dengan `fromJson()`, `toJson()`, `copyWith()` | Pola model yang lengkap |
| `StorageService` sebagai abstraksi SharedPreferences | Key disimpan sebagai konstanta private |
| `provider: ^6.1.2` sudah ada di `pubspec.yaml` | Tinggal diimplementasikan |
| Autentikasi token Bearer via header | Sudah terintegrasi di `_headers()` |

---

## 🔴 Perbaikan Prioritas Tinggi

### 1. Tambah `api_endpoints.dart`

**Masalah**: String endpoint ditulis langsung (magic string) di berbagai service file. Kalau API berubah, harus cari satu per satu.

**File yang terdampak**:
- `services/auth_service.dart` → `'auth/login'`, `'auth/logout'`, `'profile'`
- `services/attendance_service.dart` → endpoint absensi
- `services/profile_service.dart` → `'profile/change-password'`
- `services/notification_service.dart` → endpoint notifikasi
- `services/order_service.dart` → endpoint order

**Solusi**: Buat file baru `lib/config/api_endpoints.dart`

```dart
// lib/config/api_endpoints.dart
class ApiEndpoints {
  ApiEndpoints._(); // prevent instantiation

  // Auth
  static const String login    = 'auth/login';
  static const String logout   = 'auth/logout';

  // Profile
  static const String profile         = 'profile';
  static const String changePassword  = 'profile/change-password';

  // Attendance
  static const String attendance      = 'attendance';
  static const String attendanceToday = 'attendance/today';

  // Notification
  static const String notifications   = 'notifications';

  // Order
  static const String orders          = 'orders';
}
```

**Cara pakai** (contoh di `auth_service.dart`):
```dart
// Sebelum
ApiService.get('profile')

// Sesudah
ApiService.get(ApiEndpoints.profile)
```

**Status**: ✅ Selesai

---

### 2. Implementasi Provider untuk State Management

**Masalah**: Logic fetch data masih kemungkinan campur dengan UI (`setState` di dalam page). Susah di-maintain kalau page makin besar.

**Package**: `provider: ^6.1.2` ← sudah ada di `pubspec.yaml`, tinggal dipakai!

**Struktur folder baru**:
```
lib/
└── providers/
    ├── auth_provider.dart
    ├── attendance_provider.dart
    ├── notification_provider.dart
    ├── order_provider.dart
    └── profile_provider.dart
```

**Contoh implementasi `AuthProvider`**:
```dart
// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await AuthService.login(email: email, password: password);

    _isLoading = false;
    if (result['success'] == true) {
      _currentUser = await AuthService.getCurrentUser();
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    _currentUser = null;
    notifyListeners();
  }
}
```

**Register di `main.dart`**:
```dart
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
```

**Status**: ✅ Selesai (Semua fitur termasuk Auth, Attendance, Notification, Order, Profile)

---

## 🟡 Perbaikan Prioritas Menengah

### 3. Perbaiki Double-Key di `UserModel.fromJson()`

**Masalah**: Ada ambiguitas key API yang bisa menyebabkan bug tersembunyi.

```dart
// lib/models/user_model.dart — baris 22-27
// MASALAH: mana yang benar? id_users atau id?
id: json['id_users'] ?? json['id'],
phone: json['phone_number'] ?? json['phone'] ?? '',  // 3 fallback!
```

**Solusi**: Standarkan response di Laravel agar selalu pakai key yang sama, lalu update `fromJson()`:
```dart
// Setelah API Laravel distandardisasi
factory UserModel.fromJson(Map<String, dynamic> json) {
  return UserModel(
    id: json['id'] as int?,           // Laravel selalu pakai 'id'
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    phone: json['phone_number'] ?? '', // Laravel selalu pakai 'phone_number'
    role: json['role'],
    avatar: json['avatar'],
    status: 'Online',
  );
}
```

**Status**: ✅ Selesai

---

### 4. Buat Shared Widgets (Loading, Error, Empty State)

**Masalah**: Setiap halaman kemungkinan punya tampilan loading/error sendiri-sendiri → tidak konsisten.

**Solusi**: Buat `lib/widgets/shared/` dengan widget reusable:

```dart
// lib/widgets/shared/loading_widget.dart
class LoadingWidget extends StatelessWidget {
  final String? message;
  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(message!, style: const TextStyle(color: Colors.grey)),
          ],
        ],
      ),
    );
  }
}

// lib/widgets/shared/error_widget.dart
class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const AppErrorWidget({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onRetry, child: const Text('Coba Lagi')),
          ],
        ],
      ),
    );
  }
}
```

**Status**: ✅ Selesai

---

### 5. Tambah Konstanta Timeout sebagai Named Constant

**Masalah**: Nilai `15` di timeout tersebar di 4 method HTTP (GET, POST, PUT, DELETE) di `api_service.dart`.

```dart
// Sebelum — di 4 tempat
.timeout(const Duration(seconds: 15))

// Sesudah — di atas class ApiService
static const Duration _kRequestTimeout = Duration(seconds: 15);

// Pemakaian
.timeout(_kRequestTimeout)
```

**Status**: ✅ Selesai

---

## 🟢 Perbaikan Prioritas Rendah (Nice-to-Have)

### 6. Tambah `constants/` Folder untuk Design Tokens

```
lib/constants/
├── app_colors.dart    — semua warna
├── app_text_styles.dart — semua text style
└── app_dimensions.dart  — padding, radius, dll
```

**Manfaat**: Konsistensi UI dan mudah ganti tema.

**Status**: ✅ Selesai

---

### 7. `ApiService` Jadi Instance (Bukan Static) untuk Testability

**Masalah**: Method static tidak bisa di-mock untuk unit testing.

**Catatan**: Ini refactor besar, lakukan hanya jika akan menulis unit test.

**Status**: ⬜ Ditunda — lakukan setelah fitur stabil

---

## 📁 Target Struktur Folder Final

```
lib/
├── config/
│   ├── app_config.dart          ✅ Ada
│   └── api_endpoints.dart       ✅ Ada
├── constants/                   ✅ Ada
│   ├── app_colors.dart
│   ├── app_text_styles.dart
│   └── app_dimensions.dart
├── models/                      ✅ Ada
│   ├── user_model.dart
│   ├── attendance_model.dart
│   ├── notification_model.dart
│   └── order_model.dart
├── services/                    ✅ Ada
│   ├── api_service.dart
│   ├── auth_service.dart
│   ├── attendance_service.dart
│   ├── notification_service.dart
│   ├── order_service.dart
│   ├── profile_service.dart
│   └── storage_service.dart
├── providers/                   ✅ Ada
│   ├── auth_provider.dart
│   ├── attendance_provider.dart
│   ├── notification_provider.dart
│   ├── order_provider.dart
│   └── profile_provider.dart
├── pages/                       ✅ Ada
│   ├── absensi/
│   ├── menu/
│   ├── notification/
│   ├── profile/
│   └── scan/
├── widgets/                     ✅ Ada
│   └── shared/                  ✅ Ada
│       ├── loading_widget.dart
│       ├── error_widget.dart
│       └── empty_state_widget.dart
├── start/                       ✅ Ada
└── main.dart                    ✅ Ada
```

---

## 📌 Clean Code Checklist Harian

Sebelum commit, pastikan:

- [ ] Tidak ada `print()` yang tertinggal (ganti dengan `debugPrint()` atau hapus)
- [ ] Semua widget besar (>80 baris di `build()`) sudah dipecah
- [ ] Tidak ada hardcoded string endpoint (pakai `ApiEndpoints`)
- [ ] Semua warna/style pakai konstanta, bukan nilai literal
- [ ] Tidak ada logic bisnis di dalam `build()` method
- [ ] Setiap async function sudah ada error handling
- [ ] Gunakan `const` di widget yang tidak berubah

---

## 🚀 Cara Menjalankan di HP Fisik

1. **Aktifkan Developer Mode** → Pengaturan → Tentang Ponsel → ketuk Nomor Build 7x
2. **Aktifkan USB Debugging** di Opsi Pengembang
3. **Cari IP laptop** → jalankan `ipconfig` di terminal → lihat IPv4 di Wi-Fi
4. **Update `app_config.dart`**:
   ```dart
   static const String baseUrl = 'http://<IP_LAPTOP>:8000/api';
   ```
5. **Jalankan Laravel dengan host terbuka**:
   ```bash
   php artisan serve --host=0.0.0.0 --port=8000
   ```
6. **Run Flutter**:
   ```bash
   flutter run
   ```

> ⚠️ HP dan laptop harus terhubung ke **WiFi yang sama**.

---

## 📦 Dependencies

| Package | Versi | Kegunaan |
|---|---|---|
| `provider` | ^6.1.2 | State management |
| `http` | ^1.2.2 | HTTP requests |
| `shared_preferences` | ^2.3.3 | Local storage (token, user info) |
| `intl` | ^0.20.2 | Format tanggal & angka |
| `cupertino_icons` | ^1.0.8 | Icon iOS-style |

---

*Dokumen ini diperbarui setiap kali ada perbaikan yang selesai dikerjakan.*
