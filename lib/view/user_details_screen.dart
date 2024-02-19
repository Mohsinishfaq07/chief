// ignore_for_file: must_be_immutable

import 'package:chief/global_custom_widgets/custom_app_bar.dart';
import 'package:chief/view/chief_requestqueue_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../global_custom_widgets/custom_title_text.dart';
import 'forgot_password.dart';

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
        padding: EdgeInsets.symmetric(horizontal: 16.w),
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
            color: Colors.pink.shade200,
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(12.h),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                    ],
                  ),
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: EdgeInsets.all(12.h),
                      child: Column(
                        children: <Widget>[
                          Column(
                            children: [
                              CustomProductDetailContainer(
                                title: userData['Address'],
                              ),
                              CustomProductDetailContainer(
                                title: userData['Number'],
                              ),
                              CustomProductDetailContainer(
                                title: userData['Email'],
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
        });
  }
}

class CustomProductDetailContainer extends StatelessWidget {
  final String title;
  const CustomProductDetailContainer({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.006.h),
      child: Container(
          height: MediaQuery.of(context).size.height * 0.038.h,
          width: 150.w,
          decoration: const BoxDecoration(color: Colors.pinkAccent),
          child: Center(child: Text(title))),
    );
  }
}
