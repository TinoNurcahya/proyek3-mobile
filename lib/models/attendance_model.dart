class AttendanceModel {
  final int? id;
  final String? date;
  final String? clockInTime;
  final String? clockOutTime;
  final double? workHours;
  final String? status;
  final String? notes;

  AttendanceModel({
    this.id,
    this.date,
    this.clockInTime,
    this.clockOutTime,
    this.workHours,
    this.status,
    this.notes,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'],
      date: json['date'],
      clockInTime: json['clock_in_time'] ?? json['clock_in'],
      clockOutTime: json['clock_out_time'] ?? json['clock_out'],
      workHours: (json['work_hours'] as num?)?.toDouble(),
      status: json['status'],
      notes: json['notes'],
    );
  }

  bool get isWorking => clockInTime != null && clockOutTime == null;
  bool get isCompleted => clockInTime != null && clockOutTime != null;
}
