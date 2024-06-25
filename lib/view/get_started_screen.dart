// ignore_for_file: deprecated_member_use

import 'package:chief/global_custom_widgets/custom_small_buttons.dart';
 import 'package:chief/view/auth/signup_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../app_assets.dart';
import '../global_custom_widgets/custom_app_bar.dart';
import '../global_custom_widgets/custom_horizontal_line.dart';
import '../global_custom_widgets/custom_large_button.dart';
import 'auth/signup_chef.dart';
import 'auth/login_screen.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({
    super.key,
  });
  static const String tag = '/GetStartedScreen';
  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
             backgroundColor: Colors.deepOrange.shade200,
            title: Text(
              'Exit App',
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontSize: 20.sp),
            ),
            content: Text(
              'Do you really want to exit the app?',
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CustomSmallButton(
                      title: "No",
                      ontap: () {
                        Navigator.of(context).pop(false);
                      }),
                  CustomSmallButton(
                      title: "Yes",
                      ontap: () {
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
        appBar: const CustomAppBarWidget(
          showBackButton: false,
        ),
        body: Column(children: [
          const Spacer(),
          Flexible(
            child: Image.asset(
              AppAssets.imgCookingBro,
              height: MediaQuery.of(context).size.height * 0.3.h,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.05.h),
            child: CustomLargeButton(
              title: 'Login',
              ontap: () {
                onTapLogin(context);
              },
            ),
          ),
          const CustomHorizontalDivider(),
          Padding(
            padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.04.h),
            child: CustomLargeButton(
                title: 'Sign up as a Chef',
                ontap: () {
                  onTapSignUpAsAChef(context);
                }),
          ),
          CustomLargeButton(
              title: 'Sign up as a User',
              ontap: () {
                onTapSignUpAsAUser(context);
              }),
          const Spacer(),
        ]),
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
