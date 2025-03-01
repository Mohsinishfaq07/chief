import 'package:chief/model/app_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../global_custom_widgets/custom_product_small_container.dart';
import '../../global_custom_widgets/custom_userinfo_section.dart';
import '../../model/request_model.dart'; // Import the RequestModel
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
    return Scaffold(
      drawer: const ChefDrawer(),
      appBar: AppBar(
        title: const Text('My Orders',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.deepOrange.shade200,
      ),
      body: Consumer<RequestData>(
        builder: (context, requestData, _) {
          return StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('food_orders') // Use the correct collection name
                .where('acceptedChiefId',
                    isEqualTo: user!.uid) // Filter by acceptedChiefId
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                // Parse Firestore data into RequestModel
                final requests = snapshot.data!.docs
                    .map((doc) => RequestModel.fromJson(
                          doc.data() as Map<String, dynamic>,
                        ))
                    .toList();

                if (requests.isEmpty) {
                  return const Center(child: Text("No active orders."));
                }

                return ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (BuildContext context, int index) {
                    final request = requests[index];
                    // final timestamp = request.timestamp; // Use the timestamp from RequestModel
                    // final dateTime = timestamp.toDate();
                    // final year = dateTime.year;
                    // final month = dateTime.month;
                    // final day = dateTime.day;
                    // final hour = dateTime.hour;
                    // final minute = dateTime.minute;

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
                                          UserInfoSection(image: ''),
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
                                            label: 'User Details',
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => UserDetails(
                                                      userid: request
                                                          .clientId), // Use clientId from RequestModel
                                                ),
                                              );
                                            },
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
                                              label: "Gathering",
                                              title: request
                                                  .totalPerson), // Use totalPerson from RequestModel
                                          CustomProductDetailSmallContainer(
                                              label: "Time",
                                              title: request
                                                  .arrivalTime), // Use arrivalTime from RequestModel
                                        ],
                                      ),
                                      Column(
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
                                      ),
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
                                          0.86.w,
                                      decoration: BoxDecoration(
                                        color: Colors.deepOrange.shade200,
                                      ),
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
                                                          FontWeight.bold),
                                                ),
                                                Text(request
                                                    .ingredients), // Use ingredients from RequestModel
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
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
                                            await requestData.rejectRequest(
                                                context,
                                                snapshot.data!.docs[index].id);
                                            Fluttertoast.showToast(
                                                msg: 'Rejected');
                                          },
                                        ),
                                      ),
                                      Container(
                                        color: Colors.deepOrange.shade200,
                                        child: IconButton(
                                          icon: const Icon(Icons.check,
                                              color: Colors.black),
                                          onPressed: () async {
                                            // Handle order completion logic here
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Padding(
                                  //   padding: const EdgeInsets.only(top: 8, left: 5, right: 5),
                                  //   child: Row(
                                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  //     children: [
                                  //       Text('Date: $day/$month/$year'),
                                  //       Text('Time: $hour:$minute'),
                                  //     ],
                                  //   ),
                                  // ),
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
                  ),
                ); // Or any other loading indicator
              }
            },
          );
        },
      ),
    );
  }
}
