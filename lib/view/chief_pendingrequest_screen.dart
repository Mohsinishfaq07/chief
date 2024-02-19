// ignore_for_file: deprecated_member_use

import 'package:chief/global_custom_widgets/custom_small_buttons.dart';
import 'package:chief/model/app_database.dart';
import 'package:chief/view/chief_drawer.dart';
import 'package:chief/view/user_details_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chief/view/chief_requestqueue_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../global_custom_widgets/custom_product_smallcontainer.dart';

class ShiefPendingRequest extends StatefulWidget {
  const ShiefPendingRequest({super.key});
  static const String tag = "ShiefPendingRequest";

  @override
  State<ShiefPendingRequest> createState() => _ShiefPendingRequestState();
}

class _ShiefPendingRequestState extends State<ShiefPendingRequest> {
  AppDatabase database = AppDatabase();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void removeRequest(String id) {
    // Delete document from Firestore
    FirebaseFirestore.instance
        .collection('request_form')
        .doc(id)
        .delete()
        .then((_) {
      if (kDebugMode) {
        print('Document successfully deleted from Firestore');
      }
    }).catchError((error) {
      if (kDebugMode) {
        print('Error deleting document: $error');
      }
    });
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
          drawer: const ShiefDrawer(),
            appBar: AppBar(
                title: const Text('My Requests',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                centerTitle: true,
                backgroundColor: Colors.pink.shade200),
            body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('request_form')
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (BuildContext context, int index) {
                          DocumentSnapshot document =
                              snapshot.data!.docs[index];
                          Map<String, dynamic>? data =
                              document.data() as Map<String, dynamic>;
                          String documentId =
                              document.id; // Get document ID here
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
                                          UserInfoSection(image: data['image']),
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
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.8,
                                        decoration: const BoxDecoration(
                                            color: Colors.pinkAccent),
                                        child: Center(
                                            child: Text(
                                                data['Availabe_Ingredients']))),
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
                                                'new_requestform',
                                                'rejected');
                                            setState(() {
                                              removeRequest(documentId);
                                              Fluttertoast.showToast(
                                                  msg: 'rejected');
                                            });
                                          },
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => UserDetails(
                                                  userid: data['userid']),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          width: 100,
                                          height: 40,
                                          color: Colors.pinkAccent,
                                          child: const Center(
                                              child: Text(
                                            'user details',
                                          )),
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
                                                'new_requestform',
                                                'accepted');
                                            Fluttertoast.showToast(
                                                msg: 'accepted');
                                            setState(() {
                                              removeRequest(documentId);
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                padding: const EdgeInsets.only(top: 8,left: 5,right: 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                ))));
  }
}
