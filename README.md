MyMedBuddy
Overview
MyMedBuddy is a Flutter-based mobile application designed to streamline personal health management. It enables users to track medications, log health metrics, schedule appointments, and access health tips through a user-friendly interface. Built with Dart, the app leverages the Provider package for state management, shared_preferences for local data persistence, and external APIs for dynamic content, ensuring functionality both online and offline.
Features

Onboarding: Collects user details (name, age, medications) for personalization.
Home Dashboard: Summarizes next medication, missed doses, and upcoming appointments with quick navigation to key sections.
Medication Schedule: Add, edit, delete, and track medications with time-specific dose reminders (taken/missed status).
Health Logs: Record and filter health metrics (e.g., blood pressure, heart rate) with timestamps.
Appointments: Schedule and view appointments with date and time details.
Profile: Manage settings (dark mode, notifications) and reset app data.
Health Tips: Fetch daily tips and news via APIs, with offline fallback.

Technologies Used

Flutter & Dart: Cross-platform framework for UI and logic.
Provider: Reactive state management for real-time updates.
shared_preferences: Local storage for user data, medications, logs, and appointments.
http: API calls to FDA Drug API and Advice Slip API.
flutter_riverpod: Asynchronous data fetching for health tips.

Project Structure
mymedbuddy/
├── lib/
│   ├── models/
│   │   ├── user_model.dart         # User data model
│   │   ├── medication_model.dart   # Medication data model
│   │   ├── healthlog_model.dart    # Health log data model
│   │   ├── appointmentmodel.dart   # Appointment data model
│   ├── providers/
│   │   ├── user_provider.dart      # Manages user data and settings
│   │   ├── medication_provider.dart # Handles medication CRUD and tracking
│   │   ├── health_logs_provider.dart # Manages health logs
│   │   ├── appointments_provider.dart # Manages appointments
│   ├── screens/
│   │   ├── onboarding.dart         # Onboarding UI
│   │   ├── homescreen.dart         # Dashboard and navigation
│   │   ├── medicationshedule_screen.dart # Medication management
│   │   ├── healthlogs_screen.dart  # Health log tracking
│   │   ├── appointments_screen.dart # Appointment scheduling
│   │   ├── profilescreen.dart      # User profile and settings
│   │   ├── health_tips_screen.dart # Health tips and news
│   ├── services/
│   │   ├── shared_prefs_service.dart # Local storage management
│   │   ├── api_service.dart        # API integration
│   ├── widgets/
│   │   ├── medication_card.dart    # Medication UI component
│   │   ├── health_logitem.dart     # Health log UI component
│   │   ├── dashboardcard.dart      # Dashboard card component
│   │   ├── appointment_card.dart   # Appointment UI component
│   ├── main.dart                   # App entry point
├── pubspec.yaml                   # Dependencies

Setup Instructions
Prerequisites

Flutter SDK (v3.0+)
Dart (v2.17+)
IDE: Android Studio or Visual Studio Code with Flutter plugins
Emulator or physical device (Android/iOS)

Installation

Clone the Repository:git clone https://github.com/[your-username]/mymedbuddy.git
cd mymedbuddy


Install Dependencies:flutter pub get

Installs flutter_riverpod, provider, shared_preferences, and http.
Run the App:flutter run

Launches on an emulator/device, starting with Onboarding Screen for new users or Home Screen if data exists.

Dependencies
In pubspec.yaml:
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.0.0
  provider: ^6.0.0
  shared_preferences: ^2.0.0
  http: ^0.13.0

Usage

Onboarding: Enter name (e.g., “Annmarie”), age, and medications (e.g., “Aspirin” at 8 AM). Submit to proceed.
Home Screen: Use bottom navigation (Home, Medications, Health Logs, Appointments, Profile) or tap dashboard cards for quick access.
Medications: Add/edit medications with names, application numbers, and times. Mark doses as taken/missed.
Health Logs: Log metrics (e.g., blood pressure: 120/80) and filter by type.
Appointments: Schedule appointments with title and date/time.
Profile: Toggle dark mode/notifications or clear data.
Health Tips: View daily tips and news, refreshable via icons.

Code Highlights
1. App Initialization (main.dart)

Sets up the app with ProviderScope and MultiProvider for state management.
Uses FutureBuilder to check for user data and route to OnboardingScreen or HomeScreen.
Snippet:home: FutureBuilder<bool>(
  future: SharedPrefsService.hasUserData(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return snapshot.data == true ? const HomeScreen() : const OnboardingScreen();
  },
)


Checks shared_preferences for user data to determine the initial screen.



2. State Management (medication_provider.dart)

Manages medication CRUD operations and dose tracking, persisting data to shared_preferences.
Snippet:Future<void> addMedication(MedicationModel medication) async {
  _medications.add(medication);
  await _saveAll();
  notifyListeners();
}
Future<void> _saveAll() async {
  final prefs = await SharedPreferences.getInstance();
  final encoded = _medications.map((m) => jsonEncode(m.toJson())).toList();
  await prefs.setStringList('medications', encoded);
}


Adds a medication and saves it as JSON, notifying UI listeners for updates.



3. UI Rendering (medicationschedule_screen.dart)

Uses ListView.builder to display MedicationCard widgets with dose tracking.
Snippet:CheckboxListTile(
  title: Text('Time: ${t.format(context)}'),
  value: taken,
  onChanged: (val) => provider.toggleTaken(med.id, dateStr, timeStr, val ?? false),
)


Toggles dose status, updating MedicationProvider and persisting changes.



4. Data Persistence (shared_prefs_service.dart)

Saves/retrieves data as JSON strings for persistence.
Snippet:static Future<void> saveUserData({String? name, int? age, List<String>? medications}) async {
  if (name != null) await _prefs.setString('name', name);
  if (age != null) await _prefs.setInt('age', age);
  if (medications != null) await _prefs.setStringList('medications', medications);
}


Conditionally saves non-null user data fields.



5. API Integration (api_service.dart)

Fetches data from external APIs with offline fallbacks.
Snippet:static Future<String> getHealthTip() async {
  try {
    final response = await http.get(Uri.parse('https://api.adviceslip.com/advice'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['slip']['advice'] as String;
    }
  } catch (e) {
    return fallbackTips[random.nextInt(fallbackTips.length)];
  }
}


Retrieves health tips, falling back to local data on failure.



Notes

APIs: Requires internet for FDA API (https://api.fda.gov/drug/drugsfda.json) and Advice Slip API (https://api.adviceslip.com/advice). Offline fallbacks ensure functionality.
Theming: Dynamic dark/light mode via UserProvider.
Limitations: Local storage limits scalability; consider a database for production.
Testing: Verified on Android/iOS emulators.

Contributing
Fork the repository and submit pull requests. Report issues via GitHub Issues.
License
MIT License (include LICENSE file if applicable).
Acknowledgments

Developed for a university project to showcase Flutter development.
Thanks to Flutter, Provider, and open-source communities.
