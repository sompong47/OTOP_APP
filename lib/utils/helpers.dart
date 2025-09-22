import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'constants.dart';

class Helpers {
  // Format price
  static String formatPrice(double price) {
    final formatter = NumberFormat('#,##0.00', 'th_TH');
    return '฿${formatter.format(price)}';
  }

  // Format date
  static String formatDate(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy', 'th_TH');
    return formatter.format(date);
  }

  // Format date time
  static String formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('dd/MM/yyyy HH:mm', 'th_TH');
    return formatter.format(dateTime);
  }

  // Format relative time
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} วันที่แล้ว';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ชั่วโมงที่แล้ว';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} นาทีที่แล้ว';
    } else {
      return 'เมื่อสักครู่';
    }
  }

  // Get order status color
  static Color getOrderStatusColor(String status) {
    return AppConstants.orderStatusColors[status] ?? Colors.grey;
  }

  // Get order status text
  static String getOrderStatusText(String status) {
    return AppConstants.orderStatusThai[status] ?? status;
  }

  // Get payment method text
  static String getPaymentMethodText(String method) {
    return AppConstants.paymentMethodThai[method] ?? method;
  }

  // Show snackbar
  static void showSnackBar(BuildContext context, String message, {
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: textColor ?? Colors.white),
        ),
        backgroundColor: backgroundColor ?? AppConstants.primaryColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      ),
    );
  }

  // Show success snackbar
  static void showSuccessSnackBar(BuildContext context, String message) {
    showSnackBar(
      context,
      message,
      backgroundColor: AppConstants.successColor,
    );
  }

  // Show error snackbar
  static void showErrorSnackBar(BuildContext context, String message) {
    showSnackBar(
      context,
      message,
      backgroundColor: AppConstants.errorColor,
    );
  }

  // Show warning snackbar
  static void showWarningSnackBar(BuildContext context, String message) {
    showSnackBar(
      context,
      message,
      backgroundColor: AppConstants.warningColor,
    );
  }

  // Show loading dialog
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: AppConstants.paddingMedium),
            Text(message ?? 'กำลังโหลด...'),
          ],
        ),
      ),
    );
  }

  // Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  // Show confirmation dialog
  static Future<bool?> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'ยืนยัน',
    String cancelText = 'ยกเลิก',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  // Validate email
  static bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  // Validate phone
  static bool isValidPhone(String phone) {
    return RegExp(r'^[0-9]{10}$').hasMatch(phone);
  }

  // Format phone number
  static String formatPhoneNumber(String phone) {
    if (phone.length == 10) {
      return '${phone.substring(0, 3)}-${phone.substring(3, 6)}-${phone.substring(6)}';
    }
    return phone;
  }

  // Get file size in MB
  static double getFileSizeInMB(int bytes) {
    return bytes / (1024 * 1024);
  }

  // Truncate text
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // Generate order number
  static String generateOrderNumber() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch.toString().substring(8);
    return 'ORD$timestamp';
  }

  // Calculate shipping fee
  static double calculateShippingFee(double totalAmount) {
    if (totalAmount >= 1000) return 0; // Free shipping
    return 50; // Standard shipping fee
  }

  // Get image placeholder
  static String getImagePlaceholder() {
    return AppConstants.placeholderImage;
  }

  // ===== IMAGE HELPER FUNCTIONS =====
  
  // Get full image URL
  static String? getFullImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return null;
    
    // ถ้า URL เป็น full URL แล้ว ให้ return ตรงๆ
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    
    // ถ้าเป็น relative path ให้เพิ่ม base URL
    // เปลี่ยน IP นี้ตามการใช้งาน:
    // - Android Emulator: 10.0.2.2
    // - iOS Simulator: localhost
    // - Physical Device: IP ของเครื่อง server
    const String baseUrl = 'http://10.0.2.2:8000'; // เปลี่ยนตามจริง
    
    // ลบ slash ที่ซ้ำ
    String cleanPath = imageUrl.startsWith('/') ? imageUrl : '/$imageUrl';
    return '$baseUrl$cleanPath';
  }
  
  // Log image URL for debugging
  static void logImageUrl(String? originalUrl, String? processedUrl) {
    debugPrint('📸 Original image URL: $originalUrl');
    debugPrint('📸 Processed image URL: $processedUrl');
  }
}

// Widget สำหรับแสดงรูป product
class ProductImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  
  const ProductImage({
    Key? key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final String? fullUrl = Helpers.getFullImageUrl(imageUrl);
    
    // Debug logging
    Helpers.logImageUrl(imageUrl, fullUrl);
    
    if (fullUrl == null) {
      return _buildPlaceholder();
    }
    
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Image.network(
        fullUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoading();
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint('❌ Error loading image: $fullUrl');
          debugPrint('❌ Error details: $error');
          return _buildPlaceholder();
        },
      ),
    );
  }
  
  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: borderRadius,
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported,
            size: 40,
            color: Colors.grey,
          ),
          SizedBox(height: 4),
          Text(
            'ไม่มีรูป',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLoading() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: borderRadius,
      ),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}