// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:chief/global_custom_widgets/custom_app_bar.dart';
import 'package:chief/view/chief_requestqueue_screen.dart';
import 'package:chief/view/user_details_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'forgot_password.dart';

class ChefDetails extends StatelessWidget {
  ChefDetails({super.key, this.userid});
  static const String tag = "ChefDetails";
  String? userid;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: const CustomAppBarWidget(
        showBackButton: true,
        title: 'Chief Details',
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 20),
        child: Column(
          children: [
            //  const CustomTitleText(text: ),
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
            .collection('chief_users')
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
                              CustomProductDetailContainer(
                                title: userData['Specialities'],
                              ),
                              CustomProductDetailContainer(
                                title: userData['Work Experience'],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Container(
                                  width: double.infinity, // Set container width
                                  height: 100, // Set container height
                                  decoration: BoxDecoration(
                                    color:
                                        Colors.pinkAccent, // Placeholder color
                                    borderRadius: BorderRadius.circular(
                                        10), // Optional: Add border radius
                                  ),
                                  child: userData['Certificate image'] == ""
                                      ? const Center(
                                          child:
                                              Text('No Certificate added yet'))
                                      : Image.file(
                                          File(userData[
                                              'Certificate image']), // Path to your image file
                                          fit: BoxFit
                                              .cover, // Adjust the image size to cover the container
                                        ),
                                ),
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
