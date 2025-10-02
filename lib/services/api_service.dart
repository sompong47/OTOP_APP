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

  // Public method to access headers (for ProductService)
  Future<Map<String, String>> getHeaders() async {
    return await _authHeaders;
  }

  // POST without auth (สำหรับ register/login)
  Future<http.Response> postPublic(String endpoint, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
      
      debugPrint('=== API DEBUG ===');
      debugPrint('Request URL: $url');
      debugPrint('Request Headers: $_headers');
      debugPrint('Request Body: ${jsonEncode(data)}');
      
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(data),
      ).timeout(AppConstants.apiTimeout);
      
      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');
      return response;
    } catch (e) {
      debugPrint('postPublic Exception: $e');
      throw Exception('Network error: $e');
    }
  }

  // GET with auth
  Future<http.Response> get(String endpoint) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
      final headers = await getHeaders();
      debugPrint('GET Request URL: $url');
      final response = await http.get(url, headers: headers).timeout(AppConstants.apiTimeout);
      debugPrint('GET Response Status: ${response.statusCode}');
      return response;
    } catch (e) {
      debugPrint('GET Exception: $e');
      throw Exception('Network error: $e');
    }
  }

  // POST with auth
  Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
      final headers = await getHeaders();
      debugPrint('POST Request URL: $url');
      final response = await http.post(url, headers: headers, body: jsonEncode(data)).timeout(AppConstants.apiTimeout);
      debugPrint('POST Response Status: ${response.statusCode}');
      return response;
    } catch (e) {
      debugPrint('POST Exception: $e');
      throw Exception('Network error: $e');
    }
  }

  // PUT with auth
  Future<http.Response> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
      final headers = await getHeaders();
      final response = await http.put(url, headers: headers, body: jsonEncode(data)).timeout(AppConstants.apiTimeout);
      return response;
    } catch (e) {
      debugPrint('PUT Exception: $e');
      throw Exception('Network error: $e');
    }
  }

  // DELETE with auth
  Future<http.Response> delete(String endpoint) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
      final headers = await getHeaders();
      final response = await http.delete(url, headers: headers).timeout(AppConstants.apiTimeout);
      return response;
    } catch (e) {
      debugPrint('DELETE Exception: $e');
      throw Exception('Network error: $e');
    }
  }

  // Upload file with auth
  Future<http.StreamedResponse> uploadFile(
    String endpoint,
    String filePath,
    String fieldName, {
    Map<String, String>? additionalFields,
    String method = 'POST',
  }) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
      final request = http.MultipartRequest(method, url);
      final headers = await getHeaders();
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
    } catch (e) {
      debugPrint('Upload file Exception: $e');
      throw Exception('Upload error: $e');
    }
  }
}
