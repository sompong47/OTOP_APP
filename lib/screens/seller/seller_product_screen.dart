import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../utils/validators.dart';

class SellerProductScreen extends StatefulWidget {
  const SellerProductScreen({super.key});

  @override
  State<SellerProductScreen> createState() => _SellerProductScreenState();
}

class _SellerProductScreenState extends State<SellerProductScreen> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    // TODO: Load seller products
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        title: const Text('จัดการสินค้า'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7B1FA2), Color(0xFF3949AB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'all', child: Text('ทั้งหมด')),
              PopupMenuItem(value: 'active', child: Text('เปิดขาย')),
              PopupMenuItem(value: 'inactive', child: Text('ปิดขาย')),
              PopupMenuItem(value: 'low_stock', child: Text('สินค้าใกล้หมด')),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProductDialog(context),
        backgroundColor: const Color(0xFF7B1FA2),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('เพิ่มสินค้า'),
      ),
      body: Column(
        children: [
          _buildStatsSummary(),
          Expanded(child: _buildProductsList()),
        ],
      ),
    );
  }

  Widget _buildStatsSummary() {
    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: 'สินค้าทั้งหมด',
              value: '25',
              color1: const Color(0xFF7B1FA2),
              color2: const Color(0xFF9C27B0),
              icon: Icons.inventory,
            ),
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: _buildStatCard(
              title: 'เปิดขาย',
              value: '20',
              color1: const Color(0xFF43A047),
              color2: const Color(0xFF66BB6A),
              icon: Icons.visibility,
            ),
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: _buildStatCard(
              title: 'ใกล้หมด',
              value: '5',
              color1: const Color(0xFFFFA000),
              color2: const Color(0xFFFFB74D),
              icon: Icons.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color1,
    required Color color2,
    required IconData icon,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [color1.withOpacity(0.85), color2.withOpacity(0.85)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: AppConstants.fontSizeLarge,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: AppConstants.fontSizeSmall,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsList() {
    final products = _getMockProducts();
    final filteredProducts = _filterProducts(products);

    if (filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2_outlined,
                size: 80, color: Colors.grey),
            const SizedBox(height: AppConstants.paddingMedium),
            const Text(
              'ยังไม่มีสินค้า',
              style: TextStyle(
                fontSize: AppConstants.fontSizeLarge,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              'เริ่มเพิ่มสินค้าแรกของคุณ',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshProducts,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        itemCount: filteredProducts.length,
        itemBuilder: (context, index) =>
            _buildProductCard(filteredProducts[index]),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final isActive = product['is_active'] as bool;
    final stock = product['stock'] as int;
    final isLowStock = stock < 10;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              child: const Icon(Icons.image, color: Colors.grey),
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: AppConstants.fontSizeMedium,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFF43A047).withOpacity(0.1)
                              : const Color(0xFFD32F2F).withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(AppConstants.borderRadius),
                        ),
                        child: Text(
                          isActive ? 'เปิดขาย' : 'ปิดขาย',
                          style: TextStyle(
                            color: isActive
                                ? const Color(0xFF43A047)
                                : const Color(0xFFD32F2F),
                            fontSize: AppConstants.fontSizeSmall,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Text(
                    Helpers.formatPrice(product['price']),
                    style: const TextStyle(
                      color: Color(0xFF7B1FA2),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'คงเหลือ: $stock ชิ้น',
                        style: TextStyle(
                          color: isLowStock
                              ? const Color(0xFFFFA000)
                              : Colors.grey[700],
                          fontWeight: isLowStock ? FontWeight.bold : null,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () =>
                                _showEditProductDialog(context, product),
                            tooltip: 'แก้ไข',
                            color: const Color(0xFF7B1FA2),
                          ),
                          IconButton(
                            icon: Icon(
                                isActive
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                size: 20),
                            onPressed: () => _toggleProductStatus(product),
                            tooltip: isActive ? 'ปิดขาย' : 'เปิดขาย',
                            color: isActive
                                ? const Color(0xFFFFA000)
                                : const Color(0xFF43A047),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 20),
                            onPressed: () =>
                                _showDeleteConfirmation(context, product),
                            tooltip: 'ลบ',
                            color: const Color(0xFFD32F2F),
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

  List<Map<String, dynamic>> _getMockProducts() {
    return [
      {
        'id': 1,
        'name': 'ผ้าไหมไทยสีทอง',
        'price': 1500.0,
        'stock': 15,
        'is_active': true,
        'category': 'ผ้าไหม'
      },
      {
        'id': 2,
        'name': 'เครื่องปั้นดินเผาลายไทย',
        'price': 850.0,
        'stock': 3,
        'is_active': true,
        'category': 'เครื่องปั้น'
      },
      {
        'id': 3,
        'name': 'ตะกร้าไม้ไผ่สานมือ',
        'price': 250.0,
        'stock': 25,
        'is_active': false,
        'category': 'ของใช้ไม้ไผ่'
      },
    ];
  }

  List<Map<String, dynamic>> _filterProducts(
      List<Map<String, dynamic>> products) {
    switch (_selectedFilter) {
      case 'active':
        return products.where((p) => p['is_active'] == true).toList();
      case 'inactive':
        return products.where((p) => p['is_active'] == false).toList();
      case 'low_stock':
        return products.where((p) => p['stock'] < 10).toList();
      default:
        return products;
    }
  }

  Future<void> _refreshProducts() async {
    await Future.delayed(const Duration(seconds: 2));
  }

  void _showAddProductDialog(BuildContext context) =>
      _showProductDialog(context, null);
  void _showEditProductDialog(
          BuildContext context, Map<String, dynamic> product) =>
      _showProductDialog(context, product);

  void _showProductDialog(BuildContext context, Map<String, dynamic>? product) {
    final isEdit = product != null;
    final titleText = isEdit ? 'แก้ไขสินค้า' : 'เพิ่มสินค้า';
    showDialog(
      context: context,
      builder: (context) => ProductFormDialog(
        title: titleText,
        product: product,
        onSave: (productData) {
          Navigator.of(context).pop();
          if (isEdit)
            _updateProduct(productData);
          else
            _addProduct(productData);
        },
      ),
    );
  }

  void _toggleProductStatus(Map<String, dynamic> product) {
    final isActive = product['is_active'] as bool;
    setState(() => product['is_active'] = !isActive);
    Helpers.showSuccessSnackBar(
        context, isActive ? 'ปิดขายสินค้าแล้ว' : 'เปิดขายสินค้าแล้ว');
  }

  void _showDeleteConfirmation(
      BuildContext context, Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text('คุณต้องการลบสินค้า "${product['name']}" หรือไม่?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ยกเลิก')),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteProduct(product);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
  }

  void _addProduct(Map<String, dynamic> productData) =>
      Helpers.showSuccessSnackBar(context, 'เพิ่มสินค้าสำเร็จ');
  void _updateProduct(Map<String, dynamic> productData) =>
      Helpers.showSuccessSnackBar(context, 'แก้ไขสินค้าสำเร็จ');
  void _deleteProduct(Map<String, dynamic> product) =>
      Helpers.showSuccessSnackBar(context, 'ลบสินค้าสำเร็จ');
}

class ProductFormDialog extends StatefulWidget {
  final String title;
  final Map<String, dynamic>? product;
  final Function(Map<String, dynamic>) onSave;

  const ProductFormDialog(
      {super.key, required this.title, this.product, required this.onSave});

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'ผ้าไหม';
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!['name'];
      _priceController.text = widget.product!['price'].toString();
      _stockController.text = widget.product!['stock'].toString();
      _descriptionController.text = widget.product!['description'] ?? '';
      _selectedCategory = widget.product!['category'];
      _isActive = widget.product!['is_active'];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                      labelText: 'ชื่อสินค้า', border: OutlineInputBorder()),
                  validator: (value) =>
                      Validators.validateRequired(value, 'ชื่อสินค้า'),
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                      labelText: 'ราคา (บาท)', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  validator: Validators.validatePrice,
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                TextFormField(
                  controller: _stockController,
                  decoration: const InputDecoration(
                      labelText: 'จำนวน (ชิ้น)', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  validator: Validators.validateStock,
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                      labelText: 'หมวดหมู่', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'ผ้าไหม', child: Text('ผ้าไหม')),
                    DropdownMenuItem(
                        value: 'เครื่องปั้น', child: Text('เครื่องปั้น')),
                    DropdownMenuItem(
                        value: 'ของใช้ไม้ไผ่', child: Text('ของใช้ไม้ไผ่')),
                  ],
                  onChanged: (value) =>
                      setState(() => _selectedCategory = value!),
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                SwitchListTile(
                  title: const Text('เปิดขาย'),
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ยกเลิก')),
        ElevatedButton(
          onPressed: _saveForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7B1FA2),
            foregroundColor: Colors.white,
          ),
          child: const Text('บันทึก'),
        ),
      ],
    );
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final productData = {
        'name': _nameController.text,
        'price': double.tryParse(_priceController.text) ?? 0,
        'stock': int.tryParse(_stockController.text) ?? 0,
        'category': _selectedCategory,
        'is_active': _isActive,
        'description': _descriptionController.text,
      };
      widget.onSave(productData);
    }
  }
}
