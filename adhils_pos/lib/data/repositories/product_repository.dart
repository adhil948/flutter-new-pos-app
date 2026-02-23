import '../models/product_model.dart';
import '../datasources/local/product_local_datasource.dart';

class ProductRepository {
  final ProductLocalDataSource _localDataSource =
      ProductLocalDataSource();

  Future<void> addProduct(Product product) async {
    await _localDataSource.insertProduct(product);
  }

  Future<List<Product>> getAllProducts() async {
    return await _localDataSource.getProducts();
  }

  Future<void> deleteProduct(int id) async {
    await _localDataSource.deleteProduct(id);
  }
}