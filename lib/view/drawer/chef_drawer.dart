import 'package:chief/model/app_database.dart';
import 'package:chief/model/chief_detail_model.dart';
import 'package:chief/view/all_chefs/all_chefs.dart';
import 'package:chief/view/chef_screens/rehman/active_orders/active_orders.dart';
import 'package:chief/view/chef_screens/rehman/completed_orders/chef_completed_orders.dart';
import 'package:chief/view/get_started_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app_assets.dart';

import '../chef_screens/chef_myorders_screen.dart.dart';
import '../chef_screens/chef_request_queue_screen.dart';
import '../dashboard/chef_dashboard_screen.dart';

class ChefDrawer extends StatefulWidget {
  const ChefDrawer({super.key});

  @override
  State<ChefDrawer> createState() => _ChefDrawerState();
}

class _ChefDrawerState extends State<ChefDrawer> {
  void _navigateTo(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  AppDatabase database = AppDatabase();
  User? user = FirebaseAuth.instance.currentUser;
  ChiefDetailModel? chiefDetailModel;
  getChefDetails() async {
    chiefDetailModel = await database.getChiefById(docId: user!.uid);
  }

  @override
  void initState() {
    getChefDetails();
    super.initState();
  }

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
            text: 'All Orders',
            routeName: ChefDashboardScreen.tag,
          ),
          _buildDrawerItemNew(
              context: context,
              icon: Icons.query_builder,
              text: 'Active Orders',
              screenName: const ChefActiveOrders()),
          _buildDrawerItem(
            context: context,
            icon: Icons.query_builder,
            text: 'Pending Orders',
            routeName: ChiefRequestQueueScreen.tag,
          ),
          _buildDrawerItemNew(
            context: context,
            icon: Icons.shopping_bag_outlined,
            text: 'Completed Orders',
            screenName: const ChefCompletedOrders(),
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

Widget _buildDrawerItemNew(
    {required BuildContext context,
    required IconData icon,
    required String text,
    required screenName}) {
  return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(text, style: const TextStyle(color: Colors.white)),
      onTap: () {
        if (text == 'Logout') {
          FirebaseAuth.instance.signOut();
        }
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return screenName;
        }));
      });
}
