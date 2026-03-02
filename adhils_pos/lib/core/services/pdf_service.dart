import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class PdfService {

  static Future<File> generateReportPdf({
    required String title,
    required int totalBills,
    required double totalSales,
    required List<Map<String, dynamic>> bills,
  }) async {

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [

          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 10),

          pw.Text("Total Bills: $totalBills"),
          pw.Text("Total Sales: ₹ ${totalSales.toStringAsFixed(2)}"),

          pw.SizedBox(height: 20),

          pw.Table.fromTextArray(
            headers: ["Bill ID", "Date & Time", "Total"],
            data: bills.map((bill) {

              final date = DateTime.parse(bill['date']);
              final formatted =
                  DateFormat('dd MMM yyyy – hh:mm a')
                      .format(date);

              return [
                bill['id'].toString(),
                formatted,
                "₹ ${bill['total']}"
              ];
            }).toList(),
          ),
        ],
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File(
        "${directory.path}/report_${DateTime.now().millisecondsSinceEpoch}.pdf");

    await file.writeAsBytes(await pdf.save());

    return file;
  }

  static Future<void> printPdf(File file) async {
    await Printing.layoutPdf(
      onLayout: (format) async => file.readAsBytes(),
    );
  }

  static Future<void> sharePdf(File file) async {
    await Printing.sharePdf(
      bytes: await file.readAsBytes(),
      filename: file.path.split('/').last,
    );
  }
}