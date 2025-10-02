class Category {
  final int id;
  final String name;
  final String? description;
  final String? icon;
  final DateTime createdAt;
  final DateTime updatedAt;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
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

    try {
      return Category(
        id: parseInt(json['id']),
        name: json['name']?.toString() ?? '',
        description: parseStringOrNull(json['description']),
        icon: parseStringOrNull(json['icon']),
        createdAt: parseDateTime(json['created_at']),
        updatedAt: parseDateTime(json['updated_at']),
      );
    } catch (e) {
      print('Error parsing Category JSON: $json');
      print('Parse error: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}