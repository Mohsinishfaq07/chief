// ignore_for_file: must_be_immutable, unused_element, avoid_types_as_parameter_names

import 'package:chief/global_custom_widgets/custom_app_bar.dart';
import 'package:chief/model/chief_detail_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../global_custom_widgets/custom_product_small_container.dart';
import '../../global_custom_widgets/custom_userinfo_section.dart';

class AllChefs extends StatefulWidget {
  const AllChefs({super.key, this.userid});
  static const String tag = "AllChefs";
  final String? userid;

  @override
  State<AllChefs> createState() => _AllChefsState();
}

class _AllChefsState extends State<AllChefs>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: _buildBody(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      title: Text(
        'All Chefs',
        style: TextStyle(
          color: Colors.deepOrange.shade700,
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: Colors.deepOrange.shade700,
          size: 20.sp,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
    );
  }

  Widget _buildBody() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('chief_users').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingIndicator();
        }
        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        }

        final chefs = snapshot.data!.docs
            .map((doc) =>
                ChiefDetailModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList();

        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          itemCount: chefs.length,
          itemBuilder: (context, index) {
            return ChefCard(chef: chefs[index]);
          },
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(
        color: Colors.deepOrange.shade400,
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.deepOrange.shade300,
            size: 60.sp,
          ),
          SizedBox(height: 16.h),
          Text(
            'Error: $error',
            style: TextStyle(
              color: Colors.deepOrange.shade700,
              fontSize: 16.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_search,
            color: Colors.deepOrange.shade300,
            size: 60.sp,
          ),
          SizedBox(height: 16.h),
          Text(
            'No chefs available',
            style: TextStyle(
              color: Colors.deepOrange.shade700,
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class ChefCard extends StatelessWidget {
  final ChiefDetailModel chef;

  const ChefCard({super.key, required this.chef});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Column(
          children: [
            _buildHeader(context),
            _buildBody(context),
            _buildRatingsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepOrange.shade200,
            Colors.deepOrange.shade100,
          ],
        ),
      ),
      child: Row(
        children: [
          _buildProfileImage(),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chef.name,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange.shade900,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  chef.specialties,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.deepOrange.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return Container(
      width: 80.w,
      height: 80.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipOval(
        child: chef.image.isNotEmpty
            ? Image.network(
                chef.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.person, size: 40.sp),
              )
            : Icon(Icons.person, size: 40.sp),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          _buildInfoRow('Experience', chef.workExperience),
          _buildInfoRow('Contact', chef.number),
          _buildInfoRow('Address', chef.address),
          _buildInfoRow('Email', chef.email),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingsSection(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _getChefRatingsAndComments(chef.userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final ratings = snapshot.data ?? [];
        if (ratings.isEmpty) {
          return _buildNoRatings();
        }

        final averageRating = _calculateAverageRating(ratings);
        return _buildRatingsContent(averageRating, ratings);
      },
    );
  }

  Stream<List<Map<String, dynamic>>> _getChefRatingsAndComments(String chefId) {
    return FirebaseFirestore.instance
        .collection('chef_ratings')
        .where('chefId', isEqualTo: chefId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  double _calculateAverageRating(List<Map<String, dynamic>> ratings) {
    return ratings
            .map((rating) => rating['rating'] as double)
            .fold(0.0, (a, b) => a + b) /
        ratings.length;
  }

  Widget _buildNoRatings() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
        ),
      ),
      child: Text(
        'No ratings yet',
        style: TextStyle(
          fontSize: 14.sp,
          color: Colors.grey.shade600,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildRatingsContent(
      double averageRating, List<Map<String, dynamic>> ratings) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star,
                color: Colors.amber,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                averageRating.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange.shade700,
                ),
              ),
              Text(
                ' (${ratings.length} reviews)',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          if (ratings.isNotEmpty) ...[
            SizedBox(height: 8.h),
            ...ratings.take(3).map((rating) => _buildReviewItem(rating)),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> rating) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Text(
            '${rating['rating']}★',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.amber,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              '"${rating['review']}"',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade700,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
