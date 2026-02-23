import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/utils/providers.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() =>
      _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {

  String selectedFilter = "Today";

  int totalBills = 0;
  double totalSales = 0;
  List<Map<String, dynamic>> bills = [];

  @override
  void initState() {
    super.initState();
    loadReport();
  }

  DateTimeRange getRange() {
    final now = DateTime.now();

    if (selectedFilter == "Today") {
      final start = DateTime(now.year, now.month, now.day);
      return DateTimeRange(start: start, end: start.add(const Duration(days: 1)));
    }

    if (selectedFilter == "This Week") {
      final start = now.subtract(Duration(days: now.weekday - 1));
      final cleanStart = DateTime(start.year, start.month, start.day);
      return DateTimeRange(start: cleanStart, end: cleanStart.add(const Duration(days: 7)));
    }

    if (selectedFilter == "This Month") {
      final start = DateTime(now.year, now.month, 1);
      final end = DateTime(now.year, now.month + 1, 1);
      return DateTimeRange(start: start, end: end);
    }

    // All Time
    return DateTimeRange(
      start: DateTime(2000),
      end: DateTime(2100),
    );
  }

  Future<void> loadReport() async {
    final repo = ref.read(billRepositoryProvider);
    final range = getRange();

    final summary =
        await repo.getReportByRange(range.start, range.end);

    final billList =
        await repo.getBillsByRange(range.start, range.end);

    setState(() {
      totalBills = summary['total_bills'] ?? 0;
      totalSales = (summary['total_sales'] ?? 0).toDouble();
      bills = billList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // FILTER DROPDOWN
            DropdownButton<String>(
              value: selectedFilter,
              items: const [
                DropdownMenuItem(value: "Today", child: Text("Today")),
                DropdownMenuItem(value: "This Week", child: Text("This Week")),
                DropdownMenuItem(value: "This Month", child: Text("This Month")),
                DropdownMenuItem(value: "All Time", child: Text("All Time")),
              ],
              onChanged: (value) {
                setState(() {
                  selectedFilter = value!;
                });
                loadReport();
              },
            ),

            const SizedBox(height: 10),

            // SUMMARY
            Card(
              child: ListTile(
                title: const Text("Total Bills"),
                trailing: Text("$totalBills"),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text("Total Sales"),
                trailing: Text("₹ ${totalSales.toStringAsFixed(2)}"),
              ),
            ),

            const SizedBox(height: 10),

            const Divider(),

            const Text(
              "Bills",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            // BILL LIST
            Expanded(
              child: ListView.builder(
                itemCount: bills.length,
                itemBuilder: (context, index) {
                  final bill = bills[index];
                  final date = DateTime.parse(bill['date']);
                  final formattedDate =
                      DateFormat('dd MMM yyyy – hh:mm a')
                          .format(date);

                  return Card(
                    child: ListTile(
                      title: Text("Bill #${bill['id']}"),
                      subtitle: Text(formattedDate),
                      trailing: Text(
                        "₹ ${bill['total']}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        // Later: Open bill details & reprint
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}