// lib/screens/doctor_report_screen.dart
// STEP 4 — Doctor Report Screen
// Paste this file in: lib/screens/doctor_report_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/sugar_entry.dart';
import '../../../services/sugar_service.dart';
import '../../../services/pdf_service.dart';

class DoctorReportScreen extends StatefulWidget {
  const DoctorReportScreen({super.key});

  @override
  State<DoctorReportScreen> createState() => _DoctorReportScreenState();
}

class _DoctorReportScreenState extends State<DoctorReportScreen> {
  List<SugarEntry> _entries = [];
  bool _isLoading = true;
  bool _isGenerating = false;
  int _selectedDays = 30;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final entries = await SugarService.getRecentEntries(_selectedDays);
    entries.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    setState(() {
      _entries = entries;
      _isLoading = false;
    });
  }

  Future<void> _generate() async {
    if (_entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No entries to generate report')));
      return;
    }
    setState(() => _isGenerating = true);
    try {
      await PdfService.generateAndShareReport(_entries);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy, hh:mm a');
    return Scaffold(
      appBar: AppBar(
        title: const Text('📄 Doctor Report'),
        centerTitle: true,
        actions: [
          TextButton.icon(
            onPressed: _isGenerating ? null : _generate,
            icon: _isGenerating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.picture_as_pdf),
            label: const Text('Export PDF'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [7, 14, 30, 90].map((d) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text('${d}d'),
                    selected: _selectedDays == d,
                    onSelected: (_) {
                      setState(() => _selectedDays = d);
                      _load();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_entries.isEmpty)
            const Expanded(
                child: Center(child: Text('No entries for this period')))
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: _entries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (context, i) {
                  final e = _entries[i];
                  Color levelColor;
                  if (e.level < 70) levelColor = Colors.red;
                  else if (e.level <= 140) levelColor = Colors.green;
                  else if (e.level <= 200) levelColor = Colors.orange;
                  else levelColor = Colors.red;

                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: levelColor.withOpacity(0.15),
                        child: Text(
                          e.level.toStringAsFixed(0),
                          style: TextStyle(
                              color: levelColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                        ),
                      ),
                      title: Text(fmt.format(e.dateTime),
                          style: const TextStyle(fontSize: 13)),
                      subtitle: Text(e.type),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: levelColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(e.status,
                            style: TextStyle(
                                color: levelColor, fontSize: 11)),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
