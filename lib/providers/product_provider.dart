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

  // Getters
  List<Product> get products => _products;
  List<Product> get categories => _categories;
  Product? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load products
  Future<void> loadProducts({String? search, String? ordering}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final params = <String, String>{};
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (ordering != null) params['ordering'] = ordering;

      final result = await _productService.getProducts(params);
      if (result['success'] == true) {
        _products = (result['data'] as List)
            .map((json) => Product.fromJson(json))
            .toList();
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

  // Load product detail
  Future<void> loadProductDetail(int productId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _productService.getProduct(productId);
      if (result['success'] == true) {
        _selectedProduct = Product.fromJson(result['data']);
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

  // Clear selected product
  void clearSelectedProduct() {
    _selectedProduct = null;
    notifyListeners();
  }

  // Search products
  Future<void> searchProducts(String query) async {
    await loadProducts(search: query);
  }

  // Sort products
  Future<void> sortProducts(String ordering) async {
    await loadProducts(ordering: ordering);
  }
}