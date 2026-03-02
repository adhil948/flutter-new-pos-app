import 'package:adhils_pos/core/database/app_database.dart';
import '../../models/bill_model.dart';
import '../../models/bill_item_model.dart';

class BillLocalDataSource {

  Future<int> insertBill(Bill bill) async {
    final db = await AppDatabase.instance.database;
    return await db.insert('bills', bill.toMap());
  }

  Future<void> insertBillItem(BillItem item) async {
    final db = await AppDatabase.instance.database;
    await db.insert('bill_items', item.toMap());
  }

Future<Map<String, dynamic>> getTodayReport() async {
  final db = await AppDatabase.instance.database;

  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day);
  final end = start.add(const Duration(days: 1));

  final result = await db.rawQuery('''
    SELECT COUNT(*) as total_bills,
           SUM(total) as total_sales
    FROM bills
    WHERE date >= ? AND date < ?
  ''', [start.toIso8601String(), end.toIso8601String()]);

  return result.first;
}

Future<Map<String, dynamic>> getReportByRange(
    DateTime start, DateTime end) async {
  final db = await AppDatabase.instance.database;

  final result = await db.rawQuery('''
    SELECT COUNT(*) as total_bills,
           SUM(total) as total_sales
    FROM bills
    WHERE date >= ? AND date < ?
  ''', [start.toIso8601String(), end.toIso8601String()]);

  return result.first;
}
Future<List<Map<String, dynamic>>> getBillsByRange(
    DateTime start, DateTime end) async {
  final db = await AppDatabase.instance.database;

  return await db.query(
    'bills',
    where: 'date >= ? AND date < ?',
    whereArgs: [
      start.toIso8601String(),
      end.toIso8601String()
    ],
    orderBy: 'date DESC',
  );
}
Future<List<Map<String, dynamic>>> getBillItems(int billId) async {
  final db = await AppDatabase.instance.database;

  return await db.rawQuery('''
    SELECT p.name,
           bi.quantity,
           bi.price
    FROM bill_items bi
    JOIN products p ON bi.product_id = p.id
    WHERE bi.bill_id = ?
  ''', [billId]);
}

Future<Map<String, double>> getPaymentBreakdown(
    DateTime start, DateTime end) async {
  final db = await AppDatabase.instance.database;

  final result = await db.rawQuery('''
    SELECT payment_type, SUM(total) as amount
    FROM bills
    WHERE date >= ? AND date < ?
    GROUP BY payment_type
  ''', [start.toIso8601String(), end.toIso8601String()]);

  Map<String, double> breakdown = {};

  for (var row in result) {
    final value = row['amount'];

    breakdown[row['payment_type'] as String] =
        value == null ? 0.0 : (value as num).toDouble();
  }

  return breakdown;
}


Future<void> deleteBill(int billId) async {
  final db = await AppDatabase.instance.database;

  await db.delete(
    'bill_items',
    where: 'bill_id = ?',
    whereArgs: [billId],
  );

  await db.delete(
    'bills',
    where: 'id = ?',
    whereArgs: [billId],
  );
}
}