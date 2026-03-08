class Product {
  final int? id;
  final String name;
  final double price;
  final String createdAt;
  final String? imagePath;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.createdAt,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'created_at': createdAt,
      'image_path': imagePath,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      createdAt: map['created_at'],
      imagePath: map['image_path'],
    );
  }
}