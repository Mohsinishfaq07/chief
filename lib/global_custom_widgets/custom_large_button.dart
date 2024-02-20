import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomLargeButton extends StatelessWidget {
  final VoidCallback ontap;
  final String title;

  const CustomLargeButton({
    super.key,
    required this.title,
    required this.ontap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.12.w),
      child: InkWell(
        onTap: ontap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(10.r),
          ),
          height: MediaQuery.of(context).size.height * 0.066.h,
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                  fontSize: 20.sp),
            ),
          ),
        ),
      ),
    );
  }
}
