// ignore_for_file: must_be_immutable, unused_element, avoid_types_as_parameter_names

import 'package:chief/global_custom_widgets/custom_app_bar.dart';
import 'package:chief/model/chief_detail_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../global_custom_widgets/custom_product_small_container.dart';
import '../../global_custom_widgets/custom_userinfo_section.dart';

class AllChefs extends StatelessWidget {
  AllChefs({super.key, this.userid}); // Keeping userid as an optional parameter
  static const String tag = "AllChefs";
  String? userid;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Stream<String> _listenForNewFare(String chefId) {
    return FirebaseFirestore.instance
        .collection('chef_offers')
        .snapshots()
        .map((snapshot) => snapshot.docs.first.data()['newFare'] as String);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: const CustomAppBarWidget(
        showBackButton: true,
        title: 'All Chefs',
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('chief_users').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.deepOrange,
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No chefs available'),
            );
          }

          final chefs = snapshot.data!.docs
              .map((doc) =>
                  ChiefDetailModel.fromJson(doc.data() as Map<String, dynamic>))
              .toList();

          return ListView.builder(
            itemCount: chefs.length,
            itemBuilder: (context, index) {
              final chef = chefs[index];
              return RequestCard(
                  user: chef.userId); // Pass userId to fetch ratings
            },
          );
        },
      ),
    );
  }
}

class RequestCard extends StatelessWidget {
  RequestCard({super.key, required this.user});
  String user;

  Stream<List<Map<String, dynamic>>> getChefRatingsAndComments(String chefId) {
    return FirebaseFirestore.instance
        .collection('chef_ratings')
        .where('chefId', isEqualTo: chefId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chief_users')
          .doc(user)
          .snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(
            color: Colors.deepOrange,
          );
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Text('No data available');
        }

        final userData = ChiefDetailModel.fromJson(
            snapshot.data!.data() as Map<String, dynamic>);

        return Card(
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
          child: Padding(
            padding: EdgeInsets.all(12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          UserInfoSection(image: userData.image),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                            child: Row(
                              children: [
                                const Text(
                                  "Chef Name : ",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(userData.name),
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
                          width: double.infinity,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.deepOrange.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: userData.certificateImage.isEmpty
                              ? const Center(
                                  child: Text('No Certificate added yet'))
                              : Image.network(
                                  userData.certificateImage,
                                  fit: BoxFit.cover,
                                ),
                        ),
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
                            title: userData.address,
                            label: "Address",
                          ),
                          CustomProductDetailSmallContainer(
                            title: userData.number,
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
                            title: userData.specialties,
                            label: "Specialities",
                          ),
                          CustomProductDetailSmallContainer(
                            title: userData.workExperience,
                            label: "Experience",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                CustomProductDetailSmallContainer(
                  title: userData.email,
                  label: "Mail",
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
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
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
        );
      },
    );
  }
}
