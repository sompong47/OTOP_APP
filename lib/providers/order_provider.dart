import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../services/api_service.dart';
import '../config/app_config.dart';

class OrderProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  // States
  List<Order> _orders = [];
  Order? _selectedOrder;
  bool _isLoading = false;
  String? _error;
  
  // Pagination
  int _currentPage = 1;
  bool _hasNextPage = true;
  bool _isLoadingMore = false;

  // Getters
  List<Order> get orders => _orders;
  Order? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  bool get hasNextPage => _hasNextPage;

  // Load user's orders
  Future<void> loadMyOrders({bool refresh = false}) async {
    try {
      if (refresh) {
        _currentPage = 1;
        _hasNextPage = true;
        _orders.clear();
      }

      _setLoading(true);
      _setError(null);

      final response = await _api.get('${AppConfig.ordersEndpoint}?page=$_currentPage');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        final List<Order> newOrders = (data['results'] as List)
            .map((orderJson) => Order.fromJson(orderJson))
            .toList();

        if (refresh) {
          _orders = newOrders;
        } else {
          _orders.addAll(newOrders);
        }

        _hasNextPage = data['next'] != null;
        _currentPage++;
        
        debugPrint('Loaded ${newOrders.length} orders');
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error loading orders: $e');
      _setError('ไม่สามารถโหลดรายการคำสั่งซื้อได้');
    } finally {
      _setLoading(false);
    }
  }

  // Load more orders (pagination)
  Future<void> loadMoreOrders() async {
    if (_isLoadingMore || !_hasNextPage) return;

    try {
      _isLoadingMore = true;
      notifyListeners();

      await loadMyOrders(refresh: false);
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Load specific order details
  Future<void> loadOrderDetail(int orderId) async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await _api.get('${AppConfig.ordersEndpoint}$orderId/');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _selectedOrder = Order.fromJson(data);
        
        debugPrint('Loaded order detail for ID: $orderId');
      } else if (response.statusCode == 404) {
        throw Exception('ไม่พบคำสั่งซื้อนี้');
      } else {
        throw Exception('Failed to load order detail: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error loading order detail: $e');
      _setError('ไม่สามารถโหลดรายละเอียดคำสั่งซื้อได้');
    } finally {
      _setLoading(false);
    }
  }

  // Set selected order (เพิ่ม method นี้)
  void setSelectedOrder(Order order) {
    _selectedOrder = order;
    notifyListeners();
  }

  // Create new order
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderRequest) async {
    try {
      _setLoading(true);
      _setError(null);

      debugPrint('Creating order with data: $orderRequest');

      final response = await _api.post(AppConfig.createOrderEndpoint, orderRequest);
      
      if (response.statusCode == 201) {
        final decoded = jsonDecode(response.body);

        final orderJson = decoded['data'] ?? decoded;

        final newOrder = Order.fromJson(orderJson);
        
        // Add to beginning of orders list
        _orders.insert(0, newOrder);
        _selectedOrder = newOrder;
        
        debugPrint('Order created successfully: ${newOrder.orderNumber}');
        
        return {
          'success': true,
          'order': newOrder,
          'message': 'สร้างคำสั่งซื้อสำเร็จ',
        };
      } else {
        final errorBody = response.body;
        String errorMessage = 'ไม่สามารถสร้างคำสั่งซื้อได้';
        
        try {
          final error = jsonDecode(errorBody);
          if (error['detail'] != null) {
            errorMessage = error['detail'];
          } else if (error['message'] != null) {
            errorMessage = error['message'];
          }
        } catch (e) {
          debugPrint('Error parsing create order error response: $e');
        }
        
        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      debugPrint('Error creating order: $e');
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาดในการสร้างคำสั่งซื้อ',
      };
    } finally {
      _setLoading(false);
    }
  }

  // Cancel order
  Future<Map<String, dynamic>> cancelOrder(int orderId) async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await _api.post('${AppConfig.ordersEndpoint}$orderId/cancel/', {});
      
      if (response.statusCode == 200) {
        // Update order status in local data
        final orderIndex = _orders.indexWhere((order) => order.id == orderId);
        if (orderIndex != -1) {
          final updatedOrder = Order.fromJson({
            ..._orders[orderIndex].toJson(),
            'status': 'cancelled',
            'updated_at': DateTime.now().toIso8601String(),
          });
          _orders[orderIndex] = updatedOrder;
          
          if (_selectedOrder?.id == orderId) {
            _selectedOrder = updatedOrder;
          }
        }
        
        return {
          'success': true,
          'message': 'ยกเลิกคำสั่งซื้อสำเร็จ',
        };
      } else {
        final errorBody = response.body;
        String errorMessage = 'ไม่สามารถยกเลิกคำสั่งซื้อได้';
        
        try {
          final error = jsonDecode(errorBody);
          if (error['detail'] != null) {
            errorMessage = error['detail'];
          } else if (error['message'] != null) {
            errorMessage = error['message'];
          }
        } catch (e) {
          debugPrint('Error parsing cancel order error response: $e');
        }
        
        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      debugPrint('Error cancelling order: $e');
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาดในการยกเลิกคำสั่งซื้อ',
      };
    } finally {
      _setLoading(false);
    }
  }

  // Get orders by status
  List<Order> getOrdersByStatus(String status) {
    return _orders.where((order) => order.status == status).toList();
  }

  // Search orders
  List<Order> searchOrders(String query) {
    if (query.isEmpty) return _orders;
    
    final lowercaseQuery = query.toLowerCase();
    return _orders.where((order) {
      return order.orderNumber.toLowerCase().contains(lowercaseQuery) ||
             order.items.any((item) => 
               item.productName.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Clear selected order
  void clearSelectedOrder() {
    _selectedOrder = null;
    notifyListeners();
  }

  // Refresh orders
  Future<void> refreshOrders() async {
    await loadMyOrders(refresh: true);
  }

  // Clear all data (on logout)
  void clearAll() {
    _orders.clear();
    _selectedOrder = null;
    _isLoading = false;
    _error = null;
    _currentPage = 1;
    _hasNextPage = true;
    _isLoadingMore = false;
    notifyListeners();
  }
}