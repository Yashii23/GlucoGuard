// lib/screens/insulin_log_screen.dart
// STEP 5 — Insulin Log Screen
// Paste this file in: lib/screens/insulin_log_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:diabetes_health_app/models/insulin_entry.dart';

class InsulinLogScreen extends StatefulWidget {
  const InsulinLogScreen({super.key});

  @override
  State<InsulinLogScreen> createState() => _InsulinLogScreenState();
}

class _InsulinLogScreenState extends State<InsulinLogScreen> {
  static const _key = 'insulin_entries';
  List<InsulinEntry> _entries = [];
  bool _isLoading = true;

  final _doseController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedType = 'Rapid-acting';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  final List<String> _insulinTypes = [
    'Rapid-acting',
    'Short-acting',
    'Intermediate-acting',
    'Long-acting',
    'Ultra-long-acting',
    'Mixed',
  ];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  @override
  void dispose() {
    _doseController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final entries = raw
        .map((e) => InsulinEntry.fromJson(jsonDecode(e)))
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    setState(() {
      _entries = entries;
      _isLoading = false;
    });
  }

  Future<void> _saveEntry(InsulinEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    raw.add(jsonEncode(entry.toJson()));
    await prefs.setStringList(_key, raw);
  }

  Future<void> _deleteEntry(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    // Match by dateTime
    final target = _entries[index].dateTime.toIso8601String();
    raw.removeWhere((e) {
      final entry = InsulinEntry.fromJson(jsonDecode(e));
      return entry.dateTime.toIso8601String() == target;
    });
    await prefs.setStringList(_key, raw);
    _loadEntries();
  }

  void _showAddDialog() {
    _doseController.clear();
    _notesController.clear();
    _selectedType = 'Rapid-acting';
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Log Insulin Dose',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                // Dose input
                TextField(
                  controller: _doseController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Dose (units)',
                    prefixIcon: const Icon(Icons.vaccines),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),

                // Type dropdown
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: InputDecoration(
                    labelText: 'Insulin Type',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    prefixIcon: const Icon(Icons.science),
                  ),
                  items: _insulinTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (val) =>
                      setModalState(() => _selectedType = val ?? 'Rapid-acting'),
                ),
                const SizedBox(height: 12),

                // Date & Time pickers
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text(DateFormat('dd MMM').format(_selectedDate)),
                        onPressed: () async {
                          final d = await showDatePicker(
                            context: ctx,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (d != null) setModalState(() => _selectedDate = d);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.access_time, size: 16),
                        label: Text(_selectedTime.format(ctx)),
                        onPressed: () async {
                          final t = await showTimePicker(
                            context: ctx,
                            initialTime: _selectedTime,
                          );
                          if (t != null) setModalState(() => _selectedTime = t);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Notes
                TextField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: 'Notes (optional)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 20),

                // Save
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Save Insulin Log'),
                    onPressed: () async {
                      final doseText = _doseController.text.trim();
                      if (doseText.isEmpty || double.tryParse(doseText) == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Enter a valid dose')));
                        return;
                      }
                      final dateTime = DateTime(
                        _selectedDate.year,
                        _selectedDate.month,
                        _selectedDate.day,
                        _selectedTime.hour,
                        _selectedTime.minute,
                      );
                      final entry = InsulinEntry(
                        dose: double.parse(doseText),
                        insulinType: _selectedType,
                        dateTime: dateTime,
                        notes: _notesController.text.trim().isEmpty
                            ? null
                            : _notesController.text.trim(),
                      );
                      await _saveEntry(entry);
                      Navigator.pop(ctx);
                      _loadEntries();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy, hh:mm a');
    return Scaffold(
      appBar: AppBar(
        title: const Text('💉 Insulin Log'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Log Dose'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.vaccines,
                          size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text('No insulin logs yet',
                          style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(12).copyWith(bottom: 80),
                  itemCount: _entries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (context, i) {
                    final e = _entries[i];
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.purple.shade50,
                          child: Text(
                            '${e.dose.toStringAsFixed(0)}U',
                            style: const TextStyle(
                                color: Colors.purple,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                        ),
                        title: Text(e.insulinType,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(fmt.format(e.dateTime),
                            style: const TextStyle(fontSize: 12)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          onPressed: () => showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Delete Entry?'),
                              content: const Text(
                                  'This insulin log will be permanently deleted.'),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel')),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _deleteEntry(i);
                                  },
                                  child: const Text('Delete',
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
