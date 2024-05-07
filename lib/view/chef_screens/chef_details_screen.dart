// ignore_for_file: must_be_immutable, unused_element, avoid_types_as_parameter_names

import 'package:chief/global_custom_widgets/custom_app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../global_custom_widgets/custom_product_small_container.dart';
import '../../global_custom_widgets/custom_userinfo_section.dart';
import '../auth/forgot_password.dart';

class ChefDetailsScreen extends StatelessWidget {
  ChefDetailsScreen({super.key, this.userid});
  static const String tag = "ChefDetails";
  String? userid;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Stream<String> _listenForNewFare(String chefId) {
    // Stream to listen for new fare updates
    return FirebaseFirestore.instance.collection('chef_offers')
        .where('chefId', isEqualTo: chefId)
        .snapshots()
        .map((snapshot) => snapshot.docs.first.data()['newFare'] as String);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: const CustomAppBarWidget(
        showBackButton: true,
        title: 'Chef Details',
      ),
      body: Column(
        children: [
          //  const CustomTitleText(text: ),
          RequestCard(user: userid!),
          const Spacer(),
          const BottomRightImage(),
        ],
      ),
    );
  }
}

class RequestCard extends StatelessWidget {
  RequestCard({super.key, required this.user});
  String user;
  // Helper function to fetch and calculate the average rating
  Stream<List<Map<String, dynamic>>> getChefRatingsAndComments(String chefId) {
    return FirebaseFirestore.instance
        .collection('chef_ratings')
        .where('chefId', isEqualTo: chefId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => doc.data())
        .toList());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chief_users')
            .doc(user)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(
              color: Colors.pink,
            ); // Show a loading indicator while fetching data
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          var userData = snapshot.data!.data() as Map<String, dynamic>;
          return Card(
            elevation: 4,
            child: SizedBox(
              height: MediaQuery.of(context).size.height* 0.5,
              child: Padding(
                padding: EdgeInsets.all(2.h),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                UserInfoSection(image: userData['image']),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5.0),
                                  child: Row(
                                    children: [
                                      const Text(
                                        "Chef Name : ",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(userData['Name']),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Container(
                                  width: double.infinity, // Set container width
                                  height: 100, // Set container height
                                  decoration: BoxDecoration(
                                    color:
                                        Colors.pinkAccent, // Placeholder color
                                    borderRadius: BorderRadius.circular(
                                        10), // Optional: Add border radius
                                  ),
                                  child: userData['Certificate image'] == ""
                                      ? const Center(
                                          child:
                                              Text('No Certificate added yet'))
                                      : Image.network(
                                          userData['Certificate image'],
                                          fit: BoxFit.cover,
                                        )),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomProductDetailSmallContainer(
                                  title: userData['Address'],
                                  label: "Address",
                                ),
                                CustomProductDetailSmallContainer(
                                  title: userData['Number'],
                                  label: "P.No",
                                ),

                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomProductDetailSmallContainer(
                                  title: userData['Specialities'],
                                  label: "Specialities",
                                ),

                                CustomProductDetailSmallContainer(
                                  title: userData['Work Experience'],
                                  label: " Experience",
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      CustomProductDetailSmallContainer(
                        title: userData['Email'],
                        label: "Mail",
                      ),
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance.collection('chief_users').doc(user).snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            var chefData = snapshot.data!.data() as Map<String, dynamic>;
                            bool farePendingApproval = chefData['farePendingApproval'] ?? false; // Provides a default value if null.

                            String displayFare = farePendingApproval
                                ? 'New Fare (Pending): ${chefData['newFare'] ?? 'N/A'}'
                                : 'Current Fare: ${chefData['fare'] ?? 'N/A'}';                            return Text(displayFare);
                          } else if (snapshot.hasError) {
                            return Text("Error: ${snapshot.error}");
                          } else {
                            return const CircularProgressIndicator();
                          }
                        },
                      ),





                      Padding(
                        padding: EdgeInsets.all(12.h),
                        child: StreamBuilder<List<Map<String, dynamic>>>(
                          stream: getChefRatingsAndComments(user),
                          builder: (context, ratingsSnapshot) {
                            if (!ratingsSnapshot.hasData) {
                              return const Text('Loading ratings...');
                            }
                            final ratings = ratingsSnapshot.data ?? [];
                            final averageRating = ratings
                                .map((rating) => rating['rating'] as double)
                                .fold(0.0, (sum, item) => sum + item) /
                                (ratings.isNotEmpty ? ratings.length : 1);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Ratings and Reviews',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8.h),
                                if (ratings.isNotEmpty)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '⭐ Average Rating: ${averageRating.toStringAsFixed(1)}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      SizedBox(height: 8.h),
                                      ...ratings.map(
                                            (rating) => Padding(
                                          padding: const EdgeInsets.only(top: 4.0),
                                          child: Text(
                                            '"${rating['review']}" - ${rating['rating']} ⭐',
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  const Text('No ratings or reviews yet'),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
