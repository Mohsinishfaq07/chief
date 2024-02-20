// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names, avoid_print

import 'dart:io';
import 'package:chief/model/app_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import '../global_custom_widgets/custom_app_bar.dart';
import '../global_custom_widgets/custom_horizontal_line.dart';
import '../global_custom_widgets/custom_large_button.dart';
import '../global_custom_widgets/custom_size.dart';
import '../global_custom_widgets/custom_small_text_field.dart';
import '../global_custom_widgets/custom_title_text.dart';

// ignore: must_be_immutable
class SignupUser extends StatefulWidget {
  const SignupUser({super.key});
  static const tag = 'SignupUser';

  @override
  State<SignupUser> createState() => _SignupUserState();
}

class _SignupUserState extends State<SignupUser> {
  bool userSelectedImage = false;
  String? _image;
  String? imagePath;

  TextEditingController nameController = TextEditingController();

  TextEditingController numberController = TextEditingController();

  TextEditingController addressController = TextEditingController();

  TextEditingController gmailController = TextEditingController();

  TextEditingController passController = TextEditingController();
  TextEditingController confirmpassController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  AppDatabase database = AppDatabase();

  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBarWidget(
        showBackButton: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.04.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Spacer(),
                        const CustomTitleText(
                          text: 'Signup', // Only the text parameter is required
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            CustomBottomSheet(context);
                          },
                          child: userSelectedImage
                              ? // Check if user has selected an image
                              CircleAvatar(
                                  child: ClipOval(
                                    child: Image.file(
                                      File(imagePath!),
                                      fit: BoxFit.cover,
                                      width: 80,
                                      height: 80,
                                    ),
                                  ),
                                )
                              : Container(
                                  height: 80,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(69.r),
                                    color: Colors.white,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(17.0),
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 12,
                                          width: 12,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(69.r),
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Container(
                                          height: 30,
                                          width: 30,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(69.r),
                                            color: Colors.grey,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                        CustomSize(
                          width: 4.w,
                        ),
                      ],
                    ),
                    CustomSmallTextField(
                      keyboardType: TextInputType.name,
                      controller: nameController,
                      hintText: "Enter Name",
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          vertical:
                              MediaQuery.of(context).size.height * 0.02.h),
                      child: CustomSmallTextField(
                        keyboardType: TextInputType.number,
                        controller: numberController,
                        hintText: "Enter Number",
                      ),
                    ),
                    CustomSmallTextField(
                      keyboardType: TextInputType.streetAddress,
                      controller: addressController,
                      hintText: "Enter your location",
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          vertical:
                              MediaQuery.of(context).size.height * 0.02.h),
                      child: CustomSmallTextField(
                        keyboardType: TextInputType.emailAddress,
                        controller: gmailController,
                        hintText: "Enter gmail",
                      ),
                    ),
                    CustomSmallTextField(
                      keyboardType: TextInputType.visiblePassword,
                      controller: passController,
                      hintText: "Enter Password",
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.02.h),
                      child: CustomSmallTextField(
                        keyboardType: TextInputType.visiblePassword,
                        controller: confirmpassController,
                        hintText: "Confirm your Password",
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.04.h,
                    bottom: MediaQuery.of(context).size.height * 0.02.h),
                child: const CustomHorizontalDivider(),
              ),
              CustomLargeButton(
                title: 'Signup',
                ontap: () {
                  if (nameController.text.isEmpty ||
                      numberController.text.isEmpty ||
                      addressController.text.isEmpty ||
                      gmailController.text.isEmpty ||
                      passController.text.isEmpty) {
                    Fluttertoast.showToast(msg: 'Please fill the above fields');
                  } else {
                    if (confirmpassController.text == passController.text) {
                      onTapSignupUser(
                          context,
                          nameController.text,
                          numberController.text,
                          addressController.text,
                          gmailController.text,
                          passController.text);
                    } else {
                      Fluttertoast.showToast(msg: "password didn't match");
                    }
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  onTapSignupUser(
    BuildContext context,
    String name,
    String number,
    String address,
    String email,
    String pass,
  ) async {
    FocusScope.of(context).unfocus();
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
              child: CircularProgressIndicator(
                color: Colors.pink,
              ),
            ));
    try {
      await _auth
          .createUserWithEmailAndPassword(email: email, password: pass)
          .then((uid) => {
                database.userDetailsToFirestore(
                    context, name, number, address, email, pass, _image ?? "")
              });
    } catch (e) {
      Fluttertoast.showToast(msg: '$e');
      Navigator.of(context).pop(); // Dismiss the loading dialog
    }
  }

  Future<dynamic> CustomBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
            color: Colors.pink[200],
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                items('Camera', Icons.camera_alt),
                items(
                  'Gallery',
                  Icons.photo_library,
                )
              ],
            ));
      },
    );
  }

  Widget items(String txt, IconData icon) {
    return GestureDetector(
      onTap: () {
        if (txt == 'Gallery') {
          _pickImage(ImageSource.gallery);
        } else {
          _pickImage(ImageSource.camera);
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 32, // Adjust size as needed
          ),
          Text(txt)
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    String filename = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: source);
    imagePath = pickedImage!.path;
    userSelectedImage = true;
    final Reference storageReference =
        FirebaseStorage.instance.ref().child('images/$filename');
    UploadTask uploadTask = storageReference.putFile(File(pickedImage.path));
    await uploadTask.whenComplete(() => null);
    String imagepath = await storageReference.getDownloadURL();
    setState(() {
      _image = imagepath;
    });
  }
}
