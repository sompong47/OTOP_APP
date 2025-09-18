// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
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
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<http.Response> get(String endpoint) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
      final headers = await _authHeaders;
      return await http.get(url, headers: headers);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
      final headers = await _authHeaders;
      return await http.post(
        url,
        headers: headers,
        body: jsonEncode(data),
      );
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
      final headers = await _authHeaders;
      return await http.put(
        url,
        headers: headers,
        body: jsonEncode(data),
      );
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<http.Response> delete(String endpoint) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
      final headers = await _authHeaders;
      return await http.delete(url, headers: headers);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}