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
      appBar: AppBar(
        title: const Text('สินค้าทั้งหมด'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            tooltip: _isGridView ? 'มุมมองรายการ' : 'มุมมองกริด',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: _onSort,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'name',
                child: Text('เรียงตามชื่อ'),
              ),
              const PopupMenuItem(
                value: 'price',
                child: Text('เรียงตามราคา'),
              ),
              const PopupMenuItem(
                value: '-price',
                child: Text('ราคามากไปน้อย'),
              ),
              const PopupMenuItem(
                value: '-created_at',
                child: Text('สินค้าใหม่'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            margin: const EdgeInsets.all(AppConstants.paddingMedium),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ค้นหาสินค้า...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
              ),
              onChanged: _onSearch,
            ),
          ),

          // Product List
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, productProvider, _) {
                if (productProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (productProvider.error != null) {
                  return Center(
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
                          onPressed: () => productProvider.loadProducts(),
                          child: const Text('ลองใหม่'),
                        ),
                      ],
                    ),
                  );
                }

                if (productProvider.products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: AppConstants.secondaryColor,
                        ),
                        const SizedBox(height: AppConstants.paddingMedium),
                        Text(
                          'ไม่พบสินค้า',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppConstants.paddingSmall),
                        Text(
                          'ลองค้นหาด้วยคำค้นอื่น',
                          style: TextStyle(color: AppConstants.secondaryColor),
                        ),
                      ],
                    ),
                  );
                }

                return _isGridView
                    ? _buildGridView(productProvider.products)
                    : _buildListView(productProvider.products);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(List<dynamic> products) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppConstants.paddingMedium,
        mainAxisSpacing: AppConstants.paddingMedium,
        childAspectRatio: 0.75,
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
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductListItem(product);
      },
    );
  }

  Widget _buildProductCard(dynamic product) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: InkWell(
        onTap: () => _navigateToProductDetail(product),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppConstants.borderRadius),
                  ),
                ),
                child: product.image != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppConstants.borderRadius),
                        ),
                        child: Image.network(
                          product.image!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.image,
                              size: 40,
                              color: Colors.grey,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.image,
                        size: 40,
                        color: Colors.grey,
                      ),
              ),
            ),

            // Product Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingSmall),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: AppConstants.fontSizeMedium,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          Helpers.formatPrice(product.price),
                          style: TextStyle(
                            color: AppConstants.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: AppConstants.fontSizeMedium,
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
    );
  }

  Widget _buildProductListItem(dynamic product) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: InkWell(
        onTap: () => _navigateToProductDetail(product),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Row(
            children: [
              // Product Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
                child: product.image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                        child: Image.network(
                          product.image!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.image, color: Colors.grey);
                          },
                        ),
                      )
                    : const Icon(Icons.image, color: Colors.grey),
              ),

              const SizedBox(width: AppConstants.paddingMedium),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: AppConstants.fontSizeMedium,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    Text(
                      product.description,
                      style: TextStyle(
                        color: AppConstants.secondaryColor,
                        fontSize: AppConstants.fontSizeSmall,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          Helpers.formatPrice(product.price),
                          style: TextStyle(
                            color: AppConstants.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: AppConstants.fontSizeLarge,
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
    );
  }

  Widget _buildAddToCartButton(dynamic product) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, _) {
        return IconButton(
          icon: Icon(
            cartProvider.isInCart(product.id) ? Icons.shopping_cart : Icons.add_shopping_cart,
            color: AppConstants.primaryColor,
          ),
          onPressed: () {
            cartProvider.addItem(product);
            Helpers.showSuccessSnackBar(context, 'เพิ่มสินค้าลงตะกร้าแล้ว');
          },
          tooltip: 'เพิ่มลงตะกร้า',
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