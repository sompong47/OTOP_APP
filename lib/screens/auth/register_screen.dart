import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../utils/helpers.dart';
import '../../utils/constants.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
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
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final result = await authProvider.register(
      _usernameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      Helpers.showSuccessSnackBar(context, 'สมัครสมาชิกสำเร็จ');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      Helpers.showErrorSnackBar(
          context, result['message'] ?? 'สมัครสมาชิกไม่สำเร็จ');
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => const LoginScreen(),
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
                      const SizedBox(height: 32),
                      _buildRegisterCard(),
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
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.blue.shade50,
            ],
          ),
          borderRadius: BorderRadius.circular(28),
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
          size: 55,
          color: Colors.deepPurple.shade600,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        const Text(
          'สมัครสมาชิก',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'สร้างบัญชีใหม่สำหรับ OTOP Store',
          style: TextStyle(
            color: Colors.white.withOpacity(0.95),
            fontSize: 15,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterCard() {
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
              const SizedBox(height: 16),
              _buildEmailField(),
              const SizedBox(height: 16),
              _buildPasswordField(),
              const SizedBox(height: 16),
              _buildConfirmPasswordField(),
              const SizedBox(height: 28),
              _buildRegisterButton(),
              const SizedBox(height: 20),
              _buildDivider(),
              const SizedBox(height: 20),
              _buildLoginLink(),
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
        validator: Validators.validateUsername,
      ),
    );
  }

  Widget _buildEmailField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextFormField(
        controller: _emailController,
        decoration: InputDecoration(
          labelText: 'อีเมล',
          labelStyle: TextStyle(color: Colors.deepPurple.shade400),
          prefixIcon: Icon(
            Icons.email_rounded,
            color: Colors.deepPurple.shade300,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
        keyboardType: TextInputType.emailAddress,
        validator: Validators.validateEmail,
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
        validator: Validators.validatePassword,
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextFormField(
        controller: _confirmPasswordController,
        obscureText: !_isConfirmPasswordVisible,
        decoration: InputDecoration(
          labelText: 'ยืนยันรหัสผ่าน',
          labelStyle: TextStyle(color: Colors.deepPurple.shade400),
          prefixIcon: Icon(
            Icons.lock_outline_rounded,
            color: Colors.deepPurple.shade300,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _isConfirmPasswordVisible
                  ? Icons.visibility_rounded
                  : Icons.visibility_off_rounded,
              color: Colors.grey.shade600,
            ),
            onPressed: () {
              setState(
                  () => _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
        validator: (value) => Validators.validateConfirmPassword(
          value,
          _passwordController.text,
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
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
          onTap: _isLoading ? null : _register,
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
                        'สมัครสมาชิก',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.person_add_rounded,
                          color: Colors.white, size: 20),
                    ],
                  ),
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

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "มีบัญชีแล้ว? ",
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 15,
          ),
        ),
        GestureDetector(
          onTap: _navigateToLogin,
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
              "เข้าสู่ระบบ",
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
