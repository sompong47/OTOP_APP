import 'package:flutter/material.dart';

class AppConstants {
  // Colors
  static const Color primaryColor = Color(0xFF2563EB);
  static const Color secondaryColor = Color(0xFF64748B);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);

  // Sizes
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingExtraLarge = 32.0;

  static const double borderRadius = 8.0;
  static const double borderRadiusLarge = 16.0;

  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;

  // Typography
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeExtraLarge = 18.0;
  static const double fontSizeHeading = 24.0;

  // Animation Durations
  static const Duration animationDurationShort = Duration(milliseconds: 200);
  static const Duration animationDurationMedium = Duration(milliseconds: 300);
  static const Duration animationDurationLong = Duration(milliseconds: 500);

  // Order Status
  static const Map<String, String> orderStatusThai = {
    'pending': 'รอดำเนินการ',
    'confirmed': 'ยืนยันแล้ว',
    'shipped': 'จัดส่งแล้ว',
    'delivered': 'ส่งถึงแล้ว',
    'cancelled': 'ยกเลิก',
  };

  static const Map<String, Color> orderStatusColors = {
    'pending': Color(0xFFF59E0B),
    'confirmed': Color(0xFF3B82F6),
    'shipped': Color(0xFF8B5CF6),
    'delivered': Color(0xFF10B981),
    'cancelled': Color(0xFFEF4444),
  };

  // Payment Methods
  static const Map<String, String> paymentMethodThai = {
    'transfer': 'โอนเงิน',
    'cod': 'เก็บเงินปลายทาง',
  };

  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;

  // API Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 5);

  // Image
  static const String placeholderImage = 'https://via.placeholder.com/150x150?text=No+Image';
  static const double maxImageSize = 2.0; // MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];

  // Pagination
  static const int defaultPageSize = 10;
  static const int maxPageSize = 50;
}