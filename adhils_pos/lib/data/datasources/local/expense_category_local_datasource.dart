import 'package:sqflite/sqflite.dart';
import '../../../core/database/app_database.dart';
import '../../models/expense_category_model.dart';

class ExpenseCategoryLocalDataSource {

  Future<void> insertCategory(ExpenseCategory category) async {
    final db = await AppDatabase.instance.database;
    await db.insert(
      'expense_categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }
Future<void> updateCategory(int id, String newName) async {
  final db = await AppDatabase.instance.database;

  await db.update(
    'expense_categories',
    {'name': newName},
    where: 'id = ?',
    whereArgs: [id],
  );
}

Future<void> deleteCategory(int id) async {
  final db = await AppDatabase.instance.database;

  await db.delete(
    'expense_categories',
    where: 'id = ?',
    whereArgs: [id],
  );
}

Future<bool> isCategoryUsed(int id) async {
  final db = await AppDatabase.instance.database;

  final result = await db.rawQuery('''
    SELECT COUNT(*) as count
    FROM expenses
    WHERE category_id = ?
  ''', [id]);

  return (result.first['count'] as int) > 0;
}
  Future<List<ExpenseCategory>> getCategories() async {
    final db = await AppDatabase.instance.database;

    final result =
        await db.query('expense_categories', orderBy: 'name ASC');

    return result.map((e) =>
        ExpenseCategory.fromMap(e)).toList();
  }
}