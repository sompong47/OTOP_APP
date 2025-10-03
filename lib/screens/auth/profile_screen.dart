import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../utils/helpers.dart';
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
      _usernameController.text = user.username ?? '';
      _emailController.text = user.email ?? '';
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade400,
              Colors.blue.shade300,
              Colors.white,
            ],
            stops: const [0.0, 0.3, 0.3],
          ),
        ),
        child: SafeArea(
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final user = authProvider.user;

              if (user == null) {
                return Center(
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_off_rounded,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'ไม่พบข้อมูลผู้ใช้',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(user),
                    Transform.translate(
                      offset: const Offset(0, -40),
                      child: Column(
                        children: [
                          _buildProfileCard(user),
                          const SizedBox(height: 16),
                          _buildMenuSection(),
                          const SizedBox(height: 16),
                          _buildLogoutButton(),
                          const SizedBox(height: 16),
                          _buildVersionInfo(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(dynamic user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 80),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'โปรไฟล์',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              if (!_isEditing)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.edit_rounded, color: Colors.white),
                    onPressed: () => setState(() => _isEditing = true),
                    tooltip: 'แก้ไขข้อมูล',
                  ),
                ),
            ],
          ),
          const SizedBox(height: 32),
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.blue.shade50],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.deepPurple.shade300,
                        Colors.blue.shade300,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      user.username?.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              if (_isEditing)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade400, Colors.green.shade600],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            user.username ?? 'ผู้ใช้',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email ?? '',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(dynamic user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.deepPurple.shade400,
                        Colors.blue.shade400,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'ข้อมูลบัญชี',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isEditing ? Colors.deepPurple.shade200 : Colors.transparent,
                  width: 2,
                ),
              ),
              child: TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'ชื่อผู้ใช้',
                  labelStyle: TextStyle(color: Colors.deepPurple.shade400),
                  prefixIcon: Icon(
                    Icons.person_outline_rounded,
                    color: Colors.deepPurple.shade300,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
                enabled: _isEditing,
                validator: _isEditing ? Validators.validateUsername : null,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isEditing ? Colors.deepPurple.shade200 : Colors.transparent,
                  width: 2,
                ),
              ),
              child: TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'อีเมล',
                  labelStyle: TextStyle(color: Colors.deepPurple.shade400),
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: Colors.deepPurple.shade300,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
                enabled: _isEditing,
                keyboardType: TextInputType.emailAddress,
                validator: _isEditing ? Validators.validateEmail : null,
              ),
            ),
            if (_isEditing) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isLoading
                              ? null
                              : () {
                                  setState(() => _isEditing = false);
                                  _loadUserData();
                                },
                          borderRadius: BorderRadius.circular(12),
                          child: Center(
                            child: Text(
                              'ยกเลิก',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.deepPurple.shade400,
                            Colors.blue.shade400,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isLoading ? null : _updateProfile,
                          borderRadius: BorderRadius.circular(12),
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'บันทึก',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuTile(
            icon: Icons.store_rounded,
            title: 'จัดการร้านค้า',
            subtitle: 'สำหรับผู้ขาย OTOP',
            gradient: LinearGradient(
              colors: [Colors.purple.shade400, Colors.purple.shade600],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SellerDashboardScreen(),
                ),
              );
            },
          ),
          _buildDivider(),
          _buildMenuTile(
            icon: Icons.shopping_bag_rounded,
            title: 'คำสั่งซื้อของฉัน',
            subtitle: 'ดูประวัติการสั่งซื้อ',
            gradient: LinearGradient(
              colors: [Colors.blue.shade400, Colors.blue.shade600],
            ),
            onTap: () => Helpers.showSnackBar(context, 'กำลังพัฒนา...'),
          ),
          _buildDivider(),
          _buildMenuTile(
            icon: Icons.favorite_rounded,
            title: 'รายการโปรด',
            subtitle: 'สินค้าที่ถูกใจ',
            gradient: LinearGradient(
              colors: [Colors.pink.shade300, Colors.pink.shade500],
            ),
            onTap: () => Helpers.showSnackBar(context, 'กำลังพัฒนา...'),
          ),
          _buildDivider(),
          _buildMenuTile(
            icon: Icons.notifications_rounded,
            title: 'การแจ้งเตือน',
            subtitle: 'ตั้งค่าการแจ้งเตือน',
            gradient: LinearGradient(
              colors: [Colors.orange.shade400, Colors.orange.shade600],
            ),
            onTap: () => Helpers.showSnackBar(context, 'กำลังพัฒนา...'),
          ),
          _buildDivider(),
          _buildMenuTile(
            icon: Icons.help_rounded,
            title: 'ช่วยเหลือ',
            subtitle: 'คำถามที่พบบ่อย',
            gradient: LinearGradient(
              colors: [Colors.teal.shade400, Colors.teal.shade600],
            ),
            onTap: () => Helpers.showSnackBar(context, 'กำลังพัฒนา...'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey.shade400,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: Colors.grey.shade200),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade300, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _logout,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: Colors.red.shade400),
              const SizedBox(width: 12),
              Text(
                'ออกจากระบบ',
                style: TextStyle(
                  color: Colors.red.shade400,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Text(
      'เวอร์ชัน 1.0.0',
      style: TextStyle(
        color: Colors.grey.shade500,
        fontSize: 13,
      ),
    );
  }
}