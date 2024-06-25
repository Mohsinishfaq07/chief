// ignore_for_file: deprecated_member_use

import 'package:chief/global_custom_widgets/custom_small_buttons.dart';
import 'package:chief/global_custom_widgets/custom_text_form_field.dart';
import 'package:chief/model/app_database.dart';
import 'package:chief/view/user_screens/user_details_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../global_custom_widgets/custom_product_small_container.dart';
import '../../global_custom_widgets/custom_userinfo_section.dart';
import '../drawer/chef_drawer.dart';

class ChefDashboardScreen extends StatefulWidget {
  const ChefDashboardScreen({super.key});
  static const String tag = "ChefDashboardScreen";

  @override
  State<ChefDashboardScreen> createState() => _ChefDashboardScreenState();
}

class _ChefDashboardScreenState extends State<ChefDashboardScreen> {
  AppDatabase database = AppDatabase();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController fareController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;
  int fare = 0;
  Map<String, bool> visibleRequests = {};
  void _hideRequestTemporarily(String documentId) {
    setState(() {
      visibleRequests[documentId] = false;
    });
    Future.delayed(const Duration(seconds: 30), () {
      setState(() {
        visibleRequests[documentId] = true;
      });
    });
  }

  void _submitNewFare(String chefId, String newFare) async {
    Fluttertoast.showToast(
        msg: "fare $newFare updated please approve the request!");
    // var chefDocumentReference = FirebaseFirestore.instance.collection('chief_users').doc(chefId);

    // chefDocumentReference.update({
    //   'newFare': newFare,
    //   'farePendingApproval': true
    // }).then((_) {
    //   Fluttertoast.showToast(msg: "New fare submitted for approval");
    // }).catchError((error) {
    //   Fluttertoast.showToast(msg: "Error submitting new fare: $error");
    // });
  }

  void _showFareUpdateDialog(String documentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Submit New Fare"),
          content: CustomTextField(
            controller: fareController,
            hintText: "Enter new fare",
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          actions: <Widget>[
            CustomSmallButton(
              title: "Cancel",
              ontap: () => Navigator.of(context).pop(),
            ),
            CustomSmallButton(
              title: "Submit",
              ontap: () {
                String newFare = fareController.text.trim();
                if (newFare.isNotEmpty) {
                  fare = int.parse(newFare);
                  _submitNewFare(documentId, newFare);
                  Navigator.of(context).pop();
                } else {
                  Fluttertoast.showToast(msg: "Please enter a fare");
                }
              },
            ),
          ],
        );
      },
    );
  }

  Map<String, bool> handledRequests = {};
  void _handleRequest(String documentId, Map<String, dynamic> data) {
    if (handledRequests[documentId] ?? false) {
      Fluttertoast.showToast(msg: "You've already handled this request.");
      return;
    }

    // Assume addShiefrRequest handles the database operation and takes necessary parameters
    database.addChefRequest(
        context,
        documentId,
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
        'shiefrequests',
        data['Rating'] ?? "",
        fare);

    // Mark this request as handled
    setState(() {
      handledRequests[documentId] = true;
    });

    Fluttertoast.showToast(msg: "Request successfully processed.");
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
                backgroundColor: Colors.deepOrange.shade200,
                title: const Text(
                  'Exit App',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontSize: 20),
                ),
                content: const Text(
                  'Do you really want to exit the app?',
                  style: TextStyle(color: Colors.white, fontSize: 14),
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
                            SystemNavigator.pop();
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
            backgroundColor: Colors.deepOrange.shade200,
            drawer: const ChefDrawer(),
            appBar: AppBar(
                title: const Text('All Requests',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                centerTitle: true,
                backgroundColor: Colors.deepOrange.shade200),
            body: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('chief_users')
                    .doc(user!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var data = snapshot.data!.data();
                    if (data != null && data.containsKey('Rating')) {
                      // Accessing specific field
                      // Do something with fieldValue
                    }
                  }
                  return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('request_form')
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasData) {
                            //requestData.updateRequests(snapshot.data!.docs);
                            return ListView.builder(
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (BuildContext context, int index) {
                                DocumentSnapshot document =
                                    snapshot.data!.docs[index];
                                Map<String, dynamic>? data =
                                    document.data() as Map<String, dynamic>;

                                String documentId = document.id;
                                String itemName =
                                    data['Item_Name'] ?? 'Unknown item';
                                String arrivalTime =
                                    data['Arrivel_Time'] ?? 'No time set';
                                String eventTime =
                                    data['Event_Time'] ?? 'No time set';
                                String fare =
                                    data['Fare']?.toString() ?? 'No fare';
                                String noofpeople =
                                    data['No_of_people'] ?? 'No fare';
                                String availableIngredients =
                                    data['Availabe_Ingredients'] ?? '';

                                // Check if the request should be visible
                                if (!visibleRequests.containsKey(documentId)) {
                                  visibleRequests[documentId] = true;
                                }

                                if (!visibleRequests[documentId]!) {
                                  return Container(); // Returns an empty container to hide the request
                                }

                                Timestamp timestamp = data['timestamp'];
                                // Convert Firestore Timestamp to DateTime
                                DateTime dateTime = timestamp.toDate();
                                // Extract date and time components
                                int year = dateTime.year;
                                int month = dateTime.month;
                                int day = dateTime.day;
                                int hour = dateTime.hour;
                                int minute = dateTime.minute;
                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10.r),
                                          color: Colors.white,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(6),
                                          child: Column(
                                            children: <Widget>[
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Column(
                                                    children: [
                                                      UserInfoSection(
                                                          image:
                                                              data['image'] ??
                                                                  ""),
                                                      // Text(data['Name']),
                                                      Container(
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.011.h,

                                                      ),
                                                      SizedBox(height: 22.h,),
                                                      GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  UserDetails(
                                                                      userid: data[
                                                                          'userid']),
                                                            ),
                                                          );
                                                        },
                                                        child: Container(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.06.h,
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.26.w,
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal: 2,
                                                                  vertical: 2),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .deepOrange
                                                                .shade200,
                                                             borderRadius: BorderRadius.circular(10),
                                                          ),
                                                          child: const Center(
                                                              child: Text(
                                                            'User Details',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          )),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      CustomProductDetailSmallContainer(
                                                          label: "Item",
                                                          title: itemName),
                                                      CustomProductDetailSmallContainer(
                                                          label: "People",
                                                          title: noofpeople),
                                                      CustomProductDetailSmallContainer(
                                                          label: "Arrival",
                                                          title: arrivalTime),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          _showFareUpdateDialog(
                                                              document.id);
                                                        },
                                                        child:
                                                            CustomProductDetailSmallContainer(
                                                          label: "Fare",
                                                          title: fare,
                                                        ),
                                                      ),
                                                      CustomProductDetailSmallContainer(
                                                        label: "Date",
                                                        title: data['Date'],
                                                      ),
                                                      CustomProductDetailSmallContainer(
                                                        label: "Event ",
                                                        title: eventTime,
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.006),
                                                child: Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.1,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.9,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                           BorderRadius.circular(10),
                                                      color: Colors
                                                          .deepOrange.shade200,
                                                    ),
                                                    child: Center(
                                                        child: SingleChildScrollView(
                                                          child: Column(
                                                                                                                mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                                                                                children: [
                                                          const Text(
                                                            "Available Ingredients ",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          Text(
                                                              availableIngredients),
                                                                                                                ],
                                                                                                              ),
                                                        ))),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: <Widget>[
                                                  IconButton(
                                                    icon:   const Icon(
                                                        Icons.close,
                                                        color: Colors.black,
                                                      applyTextScaling: true,
                                                     ),
                                                    onPressed: () async {
                                                      _hideRequestTemporarily(
                                                          documentId);
                                                    },
                                                  ),
                                                  IconButton(
                                                                                                        icon: const Icon(
                                                    Icons.check,
                                                    color: Colors.black),
                                                                                                        onPressed: () =>
                                                    _handleRequest(
                                                        documentId, data),
                                                                                                      ),
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8, left: 5, right: 5),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                        'Date: $day/$month/$year'),
                                                    Text('Time: $hour:$minute')
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                );
                              },
                            );
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            return Center(
                                child: CircularProgressIndicator(
                              color: Colors.pink.shade200,
                            )); // Or any other loading indicator
                          }
                        },
                      ));
                })));
  }
}
