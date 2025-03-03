import 'package:chief/global_custom_widgets/custom_product_small_container.dart';
import 'package:chief/global_custom_widgets/custom_userinfo_section.dart';
import 'package:chief/model/app_database.dart';
import 'package:chief/model/request_model.dart';
import 'package:chief/provider/chief_dashboard_provider.dart';
import 'package:chief/view/chef_screens/chef_details_screen.dart';
import 'package:chief/view/drawer/user_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:provider/provider.dart';

class UserAssignedOrders extends StatelessWidget {
  UserAssignedOrders({super.key});

  AppDatabase database = AppDatabase();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Assigned Orders',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.deepOrange.shade200,
      ),
      drawer: const UserDrawer(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w),
        child: Consumer<RequestData>(
          builder: (context, requestData, _) {
            return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('food_orders')
                  .where('clientId', isEqualTo: user!.uid)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No active orders."));
                  }

                  final filteredDocs = snapshot.data!.docs.where((doc) {
                    final chefResponses =
                        (doc['chefResponses'] as List<dynamic>?) ?? [];
                    final acceptedChiefId =
                        doc['acceptedChiefId'] as String? ?? '';
                    final orderStatus = doc['orderStatus'] as String? ?? '';
                    return chefResponses.any((response) =>
                        chefResponses.isNotEmpty &&
                        acceptedChiefId != 'noChiefSelected' &&
                        orderStatus == 'assigned');
                  }).toList();

                  return ListView.builder(
                    itemCount: filteredDocs.length,
                    itemBuilder: (BuildContext context, int index) {
                      final request = RequestModel.fromJson(
                        filteredDocs[index].data() as Map<String, dynamic>,
                      );
                      String docId = filteredDocs[index].id;
                      final timestamp = request
                          .timestamp; // Use the timestamp from RequestModel
                      final dateTime = timestamp.toDate();
                      final year = dateTime.year;
                      final month = dateTime.month;
                      final day = dateTime.day;
                      final hour = dateTime.hour;
                      final minute = dateTime.minute;

                      return Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      UserInfoSection(image: ''),
                                      Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.011.h,
                                      ),
                                      SizedBox(
                                        height: 22.h,
                                      ),
                                      CustomProductDetailSmallContainer(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ChefDetailsScreen(
                                                      userid:
                                                          request.chefResponses[
                                                              index]['userId']),
                                            ),
                                          );
                                        },
                                        label: "Chef Details",
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomProductDetailSmallContainer(
                                          label: "Item",
                                          title: request
                                              .itemName), // Use itemName from RequestModel
                                      CustomProductDetailSmallContainer(
                                          label: "People",
                                          title: request
                                              .totalPerson), // Use totalPerson from RequestModel
                                      CustomProductDetailSmallContainer(
                                          label: "Time",
                                          title: request
                                              .arrivalTime), // Use arrivalTime from RequestModel
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomProductDetailSmallContainer(
                                        label: "Fare",
                                        title: request
                                            .fare, // Use fare from RequestModel
                                      ),
                                      CustomProductDetailSmallContainer(
                                        label: "Date",
                                        title: request
                                            .date, // Use date from RequestModel
                                      ),
                                      CustomProductDetailSmallContainer(
                                        label: "Time",
                                        title: request
                                            .eventTime, // Use eventTime from RequestModel
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
                                    height: MediaQuery.of(context).size.height *
                                        0.1,
                                    width: MediaQuery.of(context).size.width *
                                        0.86.w,
                                    decoration: BoxDecoration(
                                        color: Colors.deepOrange.shade200),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Center(
                                          child: SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            const Text(
                                              "Available Ingredients",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(request
                                                .ingredients), // Use ingredients from RequestModel
                                          ],
                                        ),
                                      )),
                                    )),
                              ),
                              // Row(
                              //   mainAxisAlignment:
                              //       MainAxisAlignment.spaceAround,
                              //   children: <Widget>[
                              //     Container(
                              //       color: Colors.deepOrange.shade200,
                              //       child: IconButton(
                              //         icon: const Icon(Icons.close,
                              //             color: Colors.black),
                              //         onPressed: () async {
                              //           database.rejectByClient(
                              //               docId: docId,
                              //               chiefId:
                              //                   request.chefResponses[index]
                              //                       ['userId']);
                              //         },
                              //       ),
                              //     ),
                              //     Container(
                              //       color: Colors.deepOrange.shade200,
                              //       child: IconButton(
                              //         icon: const Icon(Icons.check,
                              //             color: Colors.black),
                              //         onPressed: () async {
                              //           database.acceptedByClient(
                              //               docId: docId,
                              //               chiefId:
                              //                   request.chefResponses[index]
                              //                       ['userId']);
                              //         },
                              //       ),
                              //     ),
                              //   ],
                              // ),
                              // Padding(
                              //   padding: const EdgeInsets.only(
                              //       top: 8, left: 5, right: 5),
                              //   child: Row(
                              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //     children: [
                              //       Text('Date: $day/$month/$year'),
                              //       Text('Time: $hour:$minute')
                              //     ],
                              //   ),
                              // )
                            ],
                          ),
                        ),
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
            );
          },
        ),
      ),
    );
  }
}
