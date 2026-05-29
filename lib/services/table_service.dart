import '../config/api_endpoints.dart';
import 'api_service.dart';

class TableService {
  // ==================== GET ALL TABLES ====================
  static Future<Map<String, dynamic>> getAllTables() async {
    return await ApiService.get(ApiEndpoints.staffTables);
  }

  // ==================== GET TABLE DETAIL ====================
  static Future<Map<String, dynamic>> getTableDetail(int tableId) async {
    return await ApiService.get(ApiEndpoints.staffTableDetail(tableId));
  }

  // ==================== SCAN TABLE ====================
  static Future<Map<String, dynamic>> scanTable(String qrCode) async {
    return await ApiService.post(ApiEndpoints.scanTable, {'qr_code': qrCode});
  }
}
