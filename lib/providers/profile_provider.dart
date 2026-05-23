import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../services/storage_service.dart';

class ProfileProvider extends ChangeNotifier {
  UserModel _user = UserModel(
    name: '',
    phone: '',
    email: '',
    status: 'Offline',
  );
  bool _isLoading = false;
  String? _errorMessage;

  UserModel get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ProfileProvider() {
    loadProfile();
  }

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    // 1. Load dari SharedPreferences (cached)
    final cached = await StorageService.getUserInfo();
    if (cached['name'] != null && (cached['name'] as String).isNotEmpty) {
      _user = UserModel(
        id: cached['id'] as int?,
        name: cached['name'] ?? '',
        email: cached['email'] ?? '',
        phone: cached['phone'] ?? '',
        role: cached['role'],
      );
      notifyListeners();
    }

    // 2. Fetch fresh dari API
    try {
      final freshUser = await AuthService.getCurrentUser();
      if (freshUser != null) {
        _user = freshUser;
        await StorageService.saveUserInfo(
          id: freshUser.id ?? 0,
          name: freshUser.name,
          email: freshUser.email,
          phone: freshUser.phone,
          role: freshUser.role,
        );
      }
    } catch (_) {
      // Tetap gunakan data cache kalau gagal
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePhone(String newPhone) async {
    _user = _user.copyWith(phone: newPhone);
    notifyListeners();
    await ProfileService.updateProfile(phone: newPhone);
    await StorageService.saveUserInfo(
      id: _user.id ?? 0,
      name: _user.name,
      email: _user.email,
      phone: newPhone,
      role: _user.role,
    );
  }

  Future<void> updateEmail(String newEmail) async {
    _user = _user.copyWith(email: newEmail);
    notifyListeners();
    await StorageService.saveUserInfo(
      id: _user.id ?? 0,
      name: _user.name,
      email: newEmail,
      phone: _user.phone,
      role: _user.role,
    );
  }

  Future<void> updateName(String newName) async {
    _user = _user.copyWith(name: newName);
    notifyListeners();
    await ProfileService.updateProfile(name: newName);
    await StorageService.saveUserInfo(
      id: _user.id ?? 0,
      name: newName,
      email: _user.email,
      phone: _user.phone,
      role: _user.role,
    );
  }
}
