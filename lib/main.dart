import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'screens/medicationshedule_screen.dart';
import 'package:mymedbuddy/screens/appointments_screen.dart';
import 'package:mymedbuddy/screens/healthlogs_screen.dart';
import 'screens/onboarding.dart';
import 'screens/homescreen.dart';
import 'screens/profilescreen.dart';
import 'providers/user_provider.dart';
import 'providers/health_logs_provider.dart';
import 'providers/appointments_provider.dart';
import 'providers/medication_provider.dart';
import 'services/shared_prefs_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefsService.init();
  runApp(const ProviderScope(child: MyMedBuddyApp()));
}

class MyMedBuddyApp extends StatelessWidget {
  const MyMedBuddyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return provider.MultiProvider(
      providers: [
        provider.ChangeNotifierProvider<UserProvider>(
            create: (_) => UserProvider()..loadUserData()), // Explicit type
        provider.ChangeNotifierProvider<HealthLogsProvider>(create: (_) {
          final p = HealthLogsProvider();
          p.loadHealthLogs();
          return p;
        }), // Explicit type
        provider.ChangeNotifierProvider<AppointmentsProvider>(create: (_) {
          final p = AppointmentsProvider();
          p.loadAppointments();
          return p;
        }), // Explicit type
        provider.ChangeNotifierProvider<MedicationProvider>(
            create: (_) =>
                MedicationProvider()..loadMedications()), // Explicit type
      ],
      child: provider.Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          return MaterialApp(
            title: 'MyMedBuddy',
            theme: userProvider.user.isDarkMode
                ? ThemeData.dark()
                : ThemeData.light(),
            home: FutureBuilder<bool>(
              future: SharedPrefsService.hasUserData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                      body: Center(child: CircularProgressIndicator()));
                }
                return snapshot.data == true
                    ? const HomeScreen()
                    : const OnboardingScreen();
              },
            ),
            routes: {
              '/home': (context) => const HomeScreen(),
              '/onboarding': (context) => const OnboardingScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/medication-schedule': (context) =>
                  const MedicationScheduleScreen(),
              '/appointment-schedule': (context) =>
                  const AppointmentScheduleScreen(),
              '/health-logs': (context) => const HealthLogsScreen(),
            },
          );
        },
      ),
    );
  }
}
