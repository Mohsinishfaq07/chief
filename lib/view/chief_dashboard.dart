// ignore_for_file: must_be_immutable

import 'package:chief/view/chief_drawer.dart';
import 'package:chief/global_custom_widgets/custom_small_buttons.dart';
import 'package:chief/model/app_database.dart';
import 'package:chief/view/user_dashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ShiefDashboardScreen extends StatefulWidget {
  const ShiefDashboardScreen({super.key});
  static const String tag = "ShiefDashboardScreen";

  @override
  State<ShiefDashboardScreen> createState() => _ShiefDashboardScreenState();
}

class _ShiefDashboardScreenState extends State<ShiefDashboardScreen> {
  AppDatabase database = AppDatabase();
  final user = FirebaseAuth.instance.currentUser;

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
    // ignore: deprecated_member_use
    return Scaffold(
      //  key: _scaffoldKey,
      drawer: const ShiefDrawer(),
      appBar: AppBar(
          title: const Text('My Orders',
              style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.pink.shade200),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('accepted_requests')
                .where('addedby', isEqualTo: user!.uid)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    DocumentSnapshot document = snapshot.data!.docs[index];
                    Map<String, dynamic>? data =
                        document.data() as Map<String, dynamic>;
                    String documentId = document.id; // Get document ID here
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
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                  vertical: MediaQuery.of(context).size.height *
                                      0.006),
                              child: Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.1,
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  decoration: const BoxDecoration(
                                      color: Colors.pinkAccent),
                                  child: Center(
                                      child:
                                          Text(data['Availabe_Ingredients']))),
                            ),
                            GestureDetector(
                              onTap: () {
                                showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: Colors.pinkAccent,
                                    title: const Text(
                                      'Cancel Request',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          fontSize: 20),
                                    ),
                                    content: const Text(
                                      'Do you really want to cancel request?',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 14),
                                    ),
                                    actions: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          CustomSmallButton(
                                              title: "No",
                                              ontap: () {
                                                Navigator.of(context).pop(true);
                                              }),
                                          CustomSmallButton(
                                              title: "Yes",
                                              ontap: () {
                                                removeRequest(documentId);
                                                Navigator.of(context).pop(true);
                                              }),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                height: 50,
                                color: Colors.pinkAccent,
                                child:
                                    const Center(child: Text('Cancel Request')),
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
          )),
    );
  }
}
