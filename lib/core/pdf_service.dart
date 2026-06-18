import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/siswa_model.dart';

class PdfService {
  static Future<void> generateAndPrintSiswaReport(List<Siswa> siswaList) async {
    final pdf = pw.Document();

    // Adding a page
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Laporan Kedisiplinan Sekolah',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.indigo,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Dicetak pada: ${DateTime.now().toLocal().toString().split('.')[0]}',
                style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
              ),
              pw.Divider(thickness: 2, color: PdfColors.indigo300),
              pw.SizedBox(height: 16),
            ],
          );
        },
        build: (context) => [
          pw.Text(
            'Daftar Siswa (Ringkasan)',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
          pw.TableHelper.fromTextArray(
            context: context,
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
            headerStyle: pw.TextStyle(
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
            ),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.indigo),
            cellAlignment: pw.Alignment.centerLeft,
            cellPadding: const pw.EdgeInsets.all(8),
            data: <List<String>>[
              <String>['No', 'NIS', 'Nama Lengkap', 'Kelas'],
              ...siswaList.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final siswa = entry.value;
                return [
                  index.toString(),
                  siswa.nis ?? '-',
                  siswa.nama,
                  siswa.kelas ?? '-',
                ];
              }),
            ],
          ),
        ],
        footer: (context) {
          return pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Divider(thickness: 1, color: PdfColors.grey300),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Dokumen Rahasia - Sistem ZiePoint', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                  pw.Text('Halaman ${context.pageNumber} dari ${context.pagesCount}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Laporan_Kedisiplinan_ZiePoint.pdf',
    );
  }
}
