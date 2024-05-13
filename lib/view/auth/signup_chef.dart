// ignore_for_file: must_be_immutable, use_build_context_synchronously, non_constant_identifier_names

import 'dart:io';
import 'package:chief/global_custom_widgets/custom_text_form_field.dart';
import 'package:chief/model/app_database.dart';
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
import '../../global_custom_widgets/custom_title_text.dart';

class SignupChef extends StatefulWidget {
  const SignupChef({super.key});
  static const tag = 'SignupChef';

  @override
  State<SignupChef> createState() => _SignupChefState();
}

class _SignupChefState extends State<SignupChef> {
  bool userSelectedImage = false;
  bool userSelectCertificate = false;
  String _image = "";
  String certificateImage = "";
  String? imagePath;

  TextEditingController nameController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController gmailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController experienceController = TextEditingController();
  TextEditingController specialityController = TextEditingController();
  TextEditingController certificateController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool showPassword = false;
  AppDatabase database = AppDatabase();

  final _auth = FirebaseAuth.instance;
  final List<String> _uploadedImages = [];
  final bool _isUploading = false; // To track uploading status

  @override
  Widget build(BuildContext context) {
    double textFieldWidth = MediaQuery.of(context).size.width * 0.8;
    double textFieldHeight = MediaQuery.of(context).size.height * 0.056;
    double paddingHeight = MediaQuery.of(context).size.height * 0.02;
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
                passwordController.text.isEmpty ||
                experienceController.text.isEmpty ||
                specialityController.text.isEmpty) {
              Fluttertoast.showToast(msg: 'Please fill the above fields');
            } else {
              if (confirmPasswordController.text == passwordController.text) {
                onTapSignupUser(
                  context,
                  nameController.text,
                  numberController.text,
                  addressController.text,
                  gmailController.text,
                  passwordController.text,
                  experienceController.text,
                  specialityController.text,
                  certificateController.text,
                  certificateImage,
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
                          text:
                              'Chef Signup', // Only the text parameter is required
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
                          width: 14.w,
                        ),
                      ],
                    ),
                    CustomTextField(
                      label: "Your Name",
                        controller: nameController,
                        hintText: "Enter name",
                        height: textFieldHeight,
                        width: textFieldWidth),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: paddingHeight),
                      child: CustomTextField(
                        controller: numberController,
                        maxLength: 11,
                        hintText: "Enter Number",
                        height: textFieldHeight,
                        width: textFieldWidth,
                        keyboardType: TextInputType.number, label: 'Enter Number',
                      ),
                    ),
                    CustomTextField(
                      label:"Enter Your Location",
                        controller: addressController,
                        hintText: "Enter Your Location",
                        height: textFieldHeight,
                        width: textFieldWidth),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: paddingHeight),
                      child: CustomTextField(
                        label:"Enter Gmail" ,
                          controller: gmailController,
                          hintText: "Enter Gmail",
                          height: textFieldHeight,
                          width: textFieldWidth),
                    ),
                    CustomTextField(label:"Enter Password",
                        controller: passwordController,
                        hintText: "Enter Password",
                        isPasswordField: true,
                        height: textFieldHeight,
                        width: textFieldWidth),
                    Padding(
                      padding: EdgeInsets.only(top: paddingHeight),
                      child: CustomTextField(label:"Confirm Password",
                          controller: confirmPasswordController,
                          hintText: "Confirm Password",
                          isPasswordField: true,
                          height: textFieldHeight,
                          width: textFieldWidth),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          vertical:
                              MediaQuery.of(context).size.height * 0.02.h),
                      child: CustomTextField(label:"Enter Work Experience",
                          keyboardType: TextInputType.number,
                          controller: experienceController,
                          hintText: "Enter Work Experience",
                          height: textFieldHeight,
                          width: textFieldWidth),
                    ),
                    CustomTextField(label: "Enter Specialities",
                        controller: specialityController,
                        hintText: "Enter Specialities",
                        height: textFieldHeight,
                        width: textFieldWidth),
                    Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: paddingHeight,
                        ),
                        child: userSelectCertificate
                            ? Image.network(
                                certificateImage,
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      // Invoke your method to show the bottom sheet or image picker
                                      CustomBottomSheet(context, 'certificate');
                                    },
                                    child: Container(
                                      width: textFieldWidth,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20.w, vertical: 10.h),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(9.h),
                                        border: Border.all(
                                            color: Colors.grey[300]!),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Enter Certifications",
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const Icon(
                                            Icons.camera_alt_outlined,
                                            color: Colors.grey,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10.h),
                                  // Show loading indicator or images
                                  _isUploading
                                      ? const Center(
                                          child: CircularProgressIndicator())
                                      : _uploadedImages.isEmpty
                                          ? Container()
                                          : SizedBox(
                                              height: 100
                                                  .h, // Adjust based on your UI needs
                                              child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount:
                                                    _uploadedImages.length,
                                                itemBuilder: (context, index) {
                                                  return Padding(
                                                    padding: EdgeInsets.only(
                                                        right: 8.w),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.h),
                                                      child: Image.network(
                                                        _uploadedImages[index],
                                                        width: 100.w,
                                                        height: 100.h,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                ],
                              )),
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
    String certificateImage,
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
                    certificateImage,
                    0),
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
        Navigator.pop(context);
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
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: source);
    if (pickedImage != null) {
      File imageFile = File(pickedImage.path);
      String filename = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference storageReference =
          FirebaseStorage.instance.ref().child('images/$filename');
      UploadTask uploadTask = storageReference.putFile(imageFile);
      await uploadTask;
      final String downloadUrl = await storageReference.getDownloadURL();
      setState(() {
        if (txt == 'certificate') {
          certificateImage = downloadUrl; // This should be the download URL
          userSelectCertificate = true;
        } else if (txt == '') {
          userSelectedImage = true;
          _image =
              downloadUrl; // Also set _image to the download URL if necessary
        }
      });
    }
  }


}
