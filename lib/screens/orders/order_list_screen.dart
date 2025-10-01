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

class _OrderListScreenState extends State<OrderListScreen> with AutomaticKeepAliveClientMixin {
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
            title: const Text('คำสั่งซื้อของฉัน'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.filter_list),
                onSelected: (value) {
                  setState(() {
                    _selectedFilter = value;
                  });
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'all',
                    child: Text('ทั้งหมด'),
                  ),
                  const PopupMenuItem(
                    value: 'pending',
                    child: Text('รอดำเนินการ'),
                  ),
                  const PopupMenuItem(
                    value: 'confirmed',
                    child: Text('ยืนยันแล้ว'),
                  ),
                  const PopupMenuItem(
                    value: 'shipped',
                    child: Text('จัดส่งแล้ว'),
                  ),
                  const PopupMenuItem(
                    value: 'delivered',
                    child: Text('ส่งถึงแล้ว'),
                  ),
                  const PopupMenuItem(
                    value: 'cancelled',
                    child: Text('ยกเลิก'),
                  ),
                ],
              ),
            ],
          ),
          body: Consumer<OrderProvider>(
            builder: (context, orderProvider, _) {
              if (orderProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
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
                onRefresh: () => orderProvider.loadMyOrders(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    return _buildOrderCard(order);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLoginRequired() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('คำสั่งซื้อของฉัน'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.login,
              size: 100,
              color: Colors.grey[400],
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              'กรุณาเข้าสู่ระบบ',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              'เข้าสู่ระบบเพื่อดูประวัติคำสั่งซื้อของคุณ',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.paddingLarge),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              icon: const Icon(Icons.login),
              label: const Text('เข้าสู่ระบบ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingLarge,
                  vertical: AppConstants.paddingMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String error, VoidCallback onRetry) {
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
            error,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppConstants.secondaryColor),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('ลองใหม่'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyOrders() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(
            _selectedFilter == 'all' ? 'ยังไม่มีคำสั่งซื้อ' : 'ไม่พบคำสั่งซื้อ',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            _selectedFilter == 'all' 
                ? 'เริ่มช้อปปิ้งเพื่อสั่งซื้อสินค้าแรกของคุณ'
                : 'ลองเปลี่ยนตัวกรองเพื่อดูคำสั่งซื้ออื่น',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          if (_selectedFilter == 'all') ...[
            const SizedBox(height: AppConstants.paddingLarge),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to products tab
                DefaultTabController.of(context)?.animateTo(1);
              },
              icon: const Icon(Icons.store),
              label: const Text('เริ่มช้อปปิ้ง'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingLarge,
                  vertical: AppConstants.paddingMedium,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderCard(dynamic order) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: InkWell(
        onTap: () => _navigateToOrderDetail(order),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
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
                    'คำสั่งซื้อ #${order.id}',
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
                      color: Helpers.getOrderStatusColor(order.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                      border: Border.all(
                        color: Helpers.getOrderStatusColor(order.status),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      Helpers.getOrderStatusText(order.status),
                      style: TextStyle(
                        color: Helpers.getOrderStatusColor(order.status),
                        fontSize: AppConstants.fontSizeSmall,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppConstants.paddingSmall),
              
              // Order Date
              Text(
                'วันที่สั่ง: ${Helpers.formatDateTime(order.createdAt)}',
                style: TextStyle(
                  color: AppConstants.secondaryColor,
                  fontSize: AppConstants.fontSizeSmall,
                ),
              ),
              
              const SizedBox(height: AppConstants.paddingSmall),
              
              // Payment Method
              Text(
                'วิธีชำระเงิน: ${Helpers.getPaymentMethodText(order.paymentMethod)}',
                style: TextStyle(
                  color: AppConstants.secondaryColor,
                  fontSize: AppConstants.fontSizeSmall,
                ),
              ),
              
              const SizedBox(height: AppConstants.paddingMedium),
              
              // Order Items Preview
              if (order.items != null && order.items.isNotEmpty) ...[
                Text(
                  'รายการสินค้า (${order.items.length} รายการ):',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppConstants.fontSizeSmall,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                ...order.items.take(2).map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '• ${item.productName} x${item.quantity}',
                          style: TextStyle(
                            color: AppConstants.secondaryColor,
                            fontSize: AppConstants.fontSizeSmall,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        Helpers.formatPrice(item.totalPrice),
                        style: TextStyle(
                          color: AppConstants.secondaryColor,
                          fontSize: AppConstants.fontSizeSmall,
                        ),
                      ),
                    ],
                  ),
                )).toList(),
                if (order.items.length > 2)
                  Text(
                    'และอีก ${order.items.length - 2} รายการ',
                    style: TextStyle(
                      color: AppConstants.secondaryColor,
                      fontSize: AppConstants.fontSizeSmall,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                const SizedBox(height: AppConstants.paddingMedium),
              ],
              
              // Total and Action Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ยอดรวม',
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeSmall,
                        ),
                      ),
                      Text(
                        Helpers.formatPrice(order.totalAmount),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: AppConstants.fontSizeLarge,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () => _navigateToOrderDetail(order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                      ),
                    ),
                    child: const Text('ดูรายละเอียด'),
                  ),
                ],
              ),
            ],
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