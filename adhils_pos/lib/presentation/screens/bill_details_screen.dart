import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/utils/providers.dart';
import '../../core/services/pdf_service.dart';

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

            if (widget.bill['note'] != null && widget.bill['note'].toString().isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Note:",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
                    ),
                    const SizedBox(height: 4),
                    Text(widget.bill['note']),
                  ],
                ),
              ),
            ],

            const Divider(),

            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];

                  return ListTile(
                    title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                        "₹ ${item['price']} x ${item['quantity']}"),
                    trailing: Text(
                        "₹ ${(item['price'] * item['quantity']).toStringAsFixed(2)}",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  );
                },
              ),
            ),

            const Divider(),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total Amount:", style: TextStyle(fontSize: 18, color: Colors.grey)),
                  Text(
                    "₹ ${widget.bill['total']}",
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: () async {
                await PdfService.generateInvoice(
                  bill: widget.bill,
                  items: items,
                );
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.print),
                  SizedBox(width: 8),
                  Text("Print Bill", style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}