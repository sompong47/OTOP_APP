import 'dart:convert';
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'ไม่สามารถโหลดข้อมูลสินค้าได้'};
      }
    } catch (e) {
      return {'success': false, 'message': 'เกิดข้อผิดพลาด: $e'};
    }
  }

  Future<Map<String, dynamic>> getProduct(int productId) async {
    try {
      final response = await _api.get('${AppConfig.productsEndpoint}$productId/');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'ไม่พบสินค้านี้'};
      }
    } catch (e) {
      return {'success': false, 'message': 'เกิดข้อผิดพลาด: $e'};
    }
  }

  Future<Map<String, dynamic>> getCategories() async {
    try {
      final response = await _api.get(AppConfig.categoriesEndpoint);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'ไม่สามารถโหลดหมวดหมู่ได้'};
      }
    } catch (e) {
      return {'success': false, 'message': 'เกิดข้อผิดพลาด: $e'};
    }
  }
}