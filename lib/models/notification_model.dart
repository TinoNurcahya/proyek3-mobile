import 'package:intl/intl.dart';

class NotificationModel {
  final int id;
  final String title;
  final String subtitle;
  final String time;
  final String group;
  final bool isRead;
  final String? type;

  NotificationModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.group,
    this.isRead = false,
    this.type,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final createdAt = json['created_at'] != null
        ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
        : DateTime.now();

    final now = DateTime.now();
    String group;
    if (createdAt.year == now.year &&
        createdAt.month == now.month &&
        createdAt.day == now.day) {
      group = 'Today';
    } else if (now.difference(createdAt).inDays == 1) {
      group = 'Yesterday';
    } else {
      group = DateFormat('dd MMM yyyy').format(createdAt);
    }

    return NotificationModel(
      id: json['id_notifikasi'] ?? json['id'] ?? 0,
      title: json['title'] ?? '',
      subtitle: json['message'] ?? '',
      time: DateFormat('HH:mm').format(createdAt),
      group: group,
      isRead: json['is_read'] == true || json['is_read'] == 1,
      type: json['type'],
    );
  }

  NotificationModel copyWith({
    int? id,
    String? title,
    String? subtitle,
    String? time,
    String? group,
    bool? isRead,
    String? type,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      time: time ?? this.time,
      group: group ?? this.group,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
    );
  }
}

