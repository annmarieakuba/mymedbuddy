import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/healthlog_model.dart';

class HealthLogsProvider extends ChangeNotifier {
  final List<HealthLog> _healthLogs = [];
  final List<String> _availableTypes = [
    'Blood Pressure',
    'Heart Rate',
    'Weight',
    'Blood Sugar',
    'Temperature',
    'Sleep Hours',
    'Water Intake',
    'Exercise Minutes',
  ];

  List<HealthLog> get healthLogs => _healthLogs;
  List<String> get availableTypes => _availableTypes;

  Future<void> loadHealthLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('healthLogs');
    if (stored != null) {
      _healthLogs.clear();
      _healthLogs.addAll(stored.map((s) => HealthLog.fromJson(jsonDecode(s))));
      notifyListeners();
    }
  }

  Future<void> addHealthLog(HealthLog log) async {
    _healthLogs.add(log);
    final prefs = await SharedPreferences.getInstance();
    final encoded = _healthLogs.map((l) => jsonEncode(l.toJson())).toList();
    await prefs.setStringList('healthLogs', encoded);
    notifyListeners();
  }

  Future<void> removeHealthLog(String id) async {
    _healthLogs.removeWhere((log) => log.id == id);
    final prefs = await SharedPreferences.getInstance();
    final encoded = _healthLogs.map((l) => jsonEncode(l.toJson())).toList();
    await prefs.setStringList('healthLogs', encoded);
    notifyListeners();
  }

  Future<void> clearAllLogs() async {
    _healthLogs.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('healthLogs');
    notifyListeners();
  }
}
