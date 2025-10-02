import 'package:flutter/material.dart';

class CheckoutForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController addressController;
  final TextEditingController districtController;
  final TextEditingController provinceController;
  final TextEditingController postalCodeController;
  final GlobalKey<FormState> formKey;

  const CheckoutForm({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    required this.addressController,
    required this.districtController,
    required this.provinceController,
    required this.postalCodeController,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ข้อมูลผู้รับ', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 😎,
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'ชื่อ-นามสกุล'),
            validator: (value) => value == null || value.isEmpty ? 'กรุณากรอกชื่อ' : null,
          ),
          TextFormField(
            controller: phoneController,
            decoration: const InputDecoration(labelText: 'เบอร์โทรศัพท์'),
            keyboardType: TextInputType.phone,
            validator: (value) => value == null || value.isEmpty ? 'กรุณากรอกเบอร์โทรศัพท์' : null,
          ),
          TextFormField(
            controller: emailController,
            decoration: const InputDecoration(labelText: 'อีเมล (ถ้ามี)'),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          Text('ที่อยู่จัดส่ง', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 😎,
          TextFormField(
            controller: addressController,
            decoration: const InputDecoration(labelText: 'ที่อยู่'),
            validator: (value) => value == null || value.isEmpty ? 'กรุณากรอกที่อยู่' : null,
          ),
          TextFormField(
            controller: districtController,
            decoration: const InputDecoration(labelText: 'ตำบล/แขวง'),
            validator: (value) => value == null || value.isEmpty ? 'กรุณากรอกตำบล/แขวง' : null,
          ),
          TextFormField(
            controller: provinceController,
            decoration: const InputDecoration(labelText: 'จังหวัด'),
            validator: (value) => value == null || value.isEmpty ? 'กรุณากรอกจังหวัด' : null,
          ),
          TextFormField(
            controller: postalCodeController,
            decoration: const InputDecoration(labelText: 'รหัสไปรษณีย์'),
            keyboardType: TextInputType.number,
            validator: (value) => value == null || value.isEmpty ? 'กรุณากรอกรหัสไปรษณีย์' : null,
          ),
        ],
      ),
    );
  }
}