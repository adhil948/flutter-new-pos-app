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
            pw.Text(
              "$filter Report",
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          );

          content.add(pw.SizedBox(height: 10));

if (filter == "Today") {

  content.add(
    pw.Text("Bills",
        style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold)),
  );

  for (var b in bills) {

    final date = DateTime.parse(b['date']);
    final time =
        DateFormat('hh:mm a').format(date);

    content.add(
      pw.Container(
        padding: const pw.EdgeInsets.all(5),
        child: pw.Column(
          crossAxisAlignment:
              pw.CrossAxisAlignment.start,
          children: [

            pw.Text(
              "Bill #${b['id']}  |  $time  |  ${b['payment_type']}  |  Rs ${b['total']}",
              style: pw.TextStyle(
                  fontWeight:
                      pw.FontWeight.bold),
            ),

            pw.SizedBox(height: 4),

            ...b['items'].map<pw.Widget>((item) {
              return pw.Padding(
                padding: const pw.EdgeInsets.only(
                    left: 10),
                child: pw.Text(
                    "- ${item['name']} x${item['quantity']}  (Rs ${item['price']})"),
              );
            }).toList(),

            pw.SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

          else {

            Map<String, double> expenseMap = {};

            for (var e in dailyExpenses) {
              expenseMap[e['day']] =
                  (e['total_expense'] ?? 0).toDouble();
            }

            content.add(
              pw.Text("Day-wise Summary",
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold)),
            );

            content.add(
              pw.Table.fromTextArray(
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
                    sales.toStringAsFixed(0),
                    expense.toStringAsFixed(0),
                    dayProfit.toStringAsFixed(0),
                  ];
                }).toList(),
              ),
            );
          }

          content.add(pw.SizedBox(height: 20));

          content.add(
            pw.Text("Summary",
                style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold)),
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
}