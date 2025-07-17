import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/medication_provider.dart';
import '../widgets/medication_card.dart';
import '../models/medication_model.dart';

class MedicationScheduleScreen extends StatefulWidget {
  const MedicationScheduleScreen({Key? key}) : super(key: key);

  @override
  State<MedicationScheduleScreen> createState() =>
      _MedicationScheduleScreenState();
}

class _MedicationScheduleScreenState extends State<MedicationScheduleScreen> {
  void _showAddMedicationDialog() async {
    final nameController = TextEditingController();
    final appNumController = TextEditingController();
    List<TimeOfDay> times = [];

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Medication'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration:
                          const InputDecoration(labelText: 'Medication Name'),
                    ),
                    TextField(
                      controller: appNumController,
                      decoration:
                          const InputDecoration(labelText: 'Medication Number'),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Times:'),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (picked != null) {
                              setState(() => times.add(picked));
                            }
                          },
                        ),
                      ],
                    ),
                    ...times.map((t) => ListTile(
                          title: Text(t.format(context)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => setState(() => times.remove(t)),
                          ),
                        )),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty &&
                        appNumController.text.isNotEmpty) {
                      final med = MedicationModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        brandName: nameController.text,
                        applicationNumber: appNumController.text,
                        times: List.from(times),
                      );
                      Provider.of<MedicationProvider>(context, listen: false)
                          .addMedication(med);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MedicationProvider>();
    final medications = provider.medications;
    final today = DateTime.now();
    final dateStr = '${today.year}-${today.month}-${today.day}';
    return Scaffold(
      appBar: AppBar(
          title: const Text('Medication Schedule'),
          backgroundColor: Colors.blue),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: medications.length,
        itemBuilder: (context, index) {
          final med = medications[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text(med.brandName),
                    subtitle: Text('App No: ${med.applicationNumber}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showEditMedicationDialog(med),
                          tooltip: 'Edit',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => provider.deleteMedication(med.id),
                          tooltip: 'Delete',
                        ),
                      ],
                    ),
                  ),
                  if (med.times.isNotEmpty)
                    ...med.times.map((t) {
                      final timeStr = t.hour.toString().padLeft(2, '0') +
                          ':' +
                          t.minute.toString().padLeft(2, '0');
                      final displayTime = t.format(context);
                      final taken = provider.isTaken(
                        med.id,
                        dateStr,
                        timeStr,
                      );
                      final missed = provider.isMissed(
                        med.id,
                        dateStr,
                        timeStr,
                      );
                      return Row(
                        children: [
                          Expanded(
                            child: CheckboxListTile(
                              title: Text('Time: $displayTime'),
                              value: taken,
                              onChanged: (val) {
                                provider.toggleTaken(
                                  med.id,
                                  dateStr,
                                  timeStr,
                                  val ?? false,
                                );
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                              secondary: const Text('Taken'),
                            ),
                          ),
                          Checkbox(
                            value: missed,
                            onChanged: (val) {
                              provider.toggleMissed(
                                med.id,
                                dateStr,
                                timeStr,
                                val ?? false,
                              );
                            },
                          ),
                          const Text('Missed'),
                        ],
                      );
                    }).toList(),
                  if (med.times.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(left: 16.0, bottom: 8.0),
                      child: Text('No times set'),
                    ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMedicationDialog,
        child: const Icon(Icons.add),
        tooltip: 'Add Medication',
      ),
    );
  }

  void _showEditMedicationDialog(MedicationModel med) async {
    final nameController = TextEditingController(text: med.brandName);
    final appNumController = TextEditingController(text: med.applicationNumber);
    List<TimeOfDay> times = List.from(med.times);
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Medication'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration:
                          const InputDecoration(labelText: 'Medication Name'),
                    ),
                    TextField(
                      controller: appNumController,
                      decoration: const InputDecoration(
                          labelText: 'Application Number'),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Times:'),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (picked != null) {
                              setState(() => times.add(picked));
                            }
                          },
                        ),
                      ],
                    ),
                    ...times.map((t) => ListTile(
                          title: Text(t.format(context)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => setState(() => times.remove(t)),
                          ),
                        )),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isNotEmpty &&
                        appNumController.text.isNotEmpty) {
                      final edited = MedicationModel(
                        id: med.id,
                        brandName: nameController.text,
                        applicationNumber: appNumController.text,
                        times: List.from(times),
                      );
                      await Provider.of<MedicationProvider>(context,
                              listen: false)
                          .editMedication(edited);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
