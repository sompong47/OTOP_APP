import 'dart:convert';
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

  // Modern Color Scheme
  static const Color primaryPurple = Color(0xFF6366F1);
  static const Color deepPurple = Color(0xFF4F46E5);
  static const Color lightPurple = Color(0xFFE0E7FF);
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color lightBlue = Color(0xFFDEEBFF);
  static const Color darkText = Color(0xFF1F2937);
  static const Color lightText = Color(0xFF6B7280);

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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'ดำเนินการสั่งซื้อ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: darkText,
        elevation: 0,
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
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, _) {
          if (cartProvider.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 100, color: lightText.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'ไม่มีสินค้าในตะกร้า',
                    style: TextStyle(
                      fontSize: 18,
                      color: lightText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildOrderSummary(cartProvider),
                        const SizedBox(height: 16),
                        _buildShippingInformation(),
                        const SizedBox(height: 16),
                        _buildPaymentMethod(),
                        const SizedBox(height: 16),
                        _buildAdditionalNotes(),
                        const SizedBox(height: 16),
                        _buildTermsAndConditions(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
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

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryPurple, deepPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
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
                  child: const Icon(Icons.receipt_long,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Text(
                  'สรุปคำสั่งซื้อ',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Items List
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ...cartProvider.items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'x${item.quantity}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item.product.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Text(
                              Helpers.formatPrice(item.totalPrice),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Divider(color: Colors.white.withOpacity(0.3), thickness: 1),
            const SizedBox(height: 16),

            // Totals
            _buildPriceRow('ยอดรวมสินค้า',
                Helpers.formatPrice(cartProvider.totalAmount), false),
            const SizedBox(height: 8),
            _buildPriceRow(
              'ค่าจัดส่ง',
              shippingFee > 0 ? Helpers.formatPrice(shippingFee) : 'ฟรี',
              shippingFee == 0,
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.white.withOpacity(0.3), thickness: 1),
            const SizedBox(height: 16),
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
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    Helpers.formatPrice(grandTotal),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryPurple,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, bool isHighlight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildShippingInformation() {
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: lightBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.local_shipping,
                      color: accentBlue, size: 24),
                ),
                const SizedBox(width: 12),
                const Text(
                  'ข้อมูลการจัดส่ง',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildStyledTextField(
              controller: _customerNameController,
              label: 'ชื่อผู้รับ',
              icon: Icons.person_outline,
              validator: (value) =>
                  Validators.validateRequired(value, 'ชื่อผู้รับ'),
            ),
            const SizedBox(height: 16),
            _buildStyledTextField(
              controller: _customerPhoneController,
              label: 'เบอร์โทรศัพท์',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              hint: '08xxxxxxxx',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณากรอกเบอร์โทรศัพท์';
                }
                return Validators.validatePhone(value);
              },
            ),
            const SizedBox(height: 16),
            _buildStyledTextField(
              controller: _customerEmailController,
              label: 'อีเมล (ไม่บังคับ)',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.validateEmail,
            ),
            const SizedBox(height: 16),
            _buildStyledTextField(
              controller: _shippingAddressController,
              label: 'ที่อยู่',
              icon: Icons.location_on_outlined,
              hint: 'บ้านเลขที่ ซอย ถนน',
              maxLines: 2,
              validator: (value) =>
                  Validators.validateRequired(value, 'ที่อยู่'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStyledTextField(
                    controller: _districtController,
                    label: 'ตำบล/แขวง',
                    icon: Icons.map_outlined,
                    validator: (value) =>
                        Validators.validateRequired(value, 'ตำบล/แขวง'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStyledTextField(
                    controller: _provinceController,
                    label: 'จังหวัด',
                    icon: Icons.location_city_outlined,
                    validator: (value) =>
                        Validators.validateRequired(value, 'จังหวัด'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStyledTextField(
              controller: _postalCodeController,
              label: 'รหัสไปรษณีย์',
              icon: Icons.local_post_office_outlined,
              keyboardType: TextInputType.number,
              hint: '10000',
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

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: primaryPurple),
        filled: true,
        fillColor: lightPurple.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightPurple.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryPurple, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildPaymentMethod() {
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: lightPurple,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      const Icon(Icons.payment, color: primaryPurple, size: 24),
                ),
                const SizedBox(width: 12),
                const Text(
                  'วิธีการชำระเงิน',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPaymentOption(
              value: 'transfer',
              icon: Icons.account_balance,
              title: 'โอนเงินผ่านธนาคาร',
              subtitle: 'โอนเงินแล้วแนบสลิปยืนยันการชำระเงิน',
              color: primaryPurple,
            ),
            const SizedBox(height: 12),
            _buildPaymentOption(
              value: 'cod',
              icon: Icons.payments,
              title: 'เก็บเงินปลายทาง',
              subtitle: 'ชำระเงินเมื่อได้รับสินค้า (+20 บาท)',
              color: accentBlue,
            ),
            if (_selectedPaymentMethod == 'transfer') ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      lightPurple.withOpacity(0.5),
                      lightBlue.withOpacity(0.5)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: primaryPurple.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryPurple,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.info_outline,
                              color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'ข้อมูลการโอนเงิน',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: darkText,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildBankInfo('ธนาคาร', 'กสิกรไทย'),
                    const SizedBox(height: 6),
                    _buildBankInfo('เลขที่บัญชี', '123-4-56789-0'),
                    const SizedBox(height: 6),
                    _buildBankInfo('ชื่อบัญชี', 'OTOP Store'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String value,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    final isSelected = _selectedPaymentMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
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
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isSelected ? color : darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: lightText,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? color : Colors.grey[400]!,
                  width: 2,
                ),
                color: isSelected ? color : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankInfo(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            color: lightText,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: darkText,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalNotes() {
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: lightBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.note_alt_outlined,
                      color: accentBlue, size: 24),
                ),
                const SizedBox(width: 12),
                const Text(
                  'หมายเหตุเพิ่มเติม',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                hintText: 'ระบุข้อมูลเพิ่มเติม เช่น จุดสังเกตเพื่อการจัดส่ง',
                hintStyle: TextStyle(color: lightText.withOpacity(0.7)),
                filled: true,
                fillColor: lightBlue.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: lightBlue.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: accentBlue, width: 2),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsAndConditions() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [lightPurple.withOpacity(0.3), lightBlue.withOpacity(0.3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryPurple.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryPurple,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      const Icon(Icons.policy, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Text(
                  'ข้อกำหนดและเงื่อนไข',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTermItem('กรุณาตรวจสอบข้อมูลให้ถูกต้องก่อนยืนยันคำสั่งซื้อ'),
            _buildTermItem('การจัดส่งใช้เวลา 3-5 วันทำการ'),
            _buildTermItem('สินค้าที่ชำรุดสามารถเปลี่ยนคืนได้ภายใน 7 วัน'),
            _buildTermItem(
                'กรณีชำระเงินโอนธนาคาร กรุณาแนบสลิปภายใน 24 ชั่วโมง'),
          ],
        ),
      ),
    );
  }

  Widget _buildTermItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: primaryPurple,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: darkText,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton(CartProvider cartProvider) {
    final shippingFee = Helpers.calculateShippingFee(cartProvider.totalAmount);
    final grandTotal = cartProvider.totalAmount +
        shippingFee +
        (_selectedPaymentMethod == 'cod' ? 20 : 0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    lightPurple.withOpacity(0.5),
                    lightBlue.withOpacity(0.5)
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ยอดรวมสุทธิ',
                        style: TextStyle(
                          fontSize: 14,
                          color: lightText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    Helpers.formatPrice(grandTotal),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryPurple,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [primaryPurple, deepPurple],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: primaryPurple.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, size: 24),
                          SizedBox(width: 12),
                          Text(
                            'ยืนยันคำสั่งซื้อ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
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
      final orderItems = cartProvider.items
          .map((item) => {
                'product_id': item.product.id,
                'quantity': item.quantity,
                'variant': null,
                'price': item.product.price,
              })
          .toList();

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

      final result = await orderProvider.createOrder(orderRequest);

      if (result['success'] == true) {
        cartProvider.clearCart();
        Helpers.showSuccessSnackBar(context, 'สั่งซื้อสำเร็จ!');

        final order = result['order'] as Order;

        if (!mounted) return;

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
