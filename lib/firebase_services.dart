import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class FirebaseApi {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Initialize notification settings and request permissions
  Future<void> initNotification() async {
    await _firebaseMessaging.requestPermission(
      sound: true,
      alert: true,
      badge: true,
      announcement: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
    );
    final FCMtoken = await _firebaseMessaging.getToken();
    print("This is my FCM token: $FCMtoken");
  }

  // Handle messages and navigate to the dashboard or show a notification
  void handleMessages(BuildContext context, RemoteMessage? message) {
    if (message == null) {
      return;
    }

    print("Received a message: ${message.notification?.title ?? ''}");

    // Show an alert dialog for foreground messages
    if (message.notification != null && message.notification!.title != null) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(message.notification!.title ?? 'No Title'),
            content: Text(message.notification!.body ?? 'No Body'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  // Initialize push notifications
  Future<void> initPushNotifications(BuildContext context) async {
    // Handle the case when the app is launched from a terminated state by a notification
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        handleMessages(context, message);
      }
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      print("Foreground message received: ${message.notification?.title ?? ''}");
      handleMessages(context, message);
    });

    // Handle background messages (when the app is in the background or terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("Message opened app: ${message.notification?.title ?? ''}");
      handleMessages(context, message);
    });
  }
}
