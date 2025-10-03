import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedSort = 'name';
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    if (query.isEmpty) {
      productProvider.loadProducts();
    } else {
      productProvider.searchProducts(query);
    }
  }

  void _onSort(String sortBy) {
    setState(() {
      _selectedSort = sortBy;
    });
    Provider.of<ProductProvider>(context, listen: false).sortProducts(sortBy);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.shade50,
              Colors.blue.shade50,
              Colors.purple.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              _buildSearchBar(),
              Expanded(child: _buildProductList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple.shade400,
            Colors.blue.shade400,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.shopping_bag_rounded,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'สินค้าทั้งหมด',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _isGridView = !_isGridView;
                });
              },
              tooltip: _isGridView ? 'มุมมองรายการ' : 'มุมมองกริด',
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.sort_rounded, color: Colors.white),
              onSelected: _onSort,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              itemBuilder: (context) => [
                _buildPopupMenuItem('name', 'เรียงตามชื่อ', Icons.text_fields_rounded),
                _buildPopupMenuItem('price', 'ราคาน้อยไปมาก', Icons.arrow_upward_rounded),
                _buildPopupMenuItem('-price', 'ราคามากไปน้อย', Icons.arrow_downward_rounded),
                _buildPopupMenuItem('-created_at', 'สินค้าใหม่', Icons.fiber_new_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(String value, String text, IconData icon) {
    final isSelected = _selectedSort == value;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isSelected ? Colors.deepPurple : Colors.grey.shade600,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.deepPurple : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (isSelected) ...[
            const Spacer(),
            Icon(Icons.check_rounded, size: 20, color: Colors.deepPurple),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'ค้นหาสินค้าที่คุณต้องการ...',
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: Icon(Icons.search_rounded, color: Colors.deepPurple.shade300, size: 26),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear_rounded, color: Colors.grey.shade400),
                  onPressed: () {
                    _searchController.clear();
                    _onSearch('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        onChanged: _onSearch,
      ),
    );
  }

  Widget _buildProductList() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, _) {
        if (productProvider.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple.shade400),
                  strokeWidth: 3,
                ),
                const SizedBox(height: 16),
                Text(
                  'กำลังโหลดสินค้า...',
                  style: TextStyle(
                    color: Colors.deepPurple.shade300,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        if (productProvider.error != null) {
          return Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline_rounded,
                      size: 64,
                      color: Colors.red.shade400,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'เกิดข้อผิดพลาด',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    productProvider.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => productProvider.loadProducts(),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('ลองใหม่'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple.shade400,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (productProvider.products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.inventory_2_outlined,
                    size: 80,
                    color: Colors.deepPurple.shade200,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'ไม่พบสินค้า',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'ลองค้นหาด้วยคำค้นอื่น',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return _isGridView
            ? _buildGridView(productProvider.products)
            : _buildListView(productProvider.products);
      },
    );
  }

  Widget _buildGridView(List<dynamic> products) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildListView(List<dynamic> products) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductListItem(product);
      },
    );
  }

  Widget _buildProductCard(dynamic product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToProductDetail(product),
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.deepPurple.shade50,
                            Colors.blue.shade50,
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      child: product.image != null
                          ? ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                              child: Image.network(
                                product.image!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Icon(
                                      Icons.image_rounded,
                                      size: 50,
                                      color: Colors.deepPurple.shade200,
                                    ),
                                  );
                                },
                              ),
                            )
                          : Center(
                              child: Icon(
                                Icons.image_rounded,
                                size: 50,
                                color: Colors.deepPurple.shade200,
                              ),
                            ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.favorite_border_rounded,
                          color: Colors.deepPurple.shade300,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.grey.shade800,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              Helpers.formatPrice(product.price),
                              style: TextStyle(
                                color: Colors.deepPurple.shade600,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          _buildAddToCartButton(product),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductListItem(dynamic product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToProductDetail(product),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.deepPurple.shade50,
                        Colors.blue.shade50,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: product.image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            product.image!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.image_rounded,
                                color: Colors.deepPurple.shade200,
                                size: 40,
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.image_rounded,
                          color: Colors.deepPurple.shade200,
                          size: 40,
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Colors.grey.shade800,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.deepPurple.shade50,
                                  Colors.blue.shade50,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              Helpers.formatPrice(product.price),
                              style: TextStyle(
                                color: Colors.deepPurple.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          _buildAddToCartButton(product),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddToCartButton(dynamic product) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, _) {
        final isInCart = cartProvider.isInCart(product.id);
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isInCart
                  ? [Colors.green.shade400, Colors.green.shade600]
                  : [Colors.deepPurple.shade400, Colors.blue.shade500],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: (isInCart ? Colors.green : Colors.deepPurple).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                cartProvider.addItem(product);
                Helpers.showSuccessSnackBar(context, 'เพิ่มสินค้าลงตะกร้าแล้ว');
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(
                  isInCart ? Icons.check_rounded : Icons.add_shopping_cart_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToProductDetail(dynamic product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(productId: product.id),
      ),
    );
  }
}