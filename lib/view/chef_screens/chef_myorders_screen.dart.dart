// ignore_for_file: must_be_immutable

import 'package:chief/provider/chief_orders_provider.dart';
 import 'package:chief/global_custom_widgets/custom_small_buttons.dart';
import 'package:chief/model/app_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../global_custom_widgets/custom_product_small_container.dart';
import '../../global_custom_widgets/custom_userinfo_section.dart';
import '../../provider/chief_dashboard_provider.dart';
import '../user_screens/user_details_screen.dart';
import 'chef_drawer.dart';

class ChefDashboardScreen extends StatefulWidget {
  const ChefDashboardScreen({super.key});
  static const String tag = "ChefDashboardScreen";

  @override
  State<ChefDashboardScreen> createState() => _ChefDashboardScreenState();
}

class _ChefDashboardScreenState extends State<ChefDashboardScreen> {
  AppDatabase database = AppDatabase();
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return Scaffold(
        drawer: const ChefDrawer(),
        appBar: AppBar(
            title: const Text('My Orders',
                style: TextStyle(fontWeight: FontWeight.bold)),
            centerTitle: true,
            backgroundColor: Colors.pink.shade200),
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Consumer<RequestData>(builder: (context, requestData, _) {
              return StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('request_form')
                    .where('Action',
                    isEqualTo:
                    "") // Filtering for documents with an empty 'Action' field
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    requestData.updateRequests(snapshot.data!.docs);
                    return ListView.builder(
                      itemCount: requestData.requests.length,
                      itemBuilder: (BuildContext context, int index) {
                        DocumentSnapshot document =
                        requestData.requests[index];
                        Map<String, dynamic>? data =
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
                        return data['status'] == 'approved'?  Card(
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: <Widget>[
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    //   mainAxisAlignment:
                                    // MainAxisAlignment.spaceAround,
                                    children: [
                                      Column(
                                        children: [
                                          UserInfoSection(
                                              image: data['image']),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          CustomProductDetailSmallContainer(
                                              label: "Item",
                                              title: data['Item_Name']),
                                          CustomProductDetailSmallContainer(
                                              label: "Gathering",
                                              title: data['No_of_People']),
                                          CustomProductDetailSmallContainer(
                                              label: "Time",
                                              title: data['Arrivel_Time']),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () {},
                                            // {
                                            //   // Function to show bottom sheet when this widget is tapped
                                            //   _showFareBottomSheet(
                                            //       context,
                                            //       data['Fare'],
                                            //       document.id);
                                            // }
                                            // ,
                                            child:
                                            CustomProductDetailSmallContainer(
                                              label: "Fare",
                                              title: data['Fare'],
                                            ),
                                          ),
                                          CustomProductDetailSmallContainer(
                                            label: "Date",
                                            title: data['Date'],
                                          ),
                                          CustomProductDetailSmallContainer(
                                            label: "Time",
                                            title: data['Event_Time'],
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: MediaQuery.of(context)
                                          .size
                                          .height *
                                          0.006),
                                  child: Container(
                                      height: MediaQuery.of(context)
                                          .size
                                          .height *
                                          0.1,
                                      width: MediaQuery.of(context)
                                          .size
                                          .width *
                                          0.8,
                                      decoration: BoxDecoration(
                                          color: Colors.pink.shade200),
                                      child: Center(
                                          child: Text(data[
                                          'Availabe_Ingredients']))),
                                ),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Container(
                                      color: Colors.pinkAccent.shade100,
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
                                              'pending',
                                              //
                                              ''
                                          );
                                          await requestData.rejectRequest(
                                              context, document.id);
                                          Fluttertoast.showToast(
                                              msg: 'rejected');
                                        },
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                UserDetails(
                                                    userid: data['userid']),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: 100,
                                        height: 40,
                                        color: Colors.pink.shade200,
                                        child: const Center(
                                            child: Text(
                                              'user details',
                                            )),
                                      ),
                                    ),
                                    Container(
                                      color: Colors.pink.shade200,
                                      child: // In ChefPendingRequestsState class
                                      IconButton(
                                        icon: const Icon(Icons.check,
                                            color: Colors.green),
                                        onPressed: () async {
                                          // 'userid': user!.uid,
                                          // 'addedby': userid,
                                          // 'User_Name': name,
                                          // 'Item_Name': itemName,
                                          // 'Date': date,
                                          // 'Arrivel_Time': arrivelTime,
                                          // 'Event_Time': eventTime,
                                          // 'No_of_People': noOfPeople,
                                          // 'Fare': fare,
                                          // 'Action': action,
                                          // 'Availabe_Ingredients': availabeingred,
                                          // 'image': image,
                                          // 'timestamp': FieldValue.serverTimestamp(),
                                          // 'status': status,
                                          database.updateRequest(context, document.id, data['userid'], data['Item_Name'], data['Date'], data['Arrivel_Time'], data['Event_Time'], data['No_of_People'], data['Fare'], data['Availabe_Ingredients'], data['User_Name'], data['image'], 'request_form', data['Action'], 'approved');
                                          //database.updateRequest(context, data['documentId'] ,data['userid'], data['Item_Name'], data['Date'], data['Arrival_Time'], data['Event_Time'], data['No_of_People'], data['Fare'], data['Availabe_Ingredients'], data['name'], data['image'], 'request_form', data['Action'], 'pending');
                                          // database
                                          //     .chefAcceptsRequest(
                                          //         document.id)
                                          //     .catchError((error) {
                                          //   Fluttertoast.showToast(
                                          //       msg: "Error: $error");
                                          // });
                                        },
                                      ),
                                    ),
                                  ],
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
                        ): SizedBox();
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
              );
            })
            ///muhsin code
            // Consumer<MyOrders>(builder: (context, myorders, _) {
            //   return StreamBuilder(
            //     stream: FirebaseFirestore.instance
            //         .collection('new_requestform')
            //         .where('isVisibleToUser', isEqualTo: true)
            //         .snapshots(),
            //     builder: (BuildContext context,
            //         AsyncSnapshot<QuerySnapshot> snapshot) {
            //       if (snapshot.hasData) {
            //         WidgetsBinding.instance.addPostFrameCallback((_) {
            //           // This ensures we are not in the middle of a build call when updating the data.
            //           myorders.updateRequests(snapshot.data!.docs);
            //         });
            //         myorders.updateRequests(snapshot.data!.docs);
            //         return ListView.builder(
            //           itemCount: myorders.orders.length,
            //           itemBuilder: (BuildContext context, int index) {
            //             DocumentSnapshot document = myorders.orders[index];
            //             Map<String, dynamic>? data =
            //                 document.data() as Map<String, dynamic>;
            //             Timestamp timestamp = data['timestamp'];
            //             // Convert Firestore Timestamp to DateTime
            //             DateTime dateTime = timestamp.toDate();
            //             // Extract date and time components
            //             int year = dateTime.year;
            //             int month = dateTime.month;
            //             int day = dateTime.day;
            //             int hour = dateTime.hour;
            //             int minute = dateTime.minute;
            //             return Card(
            //               elevation: 4,
            //               child: Padding(
            //                 padding: const EdgeInsets.all(12),
            //                 child: Column(
            //                   children: <Widget>[
            //                     Row(
            //                       mainAxisAlignment:
            //                           MainAxisAlignment.spaceAround,
            //                       children: [
            //                         Column(
            //                           children: [
            //                             UserInfoSection(image: data['image']),
            //                           ],
            //                         ),
            //                         Column(
            //                           children: [
            //                             CustomProductDetailSmallContainer(
            //                               title: data['Item_Name'],
            //                             ),
            //                             CustomProductDetailSmallContainer(
            //                               title: data['No_of_People'],
            //                             ),
            //                             CustomProductDetailSmallContainer(
            //                               title: data['Arrivel_Time'],
            //                             ),
            //                           ],
            //                         ),
            //                         Column(
            //                           children: [
            //                             CustomProductDetailSmallContainer(
            //                               title: data['Fare'],
            //                             ),
            //                             CustomProductDetailSmallContainer(
            //                               title: data['Date'],
            //                             ),
            //                             CustomProductDetailSmallContainer(
            //                               title: data['Event_Time'],
            //                             ),
            //                           ],
            //                         )
            //                       ],
            //                     ),
            //                     Padding(
            //                       padding: EdgeInsets.symmetric(
            //                           vertical:
            //                               MediaQuery.of(context).size.height *
            //                                   0.006),
            //                       child: Container(
            //                           height:
            //                               MediaQuery.of(context).size.height *
            //                                   0.1,
            //                           width: MediaQuery.of(context).size.width *
            //                               0.8,
            //                           decoration: const BoxDecoration(
            //                               color: Colors.pinkAccent),
            //                           child: Center(
            //                               child: Text(
            //                                   data['Availabe_Ingredients']))),
            //                     ),
            //                     GestureDetector(
            //                       onTap: () {
            //                         showDialog<bool>(
            //                           context: context,
            //                           builder: (context) => AlertDialog(
            //                             backgroundColor: Colors.pinkAccent,
            //                             title: const Text(
            //                               'Cancel Request',
            //                               style: TextStyle(
            //                                   fontWeight: FontWeight.w800,
            //                                   color: Colors.white,
            //                                   fontSize: 20),
            //                             ),
            //                             content: const Text(
            //                               'Do you really want to cancel request?',
            //                               style: TextStyle(
            //                                   color: Colors.white,
            //                                   fontSize: 14),
            //                             ),
            //                             actions: [
            //                               Row(
            //                                 mainAxisAlignment:
            //                                     MainAxisAlignment.spaceAround,
            //                                 children: [
            //                                   CustomSmallButton(
            //                                       title: "No",
            //                                       ontap: () {
            //                                         Navigator.of(context)
            //                                             .pop(true);
            //                                       }),
            //                                   CustomSmallButton(
            //                                       title: "Yes",
            //                                       ontap: () {
            //                                         myorders.rejectRequest(document.id);
            //                                         Navigator.of(context)
            //                                             .pop(true);
            //                                       }),
            //                                 ],
            //                               ),
            //                             ],
            //                           ),
            //                         );
            //                       },
            //                       child: Container(
            //                         width:
            //                             MediaQuery.of(context).size.width * 0.8,
            //                         height: 50,
            //                         color: Colors.pinkAccent,
            //                         child: const Center(
            //                             child: Text('Cancel Request')),
            //                       ),
            //                     ),
            //                     Padding(
            //                       padding: const EdgeInsets.only(
            //                           top: 8, left: 5, right: 5),
            //                       child: Row(
            //                         mainAxisAlignment:
            //                             MainAxisAlignment.spaceBetween,
            //                         children: [
            //                           Text('Date: $day/$month/$year'),
            //                           Text('Time: $hour:$minute')
            //                         ],
            //                       ),
            //                     )
            //                   ],
            //                 ),
            //               ),
            //             );
            //           },
            //         );
            //       } else if (snapshot.hasError) {
            //         return Text('Error: ${snapshot.error}');
            //       } else {
            //         return const Center(
            //             child: CircularProgressIndicator(
            //           color: Colors.pink,
            //         )); // Or any other loading indicator
            //       }
            //     },
            //   );
            // })
        ));
  }
}
