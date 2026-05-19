import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'user_id';
  static const _userNameKey = 'user_name';
  static const _userEmailKey = 'user_email';
  static const _userPhoneKey = 'user_phone';
  static const _userRoleKey = 'user_role';

  // ==================== Token ====================
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // ==================== User Info ====================
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
    if (role != null) await prefs.setString(_userRoleKey, role);
  }

  static Future<Map<String, dynamic>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'id': prefs.getInt(_userIdKey),
      'name': prefs.getString(_userNameKey) ?? '',
      'email': prefs.getString(_userEmailKey) ?? '',
      'phone': prefs.getString(_userPhoneKey) ?? '',
      'role': prefs.getString(_userRoleKey) ?? '',
    };
  }

  // ==================== Clear All ====================
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ==================== Check Login ====================
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
