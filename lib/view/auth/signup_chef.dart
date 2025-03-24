import 'dart:io';
import 'package:chief/global_custom_widgets/custom_text_form_field.dart';
import 'package:chief/model/all_user_detail_model.dart';
import 'package:chief/model/app_database.dart';
import 'package:chief/model/chief_detail_model.dart';
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
import '../../global_custom_widgets/custom_title_text.dart';

class SignupChef extends StatefulWidget {
  const SignupChef({super.key});
  static const tag = 'SignupChef';

  @override
  State<SignupChef> createState() => _SignupChefState();
}

class _SignupChefState extends State<SignupChef>
    with SingleTickerProviderStateMixin {
  bool userSelectedImage = false;
  bool userSelectCertificate = false;
  String _image = "";
  String certificateImage = "";
  String? imagePath;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController gmailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController specialityController = TextEditingController();
  final TextEditingController certificateController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AppDatabase database = AppDatabase();
  final _auth = FirebaseAuth.instance;
  final List<String> _uploadedImages = [];
  final bool _isUploading = false; // To track uploading status

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    nameController.dispose();
    numberController.dispose();
    addressController.dispose();
    gmailController.dispose();
    passwordController.dispose();
    experienceController.dispose();
    specialityController.dispose();
    certificateController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double textFieldWidth = MediaQuery.of(context).size.width * 0.8;
    double textFieldHeight = MediaQuery.of(context).size.height * 0.056;
    double paddingHeight = MediaQuery.of(context).size.height * 0.02;
    return Scaffold(
      appBar: const CustomAppBarWidget(
        showBackButton: true,
      ),
      // bottomNavigationBar: CustomLargeButton(
      //     title: 'Signup',
      //     ontap: () {
      //       // if (!userSelectedImage) {
      //       //   Fluttertoast.showToast(msg: 'Please upload an image to proceed');
      //       //   return;
      //       // }
      //       if (nameController.text.isEmpty ||
      //           numberController.text.isEmpty ||
      //           addressController.text.isEmpty ||
      //           gmailController.text.isEmpty ||
      //           passwordController.text.isEmpty ||
      //           experienceController.text.isEmpty ||
      //           specialityController.text.isEmpty) {
      //         Fluttertoast.showToast(msg: 'Please fill the above fields');
      //       } else {
      //         if (confirmPasswordController.text == passwordController.text) {
      //           onTapSignupUser(
      //             context,
      //             nameController.text,
      //             numberController.text,
      //             addressController.text,
      //             gmailController.text,
      //             passwordController.text,
      //             experienceController.text,
      //             specialityController.text,
      //             certificateController.text,
      //             certificateImage,
      //           );
      //         } else {
      //           Fluttertoast.showToast(msg: "password didn't match");
      //         }
      //       }
      //     }),
      //
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    // Header
                    Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange.shade700,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Sign up as a Chef',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.deepOrange.shade900.withOpacity(0.7),
                      ),
                    ),
                    SizedBox(height: 30.h),

                    // Profile Image Picker
                    Center(
                      child: GestureDetector(
                        onTap: () => CustomBottomSheet(context, ''),
                        child: Container(
                          width: 120.w,
                          height: 120.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    Colors.deepOrange.shade200.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: userSelectedImage
                              ? ClipOval(
                                  child: Image.network(
                                    _image,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Icon(
                                  Icons.camera_alt_outlined,
                                  size: 40.sp,
                                  color: Colors.deepOrange.shade300,
                                ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30.h),

                    // Form Fields
                    _buildTextField(
                      controller: nameController,
                      label: 'Full Name',
                      hint: 'Enter your full name',
                      icon: Icons.person_outline,
                    ),
                    SizedBox(height: 20.h),

                    _buildTextField(
                      controller: numberController,
                      label: 'Phone Number',
                      hint: 'Enter your phone number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      maxLength: 11,
                    ),
                    SizedBox(height: 20.h),

                    _buildTextField(
                      controller: addressController,
                      label: 'Address',
                      hint: 'Enter your address',
                      icon: Icons.location_on_outlined,
                    ),
                    SizedBox(height: 20.h),

                    _buildTextField(
                      controller: gmailController,
                      label: 'Email',
                      hint: 'Enter your email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 20.h),

                    _buildTextField(
                      controller: passwordController,
                      label: 'Password',
                      hint: 'Enter your password',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      isPasswordVisible: _isPasswordVisible,
                      onTogglePassword: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    SizedBox(height: 20.h),

                    _buildTextField(
                      controller: confirmPasswordController,
                      label: 'Confirm Password',
                      hint: 'Confirm your password',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      isPasswordVisible: _isConfirmPasswordVisible,
                      onTogglePassword: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                    SizedBox(height: 20.h),

                    _buildTextField(
                      controller: experienceController,
                      label: 'Work Experience (Years)',
                      hint: 'Enter your work experience',
                      icon: Icons.work_outline,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 20.h),

                    _buildTextField(
                      controller: specialityController,
                      label: 'Specialities',
                      hint: 'Enter your specialities',
                      icon: Icons.restaurant_menu,
                    ),
                    SizedBox(height: 20.h),

                    // Certificate Upload
                    Text(
                      'Certifications',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.deepOrange.shade900,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    GestureDetector(
                      onTap: () => CustomBottomSheet(context, 'certificate'),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 15.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.upload_file,
                              color: Colors.deepOrange.shade300,
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              userSelectCertificate
                                  ? 'Certificate Uploaded'
                                  : 'Upload Certificate',
                              style: TextStyle(
                                color: Colors.deepOrange.shade300,
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 40.h),

                    // Signup Button
                    _buildButton(
                      'Sign Up',
                      () {
                        if (_validateAndSubmit()) {
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
                        }
                      },
                    ),
                    SizedBox(height: 30.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _validateAndSubmit() {
    if (!_formKey.currentState!.validate()) return false;

    if (nameController.text.isEmpty ||
        numberController.text.isEmpty ||
        addressController.text.isEmpty ||
        gmailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        experienceController.text.isEmpty ||
        specialityController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Please fill all fields');
      return false;
    }

    if (confirmPasswordController.text != passwordController.text) {
      Fluttertoast.showToast(msg: "Passwords don't match");
      return false;
    }

    return true;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool? isPasswordVisible,
    VoidCallback? onTogglePassword,
    TextInputType? keyboardType,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.deepOrange.shade900,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword && !(isPasswordVisible ?? false),
            keyboardType: keyboardType,
            maxLength: maxLength,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: hint,
              counterText: "",
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 16.sp,
              ),
              prefixIcon: Icon(
                icon,
                color: Colors.deepOrange.shade300,
              ),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        isPasswordVisible ?? false
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.deepOrange.shade300,
                      ),
                      onPressed: onTogglePassword,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: Colors.deepOrange.shade200,
                  width: 1.5,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 16.h,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(String text, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      height: 55.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepOrange.shade400,
            Colors.deepOrange.shade700,
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.deepOrange.shade200.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<dynamic> CustomBottomSheet(BuildContext context, String txt) {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          height: 150.h,
          child: Column(
            children: [
              SizedBox(height: 10.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildBottomSheetOption(
                    'Camera',
                    Icons.camera_alt,
                    () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera, txt);
                    },
                  ),
                  _buildBottomSheetOption(
                    'Gallery',
                    Icons.photo_library,
                    () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery, txt);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetOption(
      String text, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 120.w,
        padding: EdgeInsets.symmetric(vertical: 15.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 30.sp,
              color: Colors.deepOrange.shade300,
            ),
            SizedBox(height: 8.h),
            Text(
              text,
              style: TextStyle(
                color: Colors.deepOrange.shade700,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source, String txt) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: source);
    if (pickedImage != null) {
      try {
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
      } catch (e) {
        Fluttertoast.showToast(msg: '$e');
        debugPrint('error in uploading image in storage $e');
      }
    }
  }

  void onTapSignupUser(
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
                database.chefDetailToFireStore(
                  context: context,
                  chiefDetail: ChiefDetailModel(
                    address: address,
                    certificateImage: certificateImage,
                    certifications: certificate,
                    email: email,
                    name: name,
                    number: number,
                    password: pass,
                    rating: '0',
                    workExperience: experience,
                    userId: _auth.currentUser!.uid,
                    image: _image,
                    role: 'chief',
                    timestamp: Timestamp.now(),
                    specialties: speciality,
                  ),
                  allUserDetail: AllUserDetailModel(
                    id: _auth.currentUser!.uid,
                    name: name,
                    email: email,
                    role: 'chief',
                    timestamp: Timestamp.now(),
                  ),
                )
              });
    } catch (e) {
      Fluttertoast.showToast(msg: '$e');
      Navigator.of(context).pop(); // Dismiss the loading dialog
    }
  }
}
