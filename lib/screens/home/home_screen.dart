import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../models/product.dart';
import '../products/product_list_screen.dart';
import '../cart/cart_screen.dart';
import '../orders/order_list_screen.dart';
import '../auth/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const HomeTab(),
    const ProductListScreen(),
    const CartScreen(),
    const OrderListScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppConstants.primaryColor,
        unselectedItemColor: AppConstants.secondaryColor,
        selectedFontSize: AppConstants.fontSizeSmall,
        unselectedFontSize: AppConstants.fontSizeSmall,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'หน้าแรก',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'สินค้า',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'ตะกร้า',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'คำสั่งซื้อ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'โปรไฟล์',
          ),
        ],
      ),
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'OTOP Store',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: AppConstants.fontSizeExtraLarge,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppConstants.primaryColor,
        elevation: 1,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Helpers.showSnackBar(context, 'กำลังพัฒนาฟีเจอร์ค้นหา...');
            },
            icon: const Icon(Icons.search),
            tooltip: 'ค้นหาสินค้า',
          ),
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return PopupMenuButton(
                icon: Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: AppConstants.primaryColor,
                    child: Text(
                      authProvider.user?.username.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: AppConstants.fontSizeMedium,
                      ),
                    ),
                  ),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.person, color: AppConstants.primaryColor),
                        SizedBox(width: 12),
                        Text('โปรไฟล์'),
                      ],
                    ),
                    onTap: () => _navigateToTab(4),
                  ),
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.logout, color: AppConstants.errorColor),
                        SizedBox(width: 12),
                        Text('ออกจากระบบ', style: TextStyle(color: AppConstants.errorColor)),
                      ],
                    ),
                    onTap: () async {
                      final confirmed = await Helpers.showConfirmationDialog(
                        context,
                        title: 'ออกจากระบบ',
                        message: 'คุณต้องการออกจากระบบหรือไม่?',
                      );
                      if (confirmed == true && mounted) {
                        await authProvider.logout();
                        Navigator.of(context).pushReplacementNamed('/login');
                      }
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Banner Section
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(AppConstants.paddingMedium),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppConstants.primaryColor,
                    AppConstants.primaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppConstants.primaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, _) {
                              return Text(
                                'สวัสดี ${authProvider.user?.username ?? 'ผู้ใช้'}',
                                style: const TextStyle(
                                  fontSize: AppConstants.fontSizeExtraLarge,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'สินค้า OTOP คุณภาพ\nจากทั่วประเทศไทย',
                            style: TextStyle(
                              fontSize: AppConstants.fontSizeMedium,
                              color: Colors.white,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => _navigateToTab(1),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppConstants.primaryColor,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: const Text(
                              'เริ่มช้อปปิ้ง',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: AppConstants.fontSizeMedium,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.store_outlined,
                      size: 80,
                      color: Colors.white24,
                    ),
                  ],
                ),
              ),
            ),

            // Quick Access Menu
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
              child: Row(
                children: [
                  Expanded(
                    child: _buildQuickMenuItem(
                      context,
                      icon: Icons.category_outlined,
                      label: 'หมวดหมู่',
                      onTap: () => _navigateToTab(1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickMenuItem(
                      context,
                      icon: Icons.shopping_cart_outlined,
                      label: 'ตะกร้าสินค้า',
                      onTap: () => _navigateToTab(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickMenuItem(
                      context,
                      icon: Icons.receipt_long_outlined,
                      label: 'คำสั่งซื้อ',
                      onTap: () => _navigateToTab(3),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Featured Products Section
            Container(
              width: double.infinity,
              color: Colors.white,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'สินค้าแนะนำ',
                          style: TextStyle(
                            fontSize: AppConstants.fontSizeExtraLarge,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _navigateToTab(1),
                          icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                          label: const Text('ดูทั้งหมด'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppConstants.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Products Grid
                  Consumer<ProductProvider>(
                    builder: (context, productProvider, _) {
                      if (productProvider.isLoading) {
                        return Container(
                          height: 200,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (productProvider.error != null) {
                        return Container(
                          height: 200,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: AppConstants.errorColor,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'ไม่สามารถโหลดสินค้าได้',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: AppConstants.fontSizeMedium,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => productProvider.loadProducts(),
                                  child: const Text('ลองใหม่'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final products = productProvider.products.take(6).toList();
                      if (products.isEmpty) {
                        return Container(
                          height: 200,
                          child: Center(
                            child: Text(
                              'ไม่มีสินค้า',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: AppConstants.fontSizeMedium,
                              ),
                            ),
                          ),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            return _buildProductCard(product);
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToTab(int index) {
    final homeState = context.findAncestorStateOfType<_HomeScreenState>();
    if (homeState != null) {
      homeState.setState(() {
        homeState._currentIndex = index;
      });
    }
  }

  Widget _buildQuickMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 28,
                color: AppConstants.primaryColor,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: AppConstants.fontSizeSmall,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 3,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: () {
          Helpers.showSnackBar(context, 'เปิดรายละเอียดสินค้า: ${product.name}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: ProductImage(
                    imageUrl: product.image,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            
            // Product Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: AppConstants.fontSizeMedium,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (product.category != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            product.category!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: AppConstants.fontSizeSmall,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            product.formattedPrice,
                            style: TextStyle(
                              color: AppConstants.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: AppConstants.fontSizeMedium,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: product.inStock 
                                ? AppConstants.successColor.withOpacity(0.1)
                                : AppConstants.errorColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            product.inStock ? 'พร้อม' : 'หมด',
                            style: TextStyle(
                              color: product.inStock 
                                  ? AppConstants.successColor
                                  : AppConstants.errorColor,
                              fontSize: AppConstants.fontSizeSmall,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
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
}