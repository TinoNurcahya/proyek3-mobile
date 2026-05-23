import '../config/api_endpoints.dart';
import 'api_service.dart';

class OrderService {
  // ==================== GET LIST ORDERS (untuk staff) ====================
  static Future<Map<String, dynamic>> getOrders({
    String? status,
    int page = 1,
  }) async {
    final params = <String, String>{'page': '$page'};
    if (status != null) params['status'] = status;
    return await ApiService.get(ApiEndpoints.staffOrders, queryParams: params);
  }

  // ==================== GET DETAIL ORDER ====================
  static Future<Map<String, dynamic>> getOrderDetail(int orderId) async {
    return await ApiService.get(ApiEndpoints.staffOrderDetail(orderId));
  }

  // ==================== UPDATE STATUS ORDER ====================
  static Future<Map<String, dynamic>> updateOrderStatus(
    int orderId,
    String status,
  ) async {
    return await ApiService.put(ApiEndpoints.staffOrderDetail(orderId), {'status': status});
  }
}
