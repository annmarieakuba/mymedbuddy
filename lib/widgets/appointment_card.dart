import 'package:flutter/material.dart';
import '../models/appointmentmodel.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  const AppointmentCard({Key? key, required this.appointment})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(appointment.title),
        subtitle: Text(appointment.date.toString()),
      ),
    );
  }
}
