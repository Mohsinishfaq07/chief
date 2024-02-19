import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// ignore_for_file: deprecated_member_use, must_be_immutable
import 'package:chief/model/app_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../global_custom_widgets/custom_product_smallcontainer.dart';

class ChiefRequestScreen extends StatelessWidget {
  ChiefRequestScreen({super.key});
  static const String tag = "ChiefRequestScreen";

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
          title: const Text('Request Queue',
              style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.pink.shade200),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: const RequestCard(),
      ),
    );
  }
}

class RequestCard extends StatefulWidget {
  const RequestCard({super.key});

  @override
  State<RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<RequestCard> {
  AppDatabase database = AppDatabase();
  final user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('new_requestform')
          .where('userid', isEqualTo: user!.uid)
          .where('Action', isEqualTo: 'accepted')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          return Expanded(
            child: ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (BuildContext context, int index) {
                DocumentSnapshot document = snapshot.data!.docs[index];
                Map<String, dynamic> data =
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
                                UserInfoSection(image: data['image'] ?? ''),
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
                                  MediaQuery.of(context).size.height * 0.006),
                          child: Container(
                              height: MediaQuery.of(context).size.height * 0.1,
                              width: MediaQuery.of(context).size.width * 0.8,
                              decoration:
                                  const BoxDecoration(color: Colors.pinkAccent),
                              child: Center(child: Text(data['Availabe_Ingredients']))),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 8, left: 5, right: 5),
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
            ),
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
    );
  }
}

class UserInfoSection extends StatelessWidget {
  UserInfoSection({super.key, required this.image});
  String image;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        CircleAvatar(
            radius: 40,
            child: ClipOval(
                child: image == ""
                    ? const Icon(
                        Icons.person,
                        size: 30,
                      )
                    : Image.network(
                        image,
                        fit: BoxFit.cover,
                        width: 80,
                        height: 80,
                      ))),
      ],
    );
  }
}
