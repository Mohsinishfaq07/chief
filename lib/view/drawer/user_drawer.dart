import 'package:chief/view/all_chefs/all_chefs.dart';
import 'package:chief/view/user_screens/user_myorders_screen.dart'
    as userMyOrder;
import 'package:chief/view/user_screens/user_requestqueue_screen.dart';
import 'package:chief/view/user_screens/user_myrequests_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app_assets.dart';
import '../../../model/app_database.dart';
import '../dashboard/User_dashboard_request_form.dart';
import '../get_started_screen.dart';

class UserDrawer extends StatefulWidget {
  const UserDrawer({super.key});

  @override
  State<UserDrawer> createState() => _UserDrawerState();
}

class _UserDrawerState extends State<UserDrawer> {
  void _navigateTo(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  AppDatabase database = AppDatabase();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.deepOrange.shade200,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Image.asset(
              AppAssets.imgCookingBro,
              height: MediaQuery.of(context).size.height * 0.2.h,
            ),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.cookie,
            text: 'All Chefs',
            routeName: AllChefs.tag,
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.label_important_outline,
            text: 'New Request',
            routeName: UserDashboardRequestForm.tag,
          ),
          _buildDrawerItem(
              context: context,
              icon: Icons.query_builder,
              text: 'Request Queue',
              routeName: PendingRequestScreen.tag),
          _buildDrawerItem(
            context: context,
            icon: Icons.tv,
            text: 'My Requests',
            routeName: PendingRequestScreen.tag,
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.shopping_bag_outlined,
            text: 'My Orders',
            routeName: UserMyOrdersScreen.tag,
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.logout,
            text: 'Logout',
            routeName: GetStartedScreen.tag,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String text,
    required String routeName,
  }) {
    return ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(text, style: const TextStyle(color: Colors.white)),
        onTap: () {
          if (text == 'Logout') {
            FirebaseAuth.instance.signOut();
          }
          _navigateTo(context, routeName);
        });
  }
}
