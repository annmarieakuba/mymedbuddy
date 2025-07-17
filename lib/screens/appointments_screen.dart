import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/appointments_provider.dart';
import '../models/appointmentmodel.dart';
import '../widgets/appointment_card.dart';

class AppointmentScheduleScreen extends StatefulWidget {
  const AppointmentScheduleScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentScheduleScreen> createState() =>
      _AppointmentScheduleScreenState();
}

class _AppointmentScheduleScreenState extends State<AppointmentScheduleScreen> {
  final _titleController = TextEditingController();
  DateTime? _selectedDateTime;

  void _showAddAppointmentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Appointment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(_selectedDateTime == null
                      ? 'No date/time selected'
                      : 'Date: ${_selectedDateTime!.toLocal().toString().split(' ')[0]} Time: ${_selectedDateTime!.hour.toString().padLeft(2, '0')}:${_selectedDateTime!.minute.toString().padLeft(2, '0')}'),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() {
                          _selectedDateTime = DateTime(date.year, date.month,
                              date.day, time.hour, time.minute);
                        });
                      }
                    }
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () {
                _titleController.clear();
                setState(() => _selectedDateTime = null);
                Navigator.pop(context);
              },
              child: const Text('Cancel')),
          TextButton(
              onPressed: () {
                if (_titleController.text.isNotEmpty &&
                    _selectedDateTime != null) {
                  final appointment = AppointmentModel(
                    id: DateTime.now().toString(),
                    title: _titleController.text,
                    date: _selectedDateTime!,
                  );
                  context
                      .read<AppointmentsProvider>()
                      .addAppointment(appointment);
                  _titleController.clear();
                  setState(() => _selectedDateTime = null);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appointments =
        context.watch<AppointmentsProvider>().upcomingAppointments;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Schedule'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
              icon: const Icon(Icons.add), onPressed: _showAddAppointmentDialog)
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: appointments.length,
        itemBuilder: (context, index) =>
            AppointmentCard(appointment: appointments[index]),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}
