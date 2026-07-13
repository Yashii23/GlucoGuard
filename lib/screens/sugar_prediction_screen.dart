// lib/screens/sugar_prediction_screen.dart
// STEP 6 — Sugar Prediction Screen
// Paste this file in: lib/screens/sugar_prediction_screen.dart

import 'package:flutter/material.dart';
import '../../../services/prediction_service.dart';
import '../../../services/sugar_service.dart';
import '../../../models/sugar_entry.dart';

class SugarPredictionScreen extends StatefulWidget {
  const SugarPredictionScreen({super.key});

  @override
  State<SugarPredictionScreen> createState() => _SugarPredictionScreenState();
}

class _SugarPredictionScreenState extends State<SugarPredictionScreen> {
  List<SugarEntry> _entries = [];
  bool _isLoading = true;
  double _prediction = 0;
  String _confidence = '';
  String _trend = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final entries = await SugarService.getRecentEntries(14);
    final prediction = PredictionService.predictNext(entries);
    final confidence = PredictionService.confidenceMessage(entries.length);
    final trend = PredictionService.trendDirection(entries);
    setState(() {
      _entries = entries;
      _prediction = prediction;
      _confidence = confidence;
      _trend = trend;
      _isLoading = false;
    });
  }

  Color _predictionColor() {
    if (_prediction < 70) return Colors.red;
    if (_prediction <= 140) return Colors.green;
    if (_prediction <= 200) return Colors.orange;
    return Colors.red;
  }

  String _predictionLabel() {
    if (_prediction < 70) return 'Predicted LOW ⚠️';
    if (_prediction <= 140) return 'Predicted NORMAL ✅';
    if (_prediction <= 200) return 'Predicted HIGH ⚠️';
    return 'Predicted VERY HIGH 🚨';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧠 Sugar Prediction'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load)
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Main prediction card
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Text('Next Predicted Reading',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey)),
                          const SizedBox(height: 16),
                          Text(
                            '${_prediction.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 72,
                              fontWeight: FontWeight.bold,
                              color: _predictionColor(),
                            ),
                          ),
                          Text('mg/dL',
                              style: TextStyle(color: Colors.grey.shade500)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: _predictionColor().withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(_predictionLabel(),
                                style: TextStyle(
                                    color: _predictionColor(),
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Trend and Confidence
                  Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          title: 'Trend',
                          value: _trend,
                          icon: Icons.trending_up,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoCard(
                          title: 'Based on',
                          value: '${_entries.length} readings\n$_confidence',
                          icon: Icons.analytics,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // How it works
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.info_outline, size: 18),
                              SizedBox(width: 8),
                              Text('How this works',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'This prediction uses a weighted moving average of your last '
                            '${_entries.length > 5 ? 5 : _entries.length} sugar entries, '
                            'with recent readings given more importance. '
                            'It also factors in the recent trend direction.\n\n'
                            '⚠️ This is NOT a medical prediction. Always consult your doctor.',
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 13),
                          ),
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

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _InfoCard(
      {required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 6),
              Text(title,
                  style: TextStyle(
                      color: Colors.grey.shade600, fontSize: 12)),
            ]),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
