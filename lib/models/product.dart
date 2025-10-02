class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String? image;
  final String? category;
  final bool isAvailable;
  final int stock;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.image,
    this.category,
    this.isAvailable = true,
    this.stock = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Helper function to convert price safely
    double parsePrice(dynamic price) {
      if (price is double) return price;
      if (price is int) return price.toDouble();
      if (price is String) {
        return double.tryParse(price) ?? 0.0;
      }
      return 0.0;
    }

    // Helper function to parse DateTime safely
    DateTime parseDateTime(dynamic dateTime) {
      if (dateTime == null) return DateTime.now();
      if (dateTime is String) {
        return DateTime.tryParse(dateTime) ?? DateTime.now();
      }
      return DateTime.now();
    }

    // Helper function to convert to String safely
    String? parseStringOrNull(dynamic value) {
      if (value == null) return null;
      if (value is String) return value.isEmpty ? null : value;
      if (value is int) return null; // ถ้าเป็น category ID ให้ return null แทน
      if (value is double) return value.toString();
      return value.toString();
    }

    // Helper function to convert to required String
    String parseString(dynamic value, {String defaultValue = ''}) {
      if (value == null) return defaultValue;
      if (value is String) return value;
      if (value is int) return value.toString();
      if (value is double) return value.toString();
      return value.toString();
    }

    // Helper function to parse int safely
    int parseInt(dynamic value, {int defaultValue = 0}) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) {
        return int.tryParse(value) ?? defaultValue;
      }
      return defaultValue;
    }

    // Helper function to parse bool safely
    bool parseBool(dynamic value, {bool defaultValue = true}) {
      if (value == null) return defaultValue;
      if (value is bool) return value;
      if (value is int) return value != 0;
      if (value is String) {
        return value.toLowerCase() == 'true' || value == '1';
      }
      return defaultValue;
    }

    try {
      return Product(
        id: parseInt(json['id']),
        name: parseString(json['name']),
        description: parseString(json['description']),
        price: parsePrice(json['price']),
        image: parseStringOrNull(json['image']),
        category: parseStringOrNull(json['category']),
        isAvailable: parseBool(json['is_available']),
        stock: parseInt(json['stock']),
        createdAt: parseDateTime(json['created_at']),
        updatedAt: parseDateTime(json['updated_at']),
      );
    } catch (e) {
      print('Error parsing Product JSON: $json');
      print('Parse error: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'category': category,
      'is_available': isAvailable,
      'stock': stock,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper methods
  bool get inStock => stock > 0;
  String get formattedPrice => '฿${price.toStringAsFixed(2)}';
}