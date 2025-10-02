// lib/config/app_config.dart
class AppConfig {
  // API Configuration
  static const String baseUrl = "https://otopbacknd-production.up.railway.app/api/"; // Android Emulator
  // static const String baseUrl = 'http://localhost:8000/api'; // iOS Simulator
  
  // App Information
  static const String appName = 'OTOP Store';
  static const String version = '1.0.0';
  
  // API Endpoints
  static const String loginEndpoint = 'token/';
  static const String registerEndpoint = 'register/';
  static const String productsEndpoint = 'products/';
  static const String sellerProductsEndpoint = 'seller/products/'; // สำหรับ seller
  static const String categoriesEndpoint = 'categories/';
  static const String ordersEndpoint = 'orders/';
  static const String createOrderEndpoint = 'orders/create/';
  static const String profileEndpoint = 'profile/';
  static const String sellerDashboardEndpoint = 'seller/dashboard/';
  
  // Storage Keys
  static const String tokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
}