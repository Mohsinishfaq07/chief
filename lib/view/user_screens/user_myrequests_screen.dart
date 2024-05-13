// ignore_for_file: deprecated_member_use, must_be_immutable

 import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../global_custom_widgets/custom_product_small_container.dart';
import '../../global_custom_widgets/custom_userinfo_section.dart';
import '../drawer/user_drawer.dart';

class PendingRequestScreen extends StatefulWidget {
  const PendingRequestScreen({super.key});
  static const String tag = "PendingRequestScreen";

  @override
  State<PendingRequestScreen> createState() => _PendingRequestScreenState();
}

class _PendingRequestScreenState extends State<PendingRequestScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
          title: const Text('My Requests',
              style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.pink.shade200),
      drawer: const UserDrawer(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('request_form')
              .where('userid', isEqualTo: user!.uid) // Ensure this matches the user ID field in your documents
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var data =
                      snapshot.data!.docs[index].data() as Map<String, dynamic>;
                  return buildRequestCard(context, data);
                },
              );
            } else {
              return Center(
                  child: Text('No requests found.',
                      style: Theme.of(context).textTheme.headline6));
            }
          },
        ),
      ),
    );
  }
  Widget buildRequestCard(BuildContext context, Map<String, dynamic> data) {
    String itemName = data['Item_Name'] as String? ?? 'No item name';  // Handle null and provide default
    String numberOfPeople = data['No_of_People'].toString();  // Converting to string directly
    String arrivalTime = data['Arrivel_Time'] as String? ?? 'Not set';
    String fare = data['Fare'].toString();  // Assume this is a number and convert
    String date = data['Date'] as String? ?? 'Date not set';
    String eventTime = data['Event_Time'] as String? ?? 'Time not set';
    String ingredients = data['Availabe_Ingredients'] as String? ?? 'No ingredients listed';
    String imageUrl = data['image'] as String? ?? ''; // Handle potential null for image URL

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                UserInfoSection(image:imageUrl),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomProductDetailSmallContainer(title: itemName),
                    CustomProductDetailSmallContainer(title: numberOfPeople),
                    CustomProductDetailSmallContainer(title: arrivalTime),
                  ],
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomProductDetailSmallContainer(title: fare),
                    CustomProductDetailSmallContainer(title: date),
                    CustomProductDetailSmallContainer(title: eventTime),
                  ],
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.006),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.1,
                width: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(color: Colors.pink.shade200),
                child: Center(child:Text(ingredients)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
