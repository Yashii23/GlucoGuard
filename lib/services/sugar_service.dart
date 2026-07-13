// lib/services/sugar_service.dart
// Central service for storing/loading all sugar entries
// Paste this file in: lib/services/sugar_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/sugar_entry.dart';

class SugarService {
  static const _key = 'sugar_entries';

  /// Load all entries, sorted by dateTime descending (newest first)
  static Future<List<SugarEntry>> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final entries = raw
        .map((e) => SugarEntry.fromJson(jsonDecode(e)))
        .toList();
    entries.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return entries;
  }

  /// Save a new entry (appends to existing list)
  static Future<void> saveEntry(SugarEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    raw.add(jsonEncode(entry.toJson()));
    await prefs.setStringList(_key, raw);
  }

  /// Delete an entry by its dateTime string (unique identifier)
  static Future<void> deleteEntry(DateTime dateTime) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    raw.removeWhere((e) {
      final entry = SugarEntry.fromJson(jsonDecode(e));
      return entry.dateTime.toIso8601String() == dateTime.toIso8601String();
    });
    await prefs.setStringList(_key, raw);
  }

  /// Get entries for the last N days
  static Future<List<SugarEntry>> getRecentEntries(int days) async {
    final all = await loadEntries();
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return all.where((e) => e.dateTime.isAfter(cutoff)).toList();
  }

  /// Check if user logged sugar today
  static Future<bool> hasEntryToday() async {
    final all = await loadEntries();
    final now = DateTime.now();
    return all.any((e) =>
        e.dateTime.year == now.year &&
        e.dateTime.month == now.month &&
        e.dateTime.day == now.day);
  }
}
