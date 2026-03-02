import '../../../core/database/app_database.dart';
import '../../models/expense_model.dart';

class ExpenseLocalDataSource {

  Future<void> insertExpense(Expense expense) async {
    final db = await AppDatabase.instance.database;
    await db.insert('expenses', expense.toMap());
  }

  Future<List<Expense>> getExpenses() async {
    final db = await AppDatabase.instance.database;

    final result =
        await db.query('expenses', orderBy: 'date DESC');

    return result.map((e) => Expense.fromMap(e)).toList();
  }

  Future<void> deleteExpense(int id) async {
    final db = await AppDatabase.instance.database;

    await db.delete('expenses',
        where: 'id = ?', whereArgs: [id]);
  }



  Future<List<Map<String, dynamic>>> getExpensesByRange(
    DateTime start, DateTime end) async {
  final db = await AppDatabase.instance.database;

  return await db.rawQuery('''
    SELECT e.*, c.name as category_name
    FROM expenses e
    JOIN expense_categories c
    ON e.category_id = c.id
    WHERE e.date >= ? AND e.date < ?
    ORDER BY e.date DESC
  ''', [start.toIso8601String(), end.toIso8601String()]);
}


Future<double> getTotalExpenseByRange(
    DateTime start, DateTime end) async {
  final db = await AppDatabase.instance.database;

  final result = await db.rawQuery('''
    SELECT SUM(amount) as total
    FROM expenses
    WHERE date >= ? AND date < ?
  ''', [start.toIso8601String(), end.toIso8601String()]);

  final value = result.first['total'];
  return value == null ? 0.0 : (value as num).toDouble();
}

Future<List<Map<String, dynamic>>> getCategoryExpenseBreakdown(
    DateTime start, DateTime end) async {

  final db = await AppDatabase.instance.database;

  return await db.rawQuery('''
    SELECT c.name,
           SUM(e.amount) as total_amount
    FROM expenses e
    JOIN expense_categories c
    ON e.category_id = c.id
    WHERE e.date >= ? AND e.date < ?
    GROUP BY c.name
    ORDER BY total_amount DESC
  ''', [start.toIso8601String(), end.toIso8601String()]);
}
}