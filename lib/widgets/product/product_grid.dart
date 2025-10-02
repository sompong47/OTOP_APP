import 'package:flutter/material.dart';
import '../../models/product.dart';
import 'product_card.dart';

class ProductGrid extends StatelessWidget {
  final List<Product> products;

  const ProductGrid({
    Key? key,
    required this.products,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const Center(child: Text('ไม่พบสินค้า'));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // จำนวนคอลัมน์
        childAspectRatio: 0.75, // สัดส่วน card
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(product: products[index]);
      },
    );
  }
}