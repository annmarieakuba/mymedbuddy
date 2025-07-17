import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_logs_provider.dart';
import '../models/healthlog_model.dart';
import '../widgets/health_logitem.dart';

class HealthLogsScreen extends StatefulWidget {
  const HealthLogsScreen({Key? key}) : super(key: key);

  @override
  State<HealthLogsScreen> createState() => _HealthLogsScreenState();
}

class _HealthLogsScreenState extends State<HealthLogsScreen> {
  String _filter = 'All';

  void _showAddLogDialog() {
    showDialog(
      context: context,
      builder: (context) => _HealthLogDialog(
          onSave: (log) =>
              context.read<HealthLogsProvider>().addHealthLog(log)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final healthLogsProvider = context.watch<HealthLogsProvider>();
    final filteredLogs = _filter == 'All'
        ? healthLogsProvider.healthLogs
        : healthLogsProvider.healthLogs
            .where((log) => log.type == _filter)
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Logs'),
        backgroundColor: Colors.red,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => setState(() => _filter = value),
            itemBuilder: (context) => healthLogsProvider.availableTypes
                .map((type) => PopupMenuItem(value: type, child: Text(type)))
                .toList(),
            child:
                Row(children: [Text(_filter), const Icon(Icons.filter_list)]),
          ),
          IconButton(icon: const Icon(Icons.add), onPressed: _showAddLogDialog),
        ],
      ),
      body: filteredLogs.isEmpty
          ? const Center(child: Text('No health logs yet'))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: filteredLogs.length,
              itemBuilder: (context, index) => HealthLogItem(
                healthLog: filteredLogs[index],
                onDelete: () =>
                    healthLogsProvider.removeHealthLog(filteredLogs[index].id),
              ),
            ),
    );
  }
}

class _HealthLogDialog extends StatefulWidget {
  final Function(HealthLog) onSave;
  const _HealthLogDialog({Key? key, required this.onSave}) : super(key: key);

  @override
  State<_HealthLogDialog> createState() => _HealthLogDialogState();
}

class _HealthLogDialogState extends State<_HealthLogDialog> {
  final _valueController = TextEditingController();
  String _selectedType = 'Blood Pressure';
  final _logTypes = [
    'Blood Pressure',
    'Heart Rate',
    'Weight',
    'Blood Sugar',
    'Temperature',
    'Sleep Hours',
    'Water Intake',
    'Exercise Minutes',
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Health Log'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedType,
            items: _logTypes
                .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                .toList(),
            onChanged: (value) => setState(() => _selectedType = value!),
          ),
          TextField(
              controller: _valueController,
              decoration: const InputDecoration(labelText: 'Value')),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        TextButton(
            onPressed: () {
              if (_valueController.text.isNotEmpty) {
                widget.onSave(HealthLog(
                  id: DateTime.now().toString(),
                  type: _selectedType,
                  value: _valueController.text,
                  date: DateTime.now(),
                ));
                Navigator.pop(context);
              }
            },
            child: const Text('Save')),
      ],
    );
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }
}
