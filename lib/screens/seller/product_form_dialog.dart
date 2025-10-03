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
  bool _loadingCategories = true;

  // Categories
  List<Map<String, dynamic>> _categories = [];
  int? _selectedCategoryId;

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
    
    _existingImageUrl = widget.product?['image'];
    
    // ✅ โหลด categories
    _loadCategories();
  }

  // ✅ โหลดรายการหมวดหมู่
  Future<void> _loadCategories() async {
    setState(() => _loadingCategories = true);
    
    try {
      final result = await productService.getCategories();
      
      if (result['success']) {
        final data = result['data'];
        List<Map<String, dynamic>> categoryList = [];
        
        if (data is Map && data.containsKey('results')) {
          categoryList = List<Map<String, dynamic>>.from(data['results']);
        } else if (data is List) {
          categoryList = List<Map<String, dynamic>>.from(data);
        }
        
        setState(() {
          _categories = categoryList;
          
          // ถ้าเป็นการแก้ไข ให้หา category ID จากชื่อ
          if (widget.product != null && widget.product!['category'] != null) {
            final categoryName = widget.product!['category'];
            final category = _categories.firstWhere(
              (cat) => cat['name'] == categoryName,
              orElse: () => {},
            );
            if (category.isNotEmpty) {
              _selectedCategoryId = category['id'];
            }
          }
          
          _loadingCategories = false;
        });
        
        debugPrint('✅ Loaded ${_categories.length} categories');
      } else {
        setState(() => _loadingCategories = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ไม่สามารถโหลดหมวดหมู่: ${result['message']}')),
          );
        }
      }
    } catch (e) {
      setState(() => _loadingCategories = false);
      debugPrint('❌ Error loading categories: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

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

    // ✅ ตรวจสอบว่าเลือก category แล้วหรือยัง
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเลือกหมวดหมู่สินค้า')),
      );
      return;
    }

    setState(() => _loading = true);

    // ✅ สร้าง data object พร้อม type ที่ถูกต้อง
    final data = <String, dynamic>{
      'name': _nameController.text.trim(),
      'description': _descController.text.trim(),
      'price': double.tryParse(_priceController.text) ?? 0.0,
      'stock': int.tryParse(_stockController.text) ?? 0,
      'category': _selectedCategoryId!, // ✅ ส่ง category ID (int)
      'is_active': true, // ✅ เพิ่ม is_active
    };

    // ✅ ถ้ามีรูปใหม่ ให้ใส่ File object
    if (_imageFile != null) {
      data['image'] = _imageFile;
      debugPrint('📸 Image file selected: ${_imageFile!.path}');
    }

    debugPrint('📤 Submitting product data: ${data.entries.where((e) => e.key != 'image').map((e) => '${e.key}: ${e.value}').join(', ')}');

    Map<String, dynamic> res;

    try {
      if (widget.product == null) {
        // สร้างสินค้าใหม่
        res = await productService.createProduct(data);
      } else {
        // แก้ไขสินค้า
        res = await productService.updateProduct(widget.product!['id'], data);
      }

      setState(() => _loading = false);

      if (res['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.product == null ? 'เพิ่มสินค้าสำเร็จ' : 'แก้ไขสินค้าสำเร็จ'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true); // ส่ง true เพื่อ refresh
        }
      } else {
        if (mounted) {
          // แสดง error message ที่ละเอียด
          String errorMsg = 'เกิดข้อผิดพลาด';
          if (res['message'] != null) {
            errorMsg = res['message'].toString();
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
          
          debugPrint('❌ Error response: $errorMsg');
        }
      }
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      debugPrint('❌ Submit error: $e');
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
                  validator: (v) => v == null || v.trim().isEmpty ? 'กรุณากรอกชื่อสินค้า' : null,
                ),
                const SizedBox(height: 12),

                // ✅ Category Dropdown
                if (_loadingCategories)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else
                  DropdownButtonFormField<int>(
                    value: _selectedCategoryId,
                    decoration: const InputDecoration(
                      labelText: 'หมวดหมู่ *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    hint: const Text('เลือกหมวดหมู่สินค้า'),
                    items: _categories.map((category) {
                      return DropdownMenuItem<int>(
                        value: category['id'],
                        child: Text(category['name'] ?? 'ไม่มีชื่อ'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                      });
                    },
                    validator: (value) => value == null ? 'กรุณาเลือกหมวดหมู่' : null,
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
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'กรุณากรอกราคา';
                          final price = double.tryParse(v);
                          if (price == null || price <= 0) return 'ราคาต้องมากกว่า 0';
                          return null;
                        },
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
                        validator: (v) {
                          if (v == null || v.isEmpty) return null;
                          final stock = int.tryParse(v);
                          if (stock == null || stock < 0) return 'จำนวนต้องไม่ติดลบ';
                          return null;
                        },
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