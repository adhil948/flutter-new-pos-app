import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';


class PdfService {

  static Future<void> generateSmartReport({
    required String filter,
    required DateTimeRange range,
    required double totalSales,
    required double totalExpenses,
    required double profit,
    required Map<String, double> paymentBreakdown,
    required List<Map<String, dynamic>> bills,
    required List<Map<String, dynamic>> expenses,
    required List<Map<String, dynamic>> dailySales,
    required List<Map<String, dynamic>> dailyExpenses,
  }) async {

    final pdf = pw.Document();
 final font = await PdfGoogleFonts.notoSansRegular();

    pdf.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(
  base: font,
),
        pageFormat: PdfPageFormat.a4,
        build: (context) {

          List<pw.Widget> content = [];

          content.add(
            pw.Center(
              child: pw.Text(
                "FALCON FRIED CHICKEN",
                style: pw.TextStyle(
                  fontSize: 26,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.deepPurple,
                ),
              ),
            ),
          );

          content.add(pw.SizedBox(height: 5));

          content.add(
            pw.Center(
              child: pw.Text(
                "$filter Report",
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          );

          content.add(pw.SizedBox(height: 20));

          if (filter != "Today") {
            Map<String, double> expenseMap = {};

            for (var e in dailyExpenses) {
              expenseMap[e['day']] =
                  (e['total_expense'] ?? 0).toDouble();
            }

            content.add(
              pw.Text("Day-wise Summary",
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 16)),
            );

            content.add(pw.SizedBox(height: 10));

            content.add(
              pw.Table.fromTextArray(
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
                headers: ["Date", "Sales", "Expense", "Profit"],
                data: dailySales.map((s) {

                  final day = s['day'];
                  final sales =
                      (s['total_sales'] ?? 0).toDouble();

                  final expense =
                      expenseMap[day] ?? 0;

                  final dayProfit = sales - expense;

                  return [
                    day.toString(),
                    "Rs ${sales.toStringAsFixed(0)}",
                    "Rs ${expense.toStringAsFixed(0)}",
                    "Rs ${dayProfit.toStringAsFixed(0)}",
                  ];
                }).toList(),
              ),
            );
            
            content.add(pw.SizedBox(height: 20));
          }

          content.add(
            pw.Text("Financial Overview",
                style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold, fontSize: 16)),
          );

          content.add(pw.Text(
              "Total Sales: Rs${totalSales.toStringAsFixed(0)}"));

          content.add(pw.Text(
              "Total Expenses: Rs${totalExpenses.toStringAsFixed(0)}"));

          content.add(pw.Text(
              "Profit: Rs${profit.toStringAsFixed(0)}"));

          content.add(pw.SizedBox(height: 10));

          content.add(
            pw.Text("Payment Breakdown",
                style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold)),
          );

          paymentBreakdown.forEach((key, value) {
            content.add(
              pw.Text(
                  "$key : Rs${value.toStringAsFixed(0)}"),
            );
          });

          return content;
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  static Future<void> generateInvoice({
    required Map<String, dynamic> bill,
    required List<Map<String, dynamic>> items,
  }) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.notoSansRegular();

    final date = DateTime.parse(bill['date']);
    final formattedDate = DateFormat('dd MMM yyyy – hh:mm a').format(date);

    pdf.addPage(
      pw.Page(
        theme: pw.ThemeData.withFont(base: font),
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text("FALCON FRIED CHICKEN",
                      style: pw.TextStyle(
                          fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.deepPurple)),
                ),
                pw.Center(
                  child: pw.Text("POS INVOICE",
                      style: pw.TextStyle(
                          fontSize: 16, fontWeight: pw.FontWeight.bold)),
                ),
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Bill #${bill['id']}",
                        style: pw.TextStyle(
                            fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    pw.Text(formattedDate, style: const pw.TextStyle(fontSize: 14)),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Text("Payment Method: ${bill['payment_type']}",
                    style: const pw.TextStyle(fontSize: 14)),
                if (bill['note'] != null && bill['note'].toString().isNotEmpty) ...[
                  pw.SizedBox(height: 10),
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey200,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("Note:",
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.grey800)),
                        pw.SizedBox(height: 4),
                        pw.Text(bill['note'],
                            style: const pw.TextStyle(color: PdfColors.grey700)),
                      ],
                    ),
                  ),
                ],
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.SizedBox(height: 10),
                ...items.map((item) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 4),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(item['name'],
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Text("₹${item['price']} x ${item['quantity']}",
                              textAlign: pw.TextAlign.center),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Text(
                              "₹${(item['price'] * item['quantity']).toStringAsFixed(2)}",
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                }),
                pw.SizedBox(height: 10),
                pw.Divider(),
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Total Amount:",
                        style: pw.TextStyle(
                            fontSize: 18, fontWeight: pw.FontWeight.bold)),
                    pw.Text("₹${bill['total']}",
                        style: pw.TextStyle(
                            fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.Spacer(),
                pw.Center(
                  child: pw.Text("Thank you for your business!",
                      style: pw.TextStyle(fontStyle: pw.FontStyle.italic, color: PdfColors.grey600)),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}