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
        // ลอง fallback เป็น placeholder image หรือ default asset
        return _buildFallbackWidget();
      },
      httpHeaders: {
        'User-Agent': 'Flutter App',
        'Accept': 'image/*',
      },
      // เพิ่ม timeout
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 300),
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
    // สำหรับ Android Emulator (10.0.2.2)
    // สำหรับ iOS Simulator หรือ Real Device ใช้ IP จริงของเครื่อง
    String baseUrl = 'http://10.0.2.2:8000';
    
    if (url.startsWith('/media/')) {
      return '$baseUrl$url';
    }
    
    // ถ้าไม่ขึ้นต้นด้วย /media/ ให้เพิ่มให้
    if (!url.startsWith('/')) {
      url = '/media/products/$url';
    }
    
    return '$baseUrl$url';
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

  // Widget สำหรับกรณีที่ load รูปไม่ได้ แต่ยังแสดงข้อมูลได้
  Widget _buildFallbackWidget() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.blue[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: borderRadius,
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: width != null && width! > 100 ? 40 : 24,
              color: Colors.blue[300],
            ),
            const SizedBox(height: 4),
            Text(
              'รูปสินค้า',
              style: TextStyle(
                fontSize: width != null && width! > 100 ? 12 : 10,
                color: Colors.blue[600],
                fontWeight: FontWeight.w500,
              ),
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
          gradient: LinearGradient(
            colors: [Colors.grey[100]!, Colors.grey[200]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
          border: showBorder ? Border.all(color: Colors.grey[300]!) : null,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_outlined,
                size: width! > 100 ? 32 : 24,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 4),
              Text(
                'กำลังโหลด...',
                style: TextStyle(
                  fontSize: width! > 100 ? 10 : 8,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
      errorWidget: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange[50]!, Colors.orange[100]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
          border: showBorder ? Border.all(color: Colors.orange[200]!) : null,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: width! > 100 ? 28 : 20,
                color: Colors.orange[400],
              ),
              const SizedBox(height: 2),
              Text(
                'สินค้า OTOP',
                style: TextStyle(
                  fontSize: width! > 100 ? 10 : 8,
                  color: Colors.orange[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget สำหรับ Avatar หรือ Profile Image
class AvatarImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final String fallbackText;

  const AvatarImageWidget({
    Key? key,
    this.imageUrl,
    this.size = 40,
    this.fallbackText = '?',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildFallbackAvatar();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 2),
      child: NetworkImageWidget(
        imageUrl: imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorWidget: _buildFallbackAvatar(),
      ),
    );
  }

  Widget _buildFallbackAvatar() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          fallbackText.isNotEmpty ? fallbackText.substring(0, 1).toUpperCase() : '?',
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}