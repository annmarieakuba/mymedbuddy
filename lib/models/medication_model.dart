import 'package:flutter/material.dart';

class MedicationModel {
  final String id;
  final String brandName;
  final String applicationNumber;
  final List<TimeOfDay> times;

  MedicationModel({
    required this.id,
    required this.brandName,
    required this.applicationNumber,
    required this.times,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'brandName': brandName,
        'applicationNumber': applicationNumber,
        'times': times.map((t) => '${t.hour}:${t.minute}').toList(),
      };

  factory MedicationModel.fromJson(Map<String, dynamic> json) {
    List<TimeOfDay> times = [];
    if (json['times'] != null) {
      times = List<String>.from(json['times']).map((s) {
        final parts = s.split(':');
        return TimeOfDay(
            hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }).toList();
    }
    return MedicationModel(
      id: json['id'],
      brandName: json['brandName'],
      applicationNumber: json['applicationNumber'],
      times: times,
    );
  }
}
