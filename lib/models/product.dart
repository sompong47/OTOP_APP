// lib/models/product.dart
class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String? image;
  final int categoryId;
  final int sellerId;
  final int stock;
  final bool isActive;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.image,
    required this.categoryId,
    required this.sellerId,
    required this.stock,
    required this.isActive,
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      image: json['image'],
      categoryId: json['category'],
      sellerId: json['seller'],
      stock: json['stock'],
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'category': categoryId,
      'seller': sellerId,
      'stock': stock,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}