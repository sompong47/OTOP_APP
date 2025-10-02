import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../auth/login_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  int _selectedImageIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false)
          .loadProductDetail(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, _) {
          if (productProvider.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (productProvider.error != null) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('สินค้า'),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppConstants.errorColor,
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    Text(
                      'เกิดข้อผิดพลาด',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    Text(
                      productProvider.error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppConstants.secondaryColor),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    ElevatedButton(
                      onPressed: () => productProvider.loadProductDetail(widget.productId),
                      child: const Text('ลองใหม่'),
                    ),
                  ],
                ),
              ),
            );
          }

          final product = productProvider.selectedProduct;
          if (product == null) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('สินค้า'),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              body: const Center(
                child: Text('ไม่พบสินค้า'),
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              // App Bar with Image
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: AppConstants.primaryColor,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildProductImages(product),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.white),
                    onPressed: () => _shareProduct(product),
                    tooltip: 'แชร์สินค้า',
                  ),
                  Consumer<CartProvider>(
                    builder: (context, cartProvider, _) {
                      final isInCart = cartProvider.isInCart(product.id);
                      return IconButton(
                        icon: Icon(
                          isInCart ? Icons.favorite : Icons.favorite_border,
                          color: isInCart ? Colors.red : Colors.white,
                        ),
                        onPressed: () => _toggleFavorite(product),
                        tooltip: 'เพิ่มลงรายการโปรด',
                      );
                    },
                  ),
                ],
              ),

              // Product Details
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Title and Price
                      _buildProductHeader(product),
                      
                      const SizedBox(height: AppConstants.paddingMedium),
                      
                      // Stock and Category
                      _buildProductInfo(product),
                      
                      const SizedBox(height: AppConstants.paddingMedium),
                      
                      // Description
                      _buildDescription(product),
                      
                      const SizedBox(height: AppConstants.paddingMedium),
                      
                      // Quantity Selector
                      _buildQuantitySelector(product),
                      
                      const SizedBox(height: AppConstants.paddingLarge),
                      
                      // Reviews Section (Placeholder)
                      _buildReviewsSection(),
                      
                      const SizedBox(height: 100), // Space for bottom buttons
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Consumer<ProductProvider>(
        builder: (context, productProvider, _) {
          final product = productProvider.selectedProduct;
          if (product == null) return const SizedBox.shrink();
          
          return _buildBottomActions(product);
        },
      ),
    );
  }

  Widget _buildProductImages(dynamic product) {
    // For now, show placeholder since we don't have multiple images
    return Container(
      width: double.infinity,
      color: Colors.grey[200],
      child: product.image != null
          ? Image.network(
              product.image!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.image,
                  size: 100,
                  color: Colors.grey,
                );
              },
            )
          : const Icon(
              Icons.image,
              size: 100,
              color: Colors.grey,
            ),
    );
  }

  Widget _buildProductHeader(dynamic product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name,
          style: const TextStyle(
            fontSize: AppConstants.fontSizeHeading,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        Text(
          Helpers.formatPrice(product.price),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppConstants.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildProductInfo(dynamic product) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              color: AppConstants.backgroundColor,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.inventory,
                      size: 16,
                      color: AppConstants.secondaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'คงเหลือ: ${product.stock} ชิ้น',
                      style: TextStyle(
                        color: product.stock > 0 
                            ? AppConstants.successColor 
                            : AppConstants.errorColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                Row(
                  children: [
                    const Icon(
                      Icons.category,
                      size: 16,
                      color: AppConstants.secondaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'หมวดหมู่: ${product.categoryId}', // Would need category name
                      style: TextStyle(
                        color: AppConstants.secondaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                Row(
                  children: [
                    const Icon(
                      Icons.store,
                      size: 16,
                      color: AppConstants.secondaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'ผู้ขาย: ${product.sellerId}', // Would need seller name
                      style: TextStyle(
                        color: AppConstants.secondaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(dynamic product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'รายละเอียดสินค้า',
          style: TextStyle(
            fontSize: AppConstants.fontSizeExtraLarge,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          child: Text(
            product.description,
            style: const TextStyle(
              fontSize: AppConstants.fontSizeMedium,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantitySelector(dynamic product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'จำนวน',
          style: TextStyle(
            fontSize: AppConstants.fontSizeExtraLarge,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: _quantity > 1 
                        ? () => setState(() => _quantity--)
                        : null,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingMedium,
                    ),
                    child: Text(
                      '$_quantity',
                      style: const TextStyle(
                        fontSize: AppConstants.fontSizeLarge,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _quantity < product.stock 
                        ? () => setState(() => _quantity++)
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            Text(
              'มีสินค้าเหลือ ${product.stock} ชิ้น',
              style: TextStyle(
                color: AppConstants.secondaryColor,
                fontSize: AppConstants.fontSizeSmall,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'รีวิวจากลูกค้า',
          style: TextStyle(
            fontSize: AppConstants.fontSizeExtraLarge,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          decoration: BoxDecoration(
            color: AppConstants.backgroundColor,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.rate_review_outlined,
                size: 48,
                color: AppConstants.secondaryColor,
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              Text(
                'ยังไม่มีรีวิว',
                style: TextStyle(
                  color: AppConstants.secondaryColor,
                  fontSize: AppConstants.fontSizeMedium,
                ),
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              TextButton(
                onPressed: () {
                  Helpers.showSnackBar(context, 'กำลังพัฒนาฟีเจอร์รีวิว...');
                },
                child: const Text('เป็นคนแรกที่รีวิวสินค้านี้'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(dynamic product) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Add to Cart Button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: product.stock > 0 
                    ? () => _addToCart(product)
                    : null,
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('เพิ่มลงตะกร้า'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppConstants.primaryColor,
                  side: const BorderSide(color: AppConstants.primaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: AppConstants.paddingMedium),
            
            // Buy Now Button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: product.stock > 0 
                    ? () => _buyNow(product)
                    : null,
                icon: const Icon(Icons.flash_on),
                label: const Text('ซื้อทันที'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addToCart(dynamic product) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.addItem(product, quantity: _quantity);
    
    Helpers.showSuccessSnackBar(
      context, 
      'เพิ่ม ${product.name} จำนวน $_quantity ชิ้น ลงตะกร้าแล้ว',
    );
    
    // Reset quantity to 1
    setState(() => _quantity = 1);
  }

  void _buyNow(dynamic product) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (!authProvider.isLoggedIn) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('จำเป็นต้องเข้าสู่ระบบ'),
          content: const Text('กรุณาเข้าสู่ระบบก่อนสั่งซื้อสินค้า'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text('เข้าสู่ระบบ'),
            ),
          ],
        ),
      );
      return;
    }

    // Add to cart and go to checkout
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.clearCart(); // Clear existing items
    cartProvider.addItem(product, quantity: _quantity);
    
    // Navigate to checkout screen
    // This would need to be implemented
    Helpers.showSnackBar(context, 'กำลังพัฒนาหน้าชำระเงิน...');
  }

  void _shareProduct(dynamic product) {
    // Implement share functionality
    Helpers.showSnackBar(context, 'กำลังพัฒนาฟีเจอร์แชร์...');
  }

  void _toggleFavorite(dynamic product) {
    // Implement favorite functionality
    Helpers.showSnackBar(context, 'กำลังพัฒนาฟีเจอร์รายการโปรด...');
  }
}