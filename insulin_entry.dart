// lib/models/insulin_entry.dart
// STEP 5 — Insulin Entry Model
// Paste this file in: lib/models/insulin_entry.dart

class InsulinEntry {
  final double dose;         // Units of insulin
  final String insulinType;  // e.g., "Rapid-acting", "Long-acting"
  final DateTime dateTime;
  final String? notes;

  InsulinEntry({
    required this.dose,
    required this.insulinType,
    required this.dateTime,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'dose': dose,
        'insulinType': insulinType,
        'dateTime': dateTime.toIso8601String(),
        'notes': notes ?? '',
      };

  factory InsulinEntry.fromJson(Map<String, dynamic> json) => InsulinEntry(
        dose: (json['dose'] as num).toDouble(),
        insulinType: json['insulinType'] as String,
        dateTime: DateTime.parse(json['dateTime'] as String),
        notes: json['notes'] as String?,
      );
}
