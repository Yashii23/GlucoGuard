class InsulinEntry {
  final double dose;
  final String insulinType;
  final DateTime dateTime;
  final String? notes;

  InsulinEntry({
    required this.dose,
    required this.insulinType,
    required this.dateTime,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'dose': dose,
      'insulinType': insulinType,
      'dateTime': dateTime.toIso8601String(),
      'notes': notes ?? '',
    };
  }

  factory InsulinEntry.fromJson(Map<String, dynamic> json) {
    return InsulinEntry(
      dose: (json['dose'] as num?)?.toDouble() ?? 0.0,
      insulinType: json['insulinType'] ?? '',
      dateTime: json['dateTime'] != null
          ? DateTime.parse(json['dateTime'])
          : DateTime.now(),
      notes: json['notes'],
    );
  }
}