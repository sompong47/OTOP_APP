import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import 'api_service.dart';

class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> getProducts([Map<String, String>? params]) async {
    try {
      String endpoint = AppConfig.productsEndpoint;
      if (params != null && params.isNotEmpty) {
        final queryString = params.entries
            .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
            .join('&');
        endpoint += '?$queryString';
      }

      final response = await _api.get(endpoint);
      debugPrint('GET Request URL: ${AppConfig.baseUrl}$endpoint');
      debugPrint('GET Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'ไม่สามารถโหลดข้อมูลสินค้าได้'};
      }
    } catch (e) {
      debugPrint('Error in getProducts: $e');
      return {'success': false, 'message': 'เกิดข้อผิดพลาด: $e'};
    }
  }

  Future<Map<String, dynamic>> getProduct(int productId) async {
    try {
      final response = await _api.get('${AppConfig.productsEndpoint}$productId/');
      debugPrint('GET Request URL: ${AppConfig.baseUrl}${AppConfig.productsEndpoint}$productId/');
      debugPrint('GET Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'ไม่พบสินค้านี้'};
      }
    } catch (e) {
      debugPrint('Error in getProduct: $e');
      return {'success': false, 'message': 'เกิดข้อผิดพลาด: $e'};
    }
  }

  Future<Map<String, dynamic>> getCategories() async {
    try {
      final response = await _api.get(AppConfig.categoriesEndpoint);
      debugPrint('GET Request URL: ${AppConfig.baseUrl}${AppConfig.categoriesEndpoint}');
      debugPrint('GET Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'ไม่สามารถโหลดหมวดหมู่ได้'};
      }
    } catch (e) {
      debugPrint('Error in getCategories: $e');
      return {'success': false, 'message': 'เกิดข้อผิดพลาด: $e'};
    }
  }

  Future<Map<String, dynamic>> getSellerDashboard() async {
    try {
      final response = await _api.get(AppConfig.sellerDashboardEndpoint);
      debugPrint('GET Request URL: ${AppConfig.baseUrl}${AppConfig.sellerDashboardEndpoint}');
      debugPrint('GET Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else if (response.statusCode == 404) {
        // API ยังไม่พร้อม ให้ใช้ mock data
        debugPrint('Dashboard API not found, using mock data');
        return _getMockDashboardData();
      } else {
        return {'success': false, 'message': 'ไม่สามารถโหลดข้อมูล Dashboard ได้'};
      }
    } catch (e) {
      debugPrint('Error in getSellerDashboard: $e');
      // หาก API ยังไม่พร้อม ให้ใช้ mock data
      return _getMockDashboardData();
    }
  }

  // Mock data สำหรับ dashboard เมื่อ API ยังไม่พร้อม
  Map<String, dynamic> _getMockDashboardData() {
    return {
      'success': true,
      'data': {
        'today_sales': 1250.0,
        'sales_growth': 8.5,
        'new_orders': 5,
        'pending_orders': 2,
        'total_products': 12,
        'low_stock_products': 1,
        'average_rating': 4.3,
        'total_reviews': 23,
        'recent_activities': [
          {
            'type': 'order',
            'title': 'มีคำสั่งซื้อใหม่',
            'subtitle': 'ผ้าไหมไทย - 1 ชิ้น',
            'time': '10 นาทีที่แล้ว'
          },
          {
            'type': 'stock',
            'title': 'สินค้าเหลือน้อย',
            'subtitle': 'หอมแดงศรีสะเกษ เหลือ 3 ชิ้น',
            'time': '1 ชั่วโมงที่แล้ว'
          },
          {
            'type': 'review',
            'title': 'รีวิวใหม่',
            'subtitle': 'คะแนน 5 ดาว สำหรับผ้าไหมไทย',
            'time': '2 ชั่วโมงที่แล้ว'
          }
        ]
      }
    };
  }

  // เพิ่ม method สำหรับ orders
  Future<Map<String, dynamic>> getOrders([Map<String, String>? params]) async {
    try {
      String endpoint = '/api/orders/';
      if (params != null && params.isNotEmpty) {
        final queryString = params.entries
            .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
            .join('&');
        endpoint += '?$queryString';
      }

      final response = await _api.get(endpoint);
      debugPrint('GET Request URL: ${AppConfig.baseUrl}$endpoint');
      debugPrint('GET Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else if (response.statusCode == 405 || response.statusCode == 404) {
        // API ยังไม่พร้อม ให้ใช้ mock data
        return _getMockOrdersData();
      } else {
        return {'success': false, 'message': 'ไม่สามารถโหลดข้อมูลคำสั่งซื้อได้'};
      }
    } catch (e) {
      debugPrint('Error in getOrders: $e');
      return _getMockOrdersData();
    }
  }

  // Mock data สำหรับ orders
  Map<String, dynamic> _getMockOrdersData() {
    return {
      'success': true,
      'data': {
        'results': [
          {
            'id': 1,
            'order_number': 'ORD-001',
            'customer_name': 'สมชาย ใจดี',
            'total': 200.0,
            'status': 'pending',
            'created_at': DateTime.now().subtract(Duration(hours: 2)).toIso8601String(),
            'items': [
              {
                'product_name': 'ผ้าไหมไทย',
                'quantity': 1,
                'price': 200.0
              }
            ]
          },
          {
            'id': 2,
            'order_number': 'ORD-002',
            'customer_name': 'สมหญิง ดีใจ',
            'total': 60.0,
            'status': 'completed',
            'created_at': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
            'items': [
              {
                'product_name': 'หอมแดงศรีสะเกษ',
                'quantity': 3,
                'price': 20.0
              }
            ]
          }
        ],
        'next': null,
        'previous': null,
        'count': 2
      }
    };
  }
}