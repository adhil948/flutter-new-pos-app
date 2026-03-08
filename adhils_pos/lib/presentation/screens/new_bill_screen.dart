import 'dart:io';
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

  String selectedPayment = "Cash";
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> loadProducts() async {
    final repo = ref.read(productRepositoryProvider);
    final data = await repo.getAllProducts();
    if (mounted) {
      setState(() {
        products = data;
      });
    }
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
    final billNumber = await billRepo.generateBillNumber();

    final bill = Bill(
      billNumber: billNumber,
      date: DateTime.now().toIso8601String(),
      total: total,
      paymentType: selectedPayment,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
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

    if (mounted) {
      setState(() {
        cart.clear();
        _noteController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bill Saved Successfully")),
      );
    }
  }

  Widget _buildProductGrid() {
    if (products.isEmpty) {
      return const Center(child: Text("No Products available"));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final product = products[index];
        final int qty = cart[product] ?? 0;

        return GestureDetector(
          onTap: () => addToCart(product),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: product.imagePath != null
                          ? Image.file(
                              File(product.imagePath!),
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: Colors.grey.shade100,
                              child: const Icon(Icons.inventory,
                                  size: 40, color: Colors.black54),
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "₹${product.price}",
                            style: TextStyle(
                                color: Colors.grey[700], fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              if (qty > 0)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      "$qty",
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCartItem(MapEntry<Product, int> entry) {
    final product = entry.key;
    final qty = entry.value;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("₹${product.price} x $qty",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          Text(
            "₹${(product.price * qty).toStringAsFixed(2)}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, color: Colors.black),
            onPressed: () => decreaseQty(product),
          ),
          Text("$qty", style: const TextStyle(fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.black),
            onPressed: () => addToCart(product),
          ),
        ],
      ),
    );
  }

  void _showCheckoutSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Checkout",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Payment Method:",
                          style: TextStyle(fontSize: 16)),
                      DropdownButton<String>(
                        value: selectedPayment,
                        items: const [
                          DropdownMenuItem(value: "Cash", child: Text("Cash")),
                          DropdownMenuItem(value: "UPI", child: Text("UPI")),
                          DropdownMenuItem(value: "Bank", child: Text("Bank")),
                          DropdownMenuItem(value: "Card", child: Text("Card")),
                        ],
                        onChanged: (value) {
                          setSheetState(() {
                            selectedPayment = value!;
                          });
                          setState(() {
                            selectedPayment = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: "Optional Note (e.g., Customer Name)",
                      prefixIcon: Icon(Icons.note),
                    ),
                    maxLines: 2,
                    minLines: 1,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total Amount",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        "₹${total.toStringAsFixed(2)}",
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      saveBill();
                    },
                    child: const Text("Confirm & Save Bill",
                        style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }


  Widget _buildCartPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(left: BorderSide(color: Colors.black12, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            color: Colors.grey.shade100,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shopping_cart_outlined, color: Colors.black),
                const SizedBox(width: 8),
                Text(
                  "Items in Cart: ${cart.values.fold(0, (sum, i) => sum + i as int)}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: cart.isEmpty
                ? Center(
                    child: Text(
                      "Tap items to add to cart",
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  )
                : ListView(
                    children: cart.entries.map(_buildCartItem).toList(),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: ElevatedButton(
              onPressed: cart.isEmpty ? null : _showCheckoutSheet,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                minimumSize: const Size.fromHeight(64),
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Checkout",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "₹${total.toStringAsFixed(2)}",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Bill"),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            return Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    color: Colors.grey[50],
                    child: _buildProductGrid(),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: _buildCartPanel(),
                ),
              ],
            );
          } else {
            return Column(
              children: [
                Expanded(
                  child: Container(
                    color: Colors.grey[50],
                    child: _buildProductGrid(),
                  ),
                ),
                SizedBox(
                  height: 250,
                  child: _buildCartPanel(),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}