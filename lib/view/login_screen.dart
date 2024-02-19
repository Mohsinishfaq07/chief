import 'package:chief/model/app_database.dart';
import 'package:chief/view/rating_screens/rating_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../global_custom_widgets/custom_app_bar.dart';
import '../global_custom_widgets/custom_horizontal_line.dart';
import '../global_custom_widgets/custom_large_button.dart';
import '../global_custom_widgets/custom_size.dart';
import '../global_custom_widgets/custom_text_form_field.dart';
import '../global_custom_widgets/custom_title_text.dart';
import 'forgot_password.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
  });
  static const String tag = "LoginScreen";

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController numberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final AppDatabase database = AppDatabase();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBarWidget(
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          const CustomTitleText(text: 'Login'),
          CustomTextField(
            controller: numberController,
            hintText: "Enter Email",
            keyboardType: TextInputType.emailAddress,
          ),
          Padding(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.043.h,
                bottom: MediaQuery.of(context).size.height * 0.001.h),
            child: CustomTextField(
              controller: passwordController,
              hintText: "Enter Password",
              isPasswordField: true,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                right: MediaQuery.of(context).size.width * 0.09.w),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  onTapForgotPassword(context);
                },
                child: const Text(
                  'Forget Password?',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ),
          const CustomHorizontalDivider(),
          CustomSize(height: MediaQuery.of(context).size.height * 0.05.h),
          CustomLargeButton(
              title: "Login",
              ontap: () {
                if (numberController.text.isEmpty ||
                    passwordController.text.isEmpty) {
                  Fluttertoast.showToast(msg: 'Please fill the above fields');
                } else {
                  database.signIn(
                      numberController.text, passwordController.text, context);
                }
              }),
          SizedBox(
              height: MediaQuery.of(context).size.height *
                  0.04.h), // Adjust spacing as needed
          const BottomRightImage(),
        ]),
      ),
    );
  }

  onTapForgotPassword(BuildContext context) {
    Navigator.pushNamed(context, ForgotPassword.tag);
  }

  onTapLogin(BuildContext context) {
    Navigator.pushNamed(context, RatingScreen.tag);
  }
}
