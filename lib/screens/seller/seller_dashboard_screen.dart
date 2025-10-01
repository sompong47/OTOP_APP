import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart'; // เพิ่มบรรทัดนี้
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
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    await productProvider.loadSellerDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แดชบอร์ดผู้ขาย'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return PopupMenuButton<String>(
                icon: CircleAvatar(
                  radius: 16,
                  backgroundColor: AppConstants.primaryColor,
                  child: Text(
                    authProvider.user?.username.substring(0, 1).toUpperCase() ?? 'S',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onSelected: (value) {
                  switch (value) {
                    case 'profile':
                      // TODO: Navigate to seller profile
                      break;
                    case 'settings':
                      // TODO: Navigate to seller settings
                      break;
                    case 'logout':
                      _handleLogout(authProvider);
                      break;
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem<String>(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person),
                        SizedBox(width: 8),
                        Text('โปรไฟล์ร้านค้า'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings),
                        SizedBox(width: 8),
                        Text('ตั้งค่าร้าน'),
                      ],
                    ),
                  ),
                  PopupMenuDivider(),
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: AppConstants.errorColor),
                        SizedBox(width: 8),
                        Text('ออกจากระบบ', style: TextStyle(color: AppConstants.errorColor)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              _buildWelcomeSection(),
              
              const SizedBox(height: AppConstants.paddingLarge),
              
              // Statistics Cards
              _buildStatisticsCards(),
              
              const SizedBox(height: AppConstants.paddingLarge),
              
              // Quick Actions
              _buildQuickActions(),
              
              const SizedBox(height: AppConstants.paddingLarge),
              
              // Recent Activities
              _buildRecentActivities(),
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
              Text(
                'สวัสดี ${authProvider.user?.username ?? 'ผู้ขาย'}!',
                style: const TextStyle(
                  fontSize: AppConstants.fontSizeHeading,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              const Text(
                'ยินดีต้อนรับสู่ระบบจัดการร้านค้า OTOP',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeMedium,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              Row(
                children: [
                  const Icon(
                    Icons.verified_user,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'ร้านค้าได้รับการยืนยันแล้ว',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: AppConstants.fontSizeSmall,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatisticsCards() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'สถิติการขาย',
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
              childAspectRatio: 1.3,
              children: [
                _buildStatCard(
                  title: 'ยอดขายวันนี้',
                  value: '฿${productProvider.todaySales.toStringAsFixed(0)}',
                  icon: Icons.trending_up,
                  color: AppConstants.successColor,
                  subtitle: '${productProvider.salesGrowth >= 0 ? '+' : ''}${productProvider.salesGrowth.toStringAsFixed(1)}% จากเมื่อวาน',
                ),
                _buildStatCard(
                  title: 'คำสั่งซื้อใหม่',
                  value: '${productProvider.newOrders}',
                  icon: Icons.shopping_bag,
                  color: AppConstants.primaryColor,
                  subtitle: '${productProvider.pendingOrders} รอดำเนินการ',
                ),
                _buildStatCard(
                  title: 'สินค้าทั้งหมด',
                  value: '${productProvider.totalProducts}',
                  icon: Icons.inventory,
                  color: AppConstants.warningColor,
                  subtitle: '${productProvider.lowStockProducts} เหลือน้อย',
                ),
                _buildStatCard(
                  title: 'คะแนนร้าน',
                  value: '${productProvider.averageRating.toStringAsFixed(1)}',
                  icon: Icons.star,
                  color: Colors.orange,
                  subtitle: 'จาก ${productProvider.totalReviews} รีวิว',
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeHeading,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: AppConstants.fontSizeMedium,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppConstants.secondaryColor,
                  fontSize: AppConstants.fontSizeSmall,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'การจัดการ',
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
          childAspectRatio: 1.6,
          children: [
            _buildActionCard(
              title: 'จัดการสินค้า',
              subtitle: 'เพิ่ม แก้ไข ลบสินค้า',
              icon: Icons.inventory_2,
              color: AppConstants.primaryColor,
              onTap: () => _navigateToProducts(),
            ),
            _buildActionCard(
              title: 'คำสั่งซื้อ',
              subtitle: 'ดูและจัดการออร์เดอร์',
              icon: Icons.receipt_long,
              color: AppConstants.successColor,
              onTap: () => _navigateToOrders(),
            ),
            _buildActionCard(
              title: 'รีวิวและคะแนน',
              subtitle: 'ความคิดเห็นลูกค้า',
              icon: Icons.star_rate,
              color: Colors.orange,
              onTap: () => _navigateToReviews(),
            ),
            _buildActionCard(
              title: 'รายงานการขาย',
              subtitle: 'วิเคราะห์ยอดขาย',
              icon: Icons.analytics,
              color: AppConstants.warningColor,
              onTap: () => _navigateToReports(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center, // Center the content vertically
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              Flexible( // Use Flexible instead of Expanded
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppConstants.fontSizeMedium,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 2), // Reduce spacing
              Flexible( // Use Flexible instead of Expanded
                child: Text(
                  subtitle,
                  style: TextStyle(
                    color: AppConstants.secondaryColor,
                    fontSize: AppConstants.fontSizeSmall,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivities() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, _) {
        final activities = productProvider.recentActivities;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'กิจกรรมล่าสุด',
              style: TextStyle(
                fontSize: AppConstants.fontSizeExtraLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            
            if (activities.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: AppConstants.paddingSmall),
                        Text(
                          'ยังไม่มีกิจกรรม',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: AppConstants.fontSizeMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  child: Column(
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
                            color: _getActivityColor(activity['type']),
                          ),
                          if (index < activities.length - 1) const Divider(),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'order':
        return Icons.shopping_cart;
      case 'stock':
        return Icons.inventory;
      case 'review':
        return Icons.star;
      case 'product':
        return Icons.add_box;
      default:
        return Icons.notifications;
    }
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'order':
        return AppConstants.primaryColor;
      case 'stock':
        return AppConstants.warningColor;
      case 'review':
        return Colors.orange;
      case 'product':
        return AppConstants.successColor;
      default:
        return Colors.grey;
    }
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppConstants.fontSizeMedium,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppConstants.secondaryColor,
                    fontSize: AppConstants.fontSizeSmall,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: AppConstants.secondaryColor,
              fontSize: AppConstants.fontSizeSmall,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshData() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    await productProvider.loadSellerDashboardData();
  }

  Future<void> _handleLogout(AuthProvider authProvider) async {
    await authProvider.logout();
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  void _navigateToProducts() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SellerProductScreen()),
    );
  }

  void _navigateToOrders() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SellerOrderScreen()),
    );
  }

  void _navigateToReviews() {
    Helpers.showSnackBar(context, 'กำลังพัฒนาฟีเจอร์รีวิว...');
  }

  void _navigateToReports() {
    Helpers.showSnackBar(context, 'กำลังพัฒนาฟีเจอร์รายงาน...');
  }
}