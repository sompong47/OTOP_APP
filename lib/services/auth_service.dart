import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../config/app_config.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _api = ApiService();
  final StorageService _storage = StorageService();

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _api.postPublic(AppConfig.loginEndpoint, {
        'username': username,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.saveTokens(data['access'], data['refresh']);
        return {'success': true, 'data': data};
      } else {
        final errorBody = response.body;
        String errorMessage = 'เข้าสู่ระบบไม่สำเร็จ';
        
        try {
          final error = jsonDecode(errorBody);
          if (error['detail'] != null) {
            errorMessage = error['detail'];
          } else if (error['message'] != null) {
            errorMessage = error['message'];
          } else if (error['non_field_errors'] != null) {
            errorMessage = error['non_field_errors'][0];
          }
        } catch (e) {
          debugPrint('Error parsing login error response: $e');
        }
        
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      debugPrint('Login error: $e');
      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้'};
    }
  }

  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    try {
      final response = await _api.postPublic(AppConfig.registerEndpoint, {
        'username': username,
        'email': email,
        'password': password,
      });
          

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final errorBody = response.body;
        String errorMessage = 'สมัครสมาชิกไม่สำเร็จ';
        
        try {
          final error = jsonDecode(errorBody);
          
          // Handle field-specific errors
          if (error['username'] != null) {
            errorMessage = 'ชื่อผู้ใช้: ${error['username'][0]}';
          } else if (error['email'] != null) {
            errorMessage = 'อีเมล: ${error['email'][0]}';
          } else if (error['password'] != null) {
            errorMessage = 'รหัสผ่าน: ${error['password'][0]}';
          } else if (error['message'] != null) {
            errorMessage = error['message'];
          } else if (error['detail'] != null) {
            errorMessage = error['detail'];
          }
        } catch (e) {
          debugPrint('Error parsing register error response: $e');
        }
        
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      debugPrint('Register error: $e');
      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้'};
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final response = await _api.get(AppConfig.profileEndpoint);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      } else if (response.statusCode == 401) {
        // Token expired, logout user
        await logout();
        return null;
      } else {
        debugPrint('Failed to get current user: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error getting current user: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    String? username,
    String? email,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (username != null) data['username'] = username;
      if (email != null) data['email'] = email;

      final response = await _api.put(AppConfig.profileEndpoint, data);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {'success': true, 'data': responseData};
      } else {
        final errorBody = response.body;
        String errorMessage = 'อัพเดทข้อมูลไม่สำเร็จ';
        
        try {
          final error = jsonDecode(errorBody);
          if (error['username'] != null) {
            errorMessage = 'ชื่อผู้ใช้: ${error['username'][0]}';
          } else if (error['email'] != null) {
            errorMessage = 'อีเมล: ${error['email'][0]}';
          } else if (error['message'] != null) {
            errorMessage = error['message'];
          }
        } catch (e) {
          debugPrint('Error parsing update profile error response: $e');
        }
        
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      debugPrint('Update profile error: $e');
      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้'};
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _api.post('/change-password/', {
        'current_password': currentPassword,
        'new_password': newPassword,
      });

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'เปลี่ยนรหัสผ่านสำเร็จ'};
      } else {
        final errorBody = response.body;
        String errorMessage = 'เปลี่ยนรหัสผ่านไม่สำเร็จ';
        
        try {
          final error = jsonDecode(errorBody);
          if (error['current_password'] != null) {
            errorMessage = 'รหัสผ่านปัจจุบัน: ${error['current_password'][0]}';
          } else if (error['new_password'] != null) {
            errorMessage = 'รหัสผ่านใหม่: ${error['new_password'][0]}';
          } else if (error['message'] != null) {
            errorMessage = error['message'];
          }
        } catch (e) {
          debugPrint('Error parsing change password error response: $e');
        }
        
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      debugPrint('Change password error: $e');
      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้'};
    }
  }

  Future<Map<String, dynamic>> refreshToken() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null) {
        return {'success': false, 'message': 'ไม่พบ refresh token'};
      }

      final response = await _api.postPublic('/token/refresh/', {
        'refresh': refreshToken,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.saveTokens(data['access'], refreshToken);
        return {'success': true, 'data': data};
      } else {
        // Refresh token expired, logout user
        await logout();
        return {'success': false, 'message': 'Session expired'};
      }
    } catch (e) {
      debugPrint('Refresh token error: $e');
      await logout();
      return {'success': false, 'message': 'Session expired'};
    }
  }

  Future<void> logout() async {
    try {
      // Optional: Call logout endpoint to invalidate token on server
      final token = await _storage.getToken();
      if (token != null) {
        try {
          await _api.post('/logout/', {});
        } catch (e) {
          debugPrint('Server logout error: $e');
        }
      }
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      await _storage.clearAll();
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.getToken();
    return token != null && token.isNotEmpty;
  }

  // Validate token and refresh if needed
  Future<bool> validateToken() async {
    try {
      final response = await _api.get('/profile/');
      
      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        // Try to refresh token
        final refreshResult = await refreshToken();
        return refreshResult['success'] == true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Token validation error: $e');
      return false;
    }
  }
}