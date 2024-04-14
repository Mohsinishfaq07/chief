import 'package:chief/provider/chief_dashboard_provider.dart';
import 'package:chief/provider/chief_orders_provider.dart';
import 'package:chief/provider/image_upload_provider.dart';
import 'package:chief/provider/user_myorders_provider.dart';
import 'package:chief/provider/user_myrequest_provider.dart';
import 'package:chief/provider/user_requestqueue_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RequestData()),
        ChangeNotifierProvider(create: (_) => MyOrders()),
        ChangeNotifierProvider(create: (_) => UserRequestQueueProvider()),
        ChangeNotifierProvider(create: (_) => UserMyRequsets()),
        ChangeNotifierProvider(create: (_) => UserMyOrders()),
        // ChangeNotifierProvider(create: (_) => ImageUploadProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
