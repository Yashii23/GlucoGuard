// lib/services/prediction_service.dart
// STEP 6 — Sugar Prediction Service (Simple Linear Trend)
// Paste this file in: lib/services/prediction_service.dart

import '../../../models/sugar_entry.dart';

class PredictionService {
  /// Predicts the next sugar level based on last N entries
  /// Uses weighted moving average (recent entries have more weight)
  static double predictNext(List<SugarEntry> entries) {
    if (entries.isEmpty) return 100.0;
    if (entries.length == 1) return entries.first.level;

    // Sort ascending
    final sorted = List<SugarEntry>.from(entries)
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    // Take last 5 entries max
    final recent = sorted.length > 5
        ? sorted.sublist(sorted.length - 5)
        : sorted;

    // Weighted average: latest has highest weight
    double totalWeight = 0;
    double weightedSum = 0;
    for (int i = 0; i < recent.length; i++) {
      final weight = (i + 1).toDouble(); // 1, 2, 3, ...
      weightedSum += recent[i].level * weight;
      totalWeight += weight;
    }

    final weightedAvg = weightedSum / totalWeight;

    // Calculate simple trend (slope)
    if (recent.length >= 2) {
      final last = recent.last.level;
      final secondLast = recent[recent.length - 2].level;
      final trend = (last - secondLast) * 0.5; // Dampen the trend
      return (weightedAvg + trend).clamp(40, 500);
    }

    return weightedAvg.clamp(40, 500);
  }

  /// Returns confidence message based on data quality
  static String confidenceMessage(int entryCount) {
    if (entryCount < 3) return 'Low confidence (need more data)';
    if (entryCount < 7) return 'Moderate confidence';
    return 'Good confidence';
  }

  /// Returns trend direction
  static String trendDirection(List<SugarEntry> entries) {
    if (entries.length < 2) return 'Insufficient data';
    final sorted = List<SugarEntry>.from(entries)
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    final recent = sorted.length > 3 ? sorted.sublist(sorted.length - 3) : sorted;
    final first = recent.first.level;
    final last = recent.last.level;
    final diff = last - first;
    if (diff > 10) return '📈 Rising';
    if (diff < -10) return '📉 Falling';
    return '➡️ Stable';
  }
}
