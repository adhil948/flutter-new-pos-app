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
}