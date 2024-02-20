// ignore_for_file: deprecated_member_use, must_be_immutable

import 'package:chief/provider/user_myorders_provider.dart';
import 'package:chief/view/user_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../global_custom_widgets/custom_product_smallcontainer.dart';
import '../global_custom_widgets/custom_small_buttons.dart';
import '../global_custom_widgets/custom_userinfo_section.dart';

class DashboardRequestScreen extends StatelessWidget {
  DashboardRequestScreen({super.key});
  static const String tag = "DashboardRequestScreen";

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
          title: const Text('My Orders',
              style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.pink.shade200),
      drawer: const CustomDrawer(),
      body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Consumer<UserMyOrders>(builder: (context, myorders, _) {
            return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('accepted_requests')
                  .where('userid', isEqualTo: user!.uid)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  myorders.updateRequests(snapshot.data!.docs);
                  return Expanded(
                    child: ListView.builder(
                      itemCount: myorders.myorders.length,
                      itemBuilder: (BuildContext context, int index) {
                        DocumentSnapshot document = myorders.myorders[index];
                        Map<String, dynamic> data =
                            document.data() as Map<String, dynamic>;
                        Timestamp timestamp = data['timestamp'];
                        // Convert Firestore Timestamp to DateTime
                        DateTime dateTime = timestamp.toDate();
                        // Extract date and time components
                        int year = dateTime.year;
                        int month = dateTime.month;
                        int day = dateTime.day;
                        int hour = dateTime.hour;
                        int minute = dateTime.minute;
                        return Card(
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Column(
                                      children: [
                                        UserInfoSection(
                                            image: data['image'] ?? ''),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        CustomProductDetailSmallContainer(
                                          title: data['Item_Name'],
                                        ),
                                        CustomProductDetailSmallContainer(
                                          title: data['No_of_People'],
                                        ),
                                        CustomProductDetailSmallContainer(
                                          title: data['Arrivel_Time'],
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        CustomProductDetailSmallContainer(
                                          title: data['Fare'],
                                        ),
                                        CustomProductDetailSmallContainer(
                                          title: data['Date'],
                                        ),
                                        CustomProductDetailSmallContainer(
                                          title: data['Event_Time'],
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical:
                                          MediaQuery.of(context).size.height *
                                              0.006),
                                  child: Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.1,
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      decoration: const BoxDecoration(
                                          color: Colors.pinkAccent),
                                      child: Center(
                                          child: Text(
                                              data['Availabe_Ingredients']))),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        backgroundColor: Colors.pinkAccent,
                                        title: Text(
                                          'Cancel Request',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                              fontSize: 20.sp),
                                        ),
                                        content: Text(
                                          'Do you really want to cancel request?',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14.sp),
                                        ),
                                        actions: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              CustomSmallButton(
                                                  title: "No",
                                                  ontap: () {
                                                    Navigator.of(context)
                                                        .pop(true);
                                                  }),
                                              CustomSmallButton(
                                                  title: "Yes",
                                                  ontap: () {
                                                    myorders.rejectRequest(
                                                        document.id);
                                                    Navigator.of(context)
                                                        .pop(true);
                                                  }),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
                                    height: 50,
                                    color: Colors.pinkAccent,
                                    child: const Center(
                                        child: Text('Cancel Request')),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 8, left: 5, right: 5),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Date: $day/$month/$year'),
                                      Text('Time: $hour:$minute')
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return const Center(
                      child: CircularProgressIndicator(
                    color: Colors.pink,
                  )); // Or any other loading indicator
                }
              },
            );
          })),
    );
  }
}
