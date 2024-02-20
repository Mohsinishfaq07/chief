import 'package:chief/view/chief_requestqueue_screen.dart';
import 'package:chief/view/chief_myorders_screen.dart.dart';
import 'package:chief/view/chief_dashboard_screen.dart';
import 'package:chief/view/user_details_screen.dart';
import 'package:chief/view/user_requestqueue_screen.dart';
import 'package:chief/view/user_myorders_screen.dart';
import 'package:chief/view/forgot_password.dart';
import 'package:chief/view/get_started_screen.dart';
import 'package:chief/view/login_screen.dart';
import 'package:chief/view/rating_screens/rating_screen.dart';
import 'package:chief/view/user_dashboard_screen.dart';
import 'package:chief/view/signup_chief.dart';
import 'package:chief/view/signup_user.dart';
import 'package:chief/view/splash_screen.dart';
import 'package:chief/view/user_myrequests_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  String getInitialRoute() {
    return SplashScreen.tag;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return ScreenUtilInit(
        designSize: const Size(360, 690),
        builder: (_, child) {
          return MaterialApp(
            theme: ThemeData(
              scaffoldBackgroundColor: Colors.pink.shade200,
            ),
            debugShowCheckedModeBanner: false,
            title: 'My Diary App',
            initialRoute: getInitialRoute(),
            onGenerateRoute: _generateRoute,
          );
        });
  }
}

Route _generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case SplashScreen.tag:
      return _createRightToLeftRoute(const SplashScreen(), settings);
    case GetStartedScreen.tag:
      return _createRightToLeftRoute(const GetStartedScreen(), settings);
    case LoginScreen.tag:
      return _createRightToLeftRoute(const LoginScreen(), settings);
    case ForgotPassword.tag:
      return _createRightToLeftRoute(const ForgotPassword(), settings);
    case SignupUser.tag:
      return _createRightToLeftRoute(const SignupUser(), settings);
    case SignupChief.tag:
      return _createRightToLeftRoute(const SignupChief(), settings);
    case RequestForm.tag:
      return _createRightToLeftRoute(const RequestForm(), settings);
    case RatingScreen.tag:
      return _createRightToLeftRoute(const RatingScreen(), settings);
    case DashboardRequestScreen.tag:
      return _createRightToLeftRoute(DashboardRequestScreen(), settings);
    case MyRequestScreen.tag:
      return _createRightToLeftRoute(const MyRequestScreen(), settings);
    case ChiefRequestScreen.tag:
      return _createRightToLeftRoute(ChiefRequestScreen(), settings);
    case ShiefDashboardScreen.tag:
      return _createRightToLeftRoute(const ShiefDashboardScreen(), settings);
    case PendingRequestScreen.tag:
      return _createRightToLeftRoute(const PendingRequestScreen(), settings);
    case ShiefPendingRequest.tag:
      return _createRightToLeftRoute(const ShiefPendingRequest(), settings);
    case UserDetails.tag:
      return _createRightToLeftRoute(UserDetails(), settings);

    // Add other routes here
    default:
      return _createRightToLeftRoute(const SplashScreen(), settings);
  }
}

PageRoute _createRightToLeftRoute(Widget page, RouteSettings settings) {
  return PageRouteBuilder(
    settings: settings,
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = const Offset(1.0, 0.0);
      var end = Offset.zero;
      var curve = Curves.easeInOut;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}
