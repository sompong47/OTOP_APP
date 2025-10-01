class Order {
  final int id;
  final String orderNumber;
  final DateTime orderDate;
  final double totalAmount;
  final double shippingFee;
  final double discount;
  final String status;
  final String paymentMethod;
  final String? paymentStatus;
  final List<OrderItem> items;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final String shippingAddress;
  final String? trackingNumber;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.orderNumber,
    required this.orderDate,
    required this.totalAmount,
    this.shippingFee = 0.0,
    this.discount = 0.0,
    required this.status,
    required this.paymentMethod,
    this.paymentStatus,
    required this.items,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.shippingAddress,
    this.trackingNumber,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    return Order(
      id: json['id'] ?? 0,
      orderNumber: json['order_number'] ?? '',
      orderDate: DateTime.tryParse(json['order_date']?.toString() ?? '') ?? DateTime.now(),
      totalAmount: parseDouble(json['total_amount']),
      shippingFee: parseDouble(json['shipping_fee']),
      discount: parseDouble(json['discount']),
      status: json['status'] ?? 'pending',
      paymentMethod: json['payment_method'] ?? 'cod',
      paymentStatus: json['payment_status'],
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ??
          [],
      customerName: json['customer_name'] ?? '',
      customerPhone: json['customer_phone'] ?? '',
      customerEmail: json['customer_email'] ?? '',
      shippingAddress: json['shipping_address'] ?? '',
      trackingNumber: json['tracking_number'],
      notes: json['notes'],
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'order_date': orderDate.toIso8601String(),
      'total_amount': totalAmount,
      'shipping_fee': shippingFee,
      'discount': discount,
      'status': status,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'items': items.map((item) => item.toJson()).toList(),
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_email': customerEmail,
      'shipping_address': shippingAddress,
      'tracking_number': trackingNumber,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class OrderItem {
  final int id;
  final int productId;
  final String productName;
  final String? productImage;
  final double price;
  final int quantity;
  final String? variant;

  OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.price,
    required this.quantity,
    this.variant,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    return OrderItem(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      productName: json['product_name'] ?? '',
      productImage: json['product_image'],
      price: parseDouble(json['price']),
      quantity: json['quantity'] ?? 0,
      variant: json['variant'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'product_image': productImage,
      'price': price,
      'quantity': quantity,
      'variant': variant,
    };
  }

  double get subtotal => price * quantity;
  
  // ✅ เพิ่มบรรทัดนี้เพื่อแก้ปัญหา
  double get totalPrice => price * quantity;
}