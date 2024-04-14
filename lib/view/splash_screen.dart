import 'package:chief/global_custom_widgets/custom_app_bar.dart';
import 'package:chief/view/get_started_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../app_assets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const String tag = '/SplashScreen';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), () {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const GetStartedScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBarWidget(),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(12.h),
          child: Image.asset(AppAssets.imgCookingBro),
        ),
      ),
    );
  }
}
