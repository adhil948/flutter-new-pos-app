class Bill {
  final int? id;
  final String billNumber;   // NEW
  final String date;
  final double total;
  final String paymentType;

  Bill({
    this.id,
    required this.billNumber,
    required this.date,
    required this.total,
    required this.paymentType,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bill_number': billNumber,   // NEW
      'date': date,
      'total': total,
      'payment_type': paymentType,
    };
  }

  factory Bill.fromMap(Map<String, dynamic> map) {
    return Bill(
      id: map['id'],
      billNumber: map['bill_number'],  // NEW
      date: map['date'],
      total: map['total'],
      paymentType: map['payment_type'],
    );
  }
}