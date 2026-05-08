import 'package:flutter/material.dart';
import '../models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];

  List<NotificationModel> get notifications => _notifications;

  // Dummy data (nanti diganti dari API)
  void loadDummyData() {
    _notifications = [
      NotificationModel(
        id: 1,
        title: 'Pengingat Clock In',
        subtitle: 'Shift kamu mulai 15 menit lagi',
        time: '09:21',
        group: 'Today',
      ),
      NotificationModel(
        id: 2,
        title: 'Pengingat Clock Out',
        subtitle: 'Shift kamu selesai 15 menit lagi',
        time: '16:21',
        group: 'Yesterday',
      ),
      NotificationModel(
        id: 3,
        title: 'Pengingat Clock In',
        subtitle: 'Shift kamu mulai 10 menit lagi',
        time: '09:30',
        group: 'Yesterday',
      ),
    ];
    notifyListeners();
  }

  void deleteNotification(int id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  // Tambah notifikasi (kalau perlu)
  void addNotification(NotificationModel notif) {
    _notifications.add(notif);
    notifyListeners();
  }
}