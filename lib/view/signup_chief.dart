// ignore_for_file: must_be_immutable, use_build_context_synchronously, non_constant_identifier_names

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

class SignupChief extends StatefulWidget {
  const SignupChief({super.key});
  static const tag = 'SignupChief';

  @override
  State<SignupChief> createState() => _SignupChiefState();
}

class _SignupChiefState extends State<SignupChief> {
  bool userSelectedImage = false;

  String _image = "";
  String? _certificateimage;

  String? imagePath;

  TextEditingController nameController = TextEditingController();

  TextEditingController numberController = TextEditingController();

  TextEditingController addressController = TextEditingController();

  TextEditingController gmailController = TextEditingController();

  TextEditingController passController = TextEditingController();

  TextEditingController experienceController = TextEditingController();

  TextEditingController specialityController = TextEditingController();

  TextEditingController certificateController = TextEditingController();
  TextEditingController confirmpassController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool showpass = false;

  AppDatabase database = AppDatabase();

  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBarWidget(
        showBackButton: true,
      ),
      bottomNavigationBar: CustomLargeButton(
          title: 'Signup',
          ontap: () {
            if (nameController.text.isEmpty ||
                numberController.text.isEmpty ||
                addressController.text.isEmpty ||
                gmailController.text.isEmpty ||
                passController.text.isEmpty ||
                experienceController.text.isEmpty ||
                specialityController.text.isEmpty) {
              Fluttertoast.showToast(msg: 'Please fill the above fields');
            } else {
              if (confirmpassController.text == passController.text) {
                onTapSignupUser(
                  context,
                  nameController.text,
                  numberController.text,
                  addressController.text,
                  gmailController.text,
                  passController.text,
                  experienceController.text,
                  specialityController.text,
                  certificateController.text,
                  _certificateimage ?? "",
                );
              } else {
                Fluttertoast.showToast(msg: "password didn't match");
              }
            }
          }),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.04.w),
              child: Form(
                key: _formKey,
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
                        // Check if user has selected an image
                        GestureDetector(
                            onTap: () {
                              CustomBottomSheet(context, '');
                            },
                            child: userSelectedImage
                                ? CircleAvatar(
                                    radius: 50,
                                    child: ClipOval(
                                        child: Image.network(
                                      _image,
                                      fit: BoxFit.cover,
                                      width: 100,
                                      height: 100,
                                    )),
                                  )
                                : Container(
                                    height: 80,
                                    width: 80,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(69.r),
                                        color: Colors.white),
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
                                                color: Colors.grey),
                                          ),
                                          Container(
                                            height: 30,
                                            width: 30,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(69.r),
                                                color: Colors.grey),
                                          )
                                        ],
                                      ),
                                    ),
                                  )),
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
                    Padding(
                      padding: EdgeInsets.symmetric(
                          vertical:
                              MediaQuery.of(context).size.height * 0.02.h),
                      child: CustomSmallTextField(
                        keyboardType: TextInputType.number,
                        controller: experienceController,
                        hintText: "Enter Work Experience",
                      ),
                    ),
                    CustomSmallTextField(
                      keyboardType: TextInputType.name,
                      controller: specialityController,
                      hintText: "Enter Specialities",
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          vertical:
                              MediaQuery.of(context).size.height * 0.02.h),
                      child: CustomSmallTextField(
                        keyboardType: TextInputType.name,
                        controller: certificateController,
                        hintText: "Enter Certifications",
                        sufix: Icons.camera_alt_outlined,
                        onPressed: () {
                          CustomBottomSheet(context, 'certificate');
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height * 0.01.h),
              child: const CustomHorizontalDivider(),
            ),
          ],
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
    String experience,
    String speciality,
    String certificate,
    String certificateimage,
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
                database.chiefDetailsToFirestore(
                    context,
                    name,
                    number,
                    address,
                    email,
                    pass,
                    experience,
                    speciality,
                    certificate,
                    _image,
                    certificateimage),
              });
    } catch (e) {
      Fluttertoast.showToast(msg: '$e');
      Navigator.of(context).pop(); // Dismiss the loading dialog
    }
  }

  Future<dynamic> CustomBottomSheet(BuildContext context, String txt) {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
            color: Colors.pink[200],
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                items('Camera', Icons.camera_alt, txt),
                items('Gallery', Icons.photo_library, txt)
              ],
            ));
      },
    );
  }

  Widget items(String txt, IconData icon, String text) {
    return GestureDetector(
      onTap: () {
        if (txt == 'Gallery') {
          _pickImage(ImageSource.gallery, text);
        } else {
          _pickImage(ImageSource.camera, text);
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

  Future<void> _pickImage(ImageSource source, String txt) async {
    String filename = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: source);
    imagePath = pickedImage!.path;
    final Reference storageReference =
        FirebaseStorage.instance.ref().child('images/$filename');
    UploadTask uploadTask = storageReference.putFile(File(pickedImage.path));
    await uploadTask.whenComplete(() => null);
    String imagepath = await storageReference.getDownloadURL();
    setState(() {
      if (txt == 'certificate') {
        _certificateimage = imagePath;
      } else if (txt == '') {
        userSelectedImage = true;
        _image = imagepath;
      }
    });
  }
}
