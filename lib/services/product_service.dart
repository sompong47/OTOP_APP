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

  // =======================
  // สินค้าทั้งหมด (หน้าหลัก)
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

  // =======================
  // สินค้าของผู้ขาย (เฉพาะฉัน)
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

  // =======================
  // สร้างสินค้า
  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> data) async {
    try {
      if (data['image'] == null) {
        final response = await _api.post(AppConfig.productsEndpoint, data);
        if (response.statusCode == 201) {
          return {'success': true, 'data': jsonDecode(response.body)};
        } else {
          return {'success': false, 'message': response.body};
        }
      }

      File imageFile = data['image'];
      data.remove('image');

      final streamedResponse = await _api.uploadFile(
        AppConfig.productsEndpoint,
        imageFile.path,
        'image',
        additionalFields: data.map((k, v) => MapEntry(k, v.toString())),
        method: 'POST',
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'message': response.body};
      }
    } catch (e) {
      debugPrint('createProduct error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // =======================
  // อัพเดตสินค้า
  Future<Map<String, dynamic>> updateProduct(int id, Map<String, dynamic> data) async {
    try {
      if (data['image'] == null) {
        final response = await _api.put('${AppConfig.productsEndpoint}$id/', data);
        if (response.statusCode == 200) {
          return {'success': true, 'data': jsonDecode(response.body)};
        } else {
          return {'success': false, 'message': response.body};
        }
      }

      File imageFile = data['image'];
      data.remove('image');

      final streamedResponse = await _api.uploadFile(
        '${AppConfig.productsEndpoint}$id/',
        imageFile.path,
        'image',
        additionalFields: data.map((k, v) => MapEntry(k, v.toString())),
        method: 'PUT',
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'message': response.body};
      }
    } catch (e) {
      debugPrint('updateProduct error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // =======================
  // ลบสินค้า
  Future<Map<String, dynamic>> deleteProduct(int id) async {
    try {
      final response = await _api.delete('${AppConfig.productsEndpoint}$id/');
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

  // =======================
  // ดึงข้อมูลแดชบอร์ดผู้ขาย
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

  // =======================
  // ดึงสินค้าตาม id
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

  // =======================
  // ดึงหมวดหมู่สินค้า
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
