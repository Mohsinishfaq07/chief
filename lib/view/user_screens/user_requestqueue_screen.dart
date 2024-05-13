 import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../global_custom_widgets/custom_product_small_container.dart';
import '../../global_custom_widgets/custom_userinfo_section.dart';
import '../../model/app_database.dart';
import '../chef_screens/chef_details_screen.dart';
import '../drawer/user_drawer.dart';

class UserRequestQueueScreen extends StatefulWidget {
  const UserRequestQueueScreen({super.key});
  static const tag = 'UserRequestQueScreen';

  @override
  State<UserRequestQueueScreen> createState() => _UserRequestQueueScreenState();
}

class _UserRequestQueueScreenState extends State<UserRequestQueueScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  AppDatabase database = AppDatabase();

  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
          title: const Text('Request Queue ',
              style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.pink.shade200),
      drawer: const UserDrawer(),
      body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('shiefrequests')
                .where('userid', isEqualTo: user!.uid)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                // requestData.updateRequests(snapshot.data!.docs);
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    DocumentSnapshot document = snapshot.data!.docs[index];
                    Map<String, dynamic>? data =
                        document.data() as Map<String, dynamic>;
                    Timestamp timestamp = data['timestamp'];
                    // Convert Firestore Timestamp to DateTime
                    DateTime dateTime = timestamp.toDate();
                    int newfare = data['New_fare'] == 0
                        ? data['Fare']
                        : data['New_fare'];
                    // Extract date and time components
                    int year = dateTime.year;
                    int month = dateTime.month;
                    int day = dateTime.day;
                    int hour = dateTime.hour;
                    int minute = dateTime.minute;
                    return Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    UserInfoSection(image: data['image']),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomProductDetailSmallContainer(
                                        label: "Arrival",
                                        title: data['Arrivel_Time']),
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
                                      child: CustomProductDetailSmallContainer(
                                        label: "Fare",
                                        title: data['New_fare'] == 0
                                            ? data['Fare'].toString()
                                            : "${data['Fare']}+${data['New_fare'] - data['Fare']}",
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                      child: CustomProductDetailSmallContainer(
                                        label: "Dish",
                                        title: data['Item_Name'],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        database.addacceptedRequest(
                                          context,
                                          data['userid'],
                                          data['shiefid'],
                                          data['Item_Name'],
                                          data['Date'],
                                          data['Arrivel_Time'],
                                          data['Event_Time'],
                                          data['No_of_People'],
                                          newfare,
                                          data['Availabe_Ingredients'],
                                          data['User_Name'],
                                          data['image'],
                                          'accepted_requests',
                                        );
                                        await FirebaseFirestore.instance
                                            .collection('shiefrequests')
                                            .doc(document.id)
                                            .delete();
                                        await FirebaseFirestore.instance
                                            .collection('request_form')
                                            .doc(
                                              data['oldDocumentid'],
                                            )
                                            .delete();
                                      },
                                      child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: Colors.pink.shade200,
                                          ),
                                          child: const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              "Accept",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          )),
                                    ),
                                  ],
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
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ChefDetailsScreen(
                                                      userid:
                                                          data['shiefid'])));
                                    },
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              22,
                                      width:
                                          MediaQuery.of(context).size.width / 4,
                                      decoration: BoxDecoration(
                                          color: Colors.pink.shade200),
                                      child: const Center(
                                          child: Text("ChiefDetails")),
                                    ),
                                  ),
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
                return Center(
                    child: CircularProgressIndicator(
                  color: Colors.pink.shade200,
                )); // Or any other loading indicator
              }
            },
          )),
    );
  }
}
