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

class _ReportsScreenState
    extends ConsumerState<ReportsScreen>
    with SingleTickerProviderStateMixin {

  String selectedFilter = "Today";

  late TabController _tabController;

  int totalBills = 0;
  double totalSales = 0;
  double totalExpenses = 0;
  double profit = 0;

  Map<String, double> paymentBreakdown = {};

  List<Map<String, dynamic>> bills = [];
  List<Map<String, dynamic>> expenses = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    loadReport();
  }

  DateTimeRange getRange() {
    final now = DateTime.now();

    if (selectedFilter == "Today") {
      final start = DateTime(now.year, now.month, now.day);
      return DateTimeRange(
          start: start,
          end: start.add(const Duration(days: 1)));
    }

    if (selectedFilter == "This Week") {
      final start =
          now.subtract(Duration(days: now.weekday - 1));
      final cleanStart =
          DateTime(start.year, start.month, start.day);
      return DateTimeRange(
          start: cleanStart,
          end: cleanStart.add(const Duration(days: 7)));
    }

    if (selectedFilter == "This Month") {
      final start = DateTime(now.year, now.month, 1);
      final end =
          DateTime(now.year, now.month + 1, 1);
      return DateTimeRange(start: start, end: end);
    }

    return DateTimeRange(
      start: DateTime(2000),
      end: DateTime(2100),
    );
  }

  Future<void> loadReport() async {
    final billRepo =
        ref.read(billRepositoryProvider);
    final expenseRepo =
        ref.read(expenseRepositoryProvider);

    final range = getRange();

    final summary =
        await billRepo.getReportByRange(
            range.start, range.end);

    final billList =
        await billRepo.getBillsByRange(
            range.start, range.end);

    final expenseList =
        await expenseRepo.getExpensesByRange(
            range.start, range.end);

    final expenseTotal =
        await expenseRepo.getTotalExpenseByRange(
            range.start, range.end);

    final payment =
        await billRepo.getPaymentBreakdown(
            range.start, range.end);

    setState(() {
      totalBills = summary['total_bills'] ?? 0;
      totalSales =
          (summary['total_sales'] ?? 0).toDouble();
      totalExpenses = expenseTotal;
      profit = totalSales - totalExpenses;

      bills = billList;
      expenses = expenseList;
      paymentBreakdown = payment;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Overview"),
            Tab(text: "Bills"),
            Tab(text: "Expenses"),
            Tab(text: "Analytics"),
          ],
        ),
      ),
      body: Column(
        children: [

          // FILTER
          DropdownButton<String>(
            value: selectedFilter,
            items: const [
              DropdownMenuItem(
                  value: "Today", child: Text("Today")),
              DropdownMenuItem(
                  value: "This Week",
                  child: Text("This Week")),
              DropdownMenuItem(
                  value: "This Month",
                  child: Text("This Month")),
              DropdownMenuItem(
                  value: "All Time",
                  child: Text("All Time")),
            ],
            onChanged: (value) {
              setState(() {
                selectedFilter = value!;
              });
              loadReport();
            },
          ),

          // SUMMARY CARDS
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceEvenly,
            children: [
              summaryCard("Sales", totalSales),
              summaryCard(
                  "Expenses", totalExpenses),
              summaryCard("Profit", profit),
            ],
          ),

          const SizedBox(height: 5),

          // PAYMENT BREAKDOWN
          Wrap(
            spacing: 10,
            children: paymentBreakdown.entries
                .map((e) => Chip(
                      label: Text(
                          "${e.key}: ₹${e.value.toStringAsFixed(0)}"),
                    ))
                .toList(),
          ),

          const Divider(),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                buildOverview(),
                buildBills(),
                buildExpenses(),
                const Center(
                    child: Text(
                        "Analytics coming next")),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget summaryCard(String title, double value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Text(title),
            Text(
              "₹${value.toStringAsFixed(0)}",
              style: const TextStyle(
                  fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }

  Widget buildOverview() {
    return ListView(
      children: [
        const Padding(
          padding: EdgeInsets.all(8),
          child: Text("Bills",
              style:
                  TextStyle(fontWeight: FontWeight.bold)),
        ),
        ...bills.take(5).map((b) =>
            ListTile(
              title: Text(
                  "Bill #${b['id']} - ₹${b['total']}"),
            )),

        const Padding(
          padding: EdgeInsets.all(8),
          child: Text("Expenses",
              style:
                  TextStyle(fontWeight: FontWeight.bold)),
        ),
        ...expenses.take(5).map((e) =>
            ListTile(
              title: Text(
                  "${e['category_name']} - ₹${e['amount']}"),
            )),
      ],
    );
  }

  Widget buildBills() {
    return ListView.builder(
      itemCount: bills.length,
      itemBuilder: (context, index) {
        final bill = bills[index];

        return Dismissible(
          key: Key("bill_${bill['id']}"),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding:
                const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete,
                color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (_) async {
            await ref
                .read(billRepositoryProvider)
                .deleteBill(bill['id']);
            loadReport();
          },
          child: ListTile(
            title: Text(
                "Bill #${bill['id']} - ₹${bill['total']}"),
            subtitle:
                Text(bill['payment_type']),
          ),
        );
      },
    );
  }

  Widget buildExpenses() {
    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];

        return Dismissible(
          key: Key("expense_${expense['id']}"),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding:
                const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete,
                color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (_) async {
            await ref
                .read(expenseRepositoryProvider)
                .deleteExpense(expense['id']);
            loadReport();
          },
          child: ListTile(
            title: Text(
                "${expense['category_name']} - ₹${expense['amount']}"),
            subtitle: Text(expense['note'] ?? ""),
          ),
        );
      },
    );
  }
}