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

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
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
      // Navigate to home screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      Helpers.showErrorSnackBar(context, result['message'] ?? 'เข้าสู่ระบบไม่สำเร็จ');
    }
  }

  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor,
                        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                        boxShadow: [
                          BoxShadow(
                            color: AppConstants.primaryColor.withOpacity(0.3),
                            spreadRadius: 5,
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.store,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Title
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'เข้าสู่ระบบ',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppConstants.primaryColor,
                          ),
                        ),
                        const SizedBox(height: AppConstants.paddingSmall),
                        Text(
                          'ยินดีต้อนรับกลับสู่ OTOP Store',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppConstants.secondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Username Field
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'ชื่อผู้ใช้',
                      prefixIcon: Icon(Icons.person),
                      hintText: 'กรอกชื่อผู้ใช้',
                    ),
                    validator: (value) => Validators.validateRequired(value, 'ชื่อผู้ใช้'),
                    textInputAction: TextInputAction.next,
                  ),
                  
                  const SizedBox(height: AppConstants.paddingMedium),
                  
                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'รหัสผ่าน',
                      prefixIcon: const Icon(Icons.lock),
                      hintText: 'กรอกรหัสผ่าน',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() => _isPasswordVisible = !_isPasswordVisible);
                        },
                      ),
                    ),
                    obscureText: !_isPasswordVisible,
                    validator: (value) => Validators.validateRequired(value, 'รหัสผ่าน'),
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _login(),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Login Button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                        ),
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
                          : const Text(
                              'เข้าสู่ระบบ',
                              style: TextStyle(
                                fontSize: AppConstants.fontSizeLarge,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Forgot Password (Optional)
                  Center(
                    child: TextButton(
                      onPressed: () {
                        // TODO: Implement forgot password
                        Helpers.showSnackBar(context, 'กำลังพัฒนา...');
                      },
                      child: Text(
                        'ลืมรหัสผ่าน?',
                        style: TextStyle(
                          color: AppConstants.secondaryColor,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'ยังไม่มีบัญชี? ',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppConstants.secondaryColor,
                        ),
                      ),
                      GestureDetector(
                        onTap: _navigateToRegister,
                        child: Text(
                          'สมัครสมาชิก',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppConstants.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}