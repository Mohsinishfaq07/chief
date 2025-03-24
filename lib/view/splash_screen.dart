import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chief/view/get_started_screen.dart';
import 'package:chief/view/dashboard/User_dashboard_request_form.dart';
import 'package:chief/view/dashboard/chef_dashboard_screen.dart';
import '../app_assets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chief/utils/shared_preferences_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const String tag = '/SplashScreen';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkUserSession();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }

  Future<void> _checkUserSession() async {
    final userSession = await SharedPreferencesManager.getUserSession();

    // Delay for splash screen animation
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    if (userSession['isLoggedIn'] == true &&
        userSession['userId'] != null &&
        userSession['userRole'] != null) {
      // Check if user is still authenticated with Firebase
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && currentUser.uid == userSession['userId']) {
        // User is still authenticated, proceed with navigation
        if (userSession['userRole'] == 'user') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const UserDashboardRequestForm(),
            ),
          );
        } else if (userSession['userRole'] == 'chief') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const ChefDashboardScreen(),
            ),
          );
        }
      } else {
        // User is not authenticated, clear preferences and go to GetStarted
        await SharedPreferencesManager.clearUserSession();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const GetStartedScreen(),
          ),
        );
      }
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const GetStartedScreen(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.deepOrange.shade200,
                  Colors.deepOrange.shade100,
                  Colors.white,
                  Colors.white.withOpacity(0.8),
                ],
                stops: const [0.1, 0.4, 0.7, 1.0],
              ),
            ),
          ),

          // Overlay Pattern
          Positioned.fill(
            child: CustomPaint(
              painter: BackgroundPatternPainter(),
            ),
          ),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo animation
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: 180.w,
                      height: 180.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepOrange.shade200.withOpacity(0.3),
                            blurRadius: 25,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(20.w),
                      child: Image.asset(AppAssets.imgCookingBro),
                    ),
                  ),
                ),

                SizedBox(height: 40.h),

                // App name animation
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          'CHIEF',
                          style: TextStyle(
                            fontSize: 40.sp,
                            fontWeight: FontWeight.w900,
                            color: Colors.deepOrange.shade700,
                            letterSpacing: 12,
                            shadows: [
                              Shadow(
                                color:
                                    Colors.deepOrange.shade200.withOpacity(0.5),
                                offset: const Offset(2, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'Culinary Excellence',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.deepOrange.shade900,
                            letterSpacing: 3,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom loading indicator
          Positioned(
            bottom: 50.h,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.deepOrange.shade700,
                    ),
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.deepOrange.shade100.withOpacity(0.2)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    double spacing = 20;

    for (double i = 0; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(0, i),
        Offset(i, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
