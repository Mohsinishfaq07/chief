import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../app_assets.dart';
import '../global_custom_widgets/custom_app_bar.dart';
import '../global_custom_widgets/custom_horizontal_line.dart';
import '../global_custom_widgets/custom_large_button.dart';
import '../global_custom_widgets/custom_text_form_field.dart';
import '../global_custom_widgets/custom_title_text.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});
  static const String tag = "ForgotPassword";

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController numberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBarWidget(
        showBackButton: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(children: [
            const CustomTitleText(
              text: 'Forgot Password', // Only the text parameter is required
            ),
            CustomTextField(
              controller: numberController,
              hintText: "Enter Number",
              keyboardType: TextInputType.phone,
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.01.h,
                  bottom: MediaQuery.of(context).size.height * 0.01.h),
              child: CustomTextField(
                controller: passwordController,
                hintText: "Enter Password",
                isPasswordField: true,
              ),
            ),
            CustomTextField(
              controller: passwordController,
              hintText: "Re-Enter Password",
              isPasswordField: true,
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.036.h),
              child: const CustomHorizontalDivider(),
            ),
            CustomLargeButton(title: "Submit", ontap: () {}),
            SizedBox(
                height: MediaQuery.of(context).size.height *
                    0.03.h), // Adjust spacing as needed
            const BottomRightImage(),
          ]),
        ),
      ),
    );
  }
}

class BottomRightImage extends StatelessWidget {
  const BottomRightImage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Image.asset(
        AppAssets.imgCookingBro,
        height: MediaQuery.of(context).size.height * 0.17.h,
      ),
    );
  }
}
