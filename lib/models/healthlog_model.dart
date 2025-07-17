class HealthLog {
  final String id;
  final String type;
  final String value;
  final DateTime date;

  HealthLog(
      {required this.id,
      required this.type,
      required this.value,
      required this.date});

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'value': value,
        'date': date.toIso8601String(),
      };

  factory HealthLog.fromJson(Map<String, dynamic> json) {
    return HealthLog(
      id: json['id'],
      type: json['type'],
      value: json['value'],
      date: DateTime.parse(json['date']),
    );
  }
}
