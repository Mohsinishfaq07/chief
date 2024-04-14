// ignore_for_file: deprecated_member_use

import 'package:chief/global_custom_widgets/custom_large_button.dart';
import 'package:chief/global_custom_widgets/custom_small_buttons.dart';
import 'package:chief/global_custom_widgets/custom_text_form_field.dart';
import 'package:chief/model/app_database.dart';
import 'package:chief/provider/chief_dashboard_provider.dart';
import 'package:chief/view/user_screens/user_details_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../../global_custom_widgets/custom_product_small_container.dart';
import '../../global_custom_widgets/custom_userinfo_section.dart';
import 'chef_drawer.dart';

class ChefPendingRequests extends StatefulWidget {
  const ChefPendingRequests({super.key});
  static const String tag = "ShiefPendingRequest";

  @override
  State<ChefPendingRequests> createState() => _ChefPendingRequestsState();
}

class _ChefPendingRequestsState extends State<ChefPendingRequests> {
  AppDatabase database = AppDatabase();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
            drawer: const ChefDrawer(),
            appBar: AppBar(
                title: const Text('All Requests',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                centerTitle: true,
                backgroundColor: Colors.pink.shade200),
            body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child:
                    Consumer<RequestData>(builder: (context, requestData, _) {
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
                            return data['status'] == 'pending' || data['status'] == ''? Card(
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
                                              
                                              database.updateRequest(context, document.id, data['userid'], data['Item_Name'], data['Date'], data['Arrivel_Time'], data['Event_Time'], data['No_of_People'], data['Fare'], data['Availabe_Ingredients'], data['User_Name'], data['image'], 'request_form', data['Action'], 'pending');


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
                }))));
  }

  // void _showFareBottomSheet(
  //     BuildContext context, String fare, String documentId) {
  //   final TextEditingController fareController = TextEditingController();
  //   showModalBottomSheet(
  //     backgroundColor: Colors.pinkAccent.shade200,
  //     context: context,
  //     builder: (BuildContext bc) {
  //       return SizedBox(
  //         height: 250, // Adjust the height as needed
  //         child: Padding(
  //           padding: const EdgeInsets.all(16.0),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: <Widget>[
  //               const Text("Update Fare",
  //                   style: TextStyle(
  //                       fontSize: 20,
  //                       fontWeight: FontWeight.bold,
  //                       color: Colors.white)),
  //               const SizedBox(height: 10), //
  //               // For spacing
  //               Align(
  //                 alignment: Alignment.center,
  //                 child: CustomTextField(
  //                   controller: fareController,
  //                   hintText: "Enter new fare",
  //                   keyboardType: TextInputType.number,
  //                   label: 'New Fare',
  //                 ),
  //               ),
  //               CustomLargeButton(
  //                 title: "Update",
  //                 ontap: () {
  //                   String newFare = fareController.text.trim();
  //                   if (newFare.isNotEmpty) {
  //                     // Call the method to update the fare in Firestore
  //                     _updateFare(documentId, newFare, context);
  //                   }
  //                 },
  //               )
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  // void _updateFare(
  //     String documentId, String newFare, BuildContext context) async {
  //   // Reference to Firestore collection
  //   CollectionReference requests =
  //       FirebaseFirestore.instance.collection('request_form');
  //
  //   // Update the document
  //   await requests.doc(documentId).update({'Fare': newFare}).then((_) {
  //     Navigator.pop(context); // Close the bottom sheet
  //     Fluttertoast.showToast(msg: "Fare updated successfully");
  //   }).catchError((error) {
  //     Fluttertoast.showToast(msg: "Error updating fare: $error");
  //   });
  // }
}
