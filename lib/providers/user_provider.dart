import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/shared_prefs_service.dart';

class UserProvider extends ChangeNotifier {
  UserModel _user = UserModel();

  UserModel get user => _user;

  void loadUserData() async {
    _user = UserModel(
      name: await SharedPrefsService.getName(),
      age: await SharedPrefsService.getAge(),
      medications: await SharedPrefsService.getMedications(),
      isDarkMode: await SharedPrefsService.getDarkMode(),
      notificationsEnabled: await SharedPrefsService.getNotificationsEnabled(),
    );
    notifyListeners();
  }

  void updateUser(UserModel user) {
    _user = user;
    SharedPrefsService.saveUserData(
      name: user.name,
      age: user.age,
      medications: user.medications,
    );
    notifyListeners();
  }

  void toggleDarkMode(bool value) {
    _user = _user.copyWith(isDarkMode: value);
    SharedPrefsService.saveDarkMode(value);
    notifyListeners();
  }

  void toggleNotifications(bool value) {
    _user = _user.copyWith(notificationsEnabled: value);
    SharedPrefsService.saveNotificationsEnabled(value);
    notifyListeners();
  }
}

extension UserModelCopyWith on UserModel {
  UserModel copyWith({
    String? name,
    int? age,
    List<String>? medications,
    bool? isDarkMode,
    bool? notificationsEnabled,
  }) {
    return UserModel(
      name: name ?? this.name,
      age: age ?? this.age,
      medications: medications ?? this.medications,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}