import 'package:chief/view/request_queue.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../app_assets.dart';
import '../view/chief_details.dart';
import '../view/request_form.dart';
import '../view/get_started_screen.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

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
            icon: Icons.message,
            text: 'New Request',
            routeName: RequestForm.tag,
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.message,
            text: 'Request Queue',
            routeName: RequestQueue.tag,
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.details,
            text: 'ChiefDetail',
            routeName: ChiefDetail.tag,
          ),
           _buildDrawerItem(
            context: context,
            icon: Icons.logout,
            text: 'Log Out',
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
      onTap: () => _navigateTo(context, routeName),
    );
  }
}
