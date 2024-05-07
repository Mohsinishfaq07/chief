// ignore_for_file: use_build_context_synchronously

import 'package:chief/view/rating_screens/rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../global_custom_widgets/custom_app_bar.dart';
import '../../global_custom_widgets/custom_large_button.dart';

class RatingScreen extends StatefulWidget {
  final String? chefId; // Chef ID is required to construct this widget

  const RatingScreen({Key? key,   this.chefId}) : super(key: key);

  static const String tag = '/RatingScreen';

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  double _rating = 0.0; // Variable to hold the rating value
  final TextEditingController _reviewController = TextEditingController(); // Controller for the review input field

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> submitRating() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (userId.isEmpty) {
      Fluttertoast.showToast(msg: 'You must be logged in to submit a rating.');
      return;
    }

    // Push the rating to Firestore
    await FirebaseFirestore.instance.collection('chef_ratings').add({
      'chefId': widget.chefId,
      'userId': userId,
      'rating': _rating,
      'review': _reviewController.text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    Fluttertoast.showToast(msg: 'Thank you for your feedback!');

    // Clear the input fields after submission
    setState(() {
      _rating = 0.0;
      _reviewController.clear();
    });

    // Optionally navigate back
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBarWidget(title: 'Rate Chef', showBackButton: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              SizedBox(height: 20.h),
              Text(
                'Your Rating',
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20.h),
              CustomRatingBar(
                initialRating: _rating,
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
              SizedBox(height: 20.h),
              TextField(
                controller: _reviewController,
                decoration: const InputDecoration(
                  labelText: 'Write your review here...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
              SizedBox(height: 20.h),
              CustomLargeButton(
                title: 'Submit Review',
                ontap: submitRating,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Ensure that CustomRatingBar widget accepts an onRatingUpdate callback and updates the rating accordingly.
// The CustomLargeButton should be a simple ElevatedButton or similar with styling applied.
