import 'package:flutter/material.dart';
import '../../../models/user_model.dart';

class ProfileProvider extends ChangeNotifier {
  // Dummy data — nanti diganti dari API / SharedPreferences
  UserModel _user = UserModel(
    name: 'Fahrul Zahir',
    phone: '08258929584',
    email: 'fahrulzahir@gmail.com',
    status: 'Online',
  );

  UserModel get user => _user;

  void updatePhone(String newPhone) {
    _user = _user.copyWith(phone: newPhone);
    notifyListeners();
  }

  void updateEmail(String newEmail) {
    _user = _user.copyWith(email: newEmail);
    notifyListeners();
  }

  void updateName(String newName) {
    _user = _user.copyWith(name: newName);
    notifyListeners();
  }
}