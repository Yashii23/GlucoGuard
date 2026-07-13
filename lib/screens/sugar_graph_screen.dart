// lib/screens/sugar_graph_screen.dart
// STEP 3 — Sugar Graph (Line Chart)
// Paste this file in: lib/screens/sugar_graph_screen.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:diabetes_health_app/models/sugar_entry.dart';
import '../../../services/sugar_service.dart';

class SugarGraphScreen extends StatefulWidget {
  const SugarGraphScreen({super.key});

  @override
  State<SugarGraphScreen> createState() => _SugarGraphScreenState();
}

class _SugarGraphScreenState extends State<SugarGraphScreen> {
  List<SugarEntry> _entries = [];
  bool _isLoading = true;
  int _selectedDays = 7; // Default: last 7 days

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final entries = await SugarService.getRecentEntries(_selectedDays);
    // Sort by date ascending for the chart
    entries.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    setState(() {
      _entries = entries;
      _isLoading = false;
    });
  }

  /// Build chart spots from entries
  List<FlSpot> get _spots {
    if (_entries.isEmpty) return [];
    return _entries.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.level);
    }).toList();
  }

  /// Min Y value (floor at 40)
  double get _minY {
    if (_entries.isEmpty) return 40;
    return (_entries.map((e) => e.level).reduce((a, b) => a < b ? a : b) - 20)
        .clamp(0, double.infinity);
  }

  /// Max Y value (ceil at 400)
  double get _maxY {
    if (_entries.isEmpty) return 300;
    return (_entries.map((e) => e.level).reduce((a, b) => a > b ? a : b) + 30)
        .clamp(0, 500);
  }

  Color _levelColor(double level) {
    if (level < 70) return Colors.red;
    if (level <= 140) return Colors.green;
    if (level <= 200) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Sugar Trend'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [7, 14, 30].map((days) {
                final selected = _selectedDays == days;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text('${days}d'),
                    selected: selected,
                    onSelected: (_) {
                      setState(() => _selectedDays = days);
                      _loadData();
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_entries.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.show_chart, size: 80, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text('No entries in the last $_selectedDays days',
                        style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 24, 24),
                child: Column(
                  children: [
                    // Stats row
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatChip(
                            label: 'Avg',
                            value:
                                '${(_entries.map((e) => e.level).reduce((a, b) => a + b) / _entries.length).toStringAsFixed(1)}',
                            color: theme.colorScheme.primary,
                          ),
                          _StatChip(
                            label: 'Min',
                            value:
                                '${_entries.map((e) => e.level).reduce((a, b) => a < b ? a : b).toStringAsFixed(0)}',
                            color: Colors.green,
                          ),
                          _StatChip(
                            label: 'Max',
                            value:
                                '${_entries.map((e) => e.level).reduce((a, b) => a > b ? a : b).toStringAsFixed(0)}',
                            color: Colors.red,
                          ),
                          _StatChip(
                            label: 'Readings',
                            value: '${_entries.length}',
                            color: Colors.blueGrey,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Line Chart
                    Expanded(
                      child: LineChart(
                        LineChartData(
                          minY: _minY,
                          maxY: _maxY,
                          gridData: FlGridData(
                            show: true,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: isDark
                                  ? Colors.white12
                                  : Colors.grey.shade200,
                              strokeWidth: 1,
                            ),
                            drawVerticalLine: false,
                          ),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 44,
                                getTitlesWidget: (value, _) => Text(
                                  value.toInt().toString(),
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade500),
                                ),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                getTitlesWidget: (value, _) {
                                  final idx = value.toInt();
                                  if (idx >= _entries.length || idx < 0) {
                                    return const SizedBox();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      DateFormat('dd/MM')
                                          .format(_entries[idx].dateTime),
                                      style: TextStyle(
                                          fontSize: 9,
                                          color: Colors.grey.shade500),
                                    ),
                                  );
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                          ),
                          // Reference lines for normal range
                          extraLinesData: ExtraLinesData(
                            horizontalLines: [
                              HorizontalLine(
                                y: 70,
                                color: Colors.blue.withOpacity(0.4),
                                strokeWidth: 1.5,
                                dashArray: [5, 5],
                                label: HorizontalLineLabel(
                                  show: true,
                                  alignment: Alignment.topRight,
                                  labelResolver: (_) => 'Low (70)',
                                  style: const TextStyle(
                                      color: Colors.blue, fontSize: 10),
                                ),
                              ),
                              HorizontalLine(
                                y: 140,
                                color: Colors.green.withOpacity(0.4),
                                strokeWidth: 1.5,
                                dashArray: [5, 5],
                                label: HorizontalLineLabel(
                                  show: true,
                                  alignment: Alignment.topRight,
                                  labelResolver: (_) => 'Normal (140)',
                                  style: const TextStyle(
                                      color: Colors.green, fontSize: 10),
                                ),
                              ),
                              HorizontalLine(
                                y: 200,
                                color: Colors.red.withOpacity(0.4),
                                strokeWidth: 1.5,
                                dashArray: [5, 5],
                                label: HorizontalLineLabel(
                                  show: true,
                                  alignment: Alignment.topRight,
                                  labelResolver: (_) => 'High (200)',
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: _spots,
                              isCurved: true,
                              curveSmoothness: 0.3,
                              color: theme.colorScheme.primary,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, _, __, ___) =>
                                    FlDotCirclePainter(
                                  radius: 5,
                                  color: _levelColor(spot.y),
                                  strokeWidth: 2,
                                  strokeColor: Colors.white,
                                ),
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                color: theme.colorScheme.primary.withOpacity(0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
      ],
    );
  }
}
