import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [StorageService]
/// - Token autentikasi  → flutter_secure_storage (terenkripsi, aman)
/// - Data user lainnya  → SharedPreferences (tidak sensitif, akses cepat)
class StorageService {
  // ── Secure Storage (untuk data sensitif) ──────────────────────────────
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const _tokenKey = 'auth_token';

  // ── SharedPreferences keys (data non-sensitif) ─────────────────────────
  static const _userIdKey    = 'user_id';
  static const _userNameKey  = 'user_name';
  static const _userEmailKey = 'user_email';
  static const _userPhoneKey = 'user_phone';
  static const _userRoleKey  = 'user_role';

  // ==================== Token (Secure with SharedPreferences Fallback) ====================
  static Future<void> saveToken(String token) async {
    try {
      await _secureStorage.write(key: _tokenKey, value: token);
    } catch (e) {
      debugPrint('SecureStorage write error: $e');
    }
    // Selalu simpan di SharedPreferences juga sebagai cadangan
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      if (token != null && token.isNotEmpty) return token;
    } catch (e) {
      debugPrint('SecureStorage read error: $e');
    }
    // Ambil dari SharedPreferences jika secure storage kosong atau error
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> removeToken() async {
    try {
      await _secureStorage.delete(key: _tokenKey);
    } catch (e) {
      debugPrint('SecureStorage delete error: $e');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // ==================== User Info (SharedPreferences) ====================
  static Future<void> saveUserInfo({
    required int id,
    required String name,
    required String email,
    String? phone,
    String? role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, id);
    await prefs.setString(_userNameKey, name);
    await prefs.setString(_userEmailKey, email);
    if (phone != null) await prefs.setString(_userPhoneKey, phone);
    if (role != null)  await prefs.setString(_userRoleKey, role);
  }

  static Future<Map<String, dynamic>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'id':    prefs.getInt(_userIdKey),
      'name':  prefs.getString(_userNameKey)  ?? '',
      'email': prefs.getString(_userEmailKey) ?? '',
      'phone': prefs.getString(_userPhoneKey) ?? '',
      'role':  prefs.getString(_userRoleKey)  ?? '',
    };
  }

  // ==================== Clear All ====================
  static Future<void> clearAll() async {
    // Hapus token dari secure storage
    try {
      await _secureStorage.delete(key: _tokenKey);
    } catch (e) {
      debugPrint('SecureStorage clear error: $e');
    }
    // Hapus data user dari SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ==================== Check Login ====================
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
