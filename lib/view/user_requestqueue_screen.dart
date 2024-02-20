// ignore_for_file: deprecated_member_use, must_be_immutable

import 'package:chief/provider/user_requestqueue_provider.dart';
import 'package:chief/view/chief_details_screen.dart';
import 'package:chief/view/user_drawer.dart';
import 'package:chief/model/app_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../global_custom_widgets/custom_product_smallcontainer.dart';
import '../global_custom_widgets/custom_userinfo_section.dart';

class MyRequestScreen extends StatefulWidget {
  const MyRequestScreen({super.key});
  static const String tag = "MyRequestScreen";

  @override
  State<MyRequestScreen> createState() => _MyRequestScreenState();
}

class _MyRequestScreenState extends State<MyRequestScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  AppDatabase database = AppDatabase();

  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
          title: const Text('Request Queue',
              style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.pink.shade200),
      drawer: const CustomDrawer(),
      body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child:
              Consumer<UserRequsetQueue>(builder: (context, requestQueue, _) {
            return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('new_requestform')
                  .where('addedby', isEqualTo: user!.uid)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  requestQueue.updateRequests(snapshot.data!.docs);
                  return Expanded(
                    child: ListView.builder(
                      itemCount: requestQueue.requests.length,
                      itemBuilder: (BuildContext context, int index) {
                        DocumentSnapshot document =
                            requestQueue.requests[index];
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
                                      child:
                                          Center(child: Text(data['Action']))),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Container(
                                      color: Colors.pinkAccent,
                                      child: IconButton(
                                        icon: const Icon(Icons.close,
                                            color: Colors.black),
                                        onPressed: () async {
                                          requestQueue
                                              .rejectRequest(document.id);
                                        },
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ChefDetails(
                                                userid: data['userid']),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: 100,
                                        height: 40,
                                        color: Colors.pinkAccent,
                                        child: const Center(
                                            child: Text('chief details')),
                                      ),
                                    ),
                                    Container(
                                      color: Colors.pinkAccent,
                                      child: IconButton(
                                        icon: const Icon(Icons.check,
                                            color: Colors.black),
                                        onPressed: () async {
                                          await database.addrequest(
                                              context,
                                              data['userid'],
                                              data['Item_Name'],
                                              data['Date'],
                                              data['Arrivel_Time'],
                                              data['Event_Time'],
                                              data['No_of_People'],
                                              data['Fare'],
                                              data['Availabe_Ingredients'],
                                              data['User_Name'],
                                              data['image'],
                                              'accepted_requests',
                                              'accepted');
                                          Fluttertoast.showToast(
                                              msg: 'accepted');
                                          requestQueue
                                              .rejectRequest(document.id);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, left: 5, right: 5),
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
