import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NetworkImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const NetworkImageWidget({
    Key? key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ถ้าไม่มี URL หรือ URL เป็น null/empty
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildErrorWidget();
    }

    // แก้ไข URL สำหรับ Android Emulator
    String processedUrl = _processImageUrl(imageUrl!);
    
    debugPrint('📸 Original image URL: $imageUrl');
    debugPrint('📸 Processed image URL: $processedUrl');

    Widget imageWidget = CachedNetworkImage(
      imageUrl: processedUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => placeholder ?? _buildPlaceholder(),
      errorWidget: (context, url, error) {
        debugPrint('❌ Error loading image: $url');
        debugPrint('❌ Error details: $error');
        return errorWidget ?? _buildErrorWidget();
      },
      httpHeaders: {
        // เพิ่ม headers ถ้าจำเป็น
        'User-Agent': 'Flutter App',
      },
    );

    // ถ้ามี borderRadius ให้ wrap ด้วย ClipRRect
    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  String _processImageUrl(String url) {
    // ตรวจสอบว่าเป็น URL ที่สมบูรณ์หรือไม่
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    
    // ถ้าเป็น relative path ให้เพิ่ม base URL
    // สำหรับ Android Emulator
    if (url.startsWith('/media/')) {
      return 'http://10.0.2.2:8000$url';
    }
    
    // ถ้าไม่ขึ้นต้นด้วย /media/ ให้เพิ่มให้
    if (!url.startsWith('/')) {
      url = '/media/$url';
    }
    
    return 'http://10.0.2.2:8000$url';
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: borderRadius,
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            SizedBox(height: 8),
            Text(
              'กำลังโหลด...',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: borderRadius,
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 32,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              'ไม่สามารถโหลดรูปได้',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Widget สำหรับแสดงรูปสินค้าเฉพาะ
class ProductImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final bool showBorder;

  const ProductImageWidget({
    Key? key,
    this.imageUrl,
    this.width = 120,
    this.height = 120,
    this.showBorder = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NetworkImageWidget(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(8),
      placeholder: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: showBorder ? Border.all(color: Colors.grey[300]!) : null,
        ),
        child: const Center(
          child: Icon(
            Icons.shopping_bag_outlined,
            size: 32,
            color: Colors.grey,
          ),
        ),
      ),
      errorWidget: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: showBorder ? Border.all(color: Colors.grey[300]!) : null,
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 28,
                color: Colors.grey,
              ),
              SizedBox(height: 4),
              Text(
                'ไม่มีรูป',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}