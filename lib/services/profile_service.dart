import '../config/api_endpoints.dart';
import 'api_service.dart';

class ProfileService {
  static Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phone,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (phone != null) body['phone'] = phone;
    return await ApiService.put(ApiEndpoints.updateProfile, body);
  }

  // ==================== FORGOT PASSWORD ====================
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    return await ApiService.post(
      ApiEndpoints.forgotPassword,
      {'email': email},
      withAuth: false,
    );
  }

  // ==================== RESET PASSWORD ====================
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    return await ApiService.post(
      ApiEndpoints.resetPassword,
      {
        'email': email,
        'token': token,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
      withAuth: false,
    );
  }

  // ==================== SCAN QR TABLE ====================
  static Future<Map<String, dynamic>> scanTable(String qrCode) async {
    return await ApiService.post(ApiEndpoints.scanTable, {'qr_code': qrCode});
  }

  // ==================== GET TABLES ====================
  static Future<Map<String, dynamic>> getTables({String? status}) async {
    final params = <String, String>{};
    if (status != null) params['status'] = status;
    return await ApiService.get(ApiEndpoints.staffTables, queryParams: params);
  }

  // ==================== UPDATE TABLE STATUS ====================
  static Future<Map<String, dynamic>> updateTableStatus(
    int tableId,
    String status, {
    String? notes,
  }) async {
    final body = <String, dynamic>{'status': status};
    if (notes != null) body['notes'] = notes;
    return await ApiService.put(ApiEndpoints.staffTableDetail(tableId), body);
  }
}
