import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/user_model.dart';
import '../providers/medication_provider.dart';
import '../models/medication_model.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final List<_MedInput> _medInputs = [_MedInput()];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    for (final med in _medInputs) {
      med.dispose();
    }
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final userProvider = context.read<UserProvider>();
      final medicationProvider = context.read<MedicationProvider>();
      final meds = <String>[];
      for (final medInput in _medInputs) {
        final name = medInput.nameController.text.trim();
        if (name.isNotEmpty) {
          meds.add(name);
          medicationProvider.addMedication(MedicationModel(
            id: DateTime.now().millisecondsSinceEpoch.toString() + name,
            brandName: name,
            applicationNumber: 'N/A',
            times: List.from(medInput.times),
          ));
        }
      }
      userProvider.updateUser(UserModel(
        name: _nameController.text,
        age: int.tryParse(_ageController.text),
        medications: meds,
      ));
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Onboarding')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Enter name' : null,
              ),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Enter age' : null,
              ),
              const SizedBox(height: 16),
              const Text('Medications',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ..._medInputs.map((medInput) => _MedicationInputWidget(
                    medInput: medInput,
                    onRemove: _medInputs.length > 1
                        ? () {
                            setState(() {
                              _medInputs.remove(medInput);
                            });
                          }
                        : null,
                  )),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Medication'),
                  onPressed: () {
                    setState(() {
                      _medInputs.add(_MedInput());
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: _submitForm, child: const Text('Submit')),
            ],
          ),
        ),
      ),
    );
  }
}

class _MedInput {
  final TextEditingController nameController = TextEditingController();
  final List<TimeOfDay> times = [];
  void dispose() => nameController.dispose();
}

class _MedicationInputWidget extends StatefulWidget {
  final _MedInput medInput;
  final VoidCallback? onRemove;
  const _MedicationInputWidget(
      {required this.medInput, this.onRemove, Key? key})
      : super(key: key);

  @override
  State<_MedicationInputWidget> createState() => _MedicationInputWidgetState();
}

class _MedicationInputWidgetState extends State<_MedicationInputWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: widget.medInput.nameController,
                    decoration:
                        const InputDecoration(labelText: 'Medication Name'),
                    validator: (value) =>
                        value!.isEmpty ? 'Enter medication name' : null,
                  ),
                ),
                if (widget.onRemove != null)
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: widget.onRemove,
                  ),
              ],
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
                      setState(() => widget.medInput.times.add(picked));
                    }
                  },
                ),
              ],
            ),
            ...widget.medInput.times.map((t) => ListTile(
                  title: Text(t.format(context)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () =>
                        setState(() => widget.medInput.times.remove(t)),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
