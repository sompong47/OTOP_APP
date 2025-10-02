import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/product.dart';
import '../services/product_service.dart';
import '../models/category.dart' as models; // เพิ่ม prefix เพื่อแก้ conflict

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();

  List<Product> _products = [];
  List<models.Category> _categories = []; // ใช้ models.Category
  Product? _selectedProduct;
  bool _isLoading = false;
  String? _error;

  // Pagination
  int _currentPage = 1;
  bool _hasNextPage = true;
  bool _isLoadingMore = false;

  // Dashboard Statistics
  double _todaySales = 0.0;
  double _salesGrowth = 0.0;
  int _newOrders = 0;
  int _pendingOrders = 0;
  int _totalProducts = 0;
  int _lowStockProducts = 0;
  double _averageRating = 0.0;
  int _totalReviews = 0;
  List<Map<String, dynamic>> _recentActivities = [];

  // เพิ่ม method สำหรับ safe notify
  void _safeNotifyListeners() {
    scheduleMicrotask(() {
      notifyListeners();
    });
  }

  // Getters
  List<Product> get products => _products;
  List<models.Category> get categories => _categories; // ใช้ models.Category
  Product? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  bool get hasNextPage => _hasNextPage;

  // Dashboard Getters
  double get todaySales => _todaySales;
  double get salesGrowth => _salesGrowth;
  int get newOrders => _newOrders;
  int get pendingOrders => _pendingOrders;
  int get totalProducts => _totalProducts;
  int get lowStockProducts => _lowStockProducts;
  double get averageRating => _averageRating;
  int get totalReviews => _totalReviews;
  List<Map<String, dynamic>> get recentActivities => _recentActivities;

  // Load seller dashboard data
  Future<void> loadSellerDashboardData() async {
    try {
      _isLoading = true;
      _error = null;
      _safeNotifyListeners();

      final result = await _productService.getSellerDashboard();
      
      if (result['success'] == true) {
        final data = result['data'];
        
        _todaySales = (data['today_sales'] ?? 0.0).toDouble();
        _salesGrowth = (data['sales_growth'] ?? 0.0).toDouble();
        _newOrders = data['new_orders'] ?? 0;
        _pendingOrders = data['pending_orders'] ?? 0;
        _totalProducts = data['total_products'] ?? 0;
        _lowStockProducts = data['low_stock_products'] ?? 0;
        _averageRating = (data['average_rating'] ?? 0.0).toDouble();
        _totalReviews = data['total_reviews'] ?? 0;
        
        if (data['recent_activities'] != null) {
          _recentActivities = List<Map<String, dynamic>>.from(
            data['recent_activities'].map((activity) => Map<String, dynamic>.from(activity))
          );
        } else {
          _recentActivities = [];
        }
        
        debugPrint('Dashboard data loaded successfully');
        debugPrint('Today sales: $_todaySales, Total products: $_totalProducts');
        
      } else {
        _error = result['message'] ?? 'ไม่สามารถโหลดข้อมูล Dashboard ได้';
        _setDefaultDashboardData();
      }
    } catch (e) {
      _error = 'เกิดข้อผิดพลาด: $e';
      debugPrint('Error loading dashboard data: $e');
      _setDefaultDashboardData();
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  void _setDefaultDashboardData() {
    _todaySales = 0.0;
    _salesGrowth = 0.0;
    _newOrders = 0;
    _pendingOrders = 0;
    _totalProducts = _products.length;
    _lowStockProducts = _products.where((p) => (p.stock ?? 0) < 10).length;
    _averageRating = 0.0;
    _totalReviews = 0;
    _recentActivities = [];
  }

  // Load all products (public)
  Future<void> loadProducts({String? search, String? ordering, bool refresh = false}) async {
    try {
      if (refresh) {
        _currentPage = 1;
        _hasNextPage = true;
        _products.clear();
      }

      _isLoading = true;
      _error = null;
      _safeNotifyListeners();

      final params = <String, String>{ 'page': _currentPage.toString() };
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (ordering != null) params['ordering'] = ordering;

      final result = await _productService.getProducts(params);
      
      if (result['success'] == true) {
        final data = result['data'];
        List<Product> newProducts = [];

        if (data is Map<String, dynamic> && data.containsKey('results')) {
          newProducts = (data['results'] as List).map((json) => Product.fromJson(json)).toList();
          _hasNextPage = data['next'] != null;
          if (_hasNextPage) _currentPage++;
        } else if (data is List) {
          newProducts = data.map((json) => Product.fromJson(json)).toList();
          _hasNextPage = newProducts.length >= 20;
          if (_hasNextPage) _currentPage++;
        }

        if (refresh) {
          _products = newProducts;
        } else {
          final existingIds = _products.map((p) => p.id).toSet();
          final uniqueNewProducts = newProducts.where((p) => !existingIds.contains(p.id)).toList();
          if (uniqueNewProducts.isNotEmpty) _products.addAll(uniqueNewProducts);
          else _hasNextPage = false;
        }

      } else {
        _error = result['message'] ?? 'ไม่สามารถโหลดข้อมูลสินค้าได้';
      }
    } catch (e) {
      _error = 'เกิดข้อผิดพลาด: $e';
      debugPrint('Error loading products: $e');
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // Load products for seller (เฉพาะของผู้ขาย)
  Future<void> loadSellerProducts({bool refresh = false}) async {
    try {
      if (refresh) {
        _currentPage = 1;
        _hasNextPage = true;
        _products.clear();
      }

      _isLoading = true;
      _error = null;
      _safeNotifyListeners();

      final result = await _productService.getSellerProducts();

      if (result['success'] == true) {
        final data = result['data'];
        List<Product> sellerProducts = [];

        if (data is List) {
          sellerProducts = data.map((json) => Product.fromJson(json)).toList();
        } else if (data is Map<String, dynamic> && data.containsKey('results')) {
          sellerProducts = (data['results'] as List)
              .map((json) => Product.fromJson(json))
              .toList();
        }

        if (refresh) {
          _products = sellerProducts;
        } else {
          final existingIds = _products.map((p) => p.id).toSet();
          final uniqueNewProducts = sellerProducts.where((p) => !existingIds.contains(p.id)).toList();
          if (uniqueNewProducts.isNotEmpty) _products.addAll(uniqueNewProducts);
        }

        _hasNextPage = false; // แสดงทั้งหมด
        debugPrint('Loaded seller products: ${_products.length}');
      } else {
        _error = result['message'] ?? 'ไม่สามารถโหลดสินค้าของคุณได้';
      }
    } catch (e) {
      _error = 'เกิดข้อผิดพลาด: $e';
      debugPrint('Error loading seller products: $e');
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // Load more products (pagination)
  Future<void> loadMoreProducts() async {
    if (_isLoadingMore || !_hasNextPage) return;

    try {
      _isLoadingMore = true;
      _safeNotifyListeners();
      await loadProducts(refresh: false);
    } finally {
      _isLoadingMore = false;
      _safeNotifyListeners();
    }
  }

  // Load product detail
  Future<void> loadProductDetail(int productId) async {
    _isLoading = true;
    _error = null;
    _safeNotifyListeners();

    try {
      final result = await _productService.getProduct(productId);
      if (result['success'] == true) {
        final data = result['data'];
        if (data is Map<String, dynamic>) _selectedProduct = Product.fromJson(data);
        else throw Exception('Invalid product data format');
      } else {
        _error = result['message'] ?? 'ไม่สามารถโหลดรายละเอียดสินค้าได้';
      }
    } catch (e) {
      _error = 'เกิดข้อผิดพลาด: $e';
      debugPrint('Error loading product detail: $e');
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // Load categories
  Future<void> loadCategories() async {
    try {
      _isLoading = true;
      _error = null;
      _safeNotifyListeners();

      final result = await _productService.getCategories();
      if (result['success'] == true) {
        final data = result['data'];
        List<dynamic> categoryData;

        if (data is Map<String, dynamic> && data.containsKey('results')) categoryData = data['results'] as List;
        else if (data is List) categoryData = data;
        else throw Exception('Invalid category data format');

        _categories = categoryData.map((json) => models.Category.fromJson(json)).toList();
        debugPrint('Categories loaded: ${_categories.length}');
      } else _error = result['message'] ?? 'ไม่สามารถโหลดหมวดหมู่ได้';
    } catch (e) {
      _error = 'เกิดข้อผิดพลาด: $e';
      debugPrint('Error loading categories: $e');
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // Clear selected product
  void clearSelectedProduct() {
    _selectedProduct = null;
    _safeNotifyListeners();
  }

  // Search products
  Future<void> searchProducts(String query) async {
    await loadProducts(search: query, refresh: true);
  }

  // Sort products
  Future<void> sortProducts(String ordering) async {
    await loadProducts(ordering: ordering, refresh: true);
  }

  // Refresh products
  Future<void> refreshProducts() async {
    await loadProducts(refresh: true);
  }

  // Clear all data
  void clearAll() {
    _products.clear();
    _categories.clear();
    _selectedProduct = null;
    _isLoading = false;
    _error = null;
    _currentPage = 1;
    _hasNextPage = true;
    _isLoadingMore = false;
    
    _todaySales = 0.0;
    _salesGrowth = 0.0;
    _newOrders = 0;
    _pendingOrders = 0;
    _totalProducts = 0;
    _lowStockProducts = 0;
    _averageRating = 0.0;
    _totalReviews = 0;
    _recentActivities = [];
    
    _safeNotifyListeners();
  }

  // Filter products by category
  List<Product> getProductsByCategory(String categoryName) {
    return _products.where((product) => 
        product.category?.toLowerCase() == categoryName.toLowerCase()).toList();
  }
}
