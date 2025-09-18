import 'constants.dart';

class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกอีเมล';
    }
    
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'รูปแบบอีเมลไม่ถูกต้อง';
    }
    
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกรหัสผ่าน';
    }
    
    if (value.length < AppConstants.minPasswordLength) {
      return 'รหัสผ่านต้องมีอย่างน้อย ${AppConstants.minPasswordLength} ตัวอักษร';
    }
    
    if (value.length > AppConstants.maxPasswordLength) {
      return 'รหัสผ่านไม่เกิน ${AppConstants.maxPasswordLength} ตัวอักษร';
    }
    
    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'กรุณายืนยันรหัสผ่าน';
    }
    
    if (value != password) {
      return 'รหัสผ่านไม่ตรงกัน';
    }
    
    return null;
  }

  // Username validation
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกชื่อผู้ใช้';
    }
    
    if (value.length < AppConstants.minUsernameLength) {
      return 'ชื่อผู้ใช้ต้องมีอย่างน้อย ${AppConstants.minUsernameLength} ตัวอักษร';
    }
    
    if (value.length > AppConstants.maxUsernameLength) {
      return 'ชื่อผู้ใช้ไม่เกิน ${AppConstants.maxUsernameLength} ตัวอักษร';
    }
    
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(value)) {
      return 'ชื่อผู้ใช้ใช้ได้เฉพาะตัวอักษร ตัวเลข และ _';
    }
    
    return null;
  }

  // Required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'กรุณากรอก$fieldName';
    }
    return null;
  }

  // Phone number validation
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    
    final phoneRegex = RegExp(r'^[0-9]{10}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'รูปแบบเบอร์โทรไม่ถูกต้อง (10 หลัก)';
    }
    
    return null;
  }

  // Price validation
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกราคา';
    }
    
    final price = double.tryParse(value);
    if (price == null) {
      return 'ราคาต้องเป็นตัวเลข';
    }
    
    if (price <= 0) {
      return 'ราคาต้องมากกว่า 0';
    }
    
    if (price > 999999) {
      return 'ราคาไม่เกิน 999,999';
    }
    
    return null;
  }

  // Stock validation
  static String? validateStock(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกจำนวนสินค้า';
    }
    
    final stock = int.tryParse(value);
    if (stock == null) {
      return 'จำนวนสินค้าต้องเป็นตัวเลข';
    }
    
    if (stock < 0) {
      return 'จำนวนสินค้าต้องไม่น้อยกว่า 0';
    }
    
    if (stock > 999999) {
      return 'จำนวนสินค้าไม่เกิน 999,999';
    }
    
    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกชื่อ';
    }
    
    if (value.trim().length < 2) {
      return 'ชื่อต้องมีอย่างน้อย 2 ตัวอักษร';
    }
    
    if (value.length > 100) {
      return 'ชื่อไม่เกิน 100 ตัวอักษร';
    }
    
    return null;
  }

  // Address validation
  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกที่อยู่';
    }
    
    if (value.trim().length < 10) {
      return 'ที่อยู่ต้องมีอย่างน้อย 10 ตัวอักษร';
    }
    
    if (value.length > 500) {
      return 'ที่อยู่ไม่เกิน 500 ตัวอักษร';
    }
    
    return null;
  }

  // Description validation
  static String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกคำอธิบาย';
    }
    
    if (value.trim().length < 10) {
      return 'คำอธิบายต้องมีอย่างน้อย 10 ตัวอักษร';
    }
    
    if (value.length > 1000) {
      return 'คำอธิบายไม่เกิน 1,000 ตัวอักษร';
    }
    
    return null;
  }

  // Rating validation
  static String? validateRating(int? value) {
    if (value == null) {
      return 'กรุณาเลือกคะแนน';
    }
    
    if (value < 1 || value > 5) {
      return 'คะแนนต้องอยู่ระหว่าง 1-5';
    }
    
    return null;
  }

  // Quantity validation
  static String? validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกจำนวน';
    }
    
    final quantity = int.tryParse(value);
    if (quantity == null) {
      return 'จำนวนต้องเป็นตัวเลข';
    }
    
    if (quantity <= 0) {
      return 'จำนวนต้องมากกว่า 0';
    }
    
    if (quantity > 999) {
      return 'จำนวนไม่เกิน 999';
    }
    
    return null;
  }

  // URL validation
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    
    final urlRegex = RegExp(
      r'^https?:\/\/(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&=]*)$'
    );
    
    if (!urlRegex.hasMatch(value)) {
      return 'รูปแบบ URL ไม่ถูกต้อง';
    }
    
    return null;
  }
}