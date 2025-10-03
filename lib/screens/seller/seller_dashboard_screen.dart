import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import 'seller_product_screen.dart';
import 'seller_order_screen.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  // Modern Color Scheme
  static const Color primaryPurple = Color(0xFF6366F1);
  static const Color deepPurple = Color(0xFF4F46E5);
  static const Color lightPurple = Color(0xFFE0E7FF);
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color lightBlue = Color(0xFFDEEBFF);
  static const Color darkText = Color(0xFF1F2937);
  static const Color lightText = Color(0xFF6B7280);
  static const Color bgColor = Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    await productProvider.loadSellerDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          'แดชบอร์ดผู้ขาย',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: darkText,
        elevation: 0,
        centerTitle: true,
        actions: [
          Consumer<AuthProvider>(builder: (context, authProvider, _) {
            return Container(
              margin: const EdgeInsets.only(right: 12),
              child: PopupMenuButton<String>(
                offset: const Offset(0, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [primaryPurple, deepPurple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: primaryPurple.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                onSelected: (value) {
                  switch (value) {
                    case 'profile':
                      break;
                    case 'settings':
                      break;
                    case 'logout':
                      _handleLogout(authProvider);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'profile',
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: lightPurple,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.person,
                              color: primaryPurple, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text('โปรไฟล์ร้านค้า'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'settings',
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: lightBlue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.settings,
                              color: accentBlue, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text('ตั้งค่าร้าน'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.logout,
                              color: Colors.red, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text('ออกจากระบบ',
                            style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: primaryPurple,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(),
              const SizedBox(height: 24),
              _buildStatisticsCards(),
              const SizedBox(height: 24),
              _buildSectionHeader('การจัดการ', Icons.dashboard_customize),
              const SizedBox(height: 12),
              _buildQuickActions(),
              const SizedBox(height: 24),
              _buildRecentActivities(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [primaryPurple, deepPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: primaryPurple.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.store,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'สวัสดีคุณ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          authProvider.user?.username ?? 'ผู้ขาย',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_user,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'ร้านค้าได้รับการยืนยันแล้ว',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primaryPurple.withOpacity(0.2),
                accentBlue.withOpacity(0.2)
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: primaryPurple, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsCards() {
    return Consumer<ProductProvider>(builder: (context, productProvider, _) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('สถิติการขาย', Icons.bar_chart),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.15,
            children: [
              _buildStatCard(
                title: 'ยอดขายวันนี้',
                value: '฿${productProvider.todaySales.toStringAsFixed(0)}',
                icon: Icons.trending_up,
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                ),
                subtitle:
                    '${productProvider.salesGrowth >= 0 ? '+' : ''}${productProvider.salesGrowth.toStringAsFixed(1)}%',
                isPositive: productProvider.salesGrowth >= 0,
              ),
              _buildStatCard(
                title: 'คำสั่งซื้อใหม่',
                value: '${productProvider.newOrders}',
                icon: Icons.shopping_bag_outlined,
                gradient: const LinearGradient(
                  colors: [primaryPurple, deepPurple],
                ),
                subtitle: '${productProvider.pendingOrders} รอดำเนินการ',
              ),
              _buildStatCard(
                title: 'สินค้าทั้งหมด',
                value: '${productProvider.totalProducts}',
                icon: Icons.inventory_2_outlined,
                gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                ),
                subtitle: '${productProvider.lowStockProducts} เหลือน้อย',
              ),
              _buildStatCard(
                title: 'คะแนนร้าน',
                value: '${productProvider.averageRating.toStringAsFixed(1)}',
                icon: Icons.star_outline,
                gradient: const LinearGradient(
                  colors: [accentBlue, Color(0xFF2563EB)],
                ),
                subtitle: 'จาก ${productProvider.totalReviews} รีวิว',
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Gradient gradient,
    String? subtitle,
    bool isPositive = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Opacity(
                opacity: 0.1,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: gradient,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: gradient,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: primaryPurple.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(icon, color: Colors.white, size: 22),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      color: lightText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: darkText,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (subtitle.contains('%')) ...[
                          Icon(
                            isPositive
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            size: 14,
                            color: isPositive ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Flexible(
                          child: Text(
                            subtitle,
                            style: TextStyle(
                              color: subtitle.contains('%')
                                  ? (isPositive ? Colors.green : Colors.red)
                                  : lightText,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return LayoutBuilder(builder: (context, constraints) {
      final maxWidth = constraints.maxWidth;
      int crossAxisCount;
      if (maxWidth >= 1000) {
        crossAxisCount = 4;
      } else if (maxWidth >= 720) {
        crossAxisCount = 3;
      } else if (maxWidth < 360) {
        crossAxisCount = 1;
      } else {
        crossAxisCount = 2;
      }

      const double spacing = 12;
      final double totalSpacing = spacing * (crossAxisCount - 1);
      final double itemWidth = (maxWidth - totalSpacing) / crossAxisCount;
      const double desiredCardHeight = 160;
      final double childAspectRatio = itemWidth / desiredCardHeight;

      return GridView.count(
        crossAxisCount: crossAxisCount,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
        children: [
          _buildActionCard(
            title: 'จัดการสินค้า',
            subtitle: 'เพิ่ม แก้ไข ลบสินค้า',
            icon: Icons.inventory_2_outlined,
            gradient: const LinearGradient(
              colors: [primaryPurple, deepPurple],
            ),
            onTap: _navigateToProducts,
          ),
          _buildActionCard(
            title: 'คำสั่งซื้อ',
            subtitle: 'ดูและจัดการออร์เดอร์',
            icon: Icons.receipt_long_outlined,
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)],
            ),
            onTap: _navigateToOrders,
          ),
          _buildActionCard(
            title: 'รีวิวและคะแนน',
            subtitle: 'ความคิดเห็นลูกค้า',
            icon: Icons.star_outline,
            gradient: const LinearGradient(
              colors: [accentBlue, Color(0xFF2563EB)],
            ),
            onTap: _navigateToReviews,
          ),
          _buildActionCard(
            title: 'รายงานการขาย',
            subtitle: 'วิเคราะห์ยอดขาย',
            icon: Icons.analytics_outlined,
            gradient: const LinearGradient(
              colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
            ),
            onTap: _navigateToReports,
          ),
        ],
      );
    });
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned(
                right: -30,
                bottom: -30,
                child: Opacity(
                  opacity: 0.08,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: gradient,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: gradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: primaryPurple.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(icon, color: Colors.white, size: 26),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Flexible(
                      child: Text(
                        subtitle,
                        style: const TextStyle(
                          color: lightText,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
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

  Widget _buildRecentActivities() {
    return Consumer<ProductProvider>(builder: (context, productProvider, _) {
      final activities = productProvider.recentActivities;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('กิจกรรมล่าสุด', Icons.history),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: activities.isEmpty
                  ? Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: lightPurple.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.inbox_outlined,
                              size: 48,
                              color: lightText.withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'ยังไม่มีกิจกรรม',
                            style: TextStyle(
                              color: lightText,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: activities.asMap().entries.map((entry) {
                        final index = entry.key;
                        final activity = entry.value;
                        return Column(
                          children: [
                            _buildActivityItem(
                              icon: _getActivityIcon(activity['type']),
                              title: activity['title'],
                              subtitle: activity['subtitle'],
                              time: activity['time'],
                              gradient: _getActivityGradient(activity['type']),
                            ),
                            if (index < activities.length - 1)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Divider(
                                  color: Colors.grey.withOpacity(0.2),
                                  thickness: 1,
                                ),
                              ),
                          ],
                        );
                      }).toList(),
                    ),
            ),
          ),
        ],
      );
    });
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'order':
        return Icons.shopping_cart_outlined;
      case 'stock':
        return Icons.inventory_2_outlined;
      case 'review':
        return Icons.star_outline;
      case 'product':
        return Icons.add_box_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Gradient _getActivityGradient(String type) {
    switch (type) {
      case 'order':
        return const LinearGradient(
          colors: [primaryPurple, deepPurple],
        );
      case 'stock':
        return const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
        );
      case 'review':
        return const LinearGradient(
          colors: [accentBlue, Color(0xFF2563EB)],
        );
      case 'product':
        return const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
        );
      default:
        return const LinearGradient(
          colors: [Colors.grey, Colors.grey],
        );
    }
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Gradient gradient,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: primaryPurple.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: darkText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: lightText,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: lightPurple.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              time,
              style: const TextStyle(
                color: primaryPurple,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshData() async {
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    await productProvider.loadSellerDashboardData();
  }

  Future<void> _handleLogout(AuthProvider authProvider) async {
    await authProvider.logout();
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  void _navigateToProducts() {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => const SellerProductScreen()));
  }

  void _navigateToOrders() {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const SellerOrderScreen()));
  }

  void _navigateToReviews() {
    Helpers.showSnackBar(context, 'กำลังพัฒนาฟีเจอร์รีวิว...');
  }

  void _navigateToReports() {
    Helpers.showSnackBar(context, 'กำลังพัฒนาฟีเจอร์รายงาน...');
  }
}
