import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;

  Future<void> fetchNotifications({int page = 1}) async {
    if (page == 1) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    final result = await NotificationService.getNotifications(page: page);
    debugPrint("DEBUG Notification API: $result");
    
    if (result['success'] == true) {
      List<dynamic> rawData = [];
      if (result['data'] is List) {
        rawData = result['data'] as List<dynamic>;
      } else if (result['data'] is Map) {
        rawData = result['data']['data'] as List<dynamic>? ?? [];
      }

      final List<NotificationModel> newItems = rawData
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();

      if (page == 1) {
        _notifications = newItems;
      } else {
        _notifications.addAll(newItems);
      }
    } else {
      if (page == 1) {
        _errorMessage = result['message'];
      }
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchUnreadCount() async {
    final result = await NotificationService.getUnreadCount();
    if (result['success'] == true) {
      _unreadCount = result['data']?['count'] ?? 0;
      notifyListeners();
    }
  }

  Future<bool> markAsRead(int id) async {
    final result = await NotificationService.markAsRead(id);
    if (result['success'] == true) {
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        _unreadCount = (_unreadCount > 0) ? _unreadCount - 1 : 0;
        notifyListeners();
      }
      return true;
    }
    return false;
  }

  Future<bool> markAllAsRead() async {
    _isLoading = true;
    notifyListeners();

    final result = await NotificationService.markAllAsRead();
    if (result['success'] == true) {
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      _unreadCount = 0;
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> deleteNotification(int id) async {
    final result = await NotificationService.deleteNotification(id);
    if (result['success'] == true) {
      final notification = _notifications.firstWhere((n) => n.id == id);
      _notifications.removeWhere((n) => n.id == id);
      if (!notification.isRead && _unreadCount > 0) {
        _unreadCount--;
      }
      notifyListeners();
      return true;
    }
    return false;
  }
}
