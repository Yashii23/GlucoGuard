// lib/screens/food_warning_screen.dart
// STEP 7 — Food Warning Screen
// Paste this file in: lib/screens/food_warning_screen.dart

import 'package:flutter/material.dart';
import '../../../services/sugar_service.dart';

class FoodWarningScreen extends StatefulWidget {
  const FoodWarningScreen({super.key});

  @override
  State<FoodWarningScreen> createState() => _FoodWarningScreenState();
}

class _FoodWarningScreenState extends State<FoodWarningScreen> {
  double _latestLevel = 0;
  bool _isLoading = true;
  String _status = '';

  // Foods to avoid when sugar is high
  static const _avoidHighSugar = [
    '🍰 Cakes and pastries',
    '🥤 Sugary drinks & soda',
    '🍫 Chocolate and candy',
    '🍞 White bread and rice',
    '🍟 Fried foods',
    '🍦 Ice cream',
    '🥞 Pancakes with syrup',
    '🍇 High-sugar fruits (grapes, mangoes)',
    '🧁 Donuts and muffins',
    '🍕 Pizza with white crust',
  ];

  // Foods recommended when sugar is low
  static const _eatLowSugar = [
    '🍊 Orange juice (small glass)',
    '🍬 4–5 glucose tablets',
    '🥛 Regular milk (not skim)',
    '🍌 Banana (half)',
    '🍯 1 tablespoon honey',
    '🧃 Apple juice',
    '🍭 Hard candy (3–4 pieces)',
    '🥤 Regular soda (not diet)',
    '🫐 Raisins (2 tablespoons)',
    '🍞 White bread (1 slice)',
  ];

  // Healthy foods for normal/management
  static const _healthyFoods = [
    '🥦 Broccoli and leafy greens',
    '🥑 Avocado',
    '🐟 Salmon and fish',
    '🥚 Eggs',
    '🫘 Legumes (lentils, beans)',
    '🥜 Nuts (almonds, walnuts)',
    '🍓 Berries (strawberries, blueberries)',
    '🌾 Whole grains',
    '🥗 Salads with olive oil',
    '🍗 Lean protein (chicken)',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await SugarService.loadEntries();
    if (entries.isNotEmpty) {
      setState(() {
        _latestLevel = entries.first.level; // Most recent (sorted desc)
        if (_latestLevel < 70) _status = 'low';
        else if (_latestLevel <= 140) _status = 'normal';
        else _status = 'high';
        _isLoading = false;
      });
    } else {
      setState(() {
        _latestLevel = 0;
        _status = 'nodata';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🍽️ Food Guide'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load)
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _status == 'nodata'
              ? const Center(child: Text('No sugar entries found.\nLog your first reading!',
                  textAlign: TextAlign.center))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status card
                      _StatusBanner(level: _latestLevel, status: _status),
                      const SizedBox(height: 24),

                      if (_status == 'low') ...[
                        _FoodSection(
                          title: '⚡ Eat These IMMEDIATELY (Raise Sugar)',
                          subtitle: 'Your sugar is LOW — act fast!',
                          foods: _eatLowSugar,
                          color: Colors.blue,
                          icon: Icons.add_circle,
                        ),
                      ] else if (_status == 'high') ...[
                        _FoodSection(
                          title: '🚫 AVOID These Foods',
                          subtitle: 'Your sugar is HIGH — skip these!',
                          foods: _avoidHighSugar,
                          color: Colors.red,
                          icon: Icons.cancel,
                        ),
                        const SizedBox(height: 20),
                        _FoodSection(
                          title: '✅ Eat These Instead',
                          subtitle: 'Safe options to help lower your sugar',
                          foods: _healthyFoods,
                          color: Colors.green,
                          icon: Icons.check_circle,
                        ),
                      ] else ...[
                        _FoodSection(
                          title: '✅ Maintain with Healthy Foods',
                          subtitle: 'Your sugar is normal — keep it up!',
                          foods: _healthyFoods,
                          color: Colors.green,
                          icon: Icons.favorite,
                        ),
                      ],

                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber, color: Colors.amber),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Always follow your doctor\'s dietary advice. '
                                'This guide is for general reference only.',
                                style: TextStyle(
                                    color: Colors.amber.shade900,
                                    fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final double level;
  final String status;

  const _StatusBanner({required this.level, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String emoji, label;
    if (status == 'low') {
      color = Colors.blue;
      emoji = '📉';
      label = 'Low Blood Sugar';
    } else if (status == 'high') {
      color = Colors.red;
      emoji = '📈';
      label = 'High Blood Sugar';
    } else {
      color = Colors.green;
      emoji = '✅';
      label = 'Normal Blood Sugar';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 8),
          Text('${level.toStringAsFixed(0)} mg/dL',
              style: TextStyle(
                  fontSize: 32, fontWeight: FontWeight.bold, color: color)),
          Text(label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Latest reading',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        ],
      ),
    );
  }
}

class _FoodSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> foods;
  final Color color;
  final IconData icon;

  const _FoodSection({
    required this.title,
    required this.subtitle,
    required this.foods,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: color)),
                Text(subtitle,
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ),
        ]),
        const SizedBox(height: 10),
        ...foods.map((food) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.circle, size: 6, color: color),
                  const SizedBox(width: 10),
                  Text(food, style: const TextStyle(fontSize: 14)),
                ],
              ),
            )),
      ],
    );
  }
}
