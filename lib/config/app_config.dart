// Base URL untuk koneksi ke Laravel API
// Ganti dengan IP lokal kamu saat testing di device fisik (bukan emulator)
// Contoh emulator: http://10.0.2.2:8000/api
// Contoh device fisik: http://192.168.1.xxx:8000/api

class AppConfig {
  static const String baseUrl = 'http://192.168.1.9:8000/api';
  // static const String baseUrl = 'http://192.168.1.10:8000/api'; // device fisik
}
