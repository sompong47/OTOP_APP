import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../utils/constants.dart';
import 'storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final StorageService _storage = StorageService();

  // Basic headers without auth
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Headers with auth token
  Future<Map<String, String>> get _authHeaders async {
    final headers = Map<String, String>.from(_headers);
    final token = await _storage.getToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // POST without auth (สำหรับ register/login)
  Future<http.Response> postPublic(String endpoint, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
      
      // Debug logs
      debugPrint('=== API DEBUG ===');
      debugPrint('Request URL: $url');
      debugPrint('Request Headers: $_headers');
      debugPrint('Request Body: ${jsonEncode(data)}');
      
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(data),
      ).timeout(AppConstants.apiTimeout);
      
      // Debug response
      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Headers: ${response.headers}');
      debugPrint('Response Body: ${response.body}');
      debugPrint('=================');
      
      return response;
    } on SocketException catch (e) {
      debugPrint('SocketException: $e');
      throw Exception('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้');
    } on HttpException catch (e) {
      debugPrint('HttpException: $e');
      throw Exception('เกิดข้อผิดพลาดจากเซิร์ฟเวอร์');
    } catch (e) {
      debugPrint('General Exception: $e');
      throw Exception('Network error: $e');
    }
  }

  // GET with auth
  Future<http.Response> get(String endpoint) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
      final headers = await _authHeaders;
      
      debugPrint('GET Request URL: $url');
      
      final response = await http.get(
        url, 
        headers: headers,
      ).timeout(AppConstants.apiTimeout);
      
      debugPrint('GET Response Status: ${response.statusCode}');
      
      return response;
    } on SocketException {
      throw Exception('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้');
    } on HttpException {
      throw Exception('เกิดข้อผิดพลาดจากเซิร์ฟเวอร์');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // POST with auth (สำหรับ API ที่ต้อง login)
  Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
      final headers = await _authHeaders;
      
      debugPrint('POST Request URL: $url');
      debugPrint('POST Request Body: ${jsonEncode(data)}');
      
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(data),
      ).timeout(AppConstants.apiTimeout);
      
      debugPrint('POST Response Status: ${response.statusCode}');
      
      return response;
    } on SocketException {
      throw Exception('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้');
    } on HttpException {
      throw Exception('เกิดข้อผิดพลาดจากเซิร์ฟเวอร์');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // PUT with auth
  Future<http.Response> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
      final headers = await _authHeaders;
      
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(data),
      ).timeout(AppConstants.apiTimeout);
      
      return response;
    } on SocketException {
      throw Exception('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้');
    } on HttpException {
      throw Exception('เกิดข้อผิดพลาดจากเซิร์ฟเวอร์');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // PATCH with auth
  Future<http.Response> patch(String endpoint, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
      final headers = await _authHeaders;
      
      final response = await http.patch(
        url,
        headers: headers,
        body: jsonEncode(data),
      ).timeout(AppConstants.apiTimeout);
      
      return response;
    } on SocketException {
      throw Exception('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้');
    } on HttpException {
      throw Exception('เกิดข้อผิดพลาดจากเซิร์ฟเวอร์');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // DELETE with auth
  Future<http.Response> delete(String endpoint) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
      final headers = await _authHeaders;
      
      final response = await http.delete(
        url, 
        headers: headers,
      ).timeout(AppConstants.apiTimeout);
      
      return response;
    } on SocketException {
      throw Exception('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้');
    } on HttpException {
      throw Exception('เกิดข้อผิดพลาดจากเซิร์ฟเวอร์');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Upload file with auth
  Future<http.StreamedResponse> uploadFile(
    String endpoint,
    String filePath,
    String fieldName, {
    Map<String, String>? additionalFields,
  }) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
      final request = http.MultipartRequest('POST', url);
      
      // Add auth headers
      final headers = await _authHeaders;
      request.headers.addAll(headers);
      
      // Add file
      final file = await http.MultipartFile.fromPath(fieldName, filePath);
      request.files.add(file);
      
      // Add additional fields
      if (additionalFields != null) {
        request.fields.addAll(additionalFields);
      }
      
      final response = await request.send().timeout(AppConstants.apiTimeout);
      return response;
    } on SocketException {
      throw Exception('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้');
    } on HttpException {
      throw Exception('เกิดข้อผิดพลาดจากเซิร์ฟเวอร์');
    } catch (e) {
      throw Exception('Upload error: $e');
    }
  }

  // Check network connectivity
  Future<bool> checkConnectivity() async {
    try {
      // ใช้ root endpoint ตรวจสอบ
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/'),
        headers: _headers,
      ).timeout(const Duration(seconds: 5));
      
      debugPrint('Connectivity check: ${response.statusCode}');
      return response.statusCode < 500;
    } catch (e) {
      debugPrint('Connectivity check failed: $e');
      return false;
    }
  }
}