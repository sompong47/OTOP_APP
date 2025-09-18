import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/scheduler.dart';
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

  // Initialize
  Future<void> init() async {
    _isLoading = true;
    // ไม่เรียก notifyListeners ใน init เพราะ widget อาจยังไม่พร้อม

    try {
      _isLoggedIn = await _authService.isLoggedIn();
      if (_isLoggedIn) {
        _user = await _authService.getCurrentUser();
      }
    } catch (e) {
      debugPrint('Error initializing auth: $e');
    } finally {
      _isLoading = false;
      // เรียก notifyListeners ครั้งเดียวหลังจาก init เสร็จ
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  // Login
  Future<Map<String, dynamic>> login(String username, String password) async {
    _isLoading = true;
    notifyListeners(); // แจ้งว่าเริ่ม loading

    try {
      final result = await _authService.login(username, password);

      if (result['success'] == true) {
        _isLoggedIn = true;
        _user = await _authService.getCurrentUser();
      }

      _isLoading = false;
      notifyListeners(); // แจ้งผลลัพธ์
      return result;
    } catch (e) {
      _isLoading = false;
      notifyListeners(); // แจ้งว่า loading เสร็จแล้วแม้จะ error
      return {'success': false, 'message': 'เกิดข้อผิดพลาด: $e'};
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners(); // แจ้งว่าเริ่ม loading

    try {
      await _authService.logout();
      _user = null;
      _isLoggedIn = false;
    } catch (e) {
      debugPrint('Error logging out: $e');
    } finally {
      _isLoading = false;
      notifyListeners(); // แจ้งว่า logout เสร็จแล้ว
    }
  }
}