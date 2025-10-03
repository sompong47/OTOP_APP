import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'home_screen.dart';
import '../auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _slideController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Scale Animation for Logo
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    // Fade Animation for Text
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    // Slide Animation for Loading
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    // Start Animations
    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _fadeController.forward();
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _slideController.forward();
    });

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(Duration.zero);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.init();

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (authProvider.isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
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
              const Color(0xFF6A11CB), // Deep Purple
              const Color(0xFF8E44AD), // Purple
              const Color(0xFF3498DB), // Blue
              const Color(0xFF5DADE2), // Light Blue
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Decorative Circles Background
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              bottom: -150,
              left: -150,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.03),
                ),
              ),
            ),

            // Main Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with Animation
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.9),
                            Colors.white.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6A11CB).withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 5,
                            offset: const Offset(0, 10),
                          ),
                          BoxShadow(
                            color: Colors.white.withOpacity(0.2),
                            blurRadius: 15,
                            spreadRadius: -5,
                            offset: const Offset(-5, -5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF6A11CB),
                                Color(0xFF3498DB),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.store_rounded,
                            size: 75,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),

                  // App Name with Fade Animation
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        // Title
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            'OTOP STORE',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 3,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 3),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Subtitle
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Text(
                            'ร้านค้า OTOP ออนไลน์',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 70),

                  // Loading Indicator with Slide Animation
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                                strokeWidth: 3.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'กำลังโหลด...',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w400,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Version Text at Bottom
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.6),
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
