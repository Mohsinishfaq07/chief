import 'package:chief/view/get_started_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app_assets.dart';

import '../chef_screens/chef_myorders_screen.dart.dart';
import '../chef_screens/chef_request_queue_screen.dart';
import '../dashboard/chef_dashboard_screen.dart';

class ChefDrawer extends StatelessWidget {
  const ChefDrawer({super.key});

  void _navigateTo(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.pink.shade200,
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
            icon: Icons.label_important_outline,
            text: 'All Requests',
            routeName: ChefDashboardScreen.tag,
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.query_builder,
            text: 'Requests in Queue',
            routeName: ChiefRequestQueueScreen.tag,
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.shopping_bag_outlined,
            text: 'My Orders',
            routeName: ChefMyOrderScreen.tag,
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
    String? routeName,
  }) {
    return ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(text, style: const TextStyle(color: Colors.white)),
        onTap: () {
          if (text == 'Logout') {
            FirebaseAuth.instance.signOut();
          }
          _navigateTo(context, routeName!);
        });
  }
}
