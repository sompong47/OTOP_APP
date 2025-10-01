import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../utils/helpers.dart';
import '../../utils/constants.dart';
import 'login_screen.dart';
import '../seller/seller_dashboard_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    
    if (user != null) {
      _usernameController.text = user.username;
      _emailController.text = user.email;
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // TODO: Implement update profile API call
    // For now, just simulate success
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      _isEditing = false;
    });

    Helpers.showSuccessSnackBar(context, 'อัพเดทข้อมูลสำเร็จ');
  }

  Future<void> _logout() async {
    final confirmed = await Helpers.showConfirmationDialog(
      context,
      title: 'ออกจากระบบ',
      message: 'คุณต้องการออกจากระบบหรือไม่?',
      confirmText: 'ออกจากระบบ',
      cancelText: 'ยกเลิก',
    );

    if (confirmed == true) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();
      
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('ข้อมูลส่วนตัว'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: 'แก้ไขข้อมูล',
            ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;
          
          if (user == null) {
            return const Center(
              child: Text('ไม่พบข้อมูลผู้ใช้'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Avatar
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppConstants.primaryColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppConstants.primaryColor.withOpacity(0.3),
                                spreadRadius: 5,
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                        if (_isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppConstants.successColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),

                  // User Info Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.paddingLarge),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ข้อมูลบัญชี',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppConstants.primaryColor,
                            ),
                          ),
                          const SizedBox(height: AppConstants.paddingMedium),

                          // Username Field
                          TextFormField(
                            controller: _usernameController,
                            decoration: const InputDecoration(
                              labelText: 'ชื่อผู้ใช้',
                              prefixIcon: Icon(Icons.person),
                            ),
                            enabled: _isEditing,
                            validator: _isEditing ? Validators.validateUsername : null,
                          ),
                          
                          const SizedBox(height: AppConstants.paddingMedium),

                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'อีเมล',
                              prefixIcon: Icon(Icons.email),
                            ),
                            enabled: _isEditing,
                            keyboardType: TextInputType.emailAddress,
                            validator: _isEditing ? Validators.validateEmail : null,
                          ),

                          if (_isEditing) ...[
                            const SizedBox(height: 24),
                            
                            // Action Buttons for Editing
                            Row(
                              children: [
                                Expanded(
                                  child: TextButton(
                                    onPressed: _isLoading ? null : () {
                                      setState(() => _isEditing = false);
                                      _loadUserData(); // Reset to original data
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppConstants.secondaryColor,
                                    ),
                                    child: const Text('ยกเลิก'),
                                  ),
                                ),
                                const SizedBox(width: AppConstants.paddingMedium),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _updateProfile,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppConstants.primaryColor,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : const Text('บันทึก'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.paddingLarge),

                  // Menu Options
                 Card(
  elevation: 2,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
  ),
  child: Column(
    children: [
      // เพิ่มเมนูผู้ขายที่ด้านบน
      _buildMenuTile(
        icon: Icons.store,
        title: 'จัดการร้านค้า',
        subtitle: 'สำหรับผู้ขาย OTOP',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SellerDashboardScreen(),
            ),
          );
        },
      ),
      const Divider(height: 1),
      _buildMenuTile(
        icon: Icons.shopping_bag,
        title: 'คำสั่งซื้อของฉัน',
        subtitle: 'ดูประวัติการสั่งซื้อ',
        onTap: () {
          // TODO: Navigate to orders screen
          Helpers.showSnackBar(context, 'กำลังพัฒนา...');
        },
      ),
      const Divider(height: 1),
      _buildMenuTile(
        icon: Icons.favorite,
        title: 'รายการโปรด',
        subtitle: 'สินค้าที่ถูกใจ',
        onTap: () {
          // TODO: Navigate to favorites screen
          Helpers.showSnackBar(context, 'กำลังพัฒนา...');
        },
      ),
      const Divider(height: 1),
      _buildMenuTile(
        icon: Icons.notifications,
        title: 'การแจ้งเตือน',
        subtitle: 'ตั้งค่าการแจ้งเตือน',
        onTap: () {
          // TODO: Navigate to notifications settings
          Helpers.showSnackBar(context, 'กำลังพัฒนา...');
        },
      ),
      const Divider(height: 1),
      _buildMenuTile(
        icon: Icons.help,
        title: 'ช่วยเหลือ',
        subtitle: 'คำถามที่พบบ่อย',
        onTap: () {
          // TODO: Navigate to help screen
          Helpers.showSnackBar(context, 'กำลังพัฒนา...');
        },
      ),
    ],
  ),
),

                  const SizedBox(height: AppConstants.paddingLarge),

                  // Logout Button
                  SizedBox(
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout, color: AppConstants.errorColor),
                      label: const Text(
                        'ออกจากระบบ',
                        style: TextStyle(
                          color: AppConstants.errorColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppConstants.errorColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.paddingLarge),

                  // App Version
                  Center(
                    child: Text(
                      'เวอร์ชัน ${AppConstants.version}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppConstants.secondaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppConstants.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: Icon(
          icon,
          color: AppConstants.primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AppConstants.secondaryColor,
          fontSize: AppConstants.fontSizeSmall,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppConstants.secondaryColor,
      ),
      onTap: onTap,
    );
  }
}