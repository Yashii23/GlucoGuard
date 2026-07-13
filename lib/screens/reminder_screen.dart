// lib/screens/reminder_screen.dart
// STEP 1 — Reminder System Screen
// Paste this file in: lib/screens/reminder_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/notification_service.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  // List of active reminders (stored as "HH:mm" strings)
  List<String> _reminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  /// Load saved reminders from SharedPreferences
  Future<void> _loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _reminders = prefs.getStringList('reminders') ?? [];
      _isLoading = false;
    });
  }

  /// Save reminders list to SharedPreferences
  Future<void> _saveReminders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('reminders', _reminders);
  }

  /// Show time picker and add reminder
  Future<void> _addReminder() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'Select Reminder Time',
    );
//'/reminders': (_) => const ReminderScreen();

if (picked == null) return;
    if (picked == null) return;

    // Format as "HH:mm" with leading zero
    final hour = picked.hour.toString().padLeft(2, '0');
    final minute = picked.minute.toString().padLeft(2, '0');
    final timeStr = '$hour:$minute';

    if (_reminders.contains(timeStr)) {
      _showSnack('Reminder already exists for $timeStr');
      return;
    }

    setState(() => _reminders.add(timeStr));
    await _saveReminders();

    // Schedule notification (ID based on index)
    final id = _reminders.indexOf(timeStr);
    await NotificationService().scheduleDailyReminder(
      id: id,
      title: '🩸 Sugar Check Reminder',
      body: 'Time to log your blood sugar level!',
      hour: picked.hour,
      minute: picked.minute,
    );

    _showSnack('Reminder set for $timeStr ✅');
  }

  /// Delete a reminder by index
  Future<void> _deleteReminder(int index) async {
    await NotificationService().cancelReminder(index);
    setState(() => _reminders.removeAt(index));
    await _saveReminders();
    _showSnack('Reminder removed');
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔔 Reminders'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addReminder,
        icon: const Icon(Icons.add_alarm),
        label: const Text('Add Reminder'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reminders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off,
                          size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'No reminders set',
                        style: TextStyle(
                            fontSize: 18, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap + to add your first reminder',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _reminders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final time = _reminders[index];
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          child: Icon(Icons.alarm,
                              color: Theme.of(context).colorScheme.primary),
                        ),
                        title: Text(
                          time,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text('Daily sugar check reminder'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteReminder(index),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
