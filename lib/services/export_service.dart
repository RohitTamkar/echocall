import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:echocall/models/call_log.dart';

class ExportService {
  // static Future<void> exportToPdf(List<CallLog> callLogs) async {
  //   final pdf = pw.Document();
  //   final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  //
  //   // Split data into chunks for multiple pages
  //   const itemsPerPage = 15;
  //   final totalPages = (callLogs.length / itemsPerPage).ceil();
  //
  //   for (int page = 0; page < totalPages; page++) {
  //     final startIndex = page * itemsPerPage;
  //     final endIndex = (startIndex + itemsPerPage) > callLogs.length
  //         ? callLogs.length
  //         : startIndex + itemsPerPage;
  //     final pageData = callLogs.sublist(startIndex, endIndex);
  //
  //     pdf.addPage(
  //       pw.Page(
  //         pageFormat: PdfPageFormat.a4.landscape,
  //         build: (context) => pw.Column(
  //           crossAxisAlignment: pw.CrossAxisAlignment.start,
  //           children: [
  //             pw.Header(
  //               level: 0,
  //               child: pw.Row(
  //                 mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   pw.Text('Call Logs Report',
  //                       style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
  //                   pw.Text('Page ${page + 1} of $totalPages',
  //                       style: const pw.TextStyle(fontSize: 12)),
  //                 ],
  //               ),
  //             ),
  //             pw.SizedBox(height: 20),
  //             pw.Table(
  //               border: pw.TableBorder.all(color: PdfColors.grey400),
  //               columnWidths: {
  //                 0: const pw.FlexColumnWidth(2),
  //                 1: const pw.FlexColumnWidth(1.5),
  //                 2: const pw.FlexColumnWidth(1),
  //                 3: const pw.FlexColumnWidth(1.5),
  //                 4: const pw.FlexColumnWidth(1.5),
  //                 5: const pw.FlexColumnWidth(1),
  //                 6: const pw.FlexColumnWidth(1),
  //                 7: const pw.FlexColumnWidth(1),
  //               },
  //               children: [
  //                 pw.TableRow(
  //                   decoration: const pw.BoxDecoration(color: PdfColors.grey200),
  //                   children: [
  //                     _buildTableCell('Name', isHeader: true),
  //                     _buildTableCell('Receiver', isHeader: true),
  //                     _buildTableCell('Direction', isHeader: true),
  //                     _buildTableCell('Number', isHeader: true),
  //                     _buildTableCell('Department', isHeader: true),
  //                     _buildTableCell('Duration', isHeader: true),
  //                     _buildTableCell('SIM', isHeader: true),
  //                     _buildTableCell('Date', isHeader: true),
  //                   ],
  //                 ),
  //                 ...pageData.map((log) => pw.TableRow(
  //                   children: [
  //                     _buildTableCell(log.name),
  //                     _buildTableCell(log.receiverName),
  //                     _buildTableCell(log.direction.toUpperCase()),
  //                     _buildTableCell(log.receiverMobileNo),
  //                     _buildTableCell(log.department),
  //                     _buildTableCell(log.formattedDuration),
  //                     _buildTableCell(log.simLabel),
  //                     _buildTableCell(dateFormat.format(
  //                         DateTime.fromMillisecondsSinceEpoch(log.createdAt))),
  //                   ],
  //                 )),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //   }
  //
  //   final bytes = await pdf.save();
  //   await _saveAndShare(bytes, 'call_logs_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf');
  // }

  static Future<void> exportToExcel(List<CallLog> callLogs) async {
    final excel = Excel.createExcel();
    final sheet = excel['Call Logs'];
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    // Headers
    final headers = [
      'Name', 'Receiver Name', 'Direction', 'Number', 'Receiver Mobile',
      'Department', 'Duration', 'SIM Label', 'Created At', 'Uploaded At'
    ];

    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(
        fontFamily: getFontFamily(FontFamily.Calibri),
        fontSize: 12,
        bold: true,
      );
    }

    // Data rows
    for (int i = 0; i < callLogs.length; i++) {
      final log = callLogs[i];
      final rowIndex = i + 1;

      final rowData = [
        log.name,
        log.receiverName,
        log.direction.toUpperCase(),
        log.number,
        log.receiverMobileNo,
        log.department,
        log.formattedDuration,
        log.simLabel,
        dateFormat.format(DateTime.fromMillisecondsSinceEpoch(log.createdAt)),
        log.uploadedAt,
      ];

      for (int j = 0; j < rowData.length; j++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: rowIndex));
        cell.value = TextCellValue(rowData[j].toString());
      }
    }

    // Auto-fit columns
    for (int i = 0; i < headers.length; i++) {
      sheet.setColumnAutoFit(i);
    }

    final bytes = excel.encode();
    if (bytes != null) {
      await _saveAndShare(Uint8List.fromList(bytes),
          'call_logs_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx');
    }
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 8,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  // static Future<void> _saveAndShare(Uint8List bytes, String filename) async {
  //   try {
  //     final directory = await getApplicationDocumentsDirectory();
  //     final file = File('${directory.path}/$filename');
  //     await file.writeAsBytes(bytes);
  //
  //     await Share.shareXFiles(
  //       [XFile(file.path)],
  //       text: 'Call Logs Export - $filename',
  //     );
  //   } catch (e) {
  //     throw Exception('Failed to save and share file: $e');
  //   }
  // }

  static Future<void> exportToPdf(List<CallLog> callLogs) async {
    print("📄 Starting exportToPdf with ${callLogs.length} call logs");

    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    // Split data into chunks for multiple pages
    const itemsPerPage = 10;
    final totalPages = (callLogs.length / itemsPerPage).ceil();
    print("📑 Total pages to generate: $totalPages");

    for (int page = 0; page < totalPages; page++) {
      final startIndex = page * itemsPerPage;
      final endIndex =
      (startIndex + itemsPerPage) > callLogs.length ? callLogs.length : startIndex + itemsPerPage;
      final pageData = callLogs.sublist(startIndex, endIndex);

      print("➡️ Adding page ${page + 1} with items $startIndex to ${endIndex - 1} "
          "(total: ${pageData.length})");

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Call Logs Report',
                        style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Page ${page + 1} of $totalPages',
                        style: const pw.TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(1.5),
                  2: const pw.FlexColumnWidth(1),
                  3: const pw.FlexColumnWidth(1.5),
                  4: const pw.FlexColumnWidth(1.5),
                  5: const pw.FlexColumnWidth(1),
                  6: const pw.FlexColumnWidth(1),
                  7: const pw.FlexColumnWidth(1),
                  8: const pw.FlexColumnWidth(1),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _buildTableCell('Name', isHeader: true),
                      _buildTableCell('Number', isHeader: true),
                      _buildTableCell('Direction', isHeader: true),
                      _buildTableCell('Receiver', isHeader: true),
                      _buildTableCell('Rec Number', isHeader: true),
                      _buildTableCell('Dept', isHeader: true),
                      _buildTableCell('Duration', isHeader: true),
                      _buildTableCell('SIM', isHeader: true),
                      _buildTableCell('Date', isHeader: true),
                    ],
                  ),

                  ...pageData.map((log) {
                    print("   📝 Adding log: name=${log.name}, number=${log.receiverMobileNo}, "
                        "duration=${log.formattedDuration}, date=${dateFormat.format(DateTime.fromMillisecondsSinceEpoch(log.createdAt))}");
                    return pw.TableRow(
                      children: [
                        _buildTableCell(log.name ?? "Not Available"),
                        _buildTableCell(log.number ?? "Not Available"),
                        _buildTableCell(log.direction?.toUpperCase() ?? "-"),
                        _buildTableCell(log.receiverName ?? "-"),
                        _buildTableCell(log.receiverMobileNo ?? "-"),
                        _buildTableCell(log.department ?? "-"),
                        _buildTableCell(log.formattedDuration ?? "-"),
                        _buildTableCell(log.simLabel ?? "-"),
                        _buildTableCell(
                          log.timestamp != null
                              ? dateFormat.format(DateTime.fromMillisecondsSinceEpoch(log.timestamp))
                              : "-",
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      );
    }

    print("✅ PDF generation completed, saving file...");
    final bytes = await pdf.save();
    await _saveAndShare(bytes, 'call_logs_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf');
  }

  static Future<void> _saveAndShare(Uint8List bytes, String filename) async {
    try {
      print("💾 Saving file...");
      final directory = await getApplicationDocumentsDirectory();
      print("📂 Documents directory: ${directory.path}");

      final file = File('${directory.path}/$filename');
      await file.writeAsBytes(bytes);
      print("✅ File saved at: ${file.path}");

      print("📤 Sharing file...");
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Call Logs Export - $filename',
      );
      print("✅ File shared successfully.");
    } catch (e) {
      print("❌ Error while saving/sharing: $e");
      throw Exception('Failed to save and share file: $e');
    }
  }

}