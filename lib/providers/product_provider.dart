import 'package:flutter/foundation.dart';
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

  // Getters
  List<Product> get products => _products;
  List<Product> get categories => _categories;
  Product? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  bool get hasNextPage => _hasNextPage;

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
      notifyListeners();

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
          // ✅ แก้ปัญหาตรงนี้ - Direct array response
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
          
          // ✅ สำคัญ: ตรวจสอบว่ามี product ใหม่หรือไม่
          if (newProducts.isEmpty) {
            _hasNextPage = false;
          } else {
            // ถ้าได้ products น้อยกว่า expected page size (เช่น 20) = หน้าสุดท้าย
            // หรือตั้งให้ load หน้าต่อไปและดูว่าได้ข้อมูลหรือไม่
            if (newProducts.length < 20) { // สมมติ page size = 20
              _hasNextPage = false;
            } else {
              _currentPage++;
            }
          }
        } else {
          throw Exception('Unexpected response format: ${data.runtimeType}');
        }

        // ✅ ป้องกันการเพิ่มข้อมูลซ้ำ
        if (refresh) {
          _products = newProducts;
        } else {
          // เช็คว่า product ใหม่ซ้ำกับของเดิมหรือไม่
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
      notifyListeners();
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
      notifyListeners();

      await loadProducts(refresh: false);
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Load product detail
  Future<void> loadProductDetail(int productId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

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
      notifyListeners();
    }
  }

  // Load categories
  Future<void> loadCategories() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

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
      notifyListeners();
    }
  }

  // Clear selected product
  void clearSelectedProduct() {
    _selectedProduct = null;
    notifyListeners();
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
    notifyListeners();
  }

  // Filter products by category
  List<Product> getProductsByCategory(String categoryName) {
    return _products.where((product) => 
        product.category?.toLowerCase() == categoryName.toLowerCase()).toList();
  }
}