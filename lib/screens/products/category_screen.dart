import 'package:flutter/material.dart';
import '../../widgets/product/category_chip.dart';

// ตัวอย่างข้อมูลหมวดหมู่ (ควรดึงจาก API หรือ Provider จริง)
final List<Map<String, dynamic>> categories = [
  {'id': 1, 'name': 'อาหาร'},
  {'id': 2, 'name': 'เครื่องดื่ม'},
  {'id': 3, 'name': 'ของใช้'},
  {'id': 4, 'name': 'งานฝีมือ'},
];

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('หมวดหมู่สินค้า'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: categories.map((cat) {
            return CategoryChip(
              categoryName: cat['name'],
              categoryId: cat['id'],
            );
          }).toList(),
        ),
      ),
    );
  }
}