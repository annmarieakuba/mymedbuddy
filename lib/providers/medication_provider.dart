import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/medication_model.dart';
import '../services/api_service.dart';

class MedicationProvider extends ChangeNotifier {
  List<MedicationModel> _medications = [];
  bool _isLoading = false;
  String? _error;
  Map<String, Map<String, bool>> _medicationTaken =
      {}; // {medId: {date: taken}}
  // Missed doses tracking: {medId: {date_time: missed}}
  Map<String, Map<String, bool>> _medicationMissed = {};

  List<MedicationModel> get medications => _medications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, Map<String, bool>> get medicationTaken => _medicationTaken;
  Map<String, Map<String, bool>> get medicationMissed => _medicationMissed;

  Future<void> loadMedications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getStringList('medications');
      final takenMap = prefs.getString('medicationTaken');
      if (takenMap != null) {
        _medicationTaken = Map<String, Map<String, bool>>.from(
            jsonDecode(takenMap)
                .map((k, v) => MapEntry(k, Map<String, bool>.from(v))));
      }
      final missedMap = prefs.getString('medicationMissed');
      if (missedMap != null) {
        _medicationMissed = Map<String, Map<String, bool>>.from(
            jsonDecode(missedMap)
                .map((k, v) => MapEntry(k, Map<String, bool>.from(v))));
      }
      if (stored != null) {
        _medications =
            stored.map((s) => MedicationModel.fromJson(jsonDecode(s))).toList();
      } else {
        final names = await ApiService.getMedicationNames();
        _medications = names
            .map((name) => MedicationModel(
                id: UniqueKey().toString(),
                brandName: name,
                applicationNumber: 'N/A',
                times: []))
            .toList();
      }
    } catch (e) {
      _error = 'Failed to load medications.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMedication(MedicationModel medication) async {
    _medications.add(medication);
    await _saveAll();
    notifyListeners();
  }

  Future<void> editMedication(MedicationModel medication) async {
    final idx = _medications.indexWhere((m) => m.id == medication.id);
    if (idx != -1) {
      _medications[idx] = medication;
      await _saveAll();
      notifyListeners();
    }
  }

  Future<void> deleteMedication(String id) async {
    _medications.removeWhere((m) => m.id == id);
    _medicationTaken.remove(id);
    _medicationMissed.remove(id);
    await _saveAll();
    notifyListeners();
  }

  // Returns the taken status for a specific medication, date, and time
  bool isTaken(String medId, String dateStr, String timeStr) {
    return _medicationTaken[medId]?[dateStr + '_' + timeStr] ?? false;
  }

  // Toggle taken status for a specific medication, date, and time
  Future<void> toggleTaken(
      String medId, String dateStr, String timeStr, bool taken) async {
    _medicationTaken[medId] ??= {};
    _medicationTaken[medId]![dateStr + '_' + timeStr] = taken;
    if (taken) {
      // Uncheck missed if taken is checked
      _medicationMissed[medId] ??= {};
      _medicationMissed[medId]![dateStr + '_' + timeStr] = false;
    }
    await _saveAll();
    notifyListeners();
  }

  bool isMissed(String medId, String dateStr, String timeStr) {
    return _medicationMissed[medId]?[dateStr + '_' + timeStr] ?? false;
  }

  Future<void> toggleMissed(
      String medId, String dateStr, String timeStr, bool missed) async {
    _medicationMissed[medId] ??= {};
    _medicationMissed[medId]![dateStr + '_' + timeStr] = missed;
    if (missed) {
      // Uncheck taken if missed is checked
      _medicationTaken[medId] ??= {};
      _medicationTaken[medId]![dateStr + '_' + timeStr] = false;
    }
    await _saveAll();
    notifyListeners();
  }

  // Update missed count logic to count missed checkboxes
  int getMissedCountForToday() {
    final today = DateTime.now();
    final dateStr = '${today.year}-${today.month}-${today.day}';
    int missed = 0;
    for (final med in _medications) {
      for (final t in med.times) {
        final timeStr = t.hour.toString().padLeft(2, '0') +
            ':' +
            t.minute.toString().padLeft(2, '0');
        if (isMissed(med.id, dateStr, timeStr)) {
          missed++;
        }
      }
    }
    return missed;
  }

  String? getNextMedicationName() {
    final now = TimeOfDay.now();
    MedicationModel? nextMed;
    TimeOfDay? nextTime;
    for (final med in _medications) {
      for (final t in med.times) {
        final isAfterNow =
            t.hour > now.hour || (t.hour == now.hour && t.minute > now.minute);
        if (isAfterNow) {
          if (nextTime == null ||
              t.hour < nextTime.hour ||
              (t.hour == nextTime.hour && t.minute < nextTime.minute)) {
            nextTime = t;
            nextMed = med;
          }
        }
      }
    }
    // If no future time today, show the earliest for tomorrow
    if (nextMed == null) {
      for (final med in _medications) {
        for (final t in med.times) {
          if (nextTime == null ||
              t.hour < nextTime.hour ||
              (t.hour == nextTime.hour && t.minute < nextTime.minute)) {
            nextTime = t;
            nextMed = med;
          }
        }
      }
    }
    return nextMed?.brandName;
  }

  Future<void> clearAllMedications() async {
    _medications.clear();
    _medicationTaken.clear();
    _medicationMissed.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('medications');
    await prefs.remove('medicationTaken');
    await prefs.remove('medicationMissed');
    notifyListeners();
  }

  Future<void> _saveAll() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = _medications.map((m) => jsonEncode(m.toJson())).toList();
    await prefs.setStringList('medications', encoded);
    await prefs.setString('medicationTaken', jsonEncode(_medicationTaken));
    await prefs.setString('medicationMissed', jsonEncode(_medicationMissed));
  }
}
