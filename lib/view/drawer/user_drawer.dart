import 'package:chief/model/app_database.dart';
import 'package:chief/model/client_detail_model.dart';
import 'package:chief/view/all_chefs/all_chefs.dart';
import 'package:chief/view/user_screens/rehman/assigned_orders/assigned_orders.dart';
import 'package:chief/view/user_screens/rehman/completed_orders/completed_orders.dart';
import 'package:chief/view/user_screens/rehman/pending_orders/pending_requests.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app_assets.dart';
import '../dashboard/User_dashboard_request_form.dart';
import '../get_started_screen.dart';

class UserDrawer extends StatefulWidget {
  const UserDrawer({super.key});

  @override
  State<UserDrawer> createState() => _UserDrawerState();
}

class _UserDrawerState extends State<UserDrawer>
    with SingleTickerProviderStateMixin {
  final AppDatabase database = AppDatabase();
  final User? user = FirebaseAuth.instance.currentUser;
  ClientDetailModel? clientDetailModel;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    getUserDetails();
    _setupAnimations();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }

  Future<void> getUserDetails() async {
    clientDetailModel = await database.getUserById(docId: user!.uid);
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepOrange.shade200,
              Colors.deepOrange.shade100,
              Colors.white,
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    children: [
                      _buildDrawerItem(
                        icon: Icons.group,
                        text: 'All Chefs',
                        onTap: () => _navigateTo(context, AllChefs.tag),
                      ),
                      _buildDrawerItem(
                        icon: Icons.add_circle_outline,
                        text: 'New Request',
                        onTap: () =>
                            _navigateTo(context, UserDashboardRequestForm.tag),
                      ),
                      _buildDrawerItem(
                        icon: Icons.pending_actions,
                        text: 'Pending Orders',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserPendingOrders(),
                          ),
                        ),
                      ),
                      _buildDrawerItem(
                        icon: Icons.assignment_turned_in,
                        text: 'Assigned Orders',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>  UserAssignedOrders(),
                          ),
                        ),
                      ),
                      _buildDrawerItem(
                        icon: Icons.check_circle_outline,
                        text: 'Completed Orders',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UserCompletedOrders(),
                          ),
                        ),
                      ),
                      Divider(
                        color: Colors.white.withOpacity(0.5),
                        thickness: 1,
                        indent: 20.w,
                        endIndent: 20.w,
                      ),
                      _buildDrawerItem(
                        icon: Icons.logout,
                        text: 'Logout',
                        onTap: () {
                          FirebaseAuth.instance.signOut();
                          _navigateTo(context, GetStartedScreen.tag);
                        },
                        isLogout: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
      ),
      child: Column(
        children: [
          Container(
            width: 100.w,
            height: 100.w,
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
              child: Image.asset(
                AppAssets.imgCookingBro,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 15.h),
          if (clientDetailModel != null)
            Text(
              clientDetailModel!.name,
              style: TextStyle(
                color: Colors.deepOrange.shade900,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.r),
              color: isLogout
                  ? Colors.red.withOpacity(0.1)
                  : Colors.white.withOpacity(0.2),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isLogout ? Colors.red : Colors.deepOrange.shade700,
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  text,
                  style: TextStyle(
                    color: isLogout ? Colors.red : Colors.deepOrange.shade900,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }
}
