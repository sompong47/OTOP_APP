import 'package:flutter/material.dart';
import '../../services/product_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../utils/validators.dart';

class ProductFormDialog extends StatefulWidget {
  final String title;
  final Map<String, dynamic>? product;
  final Function(Map<String, dynamic>) onSave;

  const ProductFormDialog({
    super.key,
    required this.title,
    this.product,
    required this.onSave,
  });

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  // โค้ดทั้งหมดของ ProductFormDialog ที่ผมส่งให้ก่อนหน้านี้
}
