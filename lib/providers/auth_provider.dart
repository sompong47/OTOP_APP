import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final StorageService _storage = StorageService();

  User? _user;
  bool _isLoading = false;
  bool _isLoggedIn = false;

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;

  // Initialize - check if user is already logged in
  Future<void> init() async {
    // Add small delay to prevent setState during build
    await Future.delayed(Duration.zero);
    
    _isLoading = true;
    notifyListeners();

    try {
      _isLoggedIn = await _authService.isLoggedIn();
      if (_isLoggedIn) {
        _user = await _authService.getCurrentUser();
      }
    } catch (e) {
      debugPrint('Error initializing auth: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login
  Future<Map<String, dynamic>> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.login(username, password);
      
      if (result['success'] == true) {
        _isLoggedIn = true;
        _user = await _authService.getCurrentUser();
      }
      
      return result;
    } catch (e) {
      return {'success': false, 'message': 'เกิดข้อผิดพลาด: $e'};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register
  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.register(username, email, password);
      return result;
    } catch (e) {
      return {'success': false, 'message': 'เกิดข้อผิดพลาด: $e'};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update Profile
  Future<Map<String, dynamic>> updateProfile({
    String? username,
    String? email,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.updateProfile(
        username: username,
        email: email,
      );
      
      if (result['success'] == true) {
        _user = await _authService.getCurrentUser();
      }
      
      return result;
    } catch (e) {
      return {'success': false, 'message': 'เกิดข้อผิดพลาด: $e'};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _user = null;
      _isLoggedIn = false;
    } catch (e) {
      debugPrint('Error logging out: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh user data
  Future<void> refreshUser() async {
    try {
      _user = await _authService.getCurrentUser();
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing user: $e');
    }
  }

  // Validate token
  Future<bool> validateToken() async {
    try {
      return await _authService.validateToken();
    } catch (e) {
      debugPrint('Error validating token: $e');
      return false;
    }
  }
}