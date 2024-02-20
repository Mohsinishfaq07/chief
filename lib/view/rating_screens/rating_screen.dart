import 'package:chief/view/rating_screens/rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app_assets.dart';
import '../../global_custom_widgets/custom_app_bar.dart';
import '../../global_custom_widgets/custom_horizontal_line.dart';
import '../../global_custom_widgets/custom_large_button.dart';
import '../get_started_screen.dart';

class RatingScreen extends StatelessWidget {
  const RatingScreen({super.key});
  static const String tag = '/RatingScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: const CustomAppBarWidget(
        showBackButton: true,
      ),
      body: Column(children: [
        Image.asset(
          AppAssets.imgCookingBro,
          height: MediaQuery.of(context).size.height * 0.2.h,
        ),
        Padding(
          padding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.05.h),
          child: CustomRatingBar(initialRating: 5),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.04.h),
          child: CustomLargeButton(
              title: 'Comments',
              ontap: () {
                onTapSignUpAsAChef(context);
              }),
        ),
        Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.02.h),
          child: const CustomHorizontalDivider(),
        ),
        CustomLargeButton(
            title: 'Submit',
            ontap: () {
              onTapSignUpAsAUser(context);
            }),
        const SizedBox(height: 5)
      ]),
    );
  }
}
