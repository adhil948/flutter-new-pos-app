class BillItem {
  final int? id;
  final int billId;
  final int productId;
  final int quantity;
  final double price;

  BillItem({
    this.id,
    required this.billId,
    required this.productId,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bill_id': billId,
      'product_id': productId,
      'quantity': quantity,
      'price': price,
    };
  }
}