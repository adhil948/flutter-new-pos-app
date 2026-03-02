import '../models/expense_model.dart';
import '../datasources/local/expense_local_datasource.dart';

class ExpenseRepository {

  final ExpenseLocalDataSource _localDataSource =
      ExpenseLocalDataSource();

  Future<void> addExpense(Expense expense) async {
    await _localDataSource.insertExpense(expense);
  }

  Future<List<Expense>> getAllExpenses() async {
    return await _localDataSource.getExpenses();
  }

  Future<void> deleteExpense(int id) async {
    await _localDataSource.deleteExpense(id);
  }

  Future<List<Map<String, dynamic>>> getExpensesByRange(
    DateTime start, DateTime end) async {
  return await _localDataSource.getExpensesByRange(start, end);
}

Future<double> getTotalExpenseByRange(
    DateTime start, DateTime end) async {
  return await _localDataSource.getTotalExpenseByRange(start, end);
}

Future<List<Map<String, dynamic>>> getCategoryExpenseBreakdown(
    DateTime start, DateTime end) async {
  return await _localDataSource
      .getCategoryExpenseBreakdown(start, end);
}
}