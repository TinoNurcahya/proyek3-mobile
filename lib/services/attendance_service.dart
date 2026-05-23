import '../config/api_endpoints.dart';
import 'api_service.dart';

class AttendanceService {
  // ==================== CLOCK IN ====================
  // Route Laravel: POST /api/staff/clock-in
  static Future<Map<String, dynamic>> clockIn({String? notes}) async {
    final body = <String, dynamic>{};
    if (notes != null && notes.isNotEmpty) body['notes'] = notes;
    return await ApiService.post(ApiEndpoints.clockIn, body);
  }

  // ==================== CLOCK OUT ====================
  // Route Laravel: POST /api/staff/clock-out
  static Future<Map<String, dynamic>> clockOut({String? notes}) async {
    final body = <String, dynamic>{};
    if (notes != null && notes.isNotEmpty) body['notes'] = notes;
    return await ApiService.post(ApiEndpoints.clockOut, body);
  }

  // ==================== TODAY STATUS ====================
  // Route Laravel: GET /api/staff/attendance/{date} → pakai tanggal hari ini
  static Future<Map<String, dynamic>> getTodayStatus() async {
    final today =
        '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}';
    return await ApiService.get(ApiEndpoints.attendanceByDate(today));
  }

  // ==================== HISTORY ====================
  // Route Laravel: GET /api/staff/attendance
  static Future<Map<String, dynamic>> getHistory({
    int page = 1,
    String? startDate,
    String? endDate,
  }) async {
    final params = <String, String>{'page': '$page'};
    if (startDate != null) params['start_date'] = startDate;
    if (endDate != null) params['end_date'] = endDate;
    return await ApiService.get(ApiEndpoints.attendance, queryParams: params);
  }

  // ==================== SUMMARY ====================
  // Route Laravel: GET /api/staff/attendance/summary
  static Future<Map<String, dynamic>> getSummary({
    int? month,
    int? year,
  }) async {
    final params = <String, String>{};
    if (month != null) params['month'] = '$month';
    if (year != null) params['year'] = '$year';
    return await ApiService.get(ApiEndpoints.attendanceSummary, queryParams: params);
  }
}
