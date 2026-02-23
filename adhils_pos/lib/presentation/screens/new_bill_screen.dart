import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/utils/providers.dart';
import '../../data/models/product_model.dart';
import '../../data/models/bill_model.dart';
import '../../data/models/bill_item_model.dart';

class NewBillScreen extends ConsumerStatefulWidget {
  const NewBillScreen({super.key});

  @override
  ConsumerState<NewBillScreen> createState() => _NewBillScreenState();
}

class _NewBillScreenState extends ConsumerState<NewBillScreen> {

  List<Product> products = [];
  Map<Product, int> cart = {};

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    final repo = ref.read(productRepositoryProvider);
    final data = await repo.getAllProducts();
    setState(() {
      products = data;
    });
  }

  double get total {
    double sum = 0;
    cart.forEach((product, qty) {
      sum += product.price * qty;
    });
    return sum;
  }

  void addToCart(Product product) {
    setState(() {
      if (cart.containsKey(product)) {
        cart[product] = cart[product]! + 1;
      } else {
        cart[product] = 1;
      }
    });
  }

  void decreaseQty(Product product) {
    setState(() {
      if (cart[product]! > 1) {
        cart[product] = cart[product]! - 1;
      } else {
        cart.remove(product);
      }
    });
  }

  Future<void> saveBill() async {
    if (cart.isEmpty) return;

    final billRepo = ref.read(billRepositoryProvider);

    final bill = Bill(
    date: DateTime.now().toIso8601String(),
      total: total,
      paymentType: "Cash",
    );

    final billId = await billRepo.createBill(bill);

    for (var entry in cart.entries) {
      final item = BillItem(
        billId: billId,
        productId: entry.key.id!,
        quantity: entry.value,
        price: entry.key.price,
      );
      await billRepo.addBillItem(item);
    }

    setState(() {
      cart.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Bill Saved Successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Bill"),
      ),
      body: Column(
        children: [
          // Product List
          Expanded(
            flex: 2,
            child: products.isEmpty
                ? const Center(child: Text("No Products"))
                : ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ListTile(
                        title: Text(product.name),
                        subtitle: Text("₹ ${product.price}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => addToCart(product),
                        ),
                      );
                    },
                  ),
          ),

          const Divider(),

          // Cart Section
          Expanded(
            flex: 1,
            child: Column(
              children: [
                const Text(
                  "Cart",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: ListView(
                    children: cart.entries.map((entry) {
                      final product = entry.key;
                      final qty = entry.value;

                      return ListTile(
                        title: Text(product.name),
                        subtitle: Text(
                            "₹ ${product.price} x $qty"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () =>
                                  decreaseQty(product),
                            ),
                            Text("$qty"),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () =>
                                  addToCart(product),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    "Total: ₹ ${total.toStringAsFixed(2)}",
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),

                ElevatedButton(
                  onPressed: saveBill,
                  child: const Text("Save Bill"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}