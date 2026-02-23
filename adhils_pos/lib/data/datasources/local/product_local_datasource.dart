import 'package:adhils_pos/core/database/app_database.dart';
import 'package:adhils_pos/data/models/product_model.dart';

class ProductLocalDataSource {
  Future<void> insertProduct(Product product) async {
    final db = await AppDatabase.instance.database;
    await db.insert('products', product.toMap());
  }

  Future<List<Product>> getProducts() async {
    final db = await AppDatabase.instance.database;
    final result = await db.query('products', orderBy: 'id DESC');

    return result.map((e) => Product.fromMap(e)).toList();
  }

  Future<void> deleteProduct(int id) async {
    final db = await AppDatabase.instance.database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }
}