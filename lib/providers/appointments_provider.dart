import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/appointmentmodel.dart';

class AppointmentsProvider extends ChangeNotifier {
  final List<AppointmentModel> _upcomingAppointments = [];

  List<AppointmentModel> get upcomingAppointments => _upcomingAppointments;

  Future<void> loadAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('appointments');
    if (stored != null) {
      _upcomingAppointments.clear();
      _upcomingAppointments
          .addAll(stored.map((s) => AppointmentModel.fromJson(jsonDecode(s))));
      notifyListeners();
    }
  }

  Future<void> addAppointment(AppointmentModel appointment) async {
    _upcomingAppointments.add(appointment);
    final prefs = await SharedPreferences.getInstance();
    final encoded =
        _upcomingAppointments.map((a) => jsonEncode(a.toJson())).toList();
    await prefs.setStringList('appointments', encoded);
    notifyListeners();
  }

  Future<void> removeAppointment(String id) async {
    _upcomingAppointments.removeWhere((app) => app.id == id);
    final prefs = await SharedPreferences.getInstance();
    final encoded =
        _upcomingAppointments.map((a) => jsonEncode(a.toJson())).toList();
    await prefs.setStringList('appointments', encoded);
    notifyListeners();
  }

  Future<void> clearAllAppointments() async {
    _upcomingAppointments.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('appointments');
    notifyListeners();
  }
}
