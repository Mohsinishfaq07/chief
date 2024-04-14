// ignore_for_file: must_be_immutable, deprecated_member_use

import 'package:chief/global_custom_widgets/custom_small_buttons.dart';
import 'package:chief/model/app_database.dart';
import 'package:chief/view/user_screens/user_drawer.dart';
 import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../global_custom_widgets/custom_horizontal_line.dart';
import '../../global_custom_widgets/custom_large_button.dart';
import '../../global_custom_widgets/custom_size.dart';
import '../../global_custom_widgets/custom_text_form_field.dart';
import '../../global_custom_widgets/custom_title_text.dart';

class UserDashboardRequestForm extends StatefulWidget {
  const UserDashboardRequestForm({super.key});
  static const tag = 'UserDashboardRequestForm';

  @override
  State<UserDashboardRequestForm> createState() => _UserDashboardRequestFormState();
}

class _UserDashboardRequestFormState extends State<UserDashboardRequestForm> {
  TextEditingController itemNameController = TextEditingController();

  TextEditingController dateController = TextEditingController();

  TextEditingController arrivelTimeController = TextEditingController();

  TextEditingController eventTimeController = TextEditingController();

  TextEditingController noOfPeopleController = TextEditingController();

  TextEditingController fareController = TextEditingController();

  TextEditingController availableIngController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  AppDatabase database = AppDatabase();
  User? user = FirebaseAuth.instance.currentUser;
  String image = '';
  String name = '';

  @override
  void dispose() {
    // Dispose controllers when the widget is disposed
    super.dispose();
    itemNameController.dispose();
    dateController.dispose();
    arrivelTimeController.dispose();
    eventTimeController.dispose();
    noOfPeopleController.dispose();
    fareController.dispose();
    availableIngController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          // Check if the drawer is open
          if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
            // Close the drawer
            Navigator.of(context).pop();
            return false;
          } else {
            // Show the exit confirmation dialog
            final shouldPop = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: Colors.pinkAccent,
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
                          }),
                    ],
                  ),
                ],
              ),
            );
            return shouldPop ?? false;
          }
        },
        child: Scaffold(
          key: _scaffoldKey,
          drawer: const CustomDrawer(),
          appBar: AppBar(backgroundColor: Colors.pink.shade200),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomLargeButton(
              title: 'Add',
              ontap: () {
                if (itemNameController.text.isEmpty ||
                    dateController.text.isEmpty ||
                    arrivelTimeController.text.isEmpty ||
                    eventTimeController.text.isEmpty ||
                    noOfPeopleController.text.isEmpty ||
                    fareController.text.isEmpty ||
                    availableIngController.text.isEmpty) {
                  Fluttertoast.showToast(msg: 'Fill the above field');
                } else {
                  database.addrequest(
                      context,
                      '',
                      itemNameController.text,
                      dateController.text,
                      arrivelTimeController.text,
                      eventTimeController.text,
                      noOfPeopleController.text,
                      fareController.text,
                      availableIngController.text,
                      name,
                      image,
                      'request_form',
                      '',
                      ''
                      ,
                  );
                }
              },
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.04.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Spacer(),
                          const CustomTitleText(
                            text:
                            'Add Request', // Only the text parameter is required
                          ),
                          const Spacer(),
                          FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .doc(user!.uid)
                                .get(),
                            builder: (context, userSnapshot) {
                              if (userSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.pink,
                                    )); // Show loading indicator while waiting for user data
                              }
                              if (userSnapshot.hasError) {
                                return Center(
                                    child: Text(
                                        'Error: ${userSnapshot.error}')); // Show error message if user data retrieval failed
                              }
                              // User data is available, display it
                              if (userSnapshot.hasData &&
                                  userSnapshot.data!.exists) {
                                final userData = userSnapshot.data!.data()
                                as Map<String, dynamic>;
                                image = userData['image'] ?? "";
                                name = userData['Name'];
                                return CircleAvatar(
                                    radius: 40,
                                    child: ClipOval(
                                      child: image == ""
                                          ? const Icon(
                                        Icons.person,
                                        size: 30,
                                      )
                                          : Image.network(
                                        image,
                                        fit: BoxFit.cover,
                                        width: 80,
                                        height: 80,
                                      ),
                                    ));
                              } else {
                                _userImageIcon();
                              }
                              return _userImageIcon();
                            },
                          ),
                          CustomSize(
                            width: 4.w,
                          ),
                        ],
                      ),
                      CustomTextField(

                        label: "Food Item Name",
                        controller: itemNameController,
                        hintText: "Food Item Name",
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical:
                            MediaQuery.of(context).size.height * 0.01.h),
                        child: CustomTextField(formatDate: true,
                          label: "Date",
                          keyboardType: TextInputType.datetime,
                          controller: dateController,
                          hintText: "Date",

                        ),
                      ),
                      CustomTextField(
                       formatTime: true,
                        label: "Arrival Time ",
                        controller: arrivelTimeController,
                        hintText: "Arrival Time ",
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical:
                            MediaQuery.of(context).size.height * 0.01.h),
                        child: CustomTextField(
                          formatTime: true,
                          label:"Event Time",
                          controller: eventTimeController,
                          hintText: "Event Time",
                        ),
                      ),
                      CustomTextField(
                        maxLength: 4,
                        label:"No of People",
                        keyboardType: TextInputType.number,
                        controller: noOfPeopleController,
                        hintText: "No of People",
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical:
                            MediaQuery.of(context).size.height * 0.01.h),
                        child: CustomTextField(
                          maxLength: 6,
                          label:'Fare',
                          keyboardType: TextInputType.number,
                          controller: fareController,
                          hintText: 'Fare',
                        ),
                      ),
                      CustomTextField(
                        label:"Available Ingredients",
                        controller: availableIngController,
                        hintText: "Available Ingredients",
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.01.h,
                      bottom: MediaQuery.of(context).size.height * 0.01.h),
                  child: const CustomHorizontalDivider(),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _userImageIcon() {
    return Container(
      height: 80,
      width: 80,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(69.r), color: Colors.white),
      child: Padding(
        padding: const EdgeInsets.all(17.0),
        child: Column(
          children: [
            Container(
              height: 12,
              width: 12,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(69.r),
                  color: Colors.grey),
            ),
            Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(69.r),
                  color: Colors.grey),
            )
          ],
        ),
      ),
    );
  }
}