import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/health_logs_provider.dart';
import '../providers/appointments_provider.dart';
import '../providers/medication_provider.dart';
import '../widgets/dashboardcard.dart';
import '../screens/medicationshedule_screen.dart';
import '../screens/appointments_screen.dart';
import '../screens/healthlogs_screen.dart';
import '../screens/profilescreen.dart';
import '../screens/health_tips_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // For bottom navigation
  int _dashboardIndex = 0; // For dashboard card selection

  @override
  void initState() {
    super.initState();
    context.read<MedicationProvider>().loadMedications();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user.name;
    final healthLogs = context.watch<HealthLogsProvider>().healthLogs.length;
    final appointments =
        context.watch<AppointmentsProvider>().upcomingAppointments.length;
    final medications = context.watch<MedicationProvider>().medications.length;

    final List<Widget> _pages = [
      SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dashboard',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Consumer<MedicationProvider>(
              builder: (context, provider, _) =>
                  _buildDashboardSummary(provider),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              children: [
                DashboardCard(
                  title: 'Medications',
                  value: '$medications',
                  icon: Icons.medication,
                  onTap: () => setState(() => _dashboardIndex = 1),
                ),
                DashboardCard(
                  title: 'Health Logs',
                  value: '$healthLogs',
                  icon: Icons.favorite,
                  onTap: () => setState(() => _dashboardIndex = 2),
                ),
                DashboardCard(
                  title: 'Appointments',
                  value: '$appointments',
                  icon: Icons.calendar_today,
                  onTap: () => setState(() => _dashboardIndex = 3),
                ),
                DashboardCard(
                  title: 'Profile',
                  value: 'View',
                  icon: Icons.person,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfileScreen()),
                    );
                  },
                ),
                DashboardCard(
                  title: 'Health Tips',
                  value: 'Get Tips',
                  icon: Icons.lightbulb,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HealthTipsScreen()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildDashboardContent(),
          ],
        ),
      ),
      const MedicationScheduleScreen(),
      const HealthLogsScreen(),
      const AppointmentScheduleScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar:
          AppBar(title: Text('Welcome, $user'), backgroundColor: Colors.teal),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildDashboardContent() {
    switch (_dashboardIndex) {
      case 1:
        final provider = context.watch<MedicationProvider>();
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.error != null) {
          return Center(
              child: Text(provider.error!,
                  style: const TextStyle(color: Colors.red)));
        }
        final medications = provider.medications;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Medications',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MedicationScheduleScreen()),
                );
              },
              child: const Text('See All Medications'),
            ),
            ...medications.map((m) => ListTile(
                  leading: const Icon(Icons.medication),
                  title: Text(m.brandName),
                  subtitle: Text('App No: ${m.applicationNumber}'),
                )),
          ],
        );
      case 2:
        final healthLogs = context.watch<HealthLogsProvider>().healthLogs;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Health Logs',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ...healthLogs.map((log) => ListTile(
                  leading: const Icon(Icons.favorite),
                  title: Text(log.type),
                  subtitle: Text('${log.value} (${log.date.toLocal()})'),
                )),
          ],
        );
      case 3:
        final appointments =
            context.watch<AppointmentsProvider>().upcomingAppointments;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Appointments',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ...appointments.map((a) => ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(a.title),
                  subtitle: Text(a.date.toLocal().toString()),
                )),
          ],
        );
      case 4:
        final user = context.watch<UserProvider>().user;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Profile',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ListTile(
                leading: const Icon(Icons.person),
                title: Text('Name: ${user.name ?? 'Not set'}')),
            ListTile(
                leading: const Icon(Icons.cake),
                title: Text('Age: ${user.age ?? 'Not set'}')),
            if (user.medications != null)
              ListTile(
                  leading: const Icon(Icons.medication),
                  title: Text('Medications: ${user.medications!.join(', ')}')),
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: user.isDarkMode,
              onChanged: (value) =>
                  context.read<UserProvider>().toggleDarkMode(value),
            ),
            SwitchListTile(
              title: const Text('Notifications'),
              value: user.notificationsEnabled,
              onChanged: (value) =>
                  context.read<UserProvider>().toggleNotifications(value),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDashboardSummary(MedicationProvider provider) {
    final nextMedicationName = provider.getNextMedicationName() ?? 'None';
    // Optionally, you can also show the time by extending getNextMedicationName to return both name and time.
    final appointments =
        context.watch<AppointmentsProvider>().upcomingAppointments;
    // Missed Doses (use provider logic)
    final missedDoses = provider.getMissedCountForToday();
    // Weekly Appointments (count in next 7 days)
    final today = DateTime.now();
    final weeklyAppointments = appointments
        .where((a) =>
            a.date.isAfter(today) &&
            a.date.isBefore(today.add(const Duration(days: 7))))
        .length;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      color: isDark ? Colors.grey[900] : Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                const Text('Next Medication',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(nextMedicationName),
              ],
            ),
            Column(
              children: [
                const Text('Missed Doses',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('$missedDoses'),
              ],
            ),
            Column(
              children: [
                const Text('Weekly Appointments',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('$weeklyAppointments'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Duration _timeOfDayDifference(TimeOfDay from, TimeOfDay to) {
    final fromMinutes = from.hour * 60 + from.minute;
    final toMinutes = to.hour * 60 + to.minute;
    return Duration(minutes: toMinutes - fromMinutes);
  }

  Widget _buildBottomNavigation() {
    final List<Color> navColors = [
      Colors.teal, // Home
      Colors.blue, // Medications
      Colors.red, // Health Logs
      Colors.green, // Appointments
      Colors.purple, // Profile
    ];
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() {
        _currentIndex = index;
        if (_currentIndex == 0) _dashboardIndex = 0;
      }),
      backgroundColor: navColors[_currentIndex],
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.medication), label: 'Medications'),
        BottomNavigationBarItem(
            icon: Icon(Icons.favorite), label: 'Health Logs'),
        BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today), label: 'Appointments'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
