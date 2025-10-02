import 'package:flutter/material.dart';
import '../../services/product_service.dart';
import 'product_form_dialog.dart';

class SellerProductScreen extends StatefulWidget {
  const SellerProductScreen({Key? key}) : super(key: key);

  @override
  State<SellerProductScreen> createState() => _SellerProductScreenState();
}

class _SellerProductScreenState extends State<SellerProductScreen> {
  List<Map<String, dynamic>> products = []; // เปลี่ยนเป็น List<Map<String, dynamic>>
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _loading = true);
    
    try {
      final res = await ProductService().getSellerProducts();
      
      if (res['success']) {
        final data = res['data'];
        
        // ตรวจสอบว่า data เป็น format ไหน
        if (data is Map<String, dynamic> && data.containsKey('results')) {
          // Paginated response format
          setState(() {
            products = List<Map<String, dynamic>>.from(data['results']);
          });
          debugPrint('Loaded ${products.length} products (paginated)');
        } else if (data is List) {
          // Direct array response
          setState(() {
            products = List<Map<String, dynamic>>.from(data);
          });
          debugPrint('Loaded ${products.length} products (direct list)');
        } else {
          // Unknown format
          debugPrint('Unknown data format: ${data.runtimeType}');
          setState(() => products = []);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'เกิดข้อผิดพลาด'))
        );
      }
    } catch (e) {
      debugPrint('Error loading products: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e'))
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _openFormDialog([Map<String, dynamic>? product]) async {
    final refresh = await showDialog(
      context: context,
      builder: (_) => ProductFormDialog(product: product),
    );
    if (refresh == true) _loadProducts();
  }

  Future<void> _deleteProduct(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: const Text('คุณต้องการลบสินค้านี้หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final res = await ProductService().deleteProduct(id);
      if (res['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ลบสินค้าสำเร็จ'))
        );
        _loadProducts();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'เกิดข้อผิดพลาด'))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สินค้าของฉัน'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openFormDialog(),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'ยังไม่มีสินค้า',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (_, index) {
                    final p = products[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        leading: p['image'] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.network(
                                  p['image'],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => 
                                    const Icon(Icons.image_not_supported),
                                ),
                              )
                            : const Icon(Icons.image),
                        title: Text(
                          p['name'] ?? 'ไม่มีชื่อ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('฿${p['price'] ?? 0}'),
                            if (p['stock'] != null)
                              Text(
                                'คงเหลือ: ${p['stock']} ชิ้น',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: (p['stock'] ?? 0) < 10 
                                    ? Colors.red 
                                    : Colors.grey,
                                ),
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _openFormDialog(p),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteProduct(p['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}