import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/health_logs_provider.dart'; // Added import for HealthLogsProvider
import 'onboarding.dart'; // Correct import for OnboardingScreen
import 'dart:convert'; // Added import for jsonDecode
import '../providers/medication_provider.dart'; // Added import for MedicationProvider
import '../providers/appointments_provider.dart'; // Added import for AppointmentsProvider
import '../services/shared_prefs_service.dart'; // Added import for SharedPrefsService

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${userProvider.user.name ?? 'Not set'}'),
            Text('Age: ${userProvider.user.age ?? 'Not set'}'),
            if (userProvider.user.medications != null &&
                userProvider.user.medications!.isNotEmpty)
              ..._buildMedicationsDisplay(userProvider.user.medications!),
            if (userProvider.user.medications == null ||
                userProvider.user.medications!.isEmpty)
              const Text('Medications: None'),
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: userProvider.user.isDarkMode,
              onChanged: (value) => userProvider.toggleDarkMode(value),
            ),
            SwitchListTile(
              title: const Text('Notifications'),
              value: userProvider.user.notificationsEnabled,
              onChanged: (value) => userProvider.toggleNotifications(value),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.delete_forever),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              label: const Text('Clear All History'),
              onPressed: () async {
                // Clear health logs
                final healthLogsProvider =
                    Provider.of<HealthLogsProvider>(context, listen: false);
                await healthLogsProvider.clearAllLogs();
                // Clear medications
                final medicationProvider =
                    Provider.of<MedicationProvider>(context, listen: false);
                await medicationProvider.clearAllMedications();
                // Clear appointments
                final appointmentsProvider =
                    Provider.of<AppointmentsProvider>(context, listen: false);
                await appointmentsProvider.clearAllAppointments();
                // Clear user data
                await SharedPrefsService.clearAllUserData();
                // Navigate to onboarding, replacing all routes
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

List<Widget> _buildMedicationsDisplay(List<String> meds) {
  // Try to parse as JSON, fallback to string display
  try {
    final parsed =
        meds.map((s) => s.contains('{') ? _parseMedJson(s) : s).toList();
    return [
      const Text('Medications:'),
      ...parsed.map((e) => Text('• $e')),
    ];
  } catch (_) {
    return [Text('Medications: ${meds.join(", ")}')];
  }
}

String _parseMedJson(String s) {
  try {
    final map = Map<String, dynamic>.from(jsonDecode(s));
    final name = map['brandName'] ?? 'Unknown';
    final times = (map['times'] as List?)?.join(', ') ?? '';
    return times.isNotEmpty ? '$name at $times' : name;
  } catch (_) {
    return s;
  }
}
