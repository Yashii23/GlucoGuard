// lib/models/sugar_entry.dart
// Extended Sugar Entry Model — supports past date/time
// If you already have this file, REPLACE it with this version.
// This is backward-compatible (same fields, just adds fromJson/toJson helpers).

class SugarEntry {
  final double level;        // Blood sugar level (mg/dL or mmol/L)
  final DateTime dateTime;   // Date and time of the reading
  final String type;         // e.g., "Fasting", "Post-meal", "Random"
  final String? notes;       // Optional notes

  SugarEntry({
    required this.level,
    required this.dateTime,
    required this.type,
    this.notes,
  });

  /// Convert to Map for SharedPreferences storage
  Map<String, dynamic> toJson() => {
        'level': level,
        'dateTime': dateTime.toIso8601String(),
        'type': type,
        'notes': notes ?? '',
      };

  /// Create from Map (when loading from SharedPreferences)
  factory SugarEntry.fromJson(Map<String, dynamic> json) => SugarEntry(
        level: (json['level'] as num).toDouble(),
        dateTime: DateTime.parse(json['dateTime'] as String),
        type: json['type'] as String,
        notes: json['notes'] as String?,
      );

  /// Human-readable label for sugar level status
  String get status {
    if (level < 70) return 'Low 🔴';
    if (level <= 140) return 'Normal 🟢';
    if (level <= 200) return 'High 🟡';
    return 'Very High 🔴';
  }

  /// Color code for status
  String get statusColor {
    if (level < 70) return 'red';
    if (level <= 140) return 'green';
    if (level <= 200) return 'orange';
    return 'red';
  }
}
