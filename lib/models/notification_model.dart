class NotificationModel {
  final int id;
  final String title;
  final String subtitle;
  final String time;
  final String group;

  NotificationModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.group,
  });

  // CopyWith untuk update (kalau perlu)
  NotificationModel copyWith({
    int? id,
    String? title,
    String? subtitle,
    String? time,
    String? group,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      time: time ?? this.time,
      group: group ?? this.group,
    );
  }
}
