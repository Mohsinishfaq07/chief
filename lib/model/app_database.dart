// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:async';

import 'package:chief/model/all_user_detail_model.dart';
import 'package:chief/model/chief_detail_model.dart';
import 'package:chief/model/client_detail_model.dart';
import 'package:chief/model/request_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:chief/view/auth/login_screen.dart';
import 'package:chief/view/dashboard/User_dashboard_request_form.dart';
import 'package:chief/view/get_started_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../view/dashboard/chef_dashboard_screen.dart';

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
      String role = await getUserRole();
      Navigator.of(context).popUntil((route) => route.isFirst);
      // Navigate based on user role
      if (role == 'chief') {
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ChefDashboardScreen()),
          (Route<dynamic> route) => false,
        );
      } else if (role == 'user') {
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => const UserDashboardRequestForm()),
          (Route<dynamic> route) => false,
        );
      }
      Fluttertoast.showToast(msg: "Login Successful");
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

  // Future<void> chefDetailToFireStore(
  //     BuildContext context,
  //     String name,
  //     String number,
  //     String address,
  //     String email,
  //     String pass,
  //     String experience,
  //     String speciality,
  //     String certificate,
  //     String image,
  //     String certificateimage,
  //     int rating) async {
  //   var user = _auth.currentUser;
  //   CollectionReference ref =
  //       FirebaseFirestore.instance.collection('chief_users');
  //   ref.doc(user!.uid).set({
  //     'id': user.uid,
  //     'Name': name,
  //     'Number': number,
  //     'Address': address,
  //     'Email': email,
  //     'Password': pass,
  //     'Work Experience': experience,
  //     'Specialities': speciality,
  //     'Certifications': certificate,
  //     'Certificate image': certificateimage,
  //     'image': image,
  //     'Rating': rating.toString(),
  //     'role': 'chief',
  //     'timestamp': FieldValue.serverTimestamp()
  //   });
  //   CollectionReference allUsersRef =
  //       FirebaseFirestore.instance.collection('allusers');
  //   allUsersRef.doc(user.uid).set({
  //     'id': user.uid,
  //     'Name': name,
  //     'Email': email,
  //     'role': 'chief',
  //     'timestamp': FieldValue.serverTimestamp()
  //   });
  //   Fluttertoast.showToast(msg: "Account Created");
  //   Navigator.of(context).popUntil((route) => route.isFirst);
  //   Navigator.pushAndRemoveUntil(
  //     context,
  //     MaterialPageRoute(builder: (context) => const GetStartedScreen()),
  //     (Route<dynamic> route) => false,
  //   );
  // }

  Future<void> chefDetailToFireStore({
    required BuildContext context,
    required ChiefDetailModel chiefDetail,
    required AllUserDetailModel allUserDetail,
  }) async {
    try {
      var user = _auth.currentUser;

      CollectionReference chiefRef =
          FirebaseFirestore.instance.collection('chief_users');

      await chiefRef.doc(user!.uid).set(chiefDetail.toJson());

      CollectionReference allUsersRef =
          FirebaseFirestore.instance.collection('allusers');

      await allUsersRef.doc(user.uid).set(allUserDetail.toJson());

      Fluttertoast.showToast(msg: "Chief Account Created");

      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const GetStartedScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      // Handle errors
      Fluttertoast.showToast(msg: "Error: $e");
      print("Error: $e");
    }
  }
  // Future<void> chefDetailToFireStore(
  //     BuildContext context,
  //     String name,
  //     String number,
  //     String address,
  //     String email,
  //     String pass,
  //     String experience,
  //     String speciality,
  //     String certificate,
  //     String image,
  //     String certificateimage,
  //     int rating,
  //     ) async {
  //   var user = _auth.currentUser;
  //   CollectionReference ref = FirebaseFirestore.instance.collection('chief_users');
  //
  //   try {
  //     // Check if the email is verified
  //     if (!user!.emailVerified) {
  //       // Prompt the chef to verify the email
  //       Fluttertoast.showToast(msg: "Please verify your email before creating your account.");
  //       await user.sendEmailVerification(); // Send verification email
  //
  //       // Show countdown dialog with option to check verification
  //       bool isEmailVerified = await showDialog(
  //         context: context,
  //         barrierDismissible: false,
  //         builder: (context) {
  //           return EmailVerificationDialog(user: user);
  //         },
  //       ) ?? false; // If dialog is dismissed, default to false
  //
  //       // Final check after countdown or "Check Now"
  //       if (!isEmailVerified) {
  //         Fluttertoast.showToast(msg: "Email verification not completed. Sign-up process stopped.");
  //         return; // Stop the sign-up process if email is not verified
  //       }
  //     }
  //
  //     // Check if the user already exists in Firestore
  //     DocumentSnapshot existingUser = await ref.doc(user.uid).get();
  //     if (existingUser.exists) {
  //       Fluttertoast.showToast(msg: "Account already exists. Please log in.");
  //       return; // Exit the function if the user already exists
  //     }
  //
  //     // Email is verified and no existing user, proceed with creating account in Firestore
  //     await ref.doc(user.uid).set({
  //       'id': user.uid,
  //       'Name': name,
  //       'Number': number,
  //       'Address': address,
  //       'Email': email,
  //       'Password': pass,
  //       'Work Experience': experience,
  //       'Specialities': speciality,
  //       'Certifications': certificate,
  //       'Certificate image': certificateimage,
  //       'image': image,
  //       'Rating': rating.toString(),
  //       'role': 'chief',
  //       'timestamp': FieldValue.serverTimestamp()
  //     });
  //
  //     CollectionReference allUsersRef = FirebaseFirestore.instance.collection('allusers');
  //     await allUsersRef.doc(user.uid).set({
  //       'id': user.uid,
  //       'Name': name,
  //       'Email': email,
  //       'role': 'chief',
  //       'timestamp': FieldValue.serverTimestamp()
  //     });
  //
  //     // Inform user that account creation was successful
  //     Fluttertoast.showToast(msg: "Account Created");
  //
  //     // Navigate to GetStartedScreen
  //     Navigator.of(context).popUntil((route) => route.isFirst);
  //     Navigator.pushAndRemoveUntil(
  //       context,
  //       MaterialPageRoute(builder: (context) => const GetStartedScreen()),
  //           (Route<dynamic> route) => false,
  //     );
  //
  //   } catch (e) {
  //     // Handle errors related to Firebase operations or other exceptions
  //     print('Error creating chef account: $e');
  //     Fluttertoast.showToast(msg: 'An error occurred. Please try again later.');
  //   }
  // }

  // void userDetailsToFireStore(BuildContext context, String name, String number,
  //     String address, String email, String pass, String imagepath) {
  //   var user = _auth.currentUser;
  //   CollectionReference ref = FirebaseFirestore.instance.collection('users');
  //   ref.doc(user!.uid).set({
  //     'id': user.uid,
  //     'Name': name,
  //     'Number': number,
  //     'Address': address,
  //     'Email': email,
  //     'Password': pass,
  //     'role': 'user',
  //     'image': imagepath,
  //     'timestamp': FieldValue.serverTimestamp()
  //   });
  //   CollectionReference allusersref =
  //       FirebaseFirestore.instance.collection('allusers');
  //   allusersref.doc(user.uid).set({
  //     'id': user.uid,
  //     'Name': name,
  //     'Email': email,
  //     'image': imagepath,
  //     'role': 'user',
  //     'timestamp': FieldValue.serverTimestamp()
  //   });
  //   Fluttertoast.showToast(msg: "Account Created");
  //   Navigator.of(context).popUntil((route) => route.isFirst);
  //   Navigator.pushAndRemoveUntil(
  //     context,
  //     MaterialPageRoute(builder: (context) => const GetStartedScreen()),
  //     (Route<dynamic> route) => false,
  //   );
  // }

  void userDetailsToFireStore({
    required BuildContext context,
    required ClientDetailModel clientDetail,
    required AllUserDetailModel allUserDetail,
  }) async {
    try {
      var user = _auth.currentUser;

      CollectionReference userRef =
          FirebaseFirestore.instance.collection('users');
      await userRef.doc(user!.uid).set(clientDetail.toJson());
      CollectionReference allUsersRef =
          FirebaseFirestore.instance.collection('allusers');
      await allUsersRef.doc(user.uid).set(allUserDetail.toJson());
      Fluttertoast.showToast(msg: "Account Created");
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const GetStartedScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      // Handle errors
      Fluttertoast.showToast(msg: "Error: $e");
      print("Error: $e");
    }
  }

  // Future<void> addRequest(
  //   BuildContext context,
  //   String userid,
  //   String itemName,
  //   String date,
  //   String arrivelTime,
  //   String eventTime,
  //   String noOfPeople,
  //   int fare,
  //   String availabeingred,
  //   String name,
  //   String image,
  //   String collection,
  //   String action,
  //   String status,
  //   String clientNumber,
  // ) async {
  //   final user = _auth.currentUser;
  //   try {
  //     CollectionReference ref =
  //         FirebaseFirestore.instance.collection(collection);
  //     ref.doc().set({
  //       'userid': user!.uid,
  //       'shiefid': '',
  //       'User_Name': name,
  //       'Item_Name': itemName,
  //       'Date': date,
  //       'Arrivel_Time': arrivelTime,
  //       'Event_Time': eventTime,
  //       'No_of_People': noOfPeople,
  //       'Fare': fare,
  //       'image': image,
  //       'client_number': clientNumber,
  //       'Availabe_Ingredients': availabeingred,
  //       'accepted_chief_ids': [],
  //       'denied_chief_ids': [],
  //       'timestamp': FieldValue.serverTimestamp(),
  //     });
  //   } catch (e) {
  //     Fluttertoast.showToast(msg: '$e');
  //   }
  //   if (collection == 'request_form') {
  //     Fluttertoast.showToast(msg: "Request Added");
  //     Navigator.of(context).push(MaterialPageRoute(
  //         builder: (context) => const UserDashboardRequestForm()));
  //   }
  // }

  Future<void> addRequest({
    required BuildContext context,
    required RequestModel requestModel,
  }) async {
    try {
      CollectionReference ref =
          FirebaseFirestore.instance.collection('food_orders');
      await ref.doc().set(requestModel.toJson());
      Fluttertoast.showToast(msg: "Request Added");
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const UserDashboardRequestForm(),
        ),
      );
    } catch (e) {
      Fluttertoast.showToast(msg: '$e');
      print("Error: $e");
    }
  }

  Future<void> acceptByChief(
      {required String docId, required String userId}) async {
    try {
      CollectionReference ref =
          FirebaseFirestore.instance.collection('food_orders');

      await ref.doc(docId).update({
        'accepted_chief_ids': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      Fluttertoast.showToast(msg: '$e');
      print("Error: $e");
    }
  }

  Future<void> rejectByChief(
      {required String docId, required String userId}) async {
    try {
      CollectionReference ref =
          FirebaseFirestore.instance.collection('food_orders');

      await ref.doc(docId).update({
        'declined_chief_ids': FieldValue.arrayUnion([userId]),
      });
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
      });
    } catch (e) {
      Fluttertoast.showToast(msg: '$e');
      print("Error: $e");
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

// Method to handle acceptance of a request by a user
  Future<void> acceptRequestAndUpdateVisibility(String requestId) async {
    await FirebaseFirestore.instance
        .collection('new_requestform')
        .doc(requestId)
        .update({
      'status': 'accepted', // Indicate that the request has been accepted
      'isVisibleToChef': false, // No longer visible on Chef's Dashboard
      'isVisibleToUser': true, // Still visible to the user in My Orders
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
  // Future<void> userAcceptsRequest(String requestId) async {
  //   await FirebaseFirestore.instance.collection('new_requestform').doc(requestId).update({
  //     'status': 'accepted',
  //     'isVisibleToChef': false,  // This request should no longer be visible in the chef's request queue
  //     'isVisibleToUser': true,   // Should still be visible to the user until completely processed
  //     'isVisibleInMyOrders': true // Now it should be visible in the user's My Orders section
  //   });
  // }

  // Method to handle acceptance of a request by a chef
// In AppDatabase class
  // In AppDatabase or wherever you handle Firestore operations
  Future<void> chefAcceptsRequest(String requestId) async {
    await FirebaseFirestore.instance
        .collection('new_requestform')
        .doc(requestId)
        .update({
      'Action':
          'in processing', // Indicate that the chef has accepted the request but it's not finalized
    }).then((value) {
      Fluttertoast.showToast(
          msg: "Request accepted, awaiting user confirmation.");
    }).catchError((error) {
      Fluttertoast.showToast(msg: "Error accepting request: $error");
    });
  }

// Method to handle acceptance of a request by a user
  Future<void> userAcceptsRequest(String requestId) async {
    await _firestore.collection('accepted_requests').doc(requestId).update({
      'status': 'accepted',
      'isVisibleToChef':
          false, // This request should no longer be visible in the chef's request queue
      'isVisibleToUser':
          true, // Should still be visible to the user until completely processed
      // ...additional updates if needed
    }).then((value) {
      Fluttertoast.showToast(msg: "Request accepted by user.");
    }).catchError((error) {
      Fluttertoast.showToast(msg: "Error on user's acceptance: $error");
    });
  }

  Future<void> acceptRequest(BuildContext context, String documentId) async {
    await _firestore.collection('request_form').doc(documentId).update({
      'Action': 'accepted', // Update the action to 'accepted'
      'isVisibleToChef': false, // Make it invisible to other chefs
    }).then((_) {
      Fluttertoast.showToast(msg: 'Request accepted.');
      // Optionally, navigate to the chef's dashboard or update the UI
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
          return snapshot.data()!['Name'] ??
              'No Name'; // Assuming 'Name' is the field in Firestore
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
      // Update the order's status to 'completed'
      await _firestore.collection('accepted_requests').doc(documentId).update({
        'status': 'completed',
      });
      // Handle any other updates or cleanup operations here
      print("Order marked as completed.");
    } catch (e) {
      print("An error occurred while completing the order: $e");
      // Handle any errors here
    }
  }

  Future<bool> hasRatedChef(String chefId, String userId) async {
    try {
      // Assuming there's a collection named 'ratings' where each document represents a rating
      // and has 'chefId' and 'userId' fields
      var querySnapshot = await _firestore
          .collection('ratings')
          .where('chefId', isEqualTo: chefId)
          .where('userId', isEqualTo: userId)
          .get();

      // If the query returns any documents, it means the user has rated this chef
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print("Error checking rating status: $e");
      return false; // or handle the exception as needed
    }
  }
}

class EmailVerificationDialog extends StatefulWidget {
  final User user;

  EmailVerificationDialog({required this.user});

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
    await widget.user
        .reload(); // Reload the user's data to get the latest status
    setState(() {
      _isEmailVerified = widget.user.emailVerified;
    });

    if (_isEmailVerified) {
      Navigator.of(context)
          .pop(true); // Close dialog and return true if email is verified
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
