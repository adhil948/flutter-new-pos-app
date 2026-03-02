class Expense {
  final int? id;
  final String date;
  final double amount;
  final int categoryId;
  final String? note;

  Expense({
    this.id,
    required this.date,
    required this.amount,
    required this.categoryId,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'amount': amount,
      'category_id': categoryId,
      'note': note,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      date: map['date'],
      amount: map['amount'],
      categoryId: map['category_id'],
      note: map['note'],
    );
  }
}