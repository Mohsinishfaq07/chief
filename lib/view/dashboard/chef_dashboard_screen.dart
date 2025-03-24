import 'package:chief/global_custom_widgets/custom_small_buttons.dart';
import 'package:chief/global_custom_widgets/custom_text_form_field.dart';
import 'package:chief/model/app_database.dart';
import 'package:chief/model/client_detail_model.dart';
import 'package:chief/model/request_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../global_custom_widgets/custom_product_small_container.dart';
import '../../global_custom_widgets/custom_userinfo_section.dart';
import '../drawer/chef_drawer.dart';

class ChefDashboardScreen extends StatefulWidget {
  const ChefDashboardScreen({super.key});
  static const String tag = "ChefDashboardScreen";

  @override
  State<ChefDashboardScreen> createState() => _ChefDashboardScreenState();
}

class _ChefDashboardScreenState extends State<ChefDashboardScreen>
    with SingleTickerProviderStateMixin {
  final AppDatabase database = AppDatabase();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController fareController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
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
    fareController.dispose();
    super.dispose();
  }

  void _submitNewFare(String chefId, String newFare) async {
    Fluttertoast.showToast(
        msg: "Fare $newFare updated. Please approve the request!");
  }

  void _showFareUpdateDialog(String documentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Submit New Fare",
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange.shade700,
                  ),
                ),
                SizedBox(height: 20.h),
                _buildTextField(
                  controller: fareController,
                  hint: "Enter new fare",
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildDialogButton(
                      "Cancel",
                      () => Navigator.of(context).pop(),
                      isCancel: true,
                    ),
                    _buildDialogButton(
                      "Submit",
                      () {
                        if (fareController.text.isNotEmpty) {
                          Fluttertoast.showToast(
                            msg:
                                "Fare ${fareController.text} updated. Please approve the request!",
                          );
                          Navigator.of(context).pop();
                        } else {
                          Fluttertoast.showToast(msg: "Please enter a fare");
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
          Navigator.of(context).pop();
          return false;
        }
        return _showExitDialog();
      },
      child: Scaffold(
        key: _scaffoldKey,
        drawer: const ChefDrawer(),
        appBar: _buildAppBar(),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: _buildBody(),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      title: Text(
        'Requests',
        style: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          color: Colors.deepOrange.shade700,
        ),
      ),
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.deepOrange.shade700),
    );
  }

  Widget _buildBody() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('food_orders').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          final filteredDocs = snapshot.data!.docs.where((doc) {
            final chefResponses =
                (doc['chefResponses'] as List<dynamic>?) ?? [];
            return !chefResponses
                .any((response) => response['userId'] == user!.uid);
          }).toList();

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            itemCount: filteredDocs.length,
            itemBuilder: (context, index) {
              final request = RequestModel.fromJson(
                filteredDocs[index].data() as Map<String, dynamic>,
              );

              return FutureBuilder<ClientDetailModel>(
                future: database.getClientById(docId: request.clientId),
                builder: (context, clientSnapshot) {
                  if (clientSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return _buildLoadingCard();
                  }
                  if (!clientSnapshot.hasData) {
                    return const SizedBox.shrink();
                  }

                  return _buildRequestCard(
                    request,
                    filteredDocs[index].id,
                    clientSnapshot.data!,
                  );
                },
              );
            },
          );
        }
        return Center(
          child: CircularProgressIndicator(
            color: Colors.deepOrange.shade400,
          ),
        );
      },
    );
  }

  Widget _buildRequestCard(
    RequestModel request,
    String documentId,
    ClientDetailModel client,
  ) {
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
      child: Column(
        children: [
          _buildCardHeader(client),
          _buildCardDetails(request),
          _buildIngredients(request.ingredients),
          _buildCardActions(request, documentId),
        ],
      ),
    );
  }

  Widget _buildCardHeader(ClientDetailModel client) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.deepOrange.shade50,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25.r,
            backgroundColor: Colors.deepOrange.shade200,
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: 30.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                client.name,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange.shade700,
                ),
              ),
              Text(
                client.number,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.deepOrange.shade300,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardDetails(RequestModel request) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          _buildDetailRow(
            'Food',
            request.itemName,
            Icons.restaurant_menu,
          ),
          _buildDetailRow(
            'People',
            request.totalPerson,
            Icons.people,
          ),
          _buildDetailRow(
            'Date',
            request.date,
            Icons.calendar_today,
          ),
          _buildDetailRow(
            'Time',
            request.eventTime,
            Icons.access_time,
          ),
          _buildDetailRow(
            'Arrival',
            request.arrivalTime,
            Icons.timer,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20.sp,
            color: Colors.deepOrange.shade300,
          ),
          SizedBox(width: 8.w),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredients(String ingredients) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.deepOrange.shade50,
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Ingredients',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange.shade700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            ingredients,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardActions(RequestModel request, String documentId) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            Icons.close,
            Colors.red.shade400,
            () => database.rejectByChief(docId: documentId, userId: user!.uid),
          ),
          GestureDetector(
            onTap: () => _showFareUpdateDialog(documentId),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 10.h,
              ),
              decoration: BoxDecoration(
                color: Colors.deepOrange.shade50,
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: Text(
                '₨ ${request.fare}',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange.shade700,
                ),
              ),
            ),
          ),
          _buildActionButton(
            Icons.check,
            Colors.green.shade400,
            () => database.acceptByChief(
              docId: documentId,
              userId: user!.uid,
              fare: fareController.text.isEmpty
                  ? request.fare
                  : fareController.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15.r),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 200.h,
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
      child: Center(
        child: CircularProgressIndicator(
          color: Colors.deepOrange.shade400,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(
          fontSize: 16.sp,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 16.sp,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.r),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 16.h,
          ),
        ),
      ),
    );
  }

  Widget _buildDialogButton(String text, VoidCallback onTap,
      {bool isCancel = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: isCancel ? Colors.grey.shade200 : Colors.deepOrange.shade400,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isCancel ? Colors.black87 : Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _showExitDialog() async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Exit App',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange.shade700,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Do you really want to exit the app?',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDialogButton(
                    "No",
                    () => Navigator.of(context).pop(false),
                    isCancel: true,
                  ),
                  _buildDialogButton(
                    "Yes",
                    () {
                      Navigator.of(context).pop(true);
                      SystemNavigator.pop();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return shouldPop ?? false;
  }
}
