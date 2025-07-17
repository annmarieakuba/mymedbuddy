class AppointmentModel {
  final String id;
  final String title;
  final DateTime date;

  AppointmentModel({required this.id, required this.title, required this.date});

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'date': date.toIso8601String(),
      };

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'],
      title: json['title'],
      date: DateTime.parse(json['date']),
    );
  }
}
