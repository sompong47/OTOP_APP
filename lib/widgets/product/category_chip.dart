import 'package:flutter/material.dart';
import '../../screens/products/products_by_category_screen.dart';

class CategoryChip extends StatelessWidget {
  final String categoryName;
  final int categoryId;

  const CategoryChip({
    Key? key,
    required this.categoryName,
    required this.categoryId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(categoryName),
      backgroundColor: Colors.orange[100],
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductsByCategoryScreen(
              categoryId: categoryId,
              categoryName: categoryName,
            ),
          ),
        );
      },
    );
  }
}