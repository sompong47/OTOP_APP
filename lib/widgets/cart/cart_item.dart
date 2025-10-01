import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/cart_item.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem cartItem;

  const CartItemWidget({super.key, required this.cartItem});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // รูปสินค้า
            Image.network(
              cartItem.product.imageUrl ?? '',
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (, _, _) => const Icon(Icons.image_not_supported),
            ),
            const SizedBox(width: 12),
            // ข้อมูลสินค้า
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cartItem.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('฿${cartItem.product.price.toStringAsFixed(2)}'),
                  if (cartItem.variant != null)
                    Text('ตัวเลือก: ${cartItem.variant}'),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => cartProvider.decreaseQuantity(cartItem),
                      ),
                      Text('${cartItem.quantity}'),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => cartProvider.increaseQuantity(cartItem),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // ปุ่มลบ
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => cartProvider.removeItem(cartItem),
            ),
          ],
        ),
      ),
    );
  }
}