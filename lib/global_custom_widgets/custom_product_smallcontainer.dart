import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomProductDetailSmallContainer extends StatelessWidget {
  final String title;
  const CustomProductDetailSmallContainer({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.006.h),
      child: Container(
          height: MediaQuery.of(context).size.height * 0.038.h,
          width: 80.w,
          decoration: const BoxDecoration(color: Colors.pinkAccent),
          child: Center(child: Text(title))),
    );
  }
}
