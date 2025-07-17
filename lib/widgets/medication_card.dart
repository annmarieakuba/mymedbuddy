import 'package:flutter/material.dart';
import '../models/medication_model.dart';

class MedicationCard extends StatelessWidget {
  final MedicationModel medication;
  final bool takenToday;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onTakenChanged;

  const MedicationCard({
    Key? key,
    required this.medication,
    required this.takenToday,
    required this.onEdit,
    required this.onDelete,
    required this.onTakenChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timesText = medication.times.isNotEmpty
        ? 'Times: ' + medication.times.map((t) => t.format(context)).join(', ')
        : 'No times set';
    return Card(
      child: ListTile(
        title: Text(medication.brandName),
        subtitle: Text('App No: ${medication.applicationNumber}\n$timesText'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: takenToday,
              onChanged: (val) => onTakenChanged(val ?? false),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }
}
