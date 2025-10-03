import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../models/order.dart';

class OrderDetailScreen extends StatefulWidget {
  final int? orderId;
  final Order? order;

  const OrderDetailScreen({
    super.key,
    this.orderId,
    this.order,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.order != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<OrderProvider>(context, listen: false)
            .setSelectedOrder(widget.order!);
      });
    } else if (widget.orderId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<OrderProvider>(context, listen: false)
            .loadOrderDetail(widget.orderId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.shade50,
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: Consumer<OrderProvider>(
                  builder: (context, orderProvider, _) {
                    if (orderProvider.isLoading) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.deepPurple.shade400,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'กำลังโหลดข้อมูล...',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (orderProvider.error != null) {
                      return _buildErrorState(orderProvider);
                    }

                    final order = orderProvider.selectedOrder;
                    if (order == null) {
                      return _buildNotFoundState();
                    }

                    return RefreshIndicator(
                      onRefresh: () =>
                          orderProvider.loadOrderDetail(widget.orderId!),
                      color: Colors.deepPurple.shade400,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildOrderStatusCard(order),
                            const SizedBox(height: 16),
                            _buildOrderInformation(order),
                            const SizedBox(height: 16),
                            _buildShippingInformation(order),
                            const SizedBox(height: 16),
                            _buildOrderItems(order),
                            const SizedBox(height: 16),
                            _buildPaymentSummary(order),
                            const SizedBox(height: 24),
                            _buildActionButtons(order),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(20),
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
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'รายละเอียดคำสั่งซื้อ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '#${widget.orderId}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.share_rounded, color: Colors.white),
              onPressed: _shareOrder,
              tooltip: 'แชร์คำสั่งซื้อ',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(OrderProvider orderProvider) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'เกิดข้อผิดพลาด',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              orderProvider.error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.deepPurple.shade400,
                    Colors.blue.shade400,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () =>
                      Provider.of<OrderProvider>(context, listen: false)
                          .loadOrderDetail(widget.orderId!),
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    child: Text(
                      'ลองใหม่',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'ไม่พบคำสั่งซื้อ',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatusCard(dynamic order) {
    final statusColor = Helpers.getOrderStatusColor(order.status);
    final statusText = Helpers.getOrderStatusText(order.status);

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withOpacity(0.15),
            statusColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: statusColor.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              _getStatusIcon(order.status),
              size: 48,
              color: statusColor,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'สั่งเมื่อ ${Helpers.formatDateTime(order.createdAt)}',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInformation(dynamic order) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple.shade400,
                      Colors.blue.shade400,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'ข้อมูลคำสั่งซื้อ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            icon: Icons.tag_rounded,
            label: 'หมายเลขคำสั่งซื้อ',
            value: '#${order.id}',
          ),
          _buildInfoRow(
            icon: Icons.access_time_rounded,
            label: 'วันที่สั่งซื้อ',
            value: Helpers.formatDateTime(order.createdAt),
          ),
          _buildInfoRow(
            icon: Icons.payment_rounded,
            label: 'วิธีชำระเงิน',
            value: Helpers.getPaymentMethodText(order.paymentMethod),
          ),
          _buildInfoRow(
            icon: Icons.info_rounded,
            label: 'สถานะ',
            value: Helpers.getOrderStatusText(order.status),
            valueColor: Helpers.getOrderStatusColor(order.status),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingInformation(dynamic order) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.shade400,
                      Colors.cyan.shade400,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_shipping_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'ข้อมูลการจัดส่ง',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            icon: Icons.person_rounded,
            label: 'ชื่อผู้รับ',
            value: order.customerName,
          ),
          if (order.customerPhone.isNotEmpty)
            _buildInfoRow(
              icon: Icons.phone_rounded,
              label: 'เบอร์โทรศัพท์',
              value: Helpers.formatPhoneNumber(order.customerPhone),
            ),
          if (order.customerEmail.isNotEmpty)
            _buildInfoRow(
              icon: Icons.email_rounded,
              label: 'อีเมล',
              value: order.customerEmail,
            ),
          _buildInfoRow(
            icon: Icons.location_on_rounded,
            label: 'ที่อยู่จัดส่ง',
            value: order.shippingAddress,
            isMultiline: true,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems(dynamic order) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.shade400,
                      Colors.pink.shade400,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.shopping_bag_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'รายการสินค้า (${order.items?.length ?? 0} รายการ)',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (order.items != null && order.items.isNotEmpty)
            ...order.items.map((item) => _buildOrderItem(item)).toList()
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'ไม่มีข้อมูลสินค้า',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple.shade50,
            Colors.blue.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.deepPurple.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.image_rounded,
              color: Colors.deepPurple.shade200,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.grey.shade800,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${Helpers.formatPrice(item.price)} x ${item.quantity}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.deepPurple.shade400,
                            Colors.blue.shade400,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        Helpers.formatPrice(item.totalPrice),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(dynamic order) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepPurple.shade400,
            Colors.blue.shade400,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'สรุปการชำระเงิน',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildPaymentRow('ยอดรวมสินค้า', order.totalAmount - 50),
          _buildPaymentRow('ค่าจัดส่ง', 50.0),
          if (order.paymentMethod == 'cod')
            _buildPaymentRow('ค่าเก็บเงินปลายทาง', 20.0),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.white.withOpacity(0.3), thickness: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ยอดรวมทั้งหมด',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                Helpers.formatPrice(order.totalAmount),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 15,
            ),
          ),
          Text(
            Helpers.formatPrice(amount),
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool isMultiline = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple.shade50,
                  Colors.blue.shade50,
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: Colors.deepPurple.shade400,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(dynamic order) {
    return Column(
      children: [
        if (order.status != 'cancelled' && order.status != 'delivered')
          Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.deepPurple.shade300, width: 2),
              borderRadius: BorderRadius.circular(14),
              color: Colors.white,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _contactSeller(order),
                borderRadius: BorderRadius.circular(14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.message_rounded,
                        color: Colors.deepPurple.shade600),
                    const SizedBox(width: 12),
                    Text(
                      'ติดต่อผู้ขาย',
                      style: TextStyle(
                        color: Colors.deepPurple.shade600,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (order.status != 'cancelled' && order.status != 'delivered')
          const SizedBox(height: 12),
        if (order.status == 'pending')
          Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade400, Colors.red.shade600],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showCancelOrderDialog(order),
                borderRadius: BorderRadius.circular(14),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cancel_rounded, color: Colors.white),
                    SizedBox(width: 12),
                    Text(
                      'ยกเลิกคำสั่งซื้อ',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (order.status == 'delivered' || order.status == 'cancelled')
          Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple.shade400,
                  Colors.blue.shade400,
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _reorder(order),
                borderRadius: BorderRadius.circular(14),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh_rounded, color: Colors.white),
                    SizedBox(width: 12),
                    Text(
                      'สั่งซื้อซ้ำ',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.access_time_rounded;
      case 'confirmed':
        return Icons.check_circle_rounded;
      case 'shipped':
        return Icons.local_shipping_rounded;
      case 'delivered':
        return Icons.done_all_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  void _shareOrder() {
    Helpers.showSnackBar(context, 'กำลังพัฒนาฟีเจอร์แชร์...');
  }

  void _contactSeller(dynamic order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.deepPurple.shade400,
                    Colors.blue.shade400,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.message_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('ติดต่อผู้ขาย'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'วิธีติดต่อผู้ขาย:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 16),
            _buildContactItem(Icons.phone_rounded, 'โทร', '02-123-4567'),
            const SizedBox(height: 12),
            _buildContactItem(Icons.email_rounded, 'อีเมล', 'seller@otop.com'),
            const SizedBox(height: 12),
            _buildContactItem(Icons.chat_rounded, 'Line', '@otopstore'),
          ],
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple.shade400,
                  Colors.blue.shade400,
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: Text(
                    'ปิด',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.deepPurple.shade50,
                Colors.blue.shade50,
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Colors.deepPurple.shade600),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showCancelOrderDialog(dynamic order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.warning_rounded,
                  color: Colors.red.shade600, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('ยกเลิกคำสั่งซื้อ'),
          ],
        ),
        content: Text(
          'คุณต้องการยกเลิกคำสั่งซื้อ #${order.id} หรือไม่?',
          style: TextStyle(color: Colors.grey.shade700),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('ไม่ยกเลิก',
                style: TextStyle(color: Colors.grey.shade600)),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade400, Colors.red.shade600],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  _cancelOrder(order);
                },
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: Text(
                    'ยกเลิก',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _cancelOrder(dynamic order) {
    Helpers.showSnackBar(context, 'กำลังพัฒนาฟีเจอร์ยกเลิกคำสั่งซื้อ...');
  }

  void _reorder(dynamic order) {
    Helpers.showSnackBar(context, 'กำลังพัฒนาฟีเจอร์สั่งซื้อซ้ำ...');
  }
}
