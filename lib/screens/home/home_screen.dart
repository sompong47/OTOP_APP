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
      bottomNavigationBar: Container(
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
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home_rounded, 'หน้าแรก', 0),
                _buildNavItem(Icons.store_rounded, 'สินค้า', 1),
                _buildNavItem(Icons.shopping_cart_rounded, 'ตะกร้า', 2),
                _buildNavItem(Icons.receipt_long_rounded, 'คำสั่งซื้อ', 3),
                _buildNavItem(Icons.person_rounded, 'โปรไฟล์', 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _currentIndex = index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.white : Colors.white70,
                    size: isSelected ? 28 : 24,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade50,
              Colors.white,
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildWelcomeBanner(),
                  const SizedBox(height: 24),
                  _buildQuickMenu(),
                  const SizedBox(height: 32),
                  _buildFeaturedSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple.shade400,
              Colors.blue.shade400,
            ],
          ),
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.storefront_rounded, size: 24),
          ),
          const SizedBox(width: 12),
          const Text(
            'OTOP Store',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () => Helpers.showSnackBar(context, 'กำลังพัฒนาฟีเจอร์ค้นหา...'),
            icon: const Icon(Icons.search_rounded),
            tooltip: 'ค้นหาสินค้า',
          ),
        ),
        Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.blue.shade50],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: Text(
                  authProvider.user?.username.substring(0, 1).toUpperCase() ?? 'U',
                  style: TextStyle(
                    color: Colors.deepPurple.shade600,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepPurple.shade400,
            Colors.blue.shade400,
            Colors.purple.shade400,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) => Row(
                    children: [
                      Expanded(
                        child: Text(
                          "สวัสดี ${authProvider.user?.username ?? 'ผู้ใช้'} 👋",
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "ค้นพบสินค้า OTOP คุณภาพ\nจากทุกภูมิภาคของไทย",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    height: 1.5,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.blue.shade50],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _navigateToTab(1),
                      borderRadius: BorderRadius.circular(30),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "เริ่มช้อปปิ้งเลย",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.deepPurple.shade600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.deepPurple.shade600,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMenu() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickMenuItem(
              icon: Icons.category_rounded,
              label: 'หมวดหมู่',
              gradient: LinearGradient(
                colors: [Colors.purple.shade400, Colors.purple.shade600],
              ),
              onTap: () => _navigateToTab(1),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickMenuItem(
              icon: Icons.shopping_cart_rounded,
              label: 'ตะกร้า',
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.blue.shade600],
              ),
              onTap: () => _navigateToTab(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickMenuItem(
              icon: Icons.receipt_long_rounded,
              label: 'คำสั่งซื้อ',
              gradient: LinearGradient(
                colors: [Colors.indigo.shade400, Colors.indigo.shade600],
              ),
              onTap: () => _navigateToTab(3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMenuItem({
    required IconData icon,
    required String label,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 28, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.deepPurple.shade400,
                            Colors.blue.shade400,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.star_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'สินค้าแนะนำ',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.deepPurple.shade50,
                        Colors.blue.shade50,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _navigateToTab(1),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'ดูทั้งหมด',
                              style: TextStyle(
                                color: Colors.deepPurple.shade600,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: Colors.deepPurple.shade600,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Consumer<ProductProvider>(
            builder: (context, productProvider, _) {
              if (productProvider.isLoading) {
                return SizedBox(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple.shade400),
                    ),
                  ),
                );
              }

              if (productProvider.error != null) {
                return Container(
                  height: 200,
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline_rounded, size: 48, color: Colors.red.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'ไม่สามารถโหลดสินค้าได้',
                          style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w500),
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
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'ไม่มีสินค้า',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) => _buildProductCard(products[index]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
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
          borderRadius: BorderRadius.circular(20),
          onTap: () => Helpers.showSnackBar(context, "ดูรายละเอียด: ${product.name}"),
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
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        child: ProductImage(
                          imageUrl: product.image,
                          width: double.infinity,
                          fit: BoxFit.cover,
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
                          color: Colors.deepPurple.shade400,
                          size: 18,
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.grey.shade800,
                          height: 1.3,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.deepPurple.shade50,
                              Colors.blue.shade50,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.formattedPrice,
                          style: TextStyle(
                            color: Colors.deepPurple.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
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

  void _navigateToTab(int index) {
    final homeState = context.findAncestorStateOfType<_HomeScreenState>();
    if (homeState != null) {
      homeState.setState(() => homeState._currentIndex = index);
    }
  }
}