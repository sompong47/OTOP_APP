import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../utils/constants.dart';
import 'storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final StorageService _storage = StorageService();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Future<Map<String, String>> get _authHeaders async {
    final headers = Map<String, String>.from(_headers);
    final token = await _storage.getToken();
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  Future<Map<String, String>> getHeaders() async => await _authHeaders;

  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
    final headers = await getHeaders();
    return await http.get(url, headers: headers).timeout(AppConstants.apiTimeout);
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
    final headers = await getHeaders();
    return await http.post(url, headers: headers, body: jsonEncode(data))
        .timeout(AppConstants.apiTimeout);
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
    final headers = await getHeaders();
    return await http.put(url, headers: headers, body: jsonEncode(data))
        .timeout(AppConstants.apiTimeout);
  }

  Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
    final headers = await getHeaders();
    return await http.delete(url, headers: headers)
        .timeout(AppConstants.apiTimeout);
  }

  Future<http.StreamedResponse> uploadFile(
    String endpoint,
    String filePath,
    String fieldName, {
    Map<String, String>? additionalFields,
    String method = 'POST',
  }) async {
    final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
    final request = http.MultipartRequest(method, url);
    final headers = await getHeaders();
    request.headers.addAll(headers);

    final file = await http.MultipartFile.fromPath(fieldName, filePath);
    request.files.add(file);

    if (additionalFields != null) request.fields.addAll(additionalFields);

    return await request.send().timeout(AppConstants.apiTimeout);
  }
}

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
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'message': 'ไม่สามารถโหลดสินค้าได้'};
      }
    } catch (e) {
      debugPrint('getProducts error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getSellerProducts() async {
    try {
      final response = await _api.get('seller/products/');
      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'message': 'โหลดสินค้าของคุณไม่สำเร็จ'};
      }
    } catch (e) {
      debugPrint('getSellerProducts error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // ✅ แก้ไข createProduct - รองรับทั้งมีรูปและไม่มีรูป
  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> data) async {
    try {
      debugPrint('📤 Creating product with data: $data');
      
      // ถ้าไม่มีรูป ส่งเป็น JSON ธรรมดา
      if (data['image'] == null) {
        // ลบ key ที่เป็น null ออก
        data.removeWhere((key, value) => value == null);
        
        final response = await _api.post('seller/products/', data);
        debugPrint('📥 Response status: ${response.statusCode}');
        debugPrint('📥 Response body: ${response.body}');
        
        if (response.statusCode == 201) {
          return {'success': true, 'data': jsonDecode(response.body)};
        } else {
          final errorBody = response.body;
          debugPrint('❌ Error response: $errorBody');
          return {'success': false, 'message': errorBody};
        }
      }

      // ถ้ามีรูป ใช้ multipart
      File imageFile = data['image'];
      data.remove('image');

      // ✅ แปลงเฉพาะ field ที่เป็น string เท่านั้น
      final fields = <String, String>{};
      data.forEach((key, value) {
        if (value != null) {
          fields[key] = value.toString();
        }
      });

      debugPrint('📤 Uploading with fields: $fields');

      final streamedResponse = await _api.uploadFile(
        'seller/products/',
        imageFile.path,
        'image',
        additionalFields: fields,
        method: 'POST',
      );

      final response = await http.Response.fromStream(streamedResponse);
      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response body: ${response.body}');

      if (response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'message': response.body};
      }
    } catch (e) {
      debugPrint('❌ createProduct error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // ✅ แก้ไข updateProduct เช่นเดียวกัน
  Future<Map<String, dynamic>> updateProduct(int id, Map<String, dynamic> data) async {
    try {
      debugPrint('📤 Updating product $id with data: $data');
      
      if (data['image'] == null) {
        data.removeWhere((key, value) => value == null);
        
        final response = await _api.put('seller/products/$id/', data);
        debugPrint('📥 Response status: ${response.statusCode}');
        debugPrint('📥 Response body: ${response.body}');
        
        if (response.statusCode == 200) {
          return {'success': true, 'data': jsonDecode(response.body)};
        } else {
          return {'success': false, 'message': response.body};
        }
      }

      File imageFile = data['image'];
      data.remove('image');

      final fields = <String, String>{};
      data.forEach((key, value) {
        if (value != null) {
          fields[key] = value.toString();
        }
      });

      final streamedResponse = await _api.uploadFile(
        'seller/products/$id/',
        imageFile.path,
        'image',
        additionalFields: fields,
        method: 'PUT',
      );

      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'message': response.body};
      }
    } catch (e) {
      debugPrint('❌ updateProduct error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> deleteProduct(int id) async {
    try {
      final response = await _api.delete('seller/products/$id/');
      if (response.statusCode == 204) {
        return {'success': true};
      } else {
        return {'success': false, 'message': response.body};
      }
    } catch (e) {
      debugPrint('deleteProduct error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getSellerDashboard() async {
    try {
      final response = await _api.get('seller/dashboard/');
      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'message': 'โหลดแดชบอร์ดไม่สำเร็จ'};
      }
    } catch (e) {
      debugPrint('getSellerDashboard error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getProduct(int productId) async {
    try {
      final response = await _api.get('${AppConfig.productsEndpoint}$productId/');
      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'message': 'โหลดสินค้าไม่สำเร็จ'};
      }
    } catch (e) {
      debugPrint('getProduct error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getCategories() async {
    try {
      final response = await _api.get('categories/');
      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'message': 'โหลดหมวดหมู่ไม่สำเร็จ'};
      }
    } catch (e) {
      debugPrint('getCategories error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }
}