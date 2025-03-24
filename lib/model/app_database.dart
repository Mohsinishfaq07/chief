// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:async';

import 'package:chief/model/all_user_detail_model.dart';
import 'package:chief/model/chief_detail_model.dart';
import 'package:chief/model/client_detail_model.dart';
import 'package:chief/model/request_model.dart';
import 'package:chief/view/user_screens/user_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:chief/view/auth/login_screen.dart';
import 'package:chief/view/dashboard/User_dashboard_request_form.dart';
import 'package:chief/view/get_started_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../view/dashboard/chef_dashboard_screen.dart';
import '../utils/shared_preferences_manager.dart';

class AppDatabase {
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void signIn(String email, String pass, BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Colors.orange,
        ),
      ),
    );
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: pass);
      final user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot<Map<String, dynamic>> snapshot =
            await _firestore.collection('allusers').doc(user.uid).get();

        if (snapshot.exists) {
          final data = snapshot.data()!;
          await SharedPreferencesManager.saveUserSession(
            userId: user.uid,
            name: data['Name'] ?? '',
            email: data['Email'] ?? '',
            role: data['role'] ?? '',
            image: data['image'],
          );

          Navigator.of(context).popUntil((route) => route.isFirst);
          if (data['role'] == 'chief') {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => const ChefDashboardScreen()),
              (Route<dynamic> route) => false,
            );
          } else if (data['role'] == 'user') {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => const UserDashboardRequestForm()),
              (Route<dynamic> route) => false,
            );
          }
          Fluttertoast.showToast(msg: "Login Successful");
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: '$e');
      Navigator.of(context).pop();
    }
  }

  Future<void> resetPassword(BuildContext context, String email) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Colors.orange,
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

  Future<void> chefDetailToFireStore({
    required BuildContext context,
    required ChiefDetailModel chiefDetail,
    required AllUserDetailModel allUserDetail,
  }) async {
    try {
      var user = _auth.currentUser;

      await FirebaseFirestore.instance
          .collection('chief_users')
          .doc(user!.uid)
          .set(chiefDetail.toJson());

      await FirebaseFirestore.instance
          .collection('allusers')
          .doc(user.uid)
          .set(allUserDetail.toJson());

      // Save user info to SharedPreferences
      await saveUserInfo(
        userId: user.uid,
        name: allUserDetail.name,
        email: allUserDetail.email,
        role: allUserDetail.role,
        image: chiefDetail.image,
      );

      Fluttertoast.showToast(msg: "Chief Account Created");
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const GetStartedScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
      print("Error: $e");
    }
  }

  void userDetailsToFireStore({
    required BuildContext context,
    required ClientDetailModel clientDetail,
    required AllUserDetailModel allUserDetail,
  }) async {
    try {
      var user = _auth.currentUser;

      await FirebaseFirestore.instance
          .collection('client_users')
          .doc(user!.uid)
          .set(clientDetail.toJson());

      await FirebaseFirestore.instance
          .collection('allusers')
          .doc(user.uid)
          .set(allUserDetail.toJson());

      // Save user info to SharedPreferences
      await saveUserInfo(
        userId: user.uid,
        name: allUserDetail.name,
        email: allUserDetail.email,
        role: allUserDetail.role,
        image: clientDetail.image,
      );

      Fluttertoast.showToast(msg: "User Account Created");
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const GetStartedScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
      print("Error: $e");
    }
  }

  Future<void> requestToFireStore({
    required BuildContext context,
    required RequestModel requestModel,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('requests')
          .add(requestModel.toJson())
          .then((value) {
        Fluttertoast.showToast(msg: 'Request Added Successfully');
        Navigator.pop(context);
      });
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: $e');
    }
  }

  Future<void> acceptByChief({
    required String docId,
    required String userId,
    required String fare,
  }) async {
    try {
      CollectionReference ref =
          FirebaseFirestore.instance.collection('food_orders');

      await ref.doc(docId).update({
        'chefResponses': FieldValue.arrayUnion([
          {'userId': userId, 'reqStatus': 'applied', 'fare': fare} // Accepted
        ]),
      });

      Fluttertoast.showToast(msg: 'Request accepted.');
    } catch (e) {
      Fluttertoast.showToast(msg: '$e');
      print("Error: $e");
    }
  }

  Future<void> rejectByChief({
    required String docId,
    required String userId,
  }) async {
    try {
      CollectionReference ref =
          FirebaseFirestore.instance.collection('food_orders');

      await ref.doc(docId).update({
        'chefResponses': FieldValue.arrayUnion([
          {'userId': userId, 'reqStatus': 'rejected', 'fare': '0'} // Rejected
        ]),
      });

      Fluttertoast.showToast(msg: 'Request rejected.');
    } catch (e) {
      Fluttertoast.showToast(msg: '$e');
      print("Error: $e");
    }
  }

  Future<void> acceptedByClient({
    required String docId,
    required String chiefId,
  }) async {
    try {
      CollectionReference ref =
          FirebaseFirestore.instance.collection('food_orders');
      await ref.doc(docId).update({
        'acceptedChiefId': chiefId,
        'orderStatus': 'assigned',
      });
    } catch (e) {
      Fluttertoast.showToast(msg: '$e');
      print("Error: $e");
    }
  }

  Future<void> rejectByClient({
    required String docId,
    required String chiefId,
  }) async {
    try {
      CollectionReference ref =
          FirebaseFirestore.instance.collection('food_orders');
      await ref.doc(docId).update({
        'chefResponses': FieldValue.arrayUnion([
          {'userId': chiefId, 'reqStatus': 'rejected', 'fare': '0'} // Rejected
        ]),
      });
      // await ref.doc(docId).update({
      //   'acceptedChiefId': chiefId,
      // });
    } catch (e) {
      Fluttertoast.showToast(msg: '$e');
      print("Error: $e");
    }
  }

  Future<void> orderCompleted({
    required String docId,
  }) async {
    try {
      CollectionReference ref =
          FirebaseFirestore.instance.collection('food_orders');
      await ref.doc(docId).update({
        'orderStatus': 'completed',
      });
      Fluttertoast.showToast(msg: 'order completed');
      // await ref.doc(docId).update({
      //   'acceptedChiefId': chiefId,
      // });
    } catch (e) {
      Fluttertoast.showToast(msg: '$e');
      print("Error: $e");
    }
  }

  Future<ChiefDetailModel?> getChiefById({required String docId}) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('chief_users').doc(docId).get();

      if (doc.exists && doc.data() != null) {
        return ChiefDetailModel.fromJson(doc.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching chief user: $e');
      return null;
    }
  }

  Future<ClientDetailModel?> getUserById({required String docId}) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(docId).get();

      if (doc.exists && doc.data() != null) {
        return ClientDetailModel.fromJson(doc.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching  user: $e');
      return null;
    }
  }

  Future<ClientDetailModel> getClientById({required String docId}) async {
    final snapshot =
        await FirebaseFirestore.instance.collection('users').doc(docId).get();

    if (!snapshot.exists) {
      throw Exception('User not found');
    }

    return ClientDetailModel.fromJson(snapshot.data()!);
  }

  Future<void> rateChef({
    required String docId,
    required String givenRating,
  }) async {
    try {
      DocumentReference chefRef =
          FirebaseFirestore.instance.collection('chief_users').doc(docId);

      DocumentSnapshot chefSnapshot = await chefRef.get();

      if (chefSnapshot.exists) {
        String previousRatingStr = (chefSnapshot['rating'] ?? "0");
        double previousRating = double.tryParse(previousRatingStr) ?? 0.0;

        double newRatingValue = double.tryParse(givenRating) ?? 0.0;

        double newRating = (previousRating + newRatingValue) / 2;

        await chefRef.update({'rating': newRating.toString()});

        print("Chef rating updated successfully: $newRating");
      } else {
        print("Chef document does not exist.");
      }
    } catch (e) {
      print("Error updating chef rating: $e");
    }
  }

  Future<void> cookSideRequest(
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
      String status,
      String cookPhoneNumber,
      String cookEmail,
      String cookId) async {
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
        'timestamp': FieldValue.serverTimestamp(),
        'status': status,
        'cookPhoneNumber': cookPhoneNumber,
        'cookEmail': cookEmail,
        'cookId': cookId
      });
    } catch (e) {
      Fluttertoast.showToast(msg: '$e');
    }
    if (collection == 'request_form') {
      Fluttertoast.showToast(msg: "Request Added");
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const UserDashboardRequestForm()));
    }
  }

  Future<void> addAcceptedRequest(
    BuildContext context,
    String userid,
    String shiefid,
    String itemName,
    String date,
    String arrivelTime,
    String eventTime,
    String noOfPeople,
    int fare,
    String availabeingred,
    String name,
    String image,
    String collection,
  ) async {
    try {
      CollectionReference ref =
          FirebaseFirestore.instance.collection(collection);
      ref.doc().set({
        'shiefid': shiefid,
        'userid': userid,
        'User_Name': name,
        'Item_Name': itemName,
        'Date': date,
        'Arrivel_Time': arrivelTime,
        'Event_Time': eventTime,
        'No_of_People': noOfPeople,
        'Fare': fare,
        'Availabe_Ingredients': availabeingred,
        'image': image,
        'timestamp': FieldValue.serverTimestamp(),
        // Note: serverTimestamp() should not be updated if you want to retain the original creation time
      });
      Fluttertoast.showToast(msg: "Request Updated");
      // Navigator.of(context).pop(); // Typically you might want to pop back instead of navigating to a new route
    } catch (e) {
      Fluttertoast.showToast(msg: '$e');
    }
  }

  Future<void> addChefRequest(
    BuildContext context,
    String documentId,
    String userid,
    String itemName,
    String date,
    String arrivelTime,
    String eventTime,
    String noOfPeople,
    int fare,
    String availabeingred,
    String name,
    String image,
    String collection,
    String rating,
    int newfare,
  ) async {
    final user = _auth.currentUser;
    try {
      CollectionReference ref =
          FirebaseFirestore.instance.collection(collection);
      ref.doc().set({
        'shiefid': user!.uid,
        'userid': userid,
        'oldDocumentid': documentId,
        'User_Name': name,
        'Item_Name': itemName,
        'Date': date,
        'Arrivel_Time': arrivelTime,
        'Event_Time': eventTime,
        'No_of_People': noOfPeople,
        'New_fare': newfare,
        'Fare': fare,
        'Shiefrating,': rating,
        'Availabe_Ingredients': availabeingred,
        'image': image,
        'timestamp': FieldValue.serverTimestamp(),
        // Note: serverTimestamp() should not be updated if you want to retain the original creation time
      });
      Fluttertoast.showToast(msg: "Request Updated");
      // Navigator.of(context).pop(); // Typically you might want to pop back instead of navigating to a new route
    } catch (e) {
      Fluttertoast.showToast(msg: '$e');
    }
  }

  Future<void> acceptRequestAndUpdateVisibility(String requestId) async {
    await FirebaseFirestore.instance
        .collection('new_requestform')
        .doc(requestId)
        .update({
      'status': 'accepted',
      'isVisibleToChef': false,
      'isVisibleToUser': true,
    }).then((value) {
      Fluttertoast.showToast(msg: "Request moved to My Orders");
    }).catchError((error) {
      Fluttertoast.showToast(msg: "Error updating request: $error");
    });
  }

  Future<void> updateRequestStatus(String requestId, String status) async {
    try {
      await _firestore.collection('request_form').doc(requestId).update({
        'status': status,
      });
    } catch (e) {
      // Handle exceptions
      print(e);
    }
  }

  Future<void> chefAcceptsRequest(String requestId) async {
    await FirebaseFirestore.instance
        .collection('new_requestform')
        .doc(requestId)
        .update({
      'Action': 'in processing',
    }).then((value) {
      Fluttertoast.showToast(
          msg: "Request accepted, awaiting user confirmation.");
    }).catchError((error) {
      Fluttertoast.showToast(msg: "Error accepting request: $error");
    });
  }

  Future<void> userAcceptsRequest(String requestId) async {
    await _firestore.collection('accepted_requests').doc(requestId).update({
      'status': 'accepted',
      'isVisibleToChef': false,
      'isVisibleToUser': true,
    }).then((value) {
      Fluttertoast.showToast(msg: "Request accepted by user.");
    }).catchError((error) {
      Fluttertoast.showToast(msg: "Error on user's acceptance: $error");
    });
  }

  Future<void> acceptRequest(BuildContext context, String documentId) async {
    await _firestore.collection('request_form').doc(documentId).update({
      'Action': 'accepted',
      'isVisibleToChef': false,
    }).then((_) {
      Fluttertoast.showToast(msg: 'Request accepted.');
    }).catchError((error) {
      Fluttertoast.showToast(msg: 'Error accepting request: $error');
    });
  }

  Future<String> getUserName() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot<Map<String, dynamic>> snapshot =
            await _firestore.collection('allusers').doc(user.uid).get();
        if (snapshot.exists && snapshot.data() != null) {
          return snapshot.data()!['Name'] ?? 'No Name';
        } else {
          return 'No Name';
        }
      } else {
        return 'No User';
      }
    } catch (e) {
      print('Error fetching user name: $e');
      return 'Error';
    }
  }

  Future<void> completeOrder(String documentId) async {
    try {
      await _firestore.collection('accepted_requests').doc(documentId).update({
        'status': 'completed',
      });
      print("Order marked as completed.");
    } catch (e) {
      print("An error occurred while completing the order: $e");
    }
  }

  Future<bool> hasRatedChef(String chefId, String userId) async {
    try {
      var querySnapshot = await _firestore
          .collection('ratings')
          .where('chefId', isEqualTo: chefId)
          .where('userId', isEqualTo: userId)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print("Error checking rating status: $e");
      return false;
    }
  }

  Future<void> logout(BuildContext context) async {
    await SharedPreferencesManager.clearUserSession();
    await _auth.signOut();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const GetStartedScreen()),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> saveUserInfo({
    required String userId,
    required String name,
    required String email,
    required String role,
    String? image,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userId', userId);
    await prefs.setString('userName', name);
    await prefs.setString('userEmail', email);
    await prefs.setString('userRole', role);
    if (image != null) {
      await prefs.setString('userImage', image);
    }
  }
}

class EmailVerificationDialog extends StatefulWidget {
  final User user;

  const EmailVerificationDialog({required this.user});

  @override
  _EmailVerificationDialogState createState() =>
      _EmailVerificationDialogState();
}

class _EmailVerificationDialogState extends State<EmailVerificationDialog> {
  int _secondsRemaining = 30;
  Timer? _timer;
  bool _isEmailVerified = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) async {
      setState(() {
        _secondsRemaining--;
      });

      if (_secondsRemaining == 0) {
        _timer?.cancel();
        await _checkEmailVerification();
      }
    });
  }

  Future<void> _checkEmailVerification() async {
    await widget.user.reload();
    setState(() {
      _isEmailVerified = widget.user.emailVerified;
    });

    if (_isEmailVerified) {
      Navigator.of(context).pop(true);
    } else {
      Fluttertoast.showToast(
          msg: "Email not verified yet. Please check your email.");
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Verify Your Email"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
              "You need to verify your email to complete the sign-up process."),
          SizedBox(height: 10),
          Text("Returning in $_secondsRemaining seconds..."),
          SizedBox(height: 10),
          CircularProgressIndicator(),
        ],
      ),
      actions: [
        TextButton(
          child: Text("Check Now"),
          onPressed: _checkEmailVerification,
        ),
      ],
    );
  }
}
