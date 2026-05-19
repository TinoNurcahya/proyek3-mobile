import 'package:flutter/material.dart';
import '../../../models/notification_model.dart';
import '../../../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  int _unreadCount = 0;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  int get unreadCount => _unreadCount;

  NotificationProvider() {
    loadNotifications();
  }

  // ==================== LOAD (refresh) ====================
  Future<void> loadNotifications({bool refresh = true}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
    }

    _isLoading = true;
    notifyListeners();

    final result = await NotificationService.getNotifications(page: _currentPage);

    _isLoading = false;

    if (result['success'] == true) {
      final raw = result['data'] as List<dynamic>? ?? [];
      final fetched = raw
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();

      if (refresh) {
        _notifications = fetched;
      } else {
        _notifications.addAll(fetched);
      }

      // Kalau hasil < 15 (perpage default), berarti sudah habis
      if (fetched.length < 15) _hasMore = false;

      // Update unread count dari data lokal
      _unreadCount = _notifications.where((n) => !n.isRead).length;
    }

    notifyListeners();
  }

  // ==================== LOAD MORE ====================
  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;
    _currentPage++;
    await loadNotifications(refresh: false);
  }

  // ==================== MARK AS READ ====================
  Future<void> markAsRead(int id) async {
    await NotificationService.markAsRead(id);
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      notifyListeners();
    }
  }

  // ==================== MARK ALL READ ====================
  Future<void> markAllAsRead() async {
    await NotificationService.markAllAsRead();
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    _unreadCount = 0;
    notifyListeners();
  }

  // ==================== DELETE ====================
  Future<void> deleteNotification(int id) async {
    await NotificationService.deleteNotification(id);
    _notifications.removeWhere((n) => n.id == id);
    _unreadCount = _notifications.where((n) => !n.isRead).length;
    notifyListeners();
  }

  // ==================== REFRESH UNREAD COUNT ====================
  Future<void> refreshUnreadCount() async {
    final result = await NotificationService.getUnreadCount();
    if (result['success'] == true) {
      _unreadCount = result['data']?['count'] ?? 0;
      notifyListeners();
    }
  }
}
