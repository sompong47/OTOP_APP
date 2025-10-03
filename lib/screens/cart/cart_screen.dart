import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

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
          child: Consumer<CartProvider>(
            builder: (context, cartProvider, _) {
              return Column(
                children: [
                  _buildAppBar(context, cartProvider),
                  Expanded(
                    child: cartProvider.isEmpty
                        ? _buildEmptyCart(context)
                        : _buildCartContent(context, cartProvider),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, CartProvider cartProvider) {
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.shopping_cart_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'ตะกร้าสินค้า',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          if (cartProvider.items.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${cartProvider.totalItemsCount} รายการ',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          if (cartProvider.items.isNotEmpty) const SizedBox(width: 8),
          if (cartProvider.items.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon:
                    const Icon(Icons.delete_sweep_rounded, color: Colors.white),
                onPressed: () => _showClearCartDialog(context, cartProvider),
                tooltip: 'ล้างทั้งหมด',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple.shade50,
                  Colors.blue.shade50,
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: Colors.deepPurple.shade300,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'ตะกร้าของคุณว่างเปล่า',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'เริ่มช้อปปิ้งเพื่อเพิ่มสินค้าลงตะกร้า',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple.shade400,
                  Colors.blue.shade400,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  DefaultTabController.of(context)?.animateTo(1);
                },
                borderRadius: BorderRadius.circular(16),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.store_rounded, color: Colors.white),
                      SizedBox(width: 12),
                      Text(
                        'เริ่มช้อปปิ้ง',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(BuildContext context, CartProvider cartProvider) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: cartProvider.items.length,
            itemBuilder: (context, index) {
              final item = cartProvider.items[index];
              return CartItemWidget(cartItem: item);
            },
          ),
        ),
        _buildCartSummary(context, cartProvider),
      ],
    );
  }

  Widget _buildCartSummary(BuildContext context, CartProvider cartProvider) {
    final shippingFee = Helpers.calculateShippingFee(cartProvider.totalAmount);
    final grandTotal = cartProvider.totalAmount + shippingFee;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          _buildSummaryRow(
            'ยอดรวมสินค้า',
            Helpers.formatPrice(cartProvider.totalAmount),
            isSubtotal: true,
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(
            'ค่าจัดส่ง',
            shippingFee > 0 ? Helpers.formatPrice(shippingFee) : 'ฟรี',
            isShipping: true,
            isFree: shippingFee == 0,
          ),
          if (shippingFee == 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade50, Colors.green.shade100],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: Colors.green.shade600, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'ฟรีค่าจัดส่ง เมื่อซื้อครบ ฿1,000',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Colors.grey.shade300, thickness: 1),
          ),
          _buildSummaryRow(
            'ยอดรวมทั้งหมด',
            Helpers.formatPrice(grandTotal),
            isTotal: true,
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple.shade400,
                  Colors.blue.shade400,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _proceedToCheckout(context),
                borderRadius: BorderRadius.circular(16),
                child: const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'ดำเนินการสั่งซื้อ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 12),
                      Icon(Icons.arrow_forward_rounded, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isSubtotal = false,
    bool isShipping = false,
    bool isFree = false,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 15,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? Colors.grey.shade800 : Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 24 : 15,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal
                ? Colors.deepPurple.shade600
                : isFree
                    ? Colors.green.shade600
                    : Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  void _showClearCartDialog(BuildContext context, CartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.warning_rounded, color: Colors.red.shade400),
            ),
            const SizedBox(width: 12),
            const Text('ล้างตะกร้า'),
          ],
        ),
        content: const Text('คุณต้องการล้างสินค้าทั้งหมดในตะกร้าหรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child:
                Text('ยกเลิก', style: TextStyle(color: Colors.grey.shade600)),
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
                  cartProvider.clearCart();
                  Navigator.of(context).pop();
                  Helpers.showSuccessSnackBar(context, 'ล้างตะกร้าแล้ว');
                },
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    'ล้าง',
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

  void _proceedToCheckout(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.isLoggedIn) {
      Helpers.showWarningSnackBar(context, 'กรุณาเข้าสู่ระบบก่อนสั่งซื้อ');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CheckoutScreen(),
      ),
    );
  }
}

class CartItemWidget extends StatelessWidget {
  final CartItem cartItem;

  const CartItemWidget({
    super.key,
    required this.cartItem,
  });

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.deepPurple.shade50,
                    Colors.blue.shade50,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: cartItem.product.image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        cartItem.product.image!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.image_rounded,
                            color: Colors.deepPurple.shade200,
                            size: 40,
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.image_rounded,
                      color: Colors.deepPurple.shade200,
                      size: 40,
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          cartItem.product.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.grey.shade800,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.delete_rounded,
                            color: Colors.red.shade400,
                            size: 20,
                          ),
                          onPressed: () => _showRemoveItemDialog(
                            context,
                            cartItem,
                            cartProvider,
                          ),
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                          tooltip: 'ลบสินค้า',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.deepPurple.shade50,
                          Colors.blue.shade50,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      Helpers.formatPrice(cartItem.product.price),
                      style: TextStyle(
                        color: Colors.deepPurple.shade700,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _buildQuantityButton(
                            icon: Icons.remove_rounded,
                            onPressed: () {
                              if (cartItem.quantity > 1) {
                                cartProvider.updateQuantity(
                                  cartItem.product.id,
                                  cartItem.quantity - 1,
                                );
                              } else {
                                cartProvider.removeItem(cartItem.product.id);
                              }
                            },
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.deepPurple.shade50,
                                  Colors.blue.shade50,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${cartItem.quantity}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.deepPurple.shade700,
                              ),
                            ),
                          ),
                          _buildQuantityButton(
                            icon: Icons.add_rounded,
                            onPressed: () {
                              if (cartItem.quantity < cartItem.product.stock) {
                                cartProvider.updateQuantity(
                                  cartItem.product.id,
                                  cartItem.quantity + 1,
                                );
                              } else {
                                Helpers.showWarningSnackBar(
                                  context,
                                  'สินค้าเหลือไม่เพียงพอ',
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'รวม',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            Helpers.formatPrice(cartItem.totalPrice),
                            style: TextStyle(
                              color: Colors.deepPurple.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple.shade400,
            Colors.blue.shade400,
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Icon(
            icon,
            size: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _showRemoveItemDialog(
    BuildContext context,
    CartItem cartItem,
    CartProvider cartProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.delete_rounded, color: Colors.red.shade400),
            ),
            const SizedBox(width: 12),
            const Text('ลบสินค้า'),
          ],
        ),
        content: Text(
          'คุณต้องการลบ "${cartItem.product.name}" ออกจากตะกร้าหรือไม่?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child:
                Text('ยกเลิก', style: TextStyle(color: Colors.grey.shade600)),
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
                  cartProvider.removeItem(cartItem.product.id);
                  Navigator.of(context).pop();
                  Helpers.showSuccessSnackBar(
                      context, 'ลบสินค้าออกจากตะกร้าแล้ว');
                },
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    'ลบ',
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
}
