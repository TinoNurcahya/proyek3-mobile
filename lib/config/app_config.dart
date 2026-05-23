// Base URL untuk koneksi ke Laravel API
// ===============================================
// CARA MENGGUNAKAN:
// 1. Emulator Android: gunakan http://10.0.2.2:8000/api
// 2. Device Fisik: ganti IP dengan IP lokal server (192.168.x.x:8000/api)
// 3. Staging/Production: ganti dengan domain/IP server
// ===============================================

enum AppEnvironment { development, staging, production }

class AppConfig {
  // Ubah ke environment yang sesuai: AppEnvironment.development
  static const AppEnvironment _currentEnv = AppEnvironment.development;

  static const Map<AppEnvironment, String> _baseUrls = {
    AppEnvironment.development: 'http://10.0.2.2:8000/api', // Emulator
    // AppEnvironment.development: 'http://192.168.1.10:8000/api', // Device fisik - ubah IP sesuai server
    AppEnvironment.staging: 'https://staging-api.example.com/api',
    AppEnvironment.production: 'https://api.example.com/api',
  };

  static String get baseUrl => _baseUrls[_currentEnv] ?? _baseUrls[AppEnvironment.development]!;
  
  static String getBaseUrl(AppEnvironment env) => _baseUrls[env] ?? _baseUrls[AppEnvironment.development]!;
}
