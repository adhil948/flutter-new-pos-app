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

  Future<Map<String, dynamic>> getReportByRange(
      DateTime start, DateTime end) async {
    return await _localDataSource.getReportByRange(start, end);
  }

  Future<List<Map<String, dynamic>>> getBillsByRange(
      DateTime start, DateTime end) async {
    return await _localDataSource.getBillsByRange(start, end);
  }

  Future<List<Map<String, dynamic>>> getBillItems(int billId) async {
  return await _localDataSource.getBillItems(billId);
}
}