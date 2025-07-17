class UserModel {
  final String? name;
  final int? age;
  final List<String>? medications;
  final bool isDarkMode;
  final bool notificationsEnabled;

  UserModel({
    this.name,
    this.age,
    this.medications,
    this.isDarkMode = false,
    this.notificationsEnabled = true,
  });
}