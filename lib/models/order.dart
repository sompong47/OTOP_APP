class Order {
  final int id;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final double totalAmount;
  final String shippingAddress;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.totalAmount,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      customerName: json['customer_name'],
      customerPhone: json['customer_phone'] ?? '',
      customerEmail: json['customer_email'] ?? '',
      totalAmount: double.parse(json['total_amount'].toString()),
      shippingAddress: json['shipping_address'],
      paymentMethod: json['payment_method'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      items: (json['items'] as List?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_email': customerEmail,
      'total_amount': totalAmount,
      'shipping_address': shippingAddress,
      'payment_method': paymentMethod,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  // Helper methods
  String get statusDisplayName {
    switch (status) {
      case 'pending':
        return 'รอดำเนินการ';
      case 'confirmed':
        return 'ยืนยันแล้ว';
      case 'shipped':
        return 'จัดส่งแล้ว';
      case 'delivered':
        return 'ส่งถึงแล้ว';
      case 'cancelled':
        return 'ยกเลิก';
      default:
        return status;
    }
  }

  String get paymentMethodDisplayName {
    switch (paymentMethod) {
      case 'transfer':
        return 'โอนเงิน';
      case 'cod':
        return 'เก็บเงินปลายทาง';
      default:
        return paymentMethod;
    }
  }

  int get totalItemsCount {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }
}

class OrderItem {
  final int? id;
  final int product;
  final String productName;
  final int quantity;
  final double price;

  OrderItem({
    this.id,
    required this.product,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      product: json['product'],
      productName: json['product_name'] ?? '',
      quantity: json['quantity'],
      price: double.parse(json['price'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'product': product,
      'product_name': productName,
      'quantity': quantity,
      'price': price,
    };
  }

  double get totalPrice => price * quantity;
}

// For creating orders
class CreateOrderRequest {
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final String shippingAddress;
  final String paymentMethod;
  final List<CreateOrderItem> items;

  CreateOrderRequest({
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_email': customerEmail,
      'shipping_address': shippingAddress,
      'payment_method': paymentMethod,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  double get totalAmount {
    return items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }
}

class CreateOrderItem {
  final int productId;
  final int quantity;
  final double price;

  CreateOrderItem({
    required this.productId,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
      'price': price,
    };
  }
}