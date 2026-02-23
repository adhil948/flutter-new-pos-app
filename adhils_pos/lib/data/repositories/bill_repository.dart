import '../models/bill_model.dart';
import '../models/bill_item_model.dart';
import '../datasources/local/bill_local_datasource.dart';

class BillRepository {

  final BillLocalDataSource _localDataSource =
      BillLocalDataSource();

  Future<int> createBill(Bill bill) async {
    return await _localDataSource.insertBill(bill);
  }

  Future<void> addBillItem(BillItem item) async {
    await _localDataSource.insertBillItem(item);
  }
}