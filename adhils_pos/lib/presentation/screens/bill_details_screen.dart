import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/utils/providers.dart';

class BillDetailsScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> bill;

  const BillDetailsScreen({super.key, required this.bill});

  @override
  ConsumerState<BillDetailsScreen> createState() =>
      _BillDetailsScreenState();
}

class _BillDetailsScreenState
    extends ConsumerState<BillDetailsScreen> {

  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  Future<void> loadItems() async {
    final repo = ref.read(billRepositoryProvider);
    final data =
        await repo.getBillItems(widget.bill['id']);
    setState(() {
      items = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(widget.bill['date']);

    return Scaffold(
      appBar: AppBar(
        title: Text("Bill #${widget.bill['id']}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            Text(
              DateFormat('dd MMM yyyy – hh:mm a')
                  .format(date),
            ),

            const SizedBox(height: 10),

            Text("Payment: ${widget.bill['payment_type']}"),

            const Divider(),

            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];

                  return ListTile(
                    title: Text(item['name']),
                    subtitle: Text(
                        "₹ ${item['price']} x ${item['quantity']}"),
                    trailing: Text(
                        "₹ ${(item['price'] * item['quantity']).toStringAsFixed(2)}"),
                  );
                },
              ),
            ),

            const Divider(),

            Text(
              "Total: ₹ ${widget.bill['total']}",
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                // print logic later
              },
              child: const Text("Print Bill"),
            ),
          ],
        ),
      ),
    );
  }
}