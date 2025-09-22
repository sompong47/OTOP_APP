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
    // Load featured products when home screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OTOP Store'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Navigate to search
              Helpers.showSnackBar(context, 'กำลังพัฒนาฟีเจอร์ค้นหา...');
            },
            icon: const Icon(Icons.search),
            tooltip: 'ค้นหา',
          ),
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return PopupMenuButton(
                icon: CircleAvatar(
                  radius: 16,
                  backgroundColor: AppConstants.primaryColor,
                  child: Text(
                    authProvider.user?.username.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.person),
                        SizedBox(width: 8),
                        Text('โปรไฟล์'),
                      ],
                    ),
                    onTap: () {
                      // Navigate to profile tab
                      if (context.findAncestorStateOfType<_HomeScreenState>() != null) {
                        context.findAncestorStateOfType<_HomeScreenState>()!.setState(() {
                          context.findAncestorStateOfType<_HomeScreenState>()!._currentIndex = 4;
                        });
                      }
                    },
                  ),
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.logout, color: AppConstants.errorColor),
                        SizedBox(width: 8),
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
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppConstants.primaryColor,
                    AppConstants.primaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      return Text(
                        'สวัสดี ${authProvider.user?.username ?? 'ผู้ใช้'}!',
                        style: const TextStyle(
                          fontSize: AppConstants.fontSizeHeading,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  const Text(
                    'ยินดีต้อนรับสู่ร้านค้า OTOP ออนไลน์',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeMedium,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to products tab
                      if (context.findAncestorStateOfType<_HomeScreenState>() != null) {
                        context.findAncestorStateOfType<_HomeScreenState>()!.setState(() {
                          context.findAncestorStateOfType<_HomeScreenState>()!._currentIndex = 1;
                        });
                      }
                    },
                    icon: const Icon(Icons.store, color: AppConstants.primaryColor),
                    label: const Text(
                      'เริ่มช้อปปิ้ง',
                      style: TextStyle(color: AppConstants.primaryColor),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.paddingLarge),

            // Quick Actions
            const Text(
              'เมนูหลัก',
              style: TextStyle(
                fontSize: AppConstants.fontSizeExtraLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AppConstants.paddingMedium,
              mainAxisSpacing: AppConstants.paddingMedium,
              children: [
                _buildQuickActionCard(
                  context,
                  icon: Icons.store,
                  title: 'สินค้าทั้งหมด',
                  subtitle: 'ดูสินค้า OTOP',
                  color: AppConstants.primaryColor,
                  onTap: () => _navigateToTab(1),
                ),
                _buildQuickActionCard(
                  context,
                  icon: Icons.shopping_cart,
                  title: 'ตะกร้าสินค้า',
                  subtitle: 'ดูของในตะกร้า',
                  color: AppConstants.successColor,
                  onTap: () => _navigateToTab(2),
                ),
                _buildQuickActionCard(
                  context,
                  icon: Icons.receipt_long,
                  title: 'คำสั่งซื้อ',
                  subtitle: 'ประวัติการสั่งซื้อ',
                  color: AppConstants.warningColor,
                  onTap: () => _navigateToTab(3),
                ),
                _buildQuickActionCard(
                  context,
                  icon: Icons.person,
                  title: 'โปรไฟล์',
                  subtitle: 'จัดการบัญชี',
                  color: AppConstants.secondaryColor,
                  onTap: () => _navigateToTab(4),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.paddingLarge),

            // Featured Products Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'สินค้าแนะนำ',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeExtraLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => _navigateToTab(1),
                  child: const Text('ดูทั้งหมด'),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingMedium),

            // Featured Products List
            Consumer<ProductProvider>(
              builder: (context, productProvider, _) {
                if (productProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (productProvider.error != null) {
                  return Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: AppConstants.errorColor,
                        ),
                        const SizedBox(height: AppConstants.paddingSmall),
                        Text(
                          'เกิดข้อผิดพลาด: ${productProvider.error}',
                          textAlign: TextAlign.center,
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

                final products = productProvider.products.take(4).toList();
                if (products.isEmpty) {
                  return const Center(
                    child: Text('ไม่มีสินค้า'),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppConstants.paddingSmall,
                    mainAxisSpacing: AppConstants.paddingSmall,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _buildProductCard(product);
                  },
                );
              },
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

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppConstants.fontSizeMedium,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppConstants.secondaryColor,
                  fontSize: AppConstants.fontSizeSmall,
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
    return InkWell(
      onTap: () {
        // TODO: Navigate to product detail
        Helpers.showSnackBar(context, 'เปิดรายละเอียดสินค้า: ${product.name}');
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                child: ProductImage(
                  imageUrl: product.image,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppConstants.borderRadius),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingSmall),
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
                            fontSize: AppConstants.fontSizeSmall,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (product.category != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            product.category!,
                            style: TextStyle(
                              color: AppConstants.secondaryColor,
                              fontSize: AppConstants.fontSizeSmall - 1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product.formattedPrice,
                          style: TextStyle(
                            color: AppConstants.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: AppConstants.fontSizeMedium,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: product.inStock 
                                ? AppConstants.successColor.withOpacity(0.1)
                                : AppConstants.errorColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            product.inStock ? 'มีสินค้า' : 'หมด',
                            style: TextStyle(
                              color: product.inStock 
                                  ? AppConstants.successColor
                                  : AppConstants.errorColor,
                              fontSize: AppConstants.fontSizeSmall - 2,
                              fontWeight: FontWeight.w500,
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