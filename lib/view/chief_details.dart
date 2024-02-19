import 'package:chief/global_custom_widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../global_custom_widgets/custom_title_text.dart';
import 'forgot_password.dart';

class ChiefDetail extends StatelessWidget {
  ChiefDetail({super.key});
  static const String tag = "ChiefDetail";

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: const CustomAppBarWidget(
        showBackButton: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: const Column(
          children: [
            CustomTitleText(text: 'Chief Details'),
            RequestCard(),
            Spacer(),
            BottomRightImage(),
          ],
        ),
      ),
    );
  }
}

class RequestCard extends StatelessWidget {
  const RequestCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.pink.shade200,
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(12.h),
        child: Column(
          children: <Widget>[
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    UserInfoSection(),
                    Text("4/5"),
                  ],
                ),
                Column(
                  children: [
                    CustomProductDetailSmallContainer(
                      title: 'Chef Name',
                    ),
                    CustomProductDetailSmallContainer(
                      title: 'Number',
                    ),
                    CustomProductDetailSmallContainer(
                      title: 'Complete',
                    ),
                  ],
                ),
                Column(
                  children: [
                    CustomProductDetailSmallContainer(
                      title: 'Number',
                    ),
                    CustomProductDetailSmallContainer(
                      title: 'Fare',
                    ),
                    CustomProductDetailSmallContainer(
                      title: 'Cancel',
                    ),
                  ],
                ),
              ],
            ),
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(12.h),
                child: const Column(
                  children: <Widget>[
                    Column(
                      children: [
                        CustomProductDetailSmallContainer(
                          title: 'Number',
                        ),
                        CustomProductDetailSmallContainer(
                          title: 'Fare',
                        ),
                        CustomProductDetailSmallContainer(
                          title: 'Cancel',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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

class CustomReviewContainer extends StatelessWidget {
  final String title;

  const CustomReviewContainer({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.006.h),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.04.h,
        width: 400.w,
        decoration: const BoxDecoration(color: Colors.pinkAccent),
        child: Center(child: Text(title)),
      ),
    );
  }
}

class UserInfoSection extends StatelessWidget {
  const UserInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: <Widget>[
        CircleAvatar(
          radius: 30,
          child: Icon(Icons.person_outline, size: 30),
        ),
      ],
    );
  }
}
