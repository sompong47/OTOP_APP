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
  final OrderAddress shippingAddress;
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
    required this.shippingAddress,
    this.trackingNumber,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? 0,
      orderNumber: json['order_number'] ?? '',
      orderDate: DateTime.parse(json['order_date'] ?? DateTime.now().toIso8601String()),
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      shippingFee: (json['shipping_fee'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      paymentMethod: json['payment_method'] ?? 'cod',
      paymentStatus: json['payment_status'],
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => OrderItem.fromJson(item))
          .toList() ?? [],
      shippingAddress: OrderAddress.fromJson(json['shipping_address'] ?? {}),
      trackingNumber: json['tracking_number'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
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
      'shipping_address': shippingAddress.toJson(),
      'tracking_number': trackingNumber,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.subtotal);
  double get finalAmount => totalAmount + shippingFee - discount;
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
    return OrderItem(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      productName: json['product_name'] ?? '',
      productImage: json['product_image'],
      price: (json['price'] ?? 0).toDouble(),
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
}

class OrderAddress {
  final String fullName;
  final String phone;
  final String address;
  final String district;
  final String province;
  final String postalCode;
  final String? additionalInfo;

  OrderAddress({
    required this.fullName,
    required this.phone,
    required this.address,
    required this.district,
    required this.province,
    required this.postalCode,
    this.additionalInfo,
  });

  factory OrderAddress.fromJson(Map<String, dynamic> json) {
    return OrderAddress(
      fullName: json['full_name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      district: json['district'] ?? '',
      province: json['province'] ?? '',
      postalCode: json['postal_code'] ?? '',
      additionalInfo: json['additional_info'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'phone': phone,
      'address': address,
      'district': district,
      'province': province,
      'postal_code': postalCode,
      'additional_info': additionalInfo,
    };
  }

  String get fullAddress {
    return '$address $district $province $postalCode';
  }
}

// สำหรับสร้าง Order ใหม่
class CreateOrderRequest {
  final List<CreateOrderItem> items;
  final OrderAddress shippingAddress;
  final String paymentMethod;
  final String? notes;

  CreateOrderRequest({
    required this.items,
    required this.shippingAddress,
    required this.paymentMethod,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'shipping_address': shippingAddress.toJson(),
      'payment_method': paymentMethod,
      'notes': notes,
    };
  }
}

class CreateOrderItem {
  final int productId;
  final int quantity;
  final String? variant;

  CreateOrderItem({
    required this.productId,
    required this.quantity,
    this.variant,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
      'variant': variant,
    };
  }
}