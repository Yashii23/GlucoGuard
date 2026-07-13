// lib/screens/stability_score_screen.dart
// STEP 8 — Weekly Diabetes Stability Score
// Paste this file in: lib/screens/stability_score_screen.dart

import 'dart:math';
import 'package:flutter/material.dart';
import '../../../services/sugar_service.dart';
import '../../../models/sugar_entry.dart';

class StabilityScoreScreen extends StatefulWidget {
  const StabilityScoreScreen({super.key});

  @override
  State<StabilityScoreScreen> createState() => _StabilityScoreScreenState();
}

class _StabilityScoreScreenState extends State<StabilityScoreScreen> {
  List<SugarEntry> _entries = [];
  bool _isLoading = true;
  int _score = 0;
  double _avg = 0;
  double _stdDev = 0;
  String _grade = '';
  String _feedback = '';
  Color _gradeColor = Colors.green;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final entries = await SugarService.getRecentEntries(7);
    if (entries.isEmpty) {
      setState(() {
        _entries = [];
        _isLoading = false;
      });
      return;
    }

    // Calculate average
    final avg = entries.map((e) => e.level).reduce((a, b) => a + b) / entries.length;

    // Calculate standard deviation (variability)
    final variance = entries.map((e) => pow(e.level - avg, 2)).reduce((a, b) => a + b) / entries.length;
    final stdDev = sqrt(variance);

    // Score algorithm:
    // - Base 50 points for having readings
    // - Up to 30 points for being in normal range (70-140)
    // - Up to 20 points for low variability

    int score = 50;

    // Average score (30 pts)
    if (avg >= 70 && avg <= 140) {
      score += 30;
    } else if (avg >= 60 && avg <= 180) {
      score += 15;
    } else if (avg >= 50 && avg <= 220) {
      score += 5;
    }

    // Variability score (20 pts)
    if (stdDev <= 20) score += 20;
    else if (stdDev <= 40) score += 14;
    else if (stdDev <= 60) score += 8;
    else if (stdDev <= 80) score += 3;

    // Clamp to 0-100
    score = score.clamp(0, 100);

    // Grade
    String grade;
    String feedback;
    Color gradeColor;
    if (score >= 85) {
      grade = 'A+';
      feedback = 'Excellent! Your blood sugar is very well controlled.';
      gradeColor = Colors.green;
    } else if (score >= 70) {
      grade = 'B';
      feedback = 'Good control. Minor fluctuations. Keep monitoring.';
      gradeColor = Colors.lightGreen;
    } else if (score >= 55) {
      grade = 'C';
      feedback = 'Moderate control. Consider adjusting diet and medication.';
      gradeColor = Colors.orange;
    } else if (score >= 40) {
      grade = 'D';
      feedback = 'Poor control. Please consult your doctor soon.';
      gradeColor = Colors.deepOrange;
    } else {
      grade = 'F';
      feedback = 'Critical. Seek medical attention immediately.';
      gradeColor = Colors.red;
    }

    setState(() {
      _entries = entries;
      _score = score;
      _avg = avg;
      _stdDev = stdDev;
      _grade = grade;
      _feedback = feedback;
      _gradeColor = gradeColor;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📈 Stability Score'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load)
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? const Center(
                  child: Text('Not enough data.\nLog sugar readings first!',
                      textAlign: TextAlign.center))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text('Weekly Stability Score',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Based on last ${_entries.length} readings',
                          style: TextStyle(color: Colors.grey.shade600)),
                      const SizedBox(height: 24),

                      // Score circle
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _gradeColor.withOpacity(0.1),
                          border: Border.all(color: _gradeColor, width: 6),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$_score',
                              style: TextStyle(
                                  fontSize: 56,
                                  fontWeight: FontWeight.bold,
                                  color: _gradeColor),
                            ),
                            Text('/100',
                                style: TextStyle(color: Colors.grey.shade500)),
                            Text(_grade,
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: _gradeColor)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Feedback
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _gradeColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: _gradeColor.withOpacity(0.3)),
                        ),
                        child: Text(_feedback,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 15, color: _gradeColor)),
                      ),
                      const SizedBox(height: 20),

                      // Stats
                      Row(
                        children: [
                          Expanded(
                            child: _ScoreCard(
                              label: 'Average Sugar',
                              value: '${_avg.toStringAsFixed(1)} mg/dL',
                              icon: Icons.analytics,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ScoreCard(
                              label: 'Variability (SD)',
                              value: '±${_stdDev.toStringAsFixed(1)} mg/dL',
                              icon: Icons.show_chart,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Score breakdown
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Score Breakdown',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                              const Divider(),
                              _ScoreRow('Base score', '50 pts'),
                              _ScoreRow('Average sugar quality',
                                  'Up to 30 pts'),
                              _ScoreRow('Low variability bonus',
                                  'Up to 20 pts'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ScoreCard(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.grey.shade600, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String label;
  final String value;

  const _ScoreRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
