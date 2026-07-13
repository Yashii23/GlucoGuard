// lib/services/pdf_service.dart
// STEP 4 — Doctor Report PDF Generator
// Paste this file in: lib/services/pdf_service.dart

import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../models/sugar_entry.dart';

class PdfService {
  /// Generate and share/print a doctor report PDF
  static Future<void> generateAndShareReport(
      List<SugarEntry> entries) async {
    final pdf = pw.Document();

    // Sort entries by date ascending
    final sorted = List<SugarEntry>.from(entries)
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    final dateFormat = DateFormat('dd MMM yyyy');
    final timeFormat = DateFormat('hh:mm a');
    final now = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());

    // Calculate stats
    double avg = 0, minVal = double.infinity, maxVal = 0;
    int normalCount = 0, highCount = 0, lowCount = 0;
    if (sorted.isNotEmpty) {
      avg = sorted.map((e) => e.level).reduce((a, b) => a + b) / sorted.length;
      minVal = sorted.map((e) => e.level).reduce((a, b) => a < b ? a : b);
      maxVal = sorted.map((e) => e.level).reduce((a, b) => a > b ? a : b);
      for (final e in sorted) {
        if (e.level < 70) lowCount++;
        else if (e.level <= 140) normalCount++;
        else highCount++;
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Blood Sugar Report',
                        style: pw.TextStyle(
                            fontSize: 22, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Generated: $now',
                        style: const pw.TextStyle(
                            fontSize: 10, color: PdfColors.grey600)),
                  ],
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue50,
                    borderRadius: const pw.BorderRadius.all(
                        pw.Radius.circular(8)),
                  ),
                  child: pw.Text('🩺 Diabetes Health App',
                      style: const pw.TextStyle(
                          fontSize: 11, color: PdfColors.blue800)),
                ),
              ],
            ),
            pw.Divider(color: PdfColors.blue300, thickness: 1.5),
            pw.SizedBox(height: 4),
          ],
        ),
        build: (_) => [
          // Summary stats
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Summary',
                    style: pw.TextStyle(
                        fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    _pdfStat('Total Readings', '${sorted.length}'),
                    _pdfStat('Average', '${avg.toStringAsFixed(1)} mg/dL'),
                    _pdfStat('Min', '${minVal.toStringAsFixed(0)} mg/dL'),
                    _pdfStat('Max', '${maxVal.toStringAsFixed(0)} mg/dL'),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    _pdfStat('Normal', '$normalCount readings', PdfColors.green700),
                    _pdfStat('High', '$highCount readings', PdfColors.orange700),
                    _pdfStat('Low', '$lowCount readings', PdfColors.red700),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Table
          pw.Text('Detailed Readings',
              style: pw.TextStyle(
                  fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(1.5),
              2: const pw.FlexColumnWidth(1.5),
              3: const pw.FlexColumnWidth(2),
              4: const pw.FlexColumnWidth(1.5),
            },
            children: [
              // Header row
              pw.TableRow(
                decoration:
                    const pw.BoxDecoration(color: PdfColors.blue800),
                children: [
                  _tableHeader('Date'),
                  _tableHeader('Time'),
                  _tableHeader('Level\n(mg/dL)'),
                  _tableHeader('Type'),
                  _tableHeader('Status'),
                ],
              ),
              // Data rows
              ...sorted.asMap().entries.map((entry) {
                final idx = entry.key;
                final e = entry.value;
                final isEven = idx % 2 == 0;
                PdfColor statusColor;
                if (e.level < 70) statusColor = PdfColors.red700;
                else if (e.level <= 140) statusColor = PdfColors.green700;
                else if (e.level <= 200) statusColor = PdfColors.orange700;
                else statusColor = PdfColors.red700;

                return pw.TableRow(
                  decoration: pw.BoxDecoration(
                      color: isEven ? PdfColors.white : PdfColors.grey50),
                  children: [
                    _tableCell(dateFormat.format(e.dateTime)),
                    _tableCell(timeFormat.format(e.dateTime)),
                    _tableCell(e.level.toStringAsFixed(0),
                        bold: true),
                    _tableCell(e.type),
                    _tableCellColored(e.status.split(' ').first, statusColor),
                  ],
                );
              }),
            ],
          ),
          pw.SizedBox(height: 20),

          // Disclaimer
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.orange300),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              color: PdfColors.orange50,
            ),
            child: pw.Text(
              '⚠️ This report is generated for informational purposes only. '
              'Please consult your healthcare provider for medical advice.',
              style: const pw.TextStyle(
                  fontSize: 9, color: PdfColors.orange900),
            ),
          ),
        ],
      ),
    );

    // Share/print the PDF
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'sugar_report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }

  static pw.Widget _pdfStat(String label, String value,
      [PdfColor color = PdfColors.black]) {
    return pw.Column(
      children: [
        pw.Text(value,
            style: pw.TextStyle(
                fontSize: 12, fontWeight: pw.FontWeight.bold, color: color)),
        pw.Text(label,
            style:
                const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
      ],
    );
  }

  static pw.Widget _tableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text,
          style: pw.TextStyle(
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
              fontSize: 10),
          textAlign: pw.TextAlign.center),
    );
  }

  static pw.Widget _tableCell(String text, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text,
          style: pw.TextStyle(
              fontSize: 9,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal),
          textAlign: pw.TextAlign.center),
    );
  }

  static pw.Widget _tableCellColored(String text, PdfColor color) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text,
          style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: color),
          textAlign: pw.TextAlign.center),
    );
  }
}
