import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import 'order_detail_screen.dart';
import '../auth/login_screen.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen>
    with AutomaticKeepAliveClientMixin {
  String _selectedFilter = 'all';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isLoggedIn) {
        Provider.of<OrderProvider>(context, listen: false).loadMyOrders();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (!authProvider.isLoggedIn) {
          return _buildLoginRequired();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'คำสั่งซื้อของฉัน',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF6A11CB),
                    Color(0xFF8E44AD),
                    Color(0xFF3498DB),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            elevation: 0,
            actions: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_list, color: Colors.white),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  offset: const Offset(0, 50),
                  onSelected: (value) {
                    setState(() {
                      _selectedFilter = value;
                    });
                  },
                  itemBuilder: (context) => [
                    _buildFilterMenuItem('all', 'ทั้งหมด', Icons.list_alt),
                    _buildFilterMenuItem(
                        'pending', 'รอดำเนินการ', Icons.hourglass_empty),
                    _buildFilterMenuItem(
                        'confirmed', 'ยืนยันแล้ว', Icons.check_circle_outline),
                    _buildFilterMenuItem(
                        'shipped', 'จัดส่งแล้ว', Icons.local_shipping_outlined),
                    _buildFilterMenuItem(
                        'delivered', 'ส่งถึงแล้ว', Icons.done_all),
                    _buildFilterMenuItem(
                        'cancelled', 'ยกเลิก', Icons.cancel_outlined),
                  ],
                ),
              ),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6A11CB).withOpacity(0.05),
                  const Color(0xFF3498DB).withOpacity(0.05),
                  Colors.white,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.3, 0.6],
              ),
            ),
            child: Consumer<OrderProvider>(
              builder: (context, orderProvider, _) {
                if (orderProvider.isLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6A11CB), Color(0xFF3498DB)],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 3,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'กำลังโหลดคำสั่งซื้อ...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF6A11CB),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (orderProvider.error != null) {
                  return _buildError(orderProvider.error!, () {
                    orderProvider.loadMyOrders();
                  });
                }

                final filteredOrders = _filterOrders(orderProvider.orders);

                if (filteredOrders.isEmpty) {
                  return _buildEmptyOrders();
                }

                return RefreshIndicator(
                  color: const Color(0xFF6A11CB),
                  onRefresh: () => orderProvider.loadMyOrders(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      return _buildOrderCard(order);
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  PopupMenuItem<String> _buildFilterMenuItem(
      String value, String label, IconData icon) {
    final isSelected = _selectedFilter == value;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isSelected ? const Color(0xFF6A11CB) : Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF6A11CB) : Colors.grey[800],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (isSelected) ...[
            const Spacer(),
            const Icon(
              Icons.check,
              size: 18,
              color: Color(0xFF6A11CB),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoginRequired() {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'คำสั่งซื้อของฉัน',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A11CB), Color(0xFF8E44AD), Color(0xFF3498DB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF6A11CB).withOpacity(0.05),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6A11CB).withOpacity(0.1),
                        const Color(0xFF3498DB).withOpacity(0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'กรุณาเข้าสู่ระบบ',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: const Color(0xFF6A11CB),
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'เข้าสู่ระบบเพื่อดูประวัติคำสั่งซื้อของคุณ',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6A11CB), Color(0xFF3498DB)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6A11CB).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                      );
                    },
                    icon: const Icon(Icons.login),
                    label: const Text('เข้าสู่ระบบ'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError(String error, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.red.withOpacity(0.1),
                    Colors.orange.withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'เกิดข้อผิดพลาด',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6A11CB), Color(0xFF3498DB)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('ลองใหม่'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyOrders() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6A11CB).withOpacity(0.1),
                    const Color(0xFF3498DB).withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 100,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _selectedFilter == 'all'
                  ? 'ยังไม่มีคำสั่งซื้อ'
                  : 'ไม่พบคำสั่งซื้อ',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF6A11CB),
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              _selectedFilter == 'all'
                  ? 'เริ่มช้อปปิ้งเพื่อสั่งซื้อสินค้าแรกของคุณ'
                  : 'ลองเปลี่ยนตัวกรองเพื่อดูคำสั่งซื้ออื่น',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
              textAlign: TextAlign.center,
            ),
            if (_selectedFilter == 'all') ...[
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6A11CB), Color(0xFF3498DB)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6A11CB).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    DefaultTabController.of(context)?.animateTo(1);
                  },
                  icon: const Icon(Icons.store_rounded),
                  label: const Text('เริ่มช้อปปิ้ง'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(dynamic order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            const Color(0xFF6A11CB).withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6A11CB).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToOrderDetail(order),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF6A11CB).withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6A11CB), Color(0xFF3498DB)],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.receipt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '#${order.id}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF6A11CB),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Helpers.getOrderStatusColor(order.status)
                                .withOpacity(0.15),
                            Helpers.getOrderStatusColor(order.status)
                                .withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Helpers.getOrderStatusColor(order.status),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        Helpers.getOrderStatusText(order.status),
                        style: TextStyle(
                          color: Helpers.getOrderStatusColor(order.status),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6A11CB).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      // Order Date
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'วันที่สั่ง: ${Helpers.formatDateTime(order.createdAt)}',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Payment Method
                      Row(
                        children: [
                          Icon(
                            Icons.payment,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'วิธีชำระเงิน: ${Helpers.getPaymentMethodText(order.paymentMethod)}',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Order Items Preview
                if (order.items != null && order.items.isNotEmpty) ...[
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6A11CB), Color(0xFF3498DB)],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'รายการสินค้า (${order.items.length} รายการ)',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF6A11CB),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...order.items
                      .take(2)
                      .map((item) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.grey[200]!,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Color(0xFF6A11CB),
                                              Color(0xFF3498DB)
                                            ],
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '${item.productName} x${item.quantity}',
                                          style: TextStyle(
                                            color: Colors.grey[800],
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  Helpers.formatPrice(item.totalPrice),
                                  style: const TextStyle(
                                    color: Color(0xFF6A11CB),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                  if (order.items.length > 2)
                    Padding(
                      padding: const EdgeInsets.only(left: 14),
                      child: Text(
                        '+ อีก ${order.items.length - 2} รายการ',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                ],

                // Divider
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        const Color(0xFF6A11CB).withOpacity(0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Total and Action Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ยอดรวมทั้งหมด',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF6A11CB).withOpacity(0.1),
                                const Color(0xFF3498DB).withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            Helpers.formatPrice(order.totalAmount),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: Color(0xFF6A11CB),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6A11CB), Color(0xFF3498DB)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6A11CB).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () => _navigateToOrderDetail(order),
                        icon: const Icon(Icons.arrow_forward, size: 18),
                        label: const Text('ดูรายละเอียด'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<dynamic> _filterOrders(List<dynamic> orders) {
    if (_selectedFilter == 'all') {
      return orders;
    }
    return orders.where((order) => order.status == _selectedFilter).toList();
  }

  void _navigateToOrderDetail(dynamic order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailScreen(orderId: order.id),
      ),
    );
  }
}
