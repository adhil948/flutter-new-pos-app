import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/bill_repository.dart';
import '../../data/repositories/expense_repository.dart';

final expenseRepositoryProvider =
    Provider<ExpenseRepository>((ref) {
  return ExpenseRepository();
});
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

final billRepositoryProvider = Provider<BillRepository>((ref) {
  return BillRepository();
});