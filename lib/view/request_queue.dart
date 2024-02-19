import 'package:chief/global_custom_widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../global_custom_widgets/custom_title_text.dart';

class RequestQueue extends StatelessWidget {
  RequestQueue({super.key});
  static const String tag = "RequestQueue";

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
            CustomTitleText(text: 'Request Queue '),
            RequestCard(),
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
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(12.h),
        child: const Column(
          children: <Widget>[
            Row(
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
                      title: 'Fare',
                    ),
                  ],
                ),
                Column(
                  children: [
                    CustomProductDetailSmallContainer(
                      title: 'Number',
                    ),
                    CustomProductDetailSmallContainer(
                      title: 'Contact',
                    ),
                  ],
                )
              ],
            ),
            RequestActionsSection(),
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

class RequestActionsSection extends StatelessWidget {
  const RequestActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.2.w,
        ),
        const CustomProductDetailSmallContainer(
          title: 'Cancel',
        ),
      ],
    );
  }
}
