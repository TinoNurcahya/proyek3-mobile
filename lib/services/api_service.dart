import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'storage_service.dart';

class ApiService {
  static String get baseUrl => AppConfig.baseUrl;

  // ==================== Headers ====================
  static Future<Map<String, String>> _headers({bool withAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (withAuth) {
      final token = await StorageService.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // ==================== GET ====================
  static Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/$endpoint');
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http
          .get(uri, headers: await _headers())
          .timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } on SocketException {
      return {'success': false, 'message': 'Tidak ada koneksi internet'};
    } on HttpException {
      return {'success': false, 'message': 'Terjadi kesalahan HTTP'};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  // ==================== POST ====================
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool withAuth = true,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/$endpoint'),
            headers: await _headers(withAuth: withAuth),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } on SocketException {
      return {'success': false, 'message': 'Tidak ada koneksi internet'};
    } on HttpException {
      return {'success': false, 'message': 'Terjadi kesalahan HTTP'};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  // ==================== PUT ====================
  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/$endpoint'),
            headers: await _headers(),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } on SocketException {
      return {'success': false, 'message': 'Tidak ada koneksi internet'};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  // ==================== DELETE ====================
  static Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/$endpoint'),
            headers: await _headers(),
          )
          .timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } on SocketException {
      return {'success': false, 'message': 'Tidak ada koneksi internet'};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  // ==================== Response Handler ====================
  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      } else if (response.statusCode == 401) {
        return {'success': false, 'message': 'Sesi berakhir, silakan login ulang', 'unauthenticated': true};
      } else if (response.statusCode == 422) {
        // Validation errors
        return {'success': false, 'message': data['message'] ?? 'Data tidak valid', 'errors': data['errors']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Terjadi kesalahan server'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Gagal memproses respons server'};
    }
  }
}
