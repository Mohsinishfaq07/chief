import 'package:chief/global_custom_widgets/custom_small_buttons.dart';
import 'package:chief/view/auth/signup_user.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../app_assets.dart';
import '../firebase_services.dart';
import '../global_custom_widgets/custom_app_bar.dart';
import 'auth/signup_chef.dart';
import 'auth/login_screen.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});
  static const String tag = '/GetStartedScreen';
  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Animation setup
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();

    // Firebase setup
    _firebaseMessaging.subscribeToTopic('all').then((_) {
      print('Subscribed to topic "all"');
    });
    FirebaseApi().initPushNotifications(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text(
              'Exit App',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.deepOrange.shade700,
                fontSize: 22.sp,
              ),
            ),
            content: Text(
              'Do you really want to exit the app?',
              style: TextStyle(
                color: Colors.deepOrange.shade900,
                fontSize: 16.sp,
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDialogButton(
                      "No", () => Navigator.of(context).pop(false)),
                  _buildDialogButton("Yes", () {
                    Navigator.of(context).pop(true);
                    SystemNavigator.pop();
                  }),
                ],
              ),
            ],
          ),
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: const CustomAppBarWidget(showBackButton: false),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  const Spacer(),
                  // Logo with shadow
                  Container(
                    width: 200.w,
                    height: 200.w,
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
                  SizedBox(height: 50.h),
                  // Buttons
                  _buildButton(
                    'Login',
                    () => onTapLogin(context),
                    Colors.white,
                    Colors.deepOrange.shade700,
                  ),
                  SizedBox(height: 20.h),
                  _buildButton(
                    'Sign up as a Chef',
                    () => onTapSignUpAsAChef(context),
                    Colors.deepOrange.shade700,
                    Colors.white,
                  ),
                  SizedBox(height: 20.h),
                  _buildButton(
                    'Sign up as a User',
                    () => onTapSignUpAsAUser(context),
                    Colors.deepOrange.shade700,
                    Colors.white,
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
      String text, VoidCallback onTap, Color bgColor, Color textColor) {
    return Container(
      width: double.infinity,
      height: 55.h,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogButton(String text, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: text == "Yes"
                ? Colors.deepOrange.shade700
                : Colors.deepOrange.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// Navigates to the loginScreen when the action is triggered.
onTapLogin(BuildContext context) {
  Navigator.pushNamed(context, LoginScreen.tag);
}

/// Navigates to the signupScreen when the action is triggered.
onTapSignUpAsAChef(BuildContext context) {
  Navigator.pushNamed(context, SignupChef.tag);
}

/// Navigates to the signupOneScreen when the action is triggered.
onTapSignUpAsAUser(BuildContext context) {
  Navigator.pushNamed(context, SignupUser.tag);
}
