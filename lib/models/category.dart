import 'package:flutter/material.dart';
import '../../widgets/product/category_chip.dart';

// ประกาศ class Category ถ้ายังไม่มี
class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});
}

// ตัวอย่างข้อมูลหมวดหมู่ (ควรดึงจาก Provider หรือ API จริง)
final List<Category> categories = [
  Category(id: 1, name: 'อาหาร'),
  Category(id: 2, name: 'เครื่องดื่ม'),
  Category(id: 3, name: 'ของใช้'),
  Category(id: 4, name: 'งานฝีมือ'),
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
              categoryName: cat.name,
              categoryId: cat.id,
            );
          }).toList(),
        ),
      ),
    );
  }
}