import 'package:flutter/material.dart';
import '../services/attendance_service.dart';
import '../models/attendance_model.dart';

class AttendanceProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  AttendanceModel? _todayStatus;
  List<AttendanceModel> _history = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AttendanceModel? get todayStatus => _todayStatus;
  List<AttendanceModel> get history => _history;

  Future<void> fetchTodayStatus() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await AttendanceService.getTodayStatus();
    
    if (result['success'] == true && result['data'] != null) {
      _todayStatus = AttendanceModel.fromJson(result['data'] as Map<String, dynamic>);
    } else {
      _errorMessage = result['message'];
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await AttendanceService.getHistory();
    
    if (result['success'] == true) {
      final data = result['data'] as List<dynamic>? ?? [];
      _history = data.map((e) => AttendanceModel.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      _errorMessage = result['message'];
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> clockIn(String? notes) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await AttendanceService.clockIn(notes: notes);

    if (result['success'] == true) {
      await fetchTodayStatus(); // refresh status
      await fetchHistory(); // refresh history
      return true;
    } else {
      _isLoading = false;
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  Future<bool> clockOut(String? notes) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await AttendanceService.clockOut(notes: notes);

    if (result['success'] == true) {
      await fetchTodayStatus(); // refresh status
      await fetchHistory(); // refresh history
      return true;
    } else {
      _isLoading = false;
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }
}

