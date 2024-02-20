// ignore_for_file: use_build_context_synchronously

import 'package:chief/view/chief_dashboard_screen.dart';
import 'package:chief/view/login_screen.dart';
import 'package:chief/view/user_dashboard_screen.dart';
import 'package:chief/view/get_started_screen.dart';
import 'package:chief/view/user_myrequests_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AppDatabase {
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void signIn(String email, String pass, BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Colors.pink,
        ),
      ),
    );
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: pass);
      String role = await getUserRole();
      Navigator.of(context).popUntil((route) => route.isFirst);
      // Navigate based on user role
      if (role == 'chief') {
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ShiefPendingRequest()),
          (Route<dynamic> route) => false,
        );
      } else if (role == 'user') {
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const RequestForm()),
          (Route<dynamic> route) => false,
        );
      }
      Fluttertoast.showToast(msg: "Login Successful");
    } catch (e) {
      Fluttertoast.showToast(msg: '$e');
      Navigator.of(context).pop(); // Dismiss the loading dialog
    }
  }

  Future<void> resetPassword(BuildContext context, String email) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Colors.pink,
        ),
      ),
    );

    try {
      // Reference to your Firestore collection
      CollectionReference users =
          FirebaseFirestore.instance.collection('allusers');

      // Query Firestore to check if the email exists
      QuerySnapshot querySnapshot =
          await users.where('Email', isEqualTo: email).get();

      if (querySnapshot.docs.isNotEmpty) {
        // Email exists, send reset password email
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
        Navigator.of(context).pop(); // Dismiss the loading dialog
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const LoginScreen()));
        Fluttertoast.showToast(msg: 'Reset password email sent');
      } else {
        // Email does not exist
        Navigator.of(context).pop(); // Dismiss the loading dialog
        Fluttertoast.showToast(msg: 'enter correct email');
      }
    } catch (e) {
      // Error occurred
      Navigator.of(context).pop(); // Dismiss the loading dialog
      Fluttertoast.showToast(msg: 'An error occurred. Please try again later.');
      if (kDebugMode) {
        print('Error resetting password: $e');
      }
    }
  }

  Future<String> getUserRole() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot<Map<String, dynamic>> snapshot =
            await _firestore.collection('allusers').doc(user.uid).get();
        if (snapshot.exists) {
          final data = snapshot.data();
          if (data != null && data.containsKey('role')) {
            return data['role'] as String;
          } else {
            // Handle the case where the role field is missing or not found
            return 'unknown';
          }
        } else {
          // Handle the case where the document does not exist
          return 'unknown';
        }
      } else {
        // Handle the case where the current user is null
        return 'unknown';
      }
    } catch (e) {
      // Handle any errors that occur during the process
      Fluttertoast.showToast(msg: "Error fetching user role: $e");
      return 'unknown';
    }
  }

  void chiefDetailsToFirestore(
      BuildContext context,
      String name,
      String number,
      String address,
      String email,
      String pass,
      String experience,
      String speciality,
      String certificate,
      String image,
      String certificateimage) {
    var user = _auth.currentUser;
    CollectionReference ref =
        FirebaseFirestore.instance.collection('chief_users');
    ref.doc(user!.uid).set({
      'id': user.uid,
      'Name': name,
      'Number': number,
      'Address': address,
      'Email': email,
      'Password': pass,
      'Work Experience': experience,
      'Specialities': speciality,
      'Certifications': certificate,
      'Certificate image': certificateimage,
      'image': image,
      'role': 'chief',
      'timestamp': FieldValue.serverTimestamp()
    });
    CollectionReference allusersref =
        FirebaseFirestore.instance.collection('allusers');
    allusersref.doc(user.uid).set({
      'id': user.uid,
      'Name': name,
      'Email': email,
      'role': 'chief',
      'timestamp': FieldValue.serverTimestamp()
    });
    Fluttertoast.showToast(msg: "Account Created");
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const GetStartedScreen()),
      (Route<dynamic> route) => false,
    );
  }

  void userDetailsToFirestore(BuildContext context, String name, String number,
      String address, String email, String pass, String imagepath) {
    var user = _auth.currentUser;
    CollectionReference ref = FirebaseFirestore.instance.collection('users');
    ref.doc(user!.uid).set({
      'id': user.uid,
      'Name': name,
      'Number': number,
      'Address': address,
      'Email': email,
      'Password': pass,
      'role': 'user',
      'image': imagepath,
      'timestamp': FieldValue.serverTimestamp()
    });
    CollectionReference allusersref =
        FirebaseFirestore.instance.collection('allusers');
    allusersref.doc(user.uid).set({
      'id': user.uid,
      'Name': name,
      'Email': email,
      'role': 'user',
      'timestamp': FieldValue.serverTimestamp()
    });
    Fluttertoast.showToast(msg: "Account Created");
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const GetStartedScreen()),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> addrequest(
    BuildContext context,
    String userid,
    String itemName,
    String date,
    String arrivelTime,
    String eventTime,
    String noOfPeople,
    String fare,
    String availabeingred,
    String name,
    String image,
    String collection,
    String action,
  ) async {
    final user = _auth.currentUser;
    try {
      CollectionReference ref =
          FirebaseFirestore.instance.collection(collection);
      ref.doc().set({
        'userid': user!.uid,
        'addedby': userid,
        'User_Name': name,
        'Item_Name': itemName,
        'Date': date,
        'Arrivel_Time': arrivelTime,
        'Event_Time': eventTime,
        'No_of_People': noOfPeople,
        'Fare': fare,
        'Action': action,
        'Availabe_Ingredients': availabeingred,
        'image': image,
        'timestamp': FieldValue.serverTimestamp()
      });
    } catch (e) {
      Fluttertoast.showToast(msg: '$e');
    }
    if (collection == 'request_form') {
      Fluttertoast.showToast(msg: "Request Added");
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const PendingRequestScreen()));
    }
  }
}
