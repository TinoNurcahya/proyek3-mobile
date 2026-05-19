import 'api_service.dart';

class NotificationService {
  // ==================== GET ALL NOTIFICATIONS ====================
  static Future<Map<String, dynamic>> getNotifications({int page = 1}) async {
    return await ApiService.get('notifications', queryParams: {'page': '$page'});
  }

  // ==================== MARK AS READ ====================
  static Future<Map<String, dynamic>> markAsRead(int notificationId) async {
    return await ApiService.put('notifications/$notificationId/read', {});
  }

  // ==================== MARK ALL AS READ ====================
  static Future<Map<String, dynamic>> markAllAsRead() async {
    return await ApiService.post('notifications/read-all', {});
  }

  // ==================== DELETE ====================
  static Future<Map<String, dynamic>> deleteNotification(
      int notificationId) async {
    return await ApiService.delete('notifications/$notificationId');
  }

  // ==================== UNREAD COUNT ====================
  static Future<Map<String, dynamic>> getUnreadCount() async {
    return await ApiService.get('notifications/unread');
  }
}
