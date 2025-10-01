import 'package:flutter/foundation.dart';
import 'dart:async'; // เพิ่มบรรทัดนี้
import '../models/product.dart';
import '../services/product_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();

  List<Product> _products = [];
  List<Product> _categories = [];
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
  List<Product> get categories => _categories;
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
      _safeNotifyListeners(); // แก้ไขจาก notifyListeners()

      // Load dashboard statistics from API
      final result = await _productService.getSellerDashboard();
      
      if (result['success'] == true) {
        final data = result['data'];
        
        // Update dashboard statistics
        _todaySales = (data['today_sales'] ?? 0.0).toDouble();
        _salesGrowth = (data['sales_growth'] ?? 0.0).toDouble();
        _newOrders = data['new_orders'] ?? 0;
        _pendingOrders = data['pending_orders'] ?? 0;
        _totalProducts = data['total_products'] ?? 0;
        _lowStockProducts = data['low_stock_products'] ?? 0;
        _averageRating = (data['average_rating'] ?? 0.0).toDouble();
        _totalReviews = data['total_reviews'] ?? 0;
        
        // Parse recent activities
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
        
        // Set default values if API fails
        _setDefaultDashboardData();
      }
    } catch (e) {
      _error = 'เกิดข้อผิดพลาด: $e';
      debugPrint('Error loading dashboard data: $e');
      
      // Set default values if error occurs
      _setDefaultDashboardData();
    } finally {
      _isLoading = false;
      _safeNotifyListeners(); // แก้ไขจาก notifyListeners()
    }
  }

  // Set default dashboard data (fallback)
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

  // Load products
  Future<void> loadProducts({String? search, String? ordering, bool refresh = false}) async {
    try {
      if (refresh) {
        _currentPage = 1;
        _hasNextPage = true;
        _products.clear();
      }

      _isLoading = true;
      _error = null;
      _safeNotifyListeners(); // แก้ไขจาก notifyListeners()

      final params = <String, String>{
        'page': _currentPage.toString(),
      };
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (ordering != null) params['ordering'] = ordering;

      final result = await _productService.getProducts(params);
      
      if (result['success'] == true) {
        final data = result['data'];
        
        List<Product> newProducts = [];
        
        if (data is Map<String, dynamic>) {
          // Paginated response format
          if (data.containsKey('results')) {
            debugPrint('Paginated response format');
            debugPrint('Raw API response: ${data['results']}');
            
            newProducts = (data['results'] as List)
                .map((json) {
                  try {
                    debugPrint('Processing product JSON: $json');
                    return Product.fromJson(json);
                  } catch (e) {
                    debugPrint('Error parsing product JSON: $json');
                    debugPrint('Parse error: $e');
                    rethrow;
                  }
                })
                .toList();
            
            // Handle pagination info
            _hasNextPage = data['next'] != null;
            if (_hasNextPage && newProducts.isNotEmpty) {
              _currentPage++;
            }
          } else {
            // Single product format
            debugPrint('Single product format');
            newProducts = [Product.fromJson(data)];
            _hasNextPage = false;
          }
        } else if (data is List) {
          // Direct array response
          debugPrint('Direct array response format');
          debugPrint('Raw API response: $data');
          
          newProducts = data
              .map((json) {
                try {
                  debugPrint('Processing product JSON: $json');
                  return Product.fromJson(json);
                } catch (e) {
                  debugPrint('Error parsing product JSON: $json');
                  debugPrint('Parse error: $e');
                  rethrow;
                }
              })
              .toList();
          
          // Check if we have more products
          if (newProducts.isEmpty) {
            _hasNextPage = false;
          } else {
            // If we got fewer products than expected page size = last page
            if (newProducts.length < 20) { // Assuming page size = 20
              _hasNextPage = false;
            } else {
              _currentPage++;
            }
          }
        } else {
          throw Exception('Unexpected response format: ${data.runtimeType}');
        }

        // Prevent duplicate data
        if (refresh) {
          _products = newProducts;
        } else {
          // Check for duplicate products
          final existingIds = _products.map((p) => p.id).toSet();
          final uniqueNewProducts = newProducts.where((p) => !existingIds.contains(p.id)).toList();
          
          if (uniqueNewProducts.isNotEmpty) {
            _products.addAll(uniqueNewProducts);
            debugPrint('Added ${uniqueNewProducts.length} new unique products');
          } else {
            debugPrint('No new unique products found - reached end');
            _hasNextPage = false;
          }
        }

        debugPrint('Loaded ${newProducts.length} products (total: ${_products.length})');
        debugPrint('Has next page: $_hasNextPage, Current page: $_currentPage');
        
      } else {
        _error = result['message'] ?? 'ไม่สามารถโหลดข้อมูลสินค้าได้';
      }
    } catch (e) {
      _error = 'เกิดข้อผิดพลาด: $e';
      debugPrint('Error loading products: $e');
    } finally {
      _isLoading = false;
      _safeNotifyListeners(); // แก้ไขจาก notifyListeners()
    }
  }

  // Load more products (pagination)
  Future<void> loadMoreProducts() async {
    if (_isLoadingMore || !_hasNextPage) {
      debugPrint('Skip loading more: isLoadingMore=$_isLoadingMore, hasNextPage=$_hasNextPage');
      return;
    }

    try {
      _isLoadingMore = true;
      _safeNotifyListeners(); // แก้ไขจาก notifyListeners()

      await loadProducts(refresh: false);
    } finally {
      _isLoadingMore = false;
      _safeNotifyListeners(); // แก้ไขจาก notifyListeners()
    }
  }

  // Load product detail
  Future<void> loadProductDetail(int productId) async {
    _isLoading = true;
    _error = null;
    _safeNotifyListeners(); // แก้ไขจาก notifyListeners()

    try {
      final result = await _productService.getProduct(productId);
      if (result['success'] == true) {
        final data = result['data'];
        
        if (data is Map<String, dynamic>) {
          _selectedProduct = Product.fromJson(data);
        } else {
          throw Exception('Invalid product data format');
        }
      } else {
        _error = result['message'] ?? 'ไม่สามารถโหลดรายละเอียดสินค้าได้';
      }
    } catch (e) {
      _error = 'เกิดข้อผิดพลาด: $e';
      debugPrint('Error loading product detail: $e');
    } finally {
      _isLoading = false;
      _safeNotifyListeners(); // แก้ไขจาก notifyListeners()
    }
  }

  // Load categories
  Future<void> loadCategories() async {
    try {
      _isLoading = true;
      _error = null;
      _safeNotifyListeners(); // แก้ไขจาก notifyListeners()

      final result = await _productService.getCategories();
      if (result['success'] == true) {
        final data = result['data'];
        
        List<dynamic> categoryData;
        if (data is Map<String, dynamic> && data.containsKey('results')) {
          categoryData = data['results'] as List;
        } else if (data is List) {
          categoryData = data;
        } else {
          throw Exception('Invalid category data format');
        }

        _categories = [];
        debugPrint('Categories loaded: ${categoryData.length}');
      } else {
        _error = result['message'] ?? 'ไม่สามารถโหลดหมวดหมู่ได้';
      }
    } catch (e) {
      _error = 'เกิดข้อผิดพลาด: $e';
      debugPrint('Error loading categories: $e');
    } finally {
      _isLoading = false;
      _safeNotifyListeners(); // แก้ไขจาก notifyListeners()
    }
  }

  // Clear selected product
  void clearSelectedProduct() {
    _selectedProduct = null;
    _safeNotifyListeners(); // แก้ไขจาก notifyListeners()
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
    
    // Clear dashboard data
    _todaySales = 0.0;
    _salesGrowth = 0.0;
    _newOrders = 0;
    _pendingOrders = 0;
    _totalProducts = 0;
    _lowStockProducts = 0;
    _averageRating = 0.0;
    _totalReviews = 0;
    _recentActivities = [];
    
    _safeNotifyListeners(); // แก้ไขจาก notifyListeners()
  }

  // Filter products by category
  List<Product> getProductsByCategory(String categoryName) {
    return _products.where((product) => 
        product.category?.toLowerCase() == categoryName.toLowerCase()).toList();
  }
}