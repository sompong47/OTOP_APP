import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
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
      appBar: AppBar(
        title: const Text('จัดการสินค้า'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'all',
                child: Text('ทั้งหมด'),
              ),
              PopupMenuItem(
                value: 'active',
                child: Text('เปิดขาย'),
              ),
              PopupMenuItem(
                value: 'inactive',
                child: Text('ปิดขาย'),
              ),
              PopupMenuItem(
                value: 'low_stock',
                child: Text('สินค้าใกล้หมด'),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProductDialog(context),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('เพิ่มสินค้า'),
      ),
      body: Column(
        children: [
          // Stats Summary
          _buildStatsSummary(),
          
          // Products List
          Expanded(
            child: _buildProductsList(),
          ),
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
              color: AppConstants.primaryColor,
              icon: Icons.inventory,
            ),
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: _buildStatCard(
              title: 'เปิดขาย',
              value: '20',
              color: AppConstants.successColor,
              icon: Icons.visibility,
            ),
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: _buildStatCard(
              title: 'ใกล้หมด',
              value: '5',
              color: AppConstants.warningColor,
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
    required Color color,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              value,
              style: TextStyle(
                fontSize: AppConstants.fontSizeLarge,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: AppConstants.fontSizeSmall,
                color: AppConstants.secondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsList() {
    // Mock data for demonstration
    final products = _getMockProducts();
    final filteredProducts = _filterProducts(products);

    if (filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: Colors.grey,
            ),
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
              style: TextStyle(
                color: AppConstants.secondaryColor,
              ),
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
        itemBuilder: (context, index) {
          final product = filteredProducts[index];
          return _buildProductCard(product);
        },
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final isActive = product['is_active'] as bool;
    final stock = product['stock'] as int;
    final isLowStock = stock < 10;

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
              child: const Icon(Icons.image, color: Colors.grey),
            ),
            
            const SizedBox(width: AppConstants.paddingMedium),
            
            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          horizontal: AppConstants.paddingSmall,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isActive 
                              ? AppConstants.successColor.withOpacity(0.1)
                              : AppConstants.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                        ),
                        child: Text(
                          isActive ? 'เปิดขาย' : 'ปิดขาย',
                          style: TextStyle(
                            color: isActive 
                                ? AppConstants.successColor
                                : AppConstants.errorColor,
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
                    style: TextStyle(
                      color: AppConstants.primaryColor,
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
                              ? AppConstants.warningColor
                              : AppConstants.secondaryColor,
                          fontWeight: isLowStock ? FontWeight.bold : null,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () => _showEditProductDialog(context, product),
                            tooltip: 'แก้ไข',
                            color: AppConstants.primaryColor,
                          ),
                          IconButton(
                            icon: Icon(
                              isActive ? Icons.visibility_off : Icons.visibility,
                              size: 20,
                            ),
                            onPressed: () => _toggleProductStatus(product),
                            tooltip: isActive ? 'ปิดขาย' : 'เปิดขาย',
                            color: isActive 
                                ? AppConstants.warningColor
                                : AppConstants.successColor,
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 20),
                            onPressed: () => _showDeleteConfirmation(context, product),
                            tooltip: 'ลบ',
                            color: AppConstants.errorColor,
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
        'category': 'ผ้าไหม',
      },
      {
        'id': 2,
        'name': 'เครื่องปั้นดินเผาลายไทย',
        'price': 850.0,
        'stock': 3,
        'is_active': true,
        'category': 'เครื่องปั้น',
      },
      {
        'id': 3,
        'name': 'ตะกร้าไม้ไผ่สานมือ',
        'price': 250.0,
        'stock': 25,
        'is_active': false,
        'category': 'ของใช้ไม้ไผ่',
      },
    ];
  }

  List<Map<String, dynamic>> _filterProducts(List<Map<String, dynamic>> products) {
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
    // TODO: Implement product refresh
    await Future.delayed(const Duration(seconds: 2));
  }

  void _showAddProductDialog(BuildContext context) {
    _showProductDialog(context, null);
  }

  void _showEditProductDialog(BuildContext context, Map<String, dynamic> product) {
    _showProductDialog(context, product);
  }

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
          if (isEdit) {
            _updateProduct(productData);
          } else {
            _addProduct(productData);
          }
        },
      ),
    );
  }

  void _toggleProductStatus(Map<String, dynamic> product) {
    final isActive = product['is_active'] as bool;
    final newStatus = !isActive;
    
    // TODO: Implement API call to update product status
    setState(() {
      product['is_active'] = newStatus;
    });
    
    Helpers.showSuccessSnackBar(
      context,
      newStatus ? 'เปิดขายสินค้าแล้ว' : 'ปิดขายสินค้าแล้ว',
    );
  }

  void _showDeleteConfirmation(BuildContext context, Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text('คุณต้องการลบสินค้า "${product['name']}" หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteProduct(product);
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

  void _addProduct(Map<String, dynamic> productData) {
    // TODO: Implement API call to add product
    Helpers.showSuccessSnackBar(context, 'เพิ่มสินค้าสำเร็จ');
  }

  void _updateProduct(Map<String, dynamic> productData) {
    // TODO: Implement API call to update product
    Helpers.showSuccessSnackBar(context, 'แก้ไขสินค้าสำเร็จ');
  }

  void _deleteProduct(Map<String, dynamic> product) {
    // TODO: Implement API call to delete product
    Helpers.showSuccessSnackBar(context, 'ลบสินค้าสำเร็จ');
  }
}

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
                    labelText: 'ชื่อสินค้า',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => Validators.validateRequired(value, 'ชื่อสินค้า'),
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'ราคา (บาท)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: Validators.validatePrice,
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                
                TextFormField(
                  controller: _stockController,
                  decoration: const InputDecoration(
                    labelText: 'จำนวน (ชิ้น)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: Validators.validateStock,
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'หมวดหมู่',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'ผ้าไหม', child: Text('ผ้าไหม')),
                    DropdownMenuItem(value: 'เครื่องปั้น', child: Text('เครื่องปั้นดินเผา')),
                    DropdownMenuItem(value: 'ของใช้ไม้ไผ่', child: Text('ของใช้ไม้ไผ่')),
                    DropdownMenuItem(value: 'อาหาร', child: Text('อาหารพื้นเมือง')),
                    DropdownMenuItem(value: 'อื่นๆ', child: Text('อื่นๆ')),
                  ],
                  onChanged: (value) => setState(() => _selectedCategory = value!),
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'รายละเอียดสินค้า',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: Validators.validateDescription,
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                
                SwitchListTile(
                  title: const Text('เปิดขาย'),
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value),
                  activeColor: AppConstants.primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('ยกเลิก'),
        ),
        ElevatedButton(
          onPressed: _saveProduct,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('บันทึก'),
        ),
      ],
    );
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      final productData = {
        'name': _nameController.text.trim(),
        'price': double.parse(_priceController.text),
        'stock': int.parse(_stockController.text),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'is_active': _isActive,
      };
      
      widget.onSave(productData);
    }
  }
}