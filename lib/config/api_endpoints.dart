class ApiEndpoints {
  ApiEndpoints._(); // prevent instantiation

  // Auth
  static const String login = 'auth/login';
  static const String logout = 'auth/logout';
  static const String forgotPassword = 'auth/forgot-password';
  static const String resetPassword = 'auth/reset-password';

  // Profile
  static const String profile = 'profile';
  static const String changePassword = 'profile/change-password';
  static const String updateProfile = 'profile/update';

  // Staff Attendance
  static const String attendance = 'staff/attendance';
  static const String clockIn = 'staff/clock-in';
  static const String clockOut = 'staff/clock-out';
  static const String attendanceSummary = 'staff/attendance/summary';
  static String attendanceByDate(String date) => 'staff/attendance/$date';

  // Notifications
  static const String notifications = 'notifications';
  static const String notificationsReadAll = 'notifications/read-all';
  static const String notificationsUnread = 'notifications/unread';
  static String notificationRead(int id) => 'notifications/$id/read';
  static String notificationDelete(int id) => 'notifications/$id';

  // Orders (Staff)
  static const String staffOrders = 'staff/orders';
  static String staffOrderDetail(int id) => 'staff/orders/$id';

  // Tables (Staff)
  static const String staffTables = 'staff/tables';
  static const String scanTable = 'staff/scan-table';
  static String staffTableDetail(int id) => 'staff/tables/$id';
}
