import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false)
          .loadOrderDetail(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('คำสั่งซื้อ #${widget.orderId}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareOrder(),
            tooltip: 'แชร์คำสั่งซื้อ',
          ),
        ],
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, _) {
          if (orderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (orderProvider.error != null) {
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
                    orderProvider.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppConstants.secondaryColor),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  ElevatedButton(
                    onPressed: () => orderProvider.loadOrderDetail(widget.orderId),
                    child: const Text('ลองใหม่'),
                  ),
                ],
              ),
            );
          }

          final order = orderProvider.selectedOrder;
          if (order == null) {
            return const Center(
              child: Text('ไม่พบคำสั่งซื้อ'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => orderProvider.loadOrderDetail(widget.orderId),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Status Card
                  _buildOrderStatusCard(order),
                  
                  const SizedBox(height: AppConstants.paddingMedium),
                  
                  // Order Information
                  _buildOrderInformation(order),
                  
                  const SizedBox(height: AppConstants.paddingMedium),
                  
                  // Shipping Information
                  _buildShippingInformation(order),
                  
                  const SizedBox(height: AppConstants.paddingMedium),
                  
                  // Order Items
                  _buildOrderItems(order),
                  
                  const SizedBox(height: AppConstants.paddingMedium),
                  
                  // Payment Summary
                  _buildPaymentSummary(order),
                  
                  const SizedBox(height: AppConstants.paddingLarge),
                  
                  // Action Buttons
                  _buildActionButtons(order),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderStatusCard(dynamic order) {
    final statusColor = Helpers.getOrderStatusColor(order.status);
    final statusText = Helpers.getOrderStatusText(order.status);

    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              statusColor.withOpacity(0.1),
              statusColor.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(color: statusColor.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getStatusIcon(order.status),
                size: 40,
                color: statusColor,
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              statusText,
              style: TextStyle(
                fontSize: AppConstants.fontSizeHeading,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              'สั่งเมื่อ ${Helpers.formatDateTime(order.createdAt)}',
              style: TextStyle(
                color: AppConstants.secondaryColor,
                fontSize: AppConstants.fontSizeMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInformation(dynamic order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ข้อมูลคำสั่งซื้อ',
              style: TextStyle(
                fontSize: AppConstants.fontSizeExtraLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            
            _buildInfoRow(
              icon: Icons.receipt_long,
              label: 'หมายเลขคำสั่งซื้อ',
              value: '#${order.id}',
            ),
            
            _buildInfoRow(
              icon: Icons.access_time,
              label: 'วันที่สั่งซื้อ',
              value: Helpers.formatDateTime(order.createdAt),
            ),
            
            _buildInfoRow(
              icon: Icons.payment,
              label: 'วิธีชำระเงิน',
              value: Helpers.getPaymentMethodText(order.paymentMethod),
            ),
            
            _buildInfoRow(
              icon: Icons.info,
              label: 'สถานะ',
              value: Helpers.getOrderStatusText(order.status),
              valueColor: Helpers.getOrderStatusColor(order.status),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingInformation(dynamic order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ข้อมูลการจัดส่ง',
              style: TextStyle(
                fontSize: AppConstants.fontSizeExtraLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            
            _buildInfoRow(
              icon: Icons.person,
              label: 'ชื่อผู้รับ',
              value: order.customerName,
            ),
            
            if (order.customerPhone.isNotEmpty)
              _buildInfoRow(
                icon: Icons.phone,
                label: 'เบอร์โทรศัพท์',
                value: Helpers.formatPhoneNumber(order.customerPhone),
              ),
            
            if (order.customerEmail.isNotEmpty)
              _buildInfoRow(
                icon: Icons.email,
                label: 'อีเมล',
                value: order.customerEmail,
              ),
            
            _buildInfoRow(
              icon: Icons.location_on,
              label: 'ที่อยู่จัดส่ง',
              value: order.shippingAddress,
              isMultiline: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItems(dynamic order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'รายการสินค้า (${order.items?.length ?? 0} รายการ)',
              style: const TextStyle(
                fontSize: AppConstants.fontSizeExtraLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            
            if (order.items != null && order.items.isNotEmpty)
              ...order.items.map((item) => _buildOrderItem(item)).toList()
            else
              const Text(
                'ไม่มีข้อมูลสินค้า',
                style: TextStyle(color: AppConstants.secondaryColor),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          // Product placeholder image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            child: const Icon(Icons.image, color: Colors.grey),
          ),
          
          const SizedBox(width: AppConstants.paddingMedium),
          
          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppConstants.fontSizeMedium,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${Helpers.formatPrice(item.price)} x ${item.quantity}',
                      style: TextStyle(
                        color: AppConstants.secondaryColor,
                        fontSize: AppConstants.fontSizeSmall,
                      ),
                    ),
                    Text(
                      Helpers.formatPrice(item.totalPrice),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryColor,
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'สรุปการชำระเงิน',
              style: TextStyle(
                fontSize: AppConstants.fontSizeExtraLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            
            // Subtotal
            _buildPaymentRow('ยอดรวมสินค้า', order.totalAmount - 50), // Assuming shipping is 50
            
            // Shipping
            _buildPaymentRow('ค่าจัดส่ง', 50.0),
            
            // COD fee if applicable
            if (order.paymentMethod == 'cod')
              _buildPaymentRow('ค่าเก็บเงินปลายทาง', 20.0),
            
            const Divider(),
            
            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ยอดรวมทั้งหมด',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  Helpers.formatPrice(order.totalAmount),
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(Helpers.formatPrice(amount)),
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
      padding: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: AppConstants.secondaryColor,
          ),
          const SizedBox(width: AppConstants.paddingSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeSmall,
                    color: AppConstants.secondaryColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeMedium,
                    fontWeight: FontWeight.w500,
                    color: valueColor,
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
        // Contact Seller Button
        if (order.status != 'cancelled' && order.status != 'delivered')
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _contactSeller(order),
              icon: const Icon(Icons.message),
              label: const Text('ติดต่อผู้ขาย'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppConstants.primaryColor,
                side: const BorderSide(color: AppConstants.primaryColor),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        
        const SizedBox(height: AppConstants.paddingMedium),
        
        // Cancel Order Button (only for pending orders)
        if (order.status == 'pending')
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showCancelOrderDialog(order),
              icon: const Icon(Icons.cancel),
              label: const Text('ยกเลิกคำสั่งซื้อ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.errorColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        
        // Reorder Button (for completed or cancelled orders)
        if (order.status == 'delivered' || order.status == 'cancelled')
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _reorder(order),
              icon: const Icon(Icons.refresh),
              label: const Text('สั่งซื้อซ้ำ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
      ],
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.access_time;
      case 'confirmed':
        return Icons.check_circle;
      case 'shipped':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  void _shareOrder() {
    Helpers.showSnackBar(context, 'กำลังพัฒนาฟีเจอร์แชร์...');
  }

  void _contactSeller(dynamic order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ติดต่อผู้ขาย'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('วิธีติดต่อผู้ขาย:'),
            SizedBox(height: AppConstants.paddingSmall),
            Text('📞 โทร: 02-123-4567'),
            Text('📧 อีเมล: seller@otop.com'),
            Text('💬 Line: @otopstore'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }

  void _showCancelOrderDialog(dynamic order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยกเลิกคำสั่งซื้อ'),
        content: Text('คุณต้องการยกเลิกคำสั่งซื้อ #${order.id} หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ไม่ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _cancelOrder(order);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('ยกเลิก'),
          ),
        ],
      ),
    );
  }

  void _cancelOrder(dynamic order) {
    // TODO: Implement order cancellation
    Helpers.showSnackBar(context, 'กำลังพัฒนาฟีเจอร์ยกเลิกคำสั่งซื้อ...');
  }

  void _reorder(dynamic order) {
    // TODO: Implement reorder functionality
    Helpers.showSnackBar(context, 'กำลังพัฒนาฟีเจอร์สั่งซื้อซ้ำ...');
  }
}