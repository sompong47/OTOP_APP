import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

class SellerOrderScreen extends StatefulWidget {
  const SellerOrderScreen({super.key});

  @override
  State<SellerOrderScreen> createState() => _SellerOrderScreenState();
}

class _SellerOrderScreenState extends State<SellerOrderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: darkText,
        title: const Text(
          'คำสั่งซื้อ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: lightPurple,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [primaryPurple, deepPurple],
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
                child: const Icon(Icons.search, color: Colors.white, size: 20),
              ),
              onPressed: () => _showSearchDialog(context),
              tooltip: 'ค้นหาคำสั่งซื้อ',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildOrderStats(),
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: primaryPurple,
              indicatorWeight: 3,
              labelColor: primaryPurple,
              unselectedLabelColor: lightText,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
              tabs: const [
                Tab(text: 'ทั้งหมด'),
                Tab(text: 'ใหม่'),
                Tab(text: 'ยืนยันแล้ว'),
                Tab(text: 'จัดส่งแล้ว'),
                Tab(text: 'เสร็จสิ้น'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOrdersList('all'),
                _buildOrdersList('pending'),
                _buildOrdersList('confirmed'),
                _buildOrdersList('shipped'),
                _buildOrdersList('delivered'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: 'รายได้วันนี้',
              value: '฿3,250',
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
              ),
              icon: Icons.monetization_on_outlined,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              title: 'คำสั่งซื้อใหม่',
              value: '8',
              gradient: const LinearGradient(
                colors: [primaryPurple, deepPurple],
              ),
              icon: Icons.shopping_cart_outlined,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              title: 'รอจัดส่ง',
              value: '5',
              gradient: const LinearGradient(
                colors: [accentBlue, Color(0xFF2563EB)],
              ),
              icon: Icons.local_shipping_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Gradient gradient,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(String status) {
    final orders = <Map<String, dynamic>>[]; // TODO: API จริง

    if (orders.isEmpty) return _buildEmptyState(status);

    return RefreshIndicator(
      onRefresh: () => _refreshOrders(status),
      color: primaryPurple,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) => _buildOrderCard(orders[index]),
      ),
    );
  }

  Widget _buildEmptyState(String status) {
    String message = 'ไม่มีคำสั่งซื้อ';
    IconData icon = Icons.inbox_outlined;
    Gradient gradient = const LinearGradient(
      colors: [primaryPurple, deepPurple],
    );

    switch (status) {
      case 'pending':
        message = 'ไม่มีคำสั่งซื้อใหม่';
        icon = Icons.notifications_outlined;
        gradient = const LinearGradient(
          colors: [primaryPurple, deepPurple],
        );
        break;
      case 'confirmed':
        message = 'ไม่มีคำสั่งซื้อที่ยืนยันแล้ว';
        icon = Icons.check_circle_outline;
        gradient = const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
        );
        break;
      case 'shipped':
        message = 'ไม่มีคำสั่งซื้อที่จัดส่งแล้ว';
        icon = Icons.local_shipping_outlined;
        gradient = const LinearGradient(
          colors: [accentBlue, Color(0xFF2563EB)],
        );
        break;
      case 'delivered':
        message = 'ไม่มีคำสั่งซื้อที่เสร็จสิ้น';
        icon = Icons.done_all;
        gradient = const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
        );
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: gradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryPurple.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, size: 64, color: Colors.white),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'คำสั่งซื้อจะปรากฏที่นี่เมื่อมีลูกค้าสั่งซื้อ',
            style: TextStyle(
              fontSize: 14,
              color: lightText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status'] as String;
    final statusColor = Helpers.getOrderStatusColor(status);
    final statusText = Helpers.getOrderStatusText(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            statusColor.withOpacity(0.2),
                            statusColor.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.receipt_long,
                        color: statusColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'คำสั่งซื้อ #${order['id']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: darkText,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: statusColor.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Customer Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: lightPurple.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: primaryPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.person_outline,
                          size: 16,
                          color: primaryPurple,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          order['customer_name'],
                          style: const TextStyle(
                            fontSize: 14,
                            color: darkText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: accentBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.access_time,
                          size: 16,
                          color: accentBlue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        Helpers.formatDateTime(order['created_at']),
                        style: TextStyle(
                          fontSize: 13,
                          color: lightText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Items
            if (order['items'] != null && order['items'].isNotEmpty) ...[
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: lightBlue.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      size: 16,
                      color: accentBlue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'สินค้า (${order['items'].length} รายการ)',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: darkText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    ...order['items'].take(2).map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: primaryPurple.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'x${item['quantity']}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: primaryPurple,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  item['product_name'],
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: darkText,
                                  ),
                                ),
                              ),
                              Text(
                                Helpers.formatPrice(item['total_price']),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: darkText,
                                ),
                              ),
                            ],
                          ),
                        )),
                    if (order['items'].length > 2)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: lightPurple.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'และอีก ${order['items'].length - 2} รายการ',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 12,
                            color: lightText,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            Divider(color: Colors.grey.withOpacity(0.2), thickness: 1),

            const SizedBox(height: 16),

            // Total & Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ยอดรวมทั้งหมด',
                      style: TextStyle(
                        fontSize: 13,
                        color: lightText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Helpers.formatPrice(order['total_amount']),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryPurple,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _viewOrderDetail(order),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryPurple,
                        side: BorderSide(color: primaryPurple.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      icon: const Icon(Icons.visibility_outlined, size: 18),
                      label: const Text('ดู'),
                    ),
                    if (_canUpdateStatus(status)) ...[
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => _showUpdateStatusDialog(order),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.update, size: 18),
                        label: const Text('อัพเดท'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _canUpdateStatus(String status) =>
      status == 'pending' || status == 'confirmed';

  Future<void> _refreshOrders(String status) async {
    await Future.delayed(const Duration(seconds: 2));
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [primaryPurple, deepPurple],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.search, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('ค้นหาคำสั่งซื้อ'),
          ],
        ),
        content: TextField(
          decoration: InputDecoration(
            hintText: 'หมายเลขคำสั่งซื้อหรือชื่อลูกค้า',
            prefixIcon: const Icon(Icons.search, color: primaryPurple),
            filled: true,
            fillColor: lightPurple.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryPurple, width: 2),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ยกเลิก', style: TextStyle(color: lightText)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Helpers.showSnackBar(context, 'กำลังพัฒนาฟีเจอร์ค้นหา...');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text('ค้นหา'),
          ),
        ],
      ),
    );
  }

  void _viewOrderDetail(Map<String, dynamic> order) {
    Helpers.showSnackBar(context, 'ดูรายละเอียดคำสั่งซื้อ #${order['id']}');
  }

  void _showUpdateStatusDialog(Map<String, dynamic> order) {
    final currentStatus = order['status'] as String;
    String newStatus = _getNextStatus(currentStatus);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [primaryPurple, deepPurple],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.update, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text('อัพเดทสถานะ #${order['id']}'),
          ],
        ),
        content: DropdownButtonFormField<String>(
          value: newStatus,
          decoration: InputDecoration(
            labelText: 'สถานะใหม่',
            filled: true,
            fillColor: lightPurple.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryPurple, width: 2),
            ),
          ),
          items: _getAvailableStatuses(currentStatus).map((s) {
            return DropdownMenuItem(
                value: s, child: Text(Helpers.getOrderStatusText(s)));
          }).toList(),
          onChanged: (value) => newStatus = value!,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ยกเลิก', style: TextStyle(color: lightText)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _updateOrderStatus(order, newStatus);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text('อัพเดท'),
          ),
        ],
      ),
    );
  }

  String _getNextStatus(String currentStatus) {
    switch (currentStatus) {
      case 'pending':
        return 'confirmed';
      case 'confirmed':
        return 'shipped';
      case 'shipped':
        return 'delivered';
      default:
        return currentStatus;
    }
  }

  List<String> _getAvailableStatuses(String currentStatus) {
    switch (currentStatus) {
      case 'pending':
        return ['confirmed', 'cancelled'];
      case 'confirmed':
        return ['shipped', 'cancelled'];
      case 'shipped':
        return ['delivered'];
      default:
        return [];
    }
  }

  void _updateOrderStatus(Map<String, dynamic> order, String newStatus) {
    setState(() => order['status'] = newStatus);
    Helpers.showSuccessSnackBar(
      context,
      'อัพเดทคำสั่งซื้อ #${order['id']} เป็น ${Helpers.getOrderStatusText(newStatus)} แล้ว',
    );
  }
}
