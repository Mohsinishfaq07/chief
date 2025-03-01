// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:chief/model/app_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../global_custom_widgets/custom_product_small_container.dart';
import '../../global_custom_widgets/custom_userinfo_section.dart';
import '../../provider/chief_dashboard_provider.dart';
import '../drawer/chef_drawer.dart';
import '../user_screens/user_details_screen.dart';

class ChefMyOrderScreen extends StatefulWidget {
  const ChefMyOrderScreen({super.key});
  static const String tag = "ChefMyOrderScreen";

  @override
  State<ChefMyOrderScreen> createState() => _ChefMyOrderScreenState();
}

class _ChefMyOrderScreenState extends State<ChefMyOrderScreen> {
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
            backgroundColor: Colors.deepOrange.shade200),
        body: Consumer<RequestData>(builder: (context, requestData, _) {
          return StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('accepted_requests')
                .where('shiefid',
                    isEqualTo: user!
                        .uid) // Filtering for documents with an empty 'Action' field
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                //  requestData.updateRequests(snapshot.data!.docs);
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    DocumentSnapshot document = snapshot.data!.docs[index];
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
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(26.r),
                              color: Colors.white,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Column(
                                        children: [
                                          UserInfoSection(image: data['image']),
                                          Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.011.h,
                                          ),
                                          SizedBox(
                                            height: 22.h,
                                          ),
                                          CustomProductDetailSmallContainer(
                                            label: 'user details',
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      UserDetails(
                                                          userid:
                                                              data['userid']),
                                                ),
                                              );
                                            },
                                          )
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                              title: data['Fare'].toString(),
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
                                                0.86.w,
                                        decoration: BoxDecoration(
                                            color: Colors.deepOrange.shade200),
                                        child: Center(
                                            child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                const Text(
                                                    "Available Ingredients",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Text(data[
                                                    'Availabe_Ingredients']),
                                              ],
                                            ),
                                          ),
                                        ))),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Container(
                                        color: Colors.deepOrange.shade200,
                                        child: IconButton(
                                          icon: const Icon(Icons.close,
                                              color: Colors.black),
                                          onPressed: () async {
                                            // await database.addRequest(
                                            //     context,
                                            //     data['userid'],
                                            //     data['Item_Name'],
                                            //     data['Date'],
                                            //     data['Arrivel_Time'],
                                            //     data['Event_Time'],
                                            //     data['No_of_People'],
                                            //     data['Fare'],
                                            //     data['Availabe_Ingredients'],
                                            //     data['User_Name'],
                                            //     data['image'],
                                            //     'new_requestform',
                                            //     'pending',
                                            //     //
                                            //     '',
                                            //     'chief_number');
                                            await requestData.rejectRequest(
                                                context, document.id);
                                            Fluttertoast.showToast(
                                                msg: 'rejected');
                                          },
                                        ),
                                      ),
                                      Container(
                                        color: Colors.deepOrange.shade200,
                                        child: // In ChefPendingRequestsState class
                                            IconButton(
                                          icon: const Icon(Icons.check,
                                              color: Colors.black),
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
                                            //  database.updateRequest(context, document.id, data['userid'], data['Item_Name'], data['Date'], data['Arrivel_Time'], data['Event_Time'], data['No_of_People'], data['Fare'], data['Availabe_Ingredients'], data['User_Name'], data['image'], 'request_form', data['Action'], 'approved');
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
                          ),
                        ),
                        SizedBox(height: 10.h),
                      ],
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return Center(
                    child: CircularProgressIndicator(
                  color: Colors.deepOrange.shade200,
                )); // Or any other loading indicator
              }
            },
          );
        }));
  }
}
