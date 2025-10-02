import 'dart:convert'; // เพิ่มบรรทัดนี้
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../utils/validators.dart';
import '../orders/order_detail_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _customerEmailController = TextEditingController();
  final _shippingAddressController = TextEditingController();
  final _districtController = TextEditingController();
  final _provinceController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _selectedPaymentMethod = 'transfer';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _customerEmailController.dispose();
    _shippingAddressController.dispose();
    _districtController.dispose();
    _provinceController.dispose();
    _postalCodeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    
    if (user != null) {
      _customerNameController.text = user.username;
      _customerEmailController.text = user.email;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ดำเนินการสั่งซื้อ'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, _) {
          if (cartProvider.isEmpty) {
            return const Center(
              child: Text('ไม่มีสินค้าในตะกร้า'),
            );
          }

          return Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Order Summary
                        _buildOrderSummary(cartProvider),
                        
                        const SizedBox(height: AppConstants.paddingLarge),
                        
                        // Shipping Information
                        _buildShippingInformation(),
                        
                        const SizedBox(height: AppConstants.paddingLarge),
                        
                        // Payment Method
                        _buildPaymentMethod(),
                        
                        const SizedBox(height: AppConstants.paddingLarge),
                        
                        // Additional Notes
                        _buildAdditionalNotes(),
                        
                        const SizedBox(height: AppConstants.paddingLarge),
                        
                        // Terms and Conditions
                        _buildTermsAndConditions(),
                      ],
                    ),
                  ),
                ),

                // Checkout Button
                _buildCheckoutButton(cartProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderSummary(CartProvider cartProvider) {
    final shippingFee = Helpers.calculateShippingFee(cartProvider.totalAmount);
    final grandTotal = cartProvider.totalAmount + shippingFee;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'สรุปคำสั่งซื้อ',
              style: TextStyle(
                fontSize: AppConstants.fontSizeExtraLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            
            // Items List
            ...cartProvider.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${item.product.name} x${item.quantity}',
                      style: const TextStyle(fontSize: AppConstants.fontSizeMedium),
                    ),
                  ),
                  Text(
                    Helpers.formatPrice(item.totalPrice),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )).toList(),
            
            const Divider(),
            
            // Totals
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('ยอดรวมสินค้า:'),
                Text(Helpers.formatPrice(cartProvider.totalAmount)),
              ],
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('ค่าจัดส่ง:'),
                Text(
                  shippingFee > 0
                      ? Helpers.formatPrice(shippingFee)
                      : 'ฟรี',
                  style: TextStyle(
                    color: shippingFee > 0 ? null : AppConstants.successColor,
                    fontWeight: shippingFee > 0 ? null : FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ยอดรวมทั้งหมด:',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  Helpers.formatPrice(grandTotal),
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

  Widget _buildShippingInformation() {
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
            
            // Customer Name
            TextFormField(
              controller: _customerNameController,
              decoration: const InputDecoration(
                labelText: 'ชื่อผู้รับ *',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) => Validators.validateRequired(value, 'ชื่อผู้รับ'),
            ),
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            // Customer Phone
            TextFormField(
              controller: _customerPhoneController,
              decoration: const InputDecoration(
                labelText: 'เบอร์โทรศัพท์ *',
                prefixIcon: Icon(Icons.phone),
                hintText: '08xxxxxxxx',
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณากรอกเบอร์โทรศัพท์';
                }
                return Validators.validatePhone(value);
              },
            ),
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            // Customer Email
            TextFormField(
              controller: _customerEmailController,
              decoration: const InputDecoration(
                labelText: 'อีเมล',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: Validators.validateEmail,
            ),
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            // Address
            TextFormField(
              controller: _shippingAddressController,
              decoration: const InputDecoration(
                labelText: 'ที่อยู่ *',
                prefixIcon: Icon(Icons.location_on),
                hintText: 'บ้านเลขที่ ซอย ถนน',
              ),
              maxLines: 2,
              validator: (value) => Validators.validateRequired(value, 'ที่อยู่'),
            ),
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            // District and Province
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _districtController,
                    decoration: const InputDecoration(
                      labelText: 'ตำบล/แขวง *',
                      prefixIcon: Icon(Icons.map),
                    ),
                    validator: (value) => Validators.validateRequired(value, 'ตำบล/แขวง'),
                  ),
                ),
                const SizedBox(width: AppConstants.paddingMedium),
                Expanded(
                  child: TextFormField(
                    controller: _provinceController,
                    decoration: const InputDecoration(
                      labelText: 'จังหวัด *',
                      prefixIcon: Icon(Icons.location_city),
                    ),
                    validator: (value) => Validators.validateRequired(value, 'จังหวัด'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            // Postal Code
            TextFormField(
              controller: _postalCodeController,
              decoration: const InputDecoration(
                labelText: 'รหัสไปรษณีย์ *',
                prefixIcon: Icon(Icons.local_post_office),
                hintText: '10000',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณากรอกรหัสไปรษณีย์';
                }
                if (value.length != 5) {
                  return 'รหัสไปรษณีย์ต้องมี 5 หลัก';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'วิธีการชำระเงิน',
              style: TextStyle(
                fontSize: AppConstants.fontSizeExtraLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            
            // Bank Transfer
            RadioListTile<String>(
              value: 'transfer',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() => _selectedPaymentMethod = value!);
              },
              title: const Row(
                children: [
                  Icon(Icons.account_balance, color: AppConstants.primaryColor),
                  SizedBox(width: AppConstants.paddingSmall),
                  Text('โอนเงินผ่านธนาคาร'),
                ],
              ),
              subtitle: const Text('โอนเงินแล้วแนบสลิปยืนยันการชำระเงิน'),
            ),
            
            // Cash on Delivery
            RadioListTile<String>(
              value: 'cod',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() => _selectedPaymentMethod = value!);
              },
              title: const Row(
                children: [
                  Icon(Icons.payments, color: AppConstants.warningColor),
                  SizedBox(width: AppConstants.paddingSmall),
                  Text('เก็บเงินปลายทาง'),
                ],
              ),
              subtitle: const Text('ชำระเงินเมื่อได้รับสินค้า (+20 บาท)'),
            ),
            
            if (_selectedPaymentMethod == 'transfer') ...[
              const SizedBox(height: AppConstants.paddingMedium),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  border: Border.all(color: AppConstants.primaryColor.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ข้อมูลการโอนเงิน',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    const Text('ธนาคารกสิกรไทย'),
                    const Text('เลขที่บัญชี: 123-4-56789-0'),
                    const Text('ชื่อบัญชี: OTOP Store'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalNotes() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'หมายเหตุเพิ่มเติม',
              style: TextStyle(
                fontSize: AppConstants.fontSizeExtraLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                hintText: 'ระบุข้อมูลเพิ่มเติม เช่น จุดสังเกตเพื่อการจัดส่ง',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsAndConditions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ข้อกำหนดและเงื่อนไข',
              style: TextStyle(
                fontSize: AppConstants.fontSizeExtraLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              '• กรุณาตรวจสอบข้อมูลให้ถูกต้องก่อนยืนยันคำสั่งซื้อ\n'
              '• การจัดส่งใช้เวลา 3-5 วันทำการ\n'
              '• สินค้าที่ชำรุดสามารถเปลี่ยนคืนได้ภายใน 7 วัน\n'
              '• กรณีชำระเงินโอนธนาคาร กรุณาแนบสลิปภายใน 24 ชั่วโมง',
              style: TextStyle(
                color: AppConstants.secondaryColor,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutButton(CartProvider cartProvider) {
    final shippingFee = Helpers.calculateShippingFee(cartProvider.totalAmount);
    final grandTotal = cartProvider.totalAmount + shippingFee + 
        (_selectedPaymentMethod == 'cod' ? 20 : 0);

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ยอดรวมสุทธิ:',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  Helpers.formatPrice(grandTotal),
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'ยืนยันคำสั่งซื้อ',
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeLarge,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processOrder() async {
    if (!_formKey.currentState!.validate()) {
      Helpers.showErrorSnackBar(context, 'กรุณากรอกข้อมูลให้ครบถ้วน');
      return;
    }

    setState(() => _isProcessing = true);

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    try {
      // สร้าง order items จาก cart พร้อม price
      final orderItems = cartProvider.items.map((item) => {
        'product_id': item.product.id,
        'quantity': item.quantity,
        'variant': null, // เพิ่มถ้ามี variant system
        'price': item.product.price, // เพิ่ม price
      }).toList();

      // สร้าง shipping address เป็น JSON string
      final shippingAddress = jsonEncode({
        'full_name': _customerNameController.text.trim(),
        'phone': _customerPhoneController.text.trim(),
        'address': _shippingAddressController.text.trim(),
        'district': _districtController.text.trim(),
        'province': _provinceController.text.trim(),
        'postal_code': _postalCodeController.text.trim(),
        'additional_info': _customerEmailController.text.trim().isNotEmpty 
            ? 'Email: ${_customerEmailController.text.trim()}' 
            : null,
      });

      // สร้าง order request data
      final orderRequest = {
        'items': orderItems,
        'shipping_address': shippingAddress,
        'payment_method': _selectedPaymentMethod,
        'notes': _notesController.text.trim().isNotEmpty 
            ? _notesController.text.trim() 
            : null,
        'customer_name': _customerNameController.text.trim(),
        'customer_phone': _customerPhoneController.text.trim(),
        'customer_email': _customerEmailController.text.trim(),
      };

      // เรียก API สร้าง order
      final result = await orderProvider.createOrder(orderRequest);

      if (result['success'] == true) {
  cartProvider.clearCart();
  Helpers.showSuccessSnackBar(context, 'สั่งซื้อสำเร็จ!');

  final order = result['order'] as Order;

  if (!mounted) return;

  // ✅ ส่ง order object ไปเลย
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (context) => OrderDetailScreen(order: order),
    ),
    (route) => route.isFirst,
  );
} else {
  Helpers.showErrorSnackBar(
    context,
    result['message'] ?? 'ไม่สามารถสร้างคำสั่งซื้อได้',
  );
}
    } catch (e) {
      Helpers.showErrorSnackBar(
        context,
        'เกิดข้อผิดพลาด: ${e.toString()}',
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}