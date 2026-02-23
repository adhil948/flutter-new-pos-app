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
}