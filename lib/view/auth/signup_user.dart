// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names, avoid_print

import 'dart:io';
import 'package:chief/model/all_user_detail_model.dart';
import 'package:chief/model/app_database.dart';
import 'package:chief/model/client_detail_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import '../../global_custom_widgets/custom_app_bar.dart';
import '../../global_custom_widgets/custom_horizontal_line.dart';
import '../../global_custom_widgets/custom_large_button.dart';
import '../../global_custom_widgets/custom_size.dart';
import '../../global_custom_widgets/custom_text_form_field.dart';
import '../../global_custom_widgets/custom_title_text.dart';

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
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
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
                          text:
                              'Signup User', // Only the text parameter is required
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            _pickImage();
                          },
                          child: userSelectedImage
                              ? // Check if user has selected an image
                              CircleAvatar(
                                  radius: 50,
                                  backgroundImage: userSelectedImage
                                      ? NetworkImage(_image!)
                                      : null,
                                  child: !userSelectedImage
                                      ? const Icon(Icons.person, size: 50)
                                      : null, // Show an icon if no image is selected
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
                          width: 14.w,
                        ),
                      ],
                    ),
                    CustomTextField(
                      label: "Enter name",
                      controller: nameController,
                      hintText: "Enter name",
                      height: MediaQuery.of(context).size.height * 0.056.h,
                      width: MediaQuery.of(context).size.width * 0.7.w,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          vertical:
                              MediaQuery.of(context).size.height * 0.02.h),
                      child: CustomTextField(
                        label: "Enter number",
                        controller: numberController,
                        maxLength: 11,
                        keyboardType: TextInputType.phone,
                        hintText: "Enter number",
                        height: MediaQuery.of(context).size.height * 0.056.h,
                        width: MediaQuery.of(context).size.width * 0.7.w,
                      ),
                    ),
                    CustomTextField(
                      label: "Enter your location",
                      controller: addressController,
                      hintText: "Enter your location",
                      height: MediaQuery.of(context).size.height * 0.056.h,
                      width: MediaQuery.of(context).size.width * 0.7.w,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          vertical:
                              MediaQuery.of(context).size.height * 0.02.h),
                      child: CustomTextField(
                        label: "Enter gmail",
                        controller: gmailController,
                        hintText: "Enter gmail",
                        height: MediaQuery.of(context).size.height * 0.056.h,
                        width: MediaQuery.of(context).size.width * 0.7.w,
                      ),
                    ),
                    CustomTextField(
                      label: "Enter Password",
                      controller: passwordController,
                      hintText: "Enter Password",
                      isPasswordField: true,
                      height: MediaQuery.of(context).size.height * 0.056.h,
                      width: MediaQuery.of(context).size.width * 0.7.w,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.02.h),
                      child:
                          // CustomSmallTextField(
                          //   keyboardType: TextInputType.visiblePassword,
                          //   controller: confirmPasswordController,
                          //   hintText: "Confirm your Password",
                          // ),
                          CustomTextField(
                        label: "Confirm your Password",
                        controller: confirmPasswordController,
                        hintText: "Confirm your Password",
                        isPasswordField: true,
                        height: MediaQuery.of(context).size.height * 0.056.h,
                        width: MediaQuery.of(context).size.width * 0.7.w,
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
                  // if (!userSelectedImage) {
                  //   Fluttertoast.showToast(msg: 'Please upload an image to proceed');
                  //   return;
                  // }
                  if (nameController.text.isEmpty ||
                      numberController.text.isEmpty ||
                      addressController.text.isEmpty ||
                      gmailController.text.isEmpty ||
                      passwordController.text.isEmpty) {
                    Fluttertoast.showToast(msg: 'Please fill the above fields');
                  } else {
                    if (confirmPasswordController.text ==
                        passwordController.text) {
                      onTapSignupUser(
                          context,
                          nameController.text,
                          numberController.text,
                          addressController.text,
                          gmailController.text,
                          passwordController.text);
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
                color: Colors.deepOrange,
              ),
            ));
    try {
      await _auth
          .createUserWithEmailAndPassword(email: email, password: pass)
          .then((uid) => {
                database.userDetailsToFireStore(
                  context: context,
                  clientDetail: ClientDetailModel(
                    address: address,
                    email: email,
                    name: name,
                    number: number,
                    password: pass,
                    userId: _auth.currentUser!.uid,
                    image: _image ?? "enable_storage",
                    role: 'user',
                    timestamp: Timestamp.now(),
                  ),
                  allUserDetail: AllUserDetailModel(
                    id: _auth.currentUser!.uid,
                    name: name,
                    email: email,
                    role: 'user',
                    timestamp: Timestamp.now(),
                  ),
                )
              });
    } catch (e) {
      Fluttertoast.showToast(msg: '$e');
      Navigator.of(context).pop(); // Dismiss the loading dialog
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Pick from gallery'),
                  onTap: () async {
                    Navigator.pop(context);
                    //_pickImageFromSource(ImageSource.gallery);
                  }),
              ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Take a picture'),
                  onTap: () async {
                    Navigator.pop(context);
                    //   _pickImageFromSource(ImageSource.camera);
                  }),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: source);

    if (pickedImage != null) {
      File imageFile = File(pickedImage.path);
      String filename = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference storageReference =
          FirebaseStorage.instance.ref().child('images/$filename');
      UploadTask uploadTask = storageReference.putFile(imageFile);

      try {
        await uploadTask;
        final String downloadUrl = await storageReference.getDownloadURL();
        print("Image URL: $downloadUrl"); // Useful for debugging

        setState(() {
          userSelectedImage = true;
          imagePath = imageFile.path;
          _image = downloadUrl;
        });
      } catch (e) {
        print("Error uploading image: $e");
        Fluttertoast.showToast(msg: "Error uploading image: $e");
      }
    } else {
      Fluttertoast.showToast(msg: "No image selected");
    }
  }
}
