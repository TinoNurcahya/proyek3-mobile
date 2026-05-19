import '../models/user_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  // ==================== LOGIN ====================
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    String? deviceName,
  }) async {
    final result = await ApiService.post(
      'auth/login',
      {
        'email': email,
        'password': password,
        'device_name': deviceName ?? 'Flutter Staff App',
      },
      withAuth: false,
    );

    if (result['success'] == true) {
      // Simpan token ke SharedPreferences
      final token = result['data']?['token'] as String?;
      if (token != null) {
        await StorageService.saveToken(token);
      }

      // Simpan info user
      final user = result['data']?['user'] as Map<String, dynamic>?;
      if (user != null) {
        await StorageService.saveUserInfo(
          id: user['id_users'] ?? 0,
          name: user['name'] ?? '',
          email: user['email'] ?? '',
          phone: user['phone_number'] ?? '',
          role: user['role'] ?? '',
        );
      }
    }

    return result;
  }

  // ==================== LOGOUT ====================
  static Future<Map<String, dynamic>> logout() async {
    final result = await ApiService.post('auth/logout', {});
    // Hapus token terlepas dari hasil API
    await StorageService.clearAll();
    return result;
  }

  // ==================== GET CURRENT USER ====================
  // Route Laravel: GET /api/profile
  static Future<UserModel?> getCurrentUser() async {
    final result = await ApiService.get('profile');
    if (result['success'] == true) {
      final userData = result['data'] as Map<String, dynamic>?;
      if (userData != null) {
        return UserModel.fromJson(userData);
      }
    }
    return null;
  }

  // ==================== CHANGE PASSWORD ====================
  // Route Laravel: PUT /api/profile/change-password
  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    return await ApiService.put('profile/change-password', {
      'current_password': currentPassword,
      'new_password': newPassword,
      'new_password_confirmation': confirmPassword,
    });
  }
}
