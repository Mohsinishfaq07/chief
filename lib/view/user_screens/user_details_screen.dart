// ignore_for_file: must_be_immutable

import 'package:chief/global_custom_widgets/custom_app_bar.dart';
 import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../global_custom_widgets/custom_product_small_container.dart';
import '../../global_custom_widgets/custom_title_text.dart';
import '../../global_custom_widgets/custom_userinfo_section.dart';
import '../auth/forgot_password.dart';

class UserDetails extends StatelessWidget {
  UserDetails({super.key, this.userid});
  static const String tag = "UserDetails";
  String? userid;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: const CustomAppBarWidget(
        showBackButton: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w),
        child: Column(
          children: [
            const CustomTitleText(text: 'User Details'),
            RequestCard(user: userid!),
            const Spacer(),
            const BottomRightImage(),
          ],
        ),
      ),
    );
  }
}

class RequestCard extends StatelessWidget {
  RequestCard({super.key, required this.user});
  String user;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(
              color: Colors.pink,
            ); // Show a loading indicator while fetching data
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          var userData = snapshot.data!.data() as Map<String, dynamic>;
          return Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      UserInfoSection(image: userData['image']),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: Text(userData['Name']),
                      ),
                    ],
                  ),
                  Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomProductDetailSmallContainer(
                          label: "Address", title: userData['Address']),
                      CustomProductDetailSmallContainer(
                        label: "Number",
                        title: userData['Number'],
                      ),
                      CustomProductDetailSmallContainer(
                        label: "Email",
                        title: userData['Email'],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }
}
