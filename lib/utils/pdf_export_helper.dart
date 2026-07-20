import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfExportHelper {
  static Future<void> exportTextToPdf(String title, String content) async {
    final pdf = pw.Document();

    // Load THSarabunNew font from assets
    final fontData = await rootBundle.load('assets/fonts/THSarabunNew.ttf');
    final ttf = pw.Font.ttf(fontData);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Text(
              title,
              style: pw.TextStyle(
                font: ttf,
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 16),
            pw.Text(
              content,
              style: pw.TextStyle(
                font: ttf,
                fontSize: 18,
              ),
            ),
          ];
        },
      ),
    );

    try {
      final bytes = await pdf.save();
      await Printing.sharePdf(
        bytes: bytes,
        filename: '${title.replaceAll(' ', '_')}.pdf',
      );
    } catch (e) {
      debugPrint('Error exporting PDF: $e');
    }
  }
}
