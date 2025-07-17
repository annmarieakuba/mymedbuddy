import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<bool> hasUserData() async {
    return _prefs.containsKey('name');
  }

  static Future<void> saveUserData(
      {String? name, int? age, List<String>? medications}) async {
    if (name != null) await _prefs.setString('name', name);
    if (age != null) await _prefs.setInt('age', age);
    if (medications != null)
      await _prefs.setStringList('medications', medications);
  }

  static Future<String?> getName() async => _prefs.getString('name');
  static Future<int?> getAge() async => _prefs.getInt('age');
  static Future<List<String>?> getMedications() async =>
      _prefs.getStringList('medications');

  static Future<void> saveDarkMode(bool value) async =>
      await _prefs.setBool('darkMode', value);
  static Future<bool> getDarkMode() async =>
      _prefs.getBool('darkMode') ?? false;

  static Future<void> saveNotificationsEnabled(bool value) async =>
      await _prefs.setBool('notificationsEnabled', value);
  static Future<bool> getNotificationsEnabled() async =>
      _prefs.getBool('notificationsEnabled') ?? true;

  static Future<void> clearAllUserData() async {
    await _prefs.remove('name');
    await _prefs.remove('age');
    await _prefs.remove('medications');
    await _prefs.remove('darkMode');
    await _prefs.remove('notificationsEnabled');
  }
}
