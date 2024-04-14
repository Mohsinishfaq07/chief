import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../../global_custom_widgets/custom_product_small_container.dart';
import '../../global_custom_widgets/custom_userinfo_section.dart';
import '../../model/app_database.dart';
import '../../provider/chief_dashboard_provider.dart';
import '../user_screens/user_details_screen.dart';
import 'chef_drawer.dart';

class ChiefRequestScreen extends StatelessWidget {
  static const String tag = "ChiefRequestScreen";

  ChiefRequestScreen({Key? key}) : super(key: key);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  AppDatabase database = AppDatabase();

  final user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const ChefDrawer(),
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Request Queue', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.pink.shade200,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
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
                    return data['status'] == 'pending'?  Card(
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
        //const RequestCard(),
      ),
    );
  }
}

class RequestCard extends StatefulWidget {
  const RequestCard({Key? key}) : super(key: key);

  @override
  _RequestCardState createState() => _RequestCardState();
}

class _RequestCardState extends State<RequestCard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      // If the user is not logged in, we cannot show the requests
      return Center(child: Text('Please log in to view requests.'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('request_form')
          .where('Action',
          isEqualTo:
          "accepted") // Filtering for documents with an empty 'Action' field
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No pending requests.'));
        }

        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            return RequestListItem(data: data);
          }).toList(),
        );
      },
    );
  }
}

class RequestListItem extends StatelessWidget {
  final Map<String, dynamic> data;

  const RequestListItem({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Timestamp timestamp = data['timestamp'];
    DateTime dateTime = timestamp.toDate();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                UserInfoSection(image: data['image']),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomProductDetailSmallContainer(title: data['Item_Name']),
                    CustomProductDetailSmallContainer(title: data['No_of_People']),
                    CustomProductDetailSmallContainer(title: data['Arrivel_Time']),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomProductDetailSmallContainer(title: data['Fare']),
                    CustomProductDetailSmallContainer(title: data['Date']),
                    CustomProductDetailSmallContainer(title: data['Event_Time']),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(data['Availabe_Ingredients']),
            Text('Date: ${dateTime.day}/${dateTime.month}/${dateTime.year} Time: ${dateTime.hour}:${dateTime.minute}'),
          ],
        ),
      ),
    );
  }
}
