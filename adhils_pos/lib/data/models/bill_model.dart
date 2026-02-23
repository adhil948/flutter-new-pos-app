class Bill {
  final int? id;
  final String date;
  final double total;
  final String paymentType;

  Bill({
    this.id,
    required this.date,
    required this.total,
    required this.paymentType,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'total': total,
      'payment_type': paymentType,
    };
  }

  factory Bill.fromMap(Map<String, dynamic> map) {
    return Bill(
      id: map['id'],
      date: map['date'],
      total: map['total'],
      paymentType: map['payment_type'],
    );
  }
}