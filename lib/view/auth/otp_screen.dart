//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:email_auth/email_auth.dart';
// /// Importing the configuration file to pass them to the EmailAuth instance
// /// You can have a custom path and a variable name,
// /// but the Map should be in the pattern {server : "", serverKey : ""}
// // import 'package:email_auth_example/auth.config.dart';
//
//
// class OtpScreen extends StatefulWidget {
//   const OtpScreen({super.key});
//
//   @override
//   // ignore: library_private_types_in_public_api
//   _OtpScreenState createState() => _OtpScreenState();
// }
//
// class _OtpScreenState extends State<OtpScreen> {
//   /// The boolean to handle the dynamic operations
//   bool submitValid = false;
//
//   /// Text editing controllers to get the value from text fields
//   final TextEditingController _emailcontroller = TextEditingController();
//   final TextEditingController _otpcontroller = TextEditingController();
//
//   // Declare the object
//   late EmailAuth emailAuth;
//
//   @override
//   void initState() {
//     super.initState();
//     // Initialize the package
//     emailAuth = EmailAuth(
//       sessionName: "Sample session",
//     );
//
//     /// Configuring the remote server
//     emailAuth.config(remoteServerConfiguration);
//   }
//
//   /// a void function to verify if the Data provided is true
//   /// Convert it into a boolean function to match your needs.
//   void verify() {
//     if (kDebugMode) {
//       print(
//           "OTP validation results >> ${emailAuth.validateOtp(recipientMail: _emailcontroller.value.text, userOtp: _otpcontroller.value.text)}");
//     }
//   }
//
//   /// a void funtion to send the OTP to the user
//   /// Can also be converted into a Boolean function and render accordingly for providers
//   void sendOtp() async {
//     bool result = await emailAuth.sendOtp(recipientMail: _emailcontroller.value.text, otpLength: 5);
//     if (result) {
//       setState(() {
//         submitValid = true;
//       });
//     } else if (kDebugMode) {
//       print("Error processing OTP requests, check server for logs");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return  Scaffold(
//       appBar: AppBar(
//         title: const Text('Email Auth sample verification'),
//       ),
//       body: Container(
//           margin: const EdgeInsets.all(5),
//           child: Center(
//             child: Card(
//               elevation: 5,
//               margin: const EdgeInsets.all(15),
//               child: Padding(
//                 padding: const EdgeInsets.all(15),
//                 child: Column(
//                   children: <Widget>[
//                     const Text(
//                       "Please enter a valid Email ID",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 20,
//                       ),
//                     ),
//                     TextField(
//                       controller: _emailcontroller,
//                       style: const TextStyle(fontSize: 18),
//                     ),
//                     Card(
//                       margin: const EdgeInsets.only(top: 20),
//                       elevation: 6,
//                       child: Container(
//                         height: 50,
//                         width: 200,
//                         color: Colors.green[400],
//                         child: GestureDetector(
//                           onTap: sendOtp,
//                           child: const Center(
//                             child: Text(
//                               "Request OTP",
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                                 fontSize: 20,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//
//                     /// A dynamically rendering text field
//                     (submitValid)
//                         ? TextField(
//                       controller: _otpcontroller,
//                     )
//                         : Container(height: 1),
//                     (submitValid)
//                         ? Container(
//                       margin: const EdgeInsets.only(top: 20),
//                       height: 50,
//                       width: 200,
//                       color: Colors.green[400],
//                       child: GestureDetector(
//                         onTap: verify,
//                         child: const Center(
//                           child: Text(
//                             "Verify",
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                               fontSize: 20,
//                             ),
//                           ),
//                         ),
//                       ),
//                     )
//                         : const SizedBox(height: 1),
//                   ],
//                 ),
//               ),
//             ),
//           )),
//     );
//   }
// }