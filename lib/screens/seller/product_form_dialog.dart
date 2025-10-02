import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/product_service.dart';

class ProductFormDialog extends StatefulWidget {
  final Map<String, dynamic>? product;

  const ProductFormDialog({Key? key, this.product}) : super(key: key);

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  bool _loading = false;

  // Image picker
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  String? _existingImageUrl;

  final ProductService productService = ProductService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?['name'] ?? '');
    _descController = TextEditingController(text: widget.product?['description'] ?? '');
    _priceController = TextEditingController(
      text: widget.product != null ? widget.product!['price'].toString() : '',
    );
    _stockController = TextEditingController(
      text: widget.product?['stock']?.toString() ?? '0',
    );
    
    // เก็บ URL รูปเดิม (ถ้ามี)
    _existingImageUrl = widget.product?['image'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  // เลือกรูปจากแกลเลอรี
  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  // ถ่ายรูป
  Future<void> _pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  // แสดง Bottom Sheet เลือกแหล่งที่มาของรูป
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('เลือกจากแกลเลอรี'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('ถ่ายรูป'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
            if (_imageFile != null || _existingImageUrl != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('ลบรูป', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _imageFile = null;
                    _existingImageUrl = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final data = {
      'name': _nameController.text,
      'description': _descController.text,
      'price': double.tryParse(_priceController.text) ?? 0,
      'stock': int.tryParse(_stockController.text) ?? 0,
    };

    // ถ้ามีรูปใหม่ ต้องส่งเป็น multipart/form-data
    // TODO: ต้องแก้ไข ProductService ให้รองรับการส่งไฟล์
    // สำหรับตอนนี้ ส่งเป็น JSON ก่อน
    if (_imageFile != null) {
      // TODO: อัพโหลดรูปและได้ URL กลับมา
      // data['image'] = imageUrl;
      debugPrint('Image file selected: ${_imageFile!.path}');
      // ⚠️ ต้องแก้ไข ProductService ให้รองรับ multipart upload
    }

    Map<String, dynamic> res;

    if (widget.product == null) {
      res = await productService.createProduct(data);
    } else {
      res = await productService.updateProduct(widget.product!['id'], data);
    }

    setState(() => _loading = false);

    if (res['success']) {
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'เกิดข้อผิดพลาด')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.product == null ? 'สร้างสินค้าใหม่' : 'แก้ไขสินค้า',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Image Preview & Upload
                GestureDetector(
                  onTap: _showImageSourceDialog,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[400]!),
                    ),
                    child: _imageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _imageFile!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          )
                        : _existingImageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  _existingImageUrl!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (_, __, ___) => _buildPlaceholder(),
                                ),
                              )
                            : _buildPlaceholder(),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'แตะเพื่อเลือกรูปภาพสินค้า',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อสินค้า *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.shopping_bag),
                  ),
                  validator: (v) => v!.isEmpty ? 'กรุณากรอกชื่อสินค้า' : null,
                ),
                const SizedBox(height: 12),

                // Description Field
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(
                    labelText: 'คำอธิบาย',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),

                // Price & Stock Row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'ราคา *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
                          suffixText: '฿',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'กรุณากรอกราคา' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _stockController,
                        decoration: const InputDecoration(
                          labelText: 'จำนวนสต็อก',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.inventory),
                          suffixText: 'ชิ้น',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _loading ? null : () => Navigator.of(context).pop(),
                      child: const Text('ยกเลิก'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('บันทึก'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate, size: 64, color: Colors.grey[400]),
        const SizedBox(height: 8),
        Text(
          'เพิ่มรูปสินค้า',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }
}