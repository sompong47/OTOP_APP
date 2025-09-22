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
      appBar: AppBar(
        title: const Text('ตะกร้าสินค้า'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, _) {
              if (cartProvider.items.isNotEmpty) {
                return TextButton(
                  onPressed: () => _showClearCartDialog(context, cartProvider),
                  child: const Text(
                    'ล้างทั้งหมด',
                    style: TextStyle(color: AppConstants.errorColor),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, _) {
          if (cartProvider.isEmpty) {
            return _buildEmptyCart(context);
          }

          return Column(
            children: [
              // Cart Items List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  itemCount: cartProvider.items.length,
                  itemBuilder: (context, index) {
                    final cartItem = cartProvider.items[index];
                    return _buildCartItem(context, cartItem, cartProvider);
                  },
                ),
              ),

              // Cart Summary and Checkout Button
              _buildCartSummary(context, cartProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(
            'ตะกร้าของคุณว่างเปล่า',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            'เริ่มช้อปปิ้งเพื่อเพิ่มสินค้าลงตะกร้า',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to products (assuming it's the second tab)
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
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem cartItem, CartProvider cartProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: cartItem.product.image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                      child: Image.network(
                        cartItem.product.image!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.image, color: Colors.grey);
                        },
                      ),
                    )
                  : const Icon(Icons.image, color: Colors.grey),
            ),

            const SizedBox(width: AppConstants.paddingMedium),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppConstants.fontSizeMedium,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Text(
                    'ราคา: ${Helpers.formatPrice(cartItem.product.price)}',
                    style: TextStyle(
                      color: AppConstants.secondaryColor,
                      fontSize: AppConstants.fontSizeSmall,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Quantity Controls
                      Row(
                        children: [
                          _buildQuantityButton(
                            icon: Icons.remove,
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
                            margin: const EdgeInsets.symmetric(
                              horizontal: AppConstants.paddingSmall,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.paddingMedium,
                              vertical: AppConstants.paddingSmall,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${cartItem.quantity}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: AppConstants.fontSizeMedium,
                              ),
                            ),
                          ),
                          _buildQuantityButton(
                            icon: Icons.add,
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
                      // Remove Button
                      IconButton(
                        icon: const Icon(Icons.delete, color: AppConstants.errorColor),
                        onPressed: () => _showRemoveItemDialog(
                          context,
                          cartItem,
                          cartProvider,
                        ),
                        tooltip: 'ลบสินค้า',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Total Price
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'รวม',
                  style: TextStyle(
                    color: AppConstants.secondaryColor,
                    fontSize: AppConstants.fontSizeSmall,
                  ),
                ),
                Text(
                  Helpers.formatPrice(cartItem.totalPrice),
                  style: TextStyle(
                    color: AppConstants.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: AppConstants.fontSizeMedium,
                  ),
                ),
              ],
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
        border: Border.all(color: AppConstants.primaryColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Icon(
          icon,
          size: 18,
          color: AppConstants.primaryColor,
        ),
      ),
    );
  }

  Widget _buildCartSummary(BuildContext context, CartProvider cartProvider) {
    final shippingFee = Helpers.calculateShippingFee(cartProvider.totalAmount);
    final grandTotal = cartProvider.totalAmount + shippingFee;

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
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
      child: Column(
        children: [
          // Order Summary
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
          if (shippingFee == 0) ...[
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              'ฟรีค่าจัดส่ง เมื่อซื้อครบ ฿1,000',
              style: TextStyle(
                color: AppConstants.successColor,
                fontSize: AppConstants.fontSizeSmall,
              ),
            ),
          ],
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ยอดรวมทั้งหมด:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppConstants.fontSizeLarge,
                ),
              ),
              Text(
                Helpers.formatPrice(grandTotal),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppConstants.fontSizeLarge,
                  color: AppConstants.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          
          // Item Count
          Text(
            '${cartProvider.totalItemsCount} รายการในตะกร้า',
            style: TextStyle(
              color: AppConstants.secondaryColor,
              fontSize: AppConstants.fontSizeSmall,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          // Checkout Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => _proceedToCheckout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
              ),
              child: const Text(
                'ดำเนินการสั่งซื้อ',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
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
        title: const Text('ลบสินค้า'),
        content: Text('คุณต้องการลบ "${cartItem.product.name}" ออกจากตะกร้าหรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              cartProvider.removeItem(cartItem.product.id);
              Navigator.of(context).pop();
              Helpers.showSuccessSnackBar(context, 'ลบสินค้าออกจากตะกร้าแล้ว');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, CartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ล้างตะกร้า'),
        content: const Text('คุณต้องการล้างสินค้าทั้งหมดในตะกร้าหรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              cartProvider.clearCart();
              Navigator.of(context).pop();
              Helpers.showSuccessSnackBar(context, 'ล้างตะกร้าแล้ว');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('ล้าง'),
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