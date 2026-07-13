// lib/screens/add_previous_entry_screen.dart
// STEP 2 — Add Previous Sugar Entry
// Paste this file in: lib/screens/add_previous_entry_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/sugar_entry.dart';
import '../../../services/sugar_service.dart';

class AddPreviousEntryScreen extends StatefulWidget {
  const AddPreviousEntryScreen({super.key});

  @override
  State<AddPreviousEntryScreen> createState() => _AddPreviousEntryScreenState();
}

class _AddPreviousEntryScreenState extends State<AddPreviousEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _levelController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedType = 'Fasting';

  final List<String> _types = [
    'Fasting',
    'Post-meal',
    'Random',
    'Before Bed',
    'Pre-meal',
  ];

  bool _isSaving = false;

  @override
  void dispose() {
    _levelController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(), // Cannot pick future date
      helpText: 'Select Entry Date',
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      helpText: 'Select Entry Time',
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    // Combine selected date and time
    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final entry = SugarEntry(
      level: double.parse(_levelController.text.trim()),
      dateTime: dateTime,
      type: _selectedType,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    await SugarService.saveEntry(entry);
    setState(() => _isSaving = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Entry saved successfully ✅'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context, true); // Return true to trigger refresh
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM yyyy').format(_selectedDate);
    final timeStr = _selectedTime.format(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🕒 Add Previous Entry'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date & Time row
              Row(
                children: [
                  Expanded(
                    child: _DateTimeCard(
                      icon: Icons.calendar_today,
                      label: 'Date',
                      value: dateStr,
                      onTap: _pickDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DateTimeCard(
                      icon: Icons.access_time,
                      label: 'Time',
                      value: timeStr,
                      onTap: _pickTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Sugar level input
              Text('Sugar Level (mg/dL)',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _levelController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'e.g. 120',
                  prefixIcon: const Icon(Icons.bloodtype),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter sugar level';
                  }
                  final num = double.tryParse(val.trim());
                  if (num == null || num <= 0 || num > 600) {
                    return 'Enter a valid value (1–600)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Type dropdown
              Text('Reading Type',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  prefixIcon: const Icon(Icons.category),
                ),
                items: _types
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (val) =>
                    setState(() => _selectedType = val ?? 'Fasting'),
              ),
              const SizedBox(height: 20),

              // Notes
              Text('Notes (optional)',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'e.g. After lunch, felt dizzy...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                ),
              ),
              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveEntry,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.save),
                  label:
                      Text(_isSaving ? 'Saving...' : 'Save Entry',
                          style: const TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small tappable card for date/time display
class _DateTimeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateTimeCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 6),
                  Text(label,
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 6),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 4),
              Text('Tap to change',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}
