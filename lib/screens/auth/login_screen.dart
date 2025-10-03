import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../utils/helpers.dart';
import '../../utils/constants.dart';
import 'register_screen.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _animationController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final result = await authProvider.login(
      _usernameController.text.trim(),
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      Helpers.showSuccessSnackBar(context, 'เข้าสู่ระบบสำเร็จ');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      Helpers.showErrorSnackBar(
          context, result['message'] ?? 'เข้าสู่ระบบไม่สำเร็จ');
    }
  }

  void _navigateToRegister() {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => const RegisterScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.shade400,
              Colors.blue.shade400,
              Colors.purple.shade300,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      _buildLogo(),
                      const SizedBox(height: 32),
                      _buildTitle(),
                      const SizedBox(height: 40),
                      _buildLoginCard(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Hero(
      tag: "app_logo",
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.blue.shade50,
            ],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Icon(
          Icons.store_rounded,
          size: 60,
          color: Colors.deepPurple.shade600,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        const Text(
          'เข้าสู่ระบบ',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'ยินดีต้อนรับกลับสู่ OTOP Store',
          style: TextStyle(
            color: Colors.white.withOpacity(0.95),
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildUsernameField(),
              const SizedBox(height: 20),
              _buildPasswordField(),
              const SizedBox(height: 28),
              _buildLoginButton(),
              const SizedBox(height: 16),
              _buildForgotPassword(),
              const SizedBox(height: 20),
              _buildDivider(),
              const SizedBox(height: 20),
              _buildRegisterLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsernameField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextFormField(
        controller: _usernameController,
        decoration: InputDecoration(
          labelText: 'ชื่อผู้ใช้',
          labelStyle: TextStyle(color: Colors.deepPurple.shade400),
          prefixIcon: Icon(
            Icons.person_rounded,
            color: Colors.deepPurple.shade300,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
        validator: (value) => Validators.validateRequired(value, 'ชื่อผู้ใช้'),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextFormField(
        controller: _passwordController,
        obscureText: !_isPasswordVisible,
        decoration: InputDecoration(
          labelText: 'รหัสผ่าน',
          labelStyle: TextStyle(color: Colors.deepPurple.shade400),
          prefixIcon: Icon(
            Icons.lock_rounded,
            color: Colors.deepPurple.shade300,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible
                  ? Icons.visibility_rounded
                  : Icons.visibility_off_rounded,
              color: Colors.grey.shade600,
            ),
            onPressed: () {
              setState(() => _isPasswordVisible = !_isPasswordVisible);
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
        validator: (value) => Validators.validateRequired(value, 'รหัสผ่าน'),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple.shade400,
            Colors.blue.shade400,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _login,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'เข้าสู่ระบบ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded,
                          color: Colors.white, size: 20),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          Helpers.showSnackBar(context, 'กำลังพัฒนา...');
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
        child: Text(
          "ลืมรหัสผ่าน?",
          style: TextStyle(
            color: Colors.deepPurple.shade600,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'หรือ',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
      ],
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "ยังไม่มีบัญชี? ",
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 15,
          ),
        ),
        GestureDetector(
          onTap: _navigateToRegister,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple.shade50,
                  Colors.blue.shade50,
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "สมัครสมาชิก",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.deepPurple.shade600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
