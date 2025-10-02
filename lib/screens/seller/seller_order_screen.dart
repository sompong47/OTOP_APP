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
  String _selectedFilter = 'all';

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
      appBar: AppBar(
        title: const Text('คำสั่งซื้อ'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppConstants.primaryColor,
          labelColor: AppConstants.primaryColor,
          unselectedLabelColor: AppConstants.secondaryColor,
          tabs: const [
            Tab(text: 'ทั้งหมด'),
            Tab(text: 'ใหม่'),
            Tab(text: 'ยืนยันแล้ว'),
            Tab(text: 'จัดส่งแล้ว'),
            Tab(text: 'เสร็จสิ้น'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
            tooltip: 'ค้นหาคำสั่งซื้อ',
          ),
        ],
      ),
      body: Column(
        children: [
          // Order Statistics
          _buildOrderStats(),
          
          // Orders List
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
      margin: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: 'รายได้วันนี้',
              value: '฿3,250',
              color: AppConstants.successColor,
              icon: Icons.monetization_on,
            ),
          ),
          const SizedBox(width: AppConstants.paddingSmall),
          Expanded(
            child: _buildStatCard(
              title: 'คำสั่งซื้อใหม่',
              value: '8',
              color: AppConstants.primaryColor,
              icon: Icons.shopping_cart,
            ),
          ),
          const SizedBox(width: AppConstants.paddingSmall),
          Expanded(
            child: _buildStatCard(
              title: 'รอจัดส่ง',
              value: '5',
              color: AppConstants.warningColor,
              icon: Icons.local_shipping,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingSmall),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: AppConstants.fontSizeMedium,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: AppConstants.fontSizeSmall,
                color: AppConstants.secondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(String status) {
    final orders = _getMockOrders(status);
    
    if (orders.isEmpty) {
      return _buildEmptyState(status);
    }

    return RefreshIndicator(
      onRefresh: () => _refreshOrders(status),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return _buildOrderCard(orders[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState(String status) {
    String message = 'ไม่มีคำสั่งซื้อ';
    IconData icon = Icons.inbox;
    
    switch (status) {
      case 'pending':
        message = 'ไม่มีคำสั่งซื้อใหม่';
        icon = Icons.notifications;
        break;
      case 'confirmed':
        message = 'ไม่มีคำสั่งซื้อที่ยืนยันแล้ว';
        icon = Icons.check_circle;
        break;
      case 'shipped':
        message = 'ไม่มีคำสั่งซื้อที่จัดส่งแล้ว';
        icon = Icons.local_shipping;
        break;
      case 'delivered':
        message = 'ไม่มีคำสั่งซื้อที่เสร็จสิ้น';
        icon = Icons.done_all;
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(
            message,
            style: TextStyle(
              fontSize: AppConstants.fontSizeLarge,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status'] as String;
    final statusColor = Helpers.getOrderStatusColor(status);
    final statusText = Helpers.getOrderStatusText(status);

    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'คำสั่งซื้อ #${order['id']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppConstants.fontSizeMedium,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingSmall,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: AppConstants.fontSizeSmall,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppConstants.paddingSmall),
            
            // Customer Info
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: AppConstants.secondaryColor),
                const SizedBox(width: 4),
                Text(
                  order['customer_name'],
                  style: TextStyle(
                    color: AppConstants.secondaryColor,
                    fontSize: AppConstants.fontSizeSmall,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppConstants.paddingSmall),
            
            // Order Date
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: AppConstants.secondaryColor),
                const SizedBox(width: 4),
                Text(
                  Helpers.formatDateTime(order['created_at']),
                  style: TextStyle(
                    color: AppConstants.secondaryColor,
                    fontSize: AppConstants.fontSizeSmall,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            // Order Items Preview
            if (order['items'] != null && order['items'].isNotEmpty) ...[
              Text(
                'รายการสินค้า (${order['items'].length} รายการ):',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppConstants.fontSizeSmall,
                ),
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              ...order['items'].take(2).map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '• ${item['product_name']} x${item['quantity']}',
                        style: TextStyle(
                          color: AppConstants.secondaryColor,
                          fontSize: AppConstants.fontSizeSmall,
                        ),
                      ),
                    ),
                    Text(
                      Helpers.formatPrice(item['total_price']),
                      style: TextStyle(
                        color: AppConstants.secondaryColor,
                        fontSize: AppConstants.fontSizeSmall,
                      ),
                    ),
                  ],
                ),
              )).toList(),
              if (order['items'].length > 2)
                Text(
                  'และอีก ${order['items'].length - 2} รายการ',
                  style: TextStyle(
                    color: AppConstants.secondaryColor,
                    fontSize: AppConstants.fontSizeSmall,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            // Total and Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ยอดรวม',
                      style: TextStyle(fontSize: AppConstants.fontSizeSmall),
                    ),
                    Text(
                      Helpers.formatPrice(order['total_amount']),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: AppConstants.fontSizeLarge,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () => _viewOrderDetail(order),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppConstants.primaryColor,
                        side: const BorderSide(color: AppConstants.primaryColor),
                      ),
                      child: const Text('ดูรายละเอียด'),
                    ),
                    if (_canUpdateStatus(status)) ...[
                      const SizedBox(width: AppConstants.paddingSmall),
                      ElevatedButton(
                        onPressed: () => _showUpdateStatusDialog(order),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('อัพเดทสถานะ'),
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

  bool _canUpdateStatus(String status) {
    return status == 'pending' || status == 'confirmed';
  }

  List<Map<String, dynamic>> _getMockOrders(String status) {
    final allOrders = [
      {
        'id': 1001,
        'customer_name': 'นายสมชาย ใจดี',
        'customer_phone': '0812345678',
        'total_amount': 1500.0,
        'status': 'pending',
        'created_at': DateTime.now().subtract(const Duration(hours: 2)),
        'items': [
          {
            'product_name': 'ผ้าไหมไทยสีทอง',
            'quantity': 1,
            'total_price': 1500.0,
          },
        ],
      },
      {
        'id': 1002,
        'customer_name': 'นางสาวมาลี สวยงาม',
        'customer_phone': '0823456789',
        'total_amount': 850.0,
        'status': 'confirmed',
        'created_at': DateTime.now().subtract(const Duration(hours: 5)),
        'items': [
          {
            'product_name': 'เครื่องปั้นดินเผาลายไทย',
            'quantity': 1,
            'total_price': 850.0,
          },
        ],
      },
      {
        'id': 1003,
        'customer_name': 'นายประยุทธ์ มั่งคั่ง',
        'customer_phone': '0834567890',
        'total_amount': 500.0,
        'status': 'shipped',
        'created_at': DateTime.now().subtract(const Duration(days: 1)),
        'items': [
          {
            'product_name': 'ตะกร้าไม้ไผ่สานมือ',
            'quantity': 2,
            'total_price': 500.0,
          },
        ],
      },
    ];

    if (status == 'all') return allOrders;
    return allOrders.where((order) => order['status'] == status).toList();
  }

  Future<void> _refreshOrders(String status) async {
    await Future.delayed(const Duration(seconds: 2));
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ค้นหาคำสั่งซื้อ'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'หมายเลขคำสั่งซื้อหรือชื่อลูกค้า',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Helpers.showSnackBar(context, 'กำลังพัฒนาฟีเจอร์ค้นหา...');
            },
            child: const Text('ค้นหา'),
          ),
        ],
      ),
    );
  }

  void _viewOrderDetail(Map<String, dynamic> order) {
    // TODO: Navigate to order detail screen
    Helpers.showSnackBar(context, 'ดูรายละเอียดคำสั่งซื้อ #${order['id']}');
  }

  void _showUpdateStatusDialog(Map<String, dynamic> order) {
    final currentStatus = order['status'] as String;
    String newStatus = _getNextStatus(currentStatus);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('อัพเดทสถานะคำสั่งซื้อ #${order['id']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('สถานะปัจจุบัน: ${Helpers.getOrderStatusText(currentStatus)}'),
            const SizedBox(height: AppConstants.paddingMedium),
            DropdownButtonFormField<String>(
              value: newStatus,
              decoration: const InputDecoration(
                labelText: 'สถานะใหม่',
                border: OutlineInputBorder(),
              ),
              items: _getAvailableStatuses(currentStatus).map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(Helpers.getOrderStatusText(status)),
                );
              }).toList(),
              onChanged: (value) => newStatus = value!,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _updateOrderStatus(order, newStatus);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
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
    // TODO: Implement API call to update order status
    setState(() {
      order['status'] = newStatus;
    });
    
    Helpers.showSuccessSnackBar(
      context,
      'อัพเดทสถานะคำสั่งซื้อ #${order['id']} เป็น ${Helpers.getOrderStatusText(newStatus)} แล้ว',
    );
  }
}