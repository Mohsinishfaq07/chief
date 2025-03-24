import 'package:chief/global_custom_widgets/custom_small_buttons.dart';
import 'package:chief/model/app_database.dart';
import 'package:chief/model/client_detail_model.dart';
import 'package:chief/model/request_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../global_custom_widgets/custom_horizontal_line.dart';
import '../../global_custom_widgets/custom_large_button.dart';
import '../../global_custom_widgets/custom_size.dart';
import '../../global_custom_widgets/custom_text_form_field.dart';
import '../../global_custom_widgets/custom_title_text.dart';
import '../drawer/user_drawer.dart';

class UserDashboardRequestForm extends StatefulWidget {
  const UserDashboardRequestForm({super.key});
  static const tag = 'UserDashboardRequestForm';

  @override
  State<UserDashboardRequestForm> createState() =>
      _UserDashboardRequestFormState();
}

class _UserDashboardRequestFormState extends State<UserDashboardRequestForm>
    with SingleTickerProviderStateMixin {
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController arrivalTimeController = TextEditingController();
  final TextEditingController eventTimeController = TextEditingController();
  final TextEditingController noOfPeopleController = TextEditingController();
  final TextEditingController fareController = TextEditingController();
  final TextEditingController availableIngController = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  TimeOfDay? selectedArrivalTime;
  TimeOfDay? selectedEventTime;
  final AppDatabase database = AppDatabase();
  final User? user = FirebaseAuth.instance.currentUser;
  String image = '';
  String name = '';
  ClientDetailModel? clientDetailModel;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    getClientDetails();
  }

  void _setupAnimations() {
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
    itemNameController.dispose();
    dateController.dispose();
    arrivalTimeController.dispose();
    eventTimeController.dispose();
    noOfPeopleController.dispose();
    fareController.dispose();
    availableIngController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => await _showExitDialog(),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: _buildAppBar(),
        drawer: const UserDrawer(),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: _buildBody(),
          ),
        ),
        bottomNavigationBar: _buildSubmitButton(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(
          Icons.menu,
          color: Colors.deepOrange.shade700,
          size: 24.sp,
        ),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      title: Text(
        'Create Request',
        style: TextStyle(
          color: Colors.deepOrange.shade700,
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: itemNameController,
                label: 'Food Item Name',
                hint: 'Enter food item name',
                maxLength: 10,
              ),
              _buildDatePicker(),
              _buildTimePicker(
                controller: arrivalTimeController,
                label: 'Arrival Time',
                onTap: _selectTime,
              ),
              _buildTimePicker(
                controller: eventTimeController,
                label: 'Event Time',
                onTap: () => _selectEventTime(context),
              ),
              _buildTextField(
                controller: noOfPeopleController,
                label: 'Number of People',
                hint: 'Enter number of people',
                keyboardType: TextInputType.number,
                maxLength: 4,
              ),
              _buildTextField(
                controller: fareController,
                label: 'Fare',
                hint: 'Enter fare amount',
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
              _buildTextField(
                controller: availableIngController,
                label: 'Available Ingredients',
                hint: 'List available ingredients',
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int? maxLength,
    int maxLines = 1,
    Widget? suffixIcon,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.deepOrange.shade700,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              maxLength: maxLength,
              maxLines: maxLines,
              readOnly: keyboardType == TextInputType.none,
              onTap: onTap,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14.sp,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 16.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.r),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: suffixIcon,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter $label';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return _buildTextField(
      controller: dateController,
      label: 'Date',
      hint: 'Select date',
      keyboardType: TextInputType.none,
      onTap: () => _selectDate(context),
      suffixIcon: IconButton(
        icon: Icon(
          Icons.calendar_today,
          color: Colors.deepOrange.shade400,
        ),
        onPressed: () => _selectDate(context),
      ),
    );
  }

  Widget _buildTimePicker({
    required TextEditingController controller,
    required String label,
    required VoidCallback onTap,
  }) {
    return _buildTextField(
      controller: controller,
      label: label,
      hint: 'Select time',
      keyboardType: TextInputType.none,
      onTap: onTap,
      suffixIcon: IconButton(
        icon: Icon(
          Icons.access_time,
          color: Colors.deepOrange.shade400,
        ),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: ElevatedButton(
        onPressed: _submitRequest,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 16.h),
          elevation: 5,
        ),
        child: Text(
          'Submit Request',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent dismissing by tapping outside
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Loading indicator
                  CircularProgressIndicator(
                    color: Colors.deepOrange.shade400,
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Processing Request...',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.deepOrange.shade700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      try {
        await database.requestToFireStore(
          context: context,
          requestModel: RequestModel(
            itemName: itemNameController.text,
            date: dateController.text,
            arrivalTime: arrivalTimeController.text,
            eventTime: eventTimeController.text,
            totalPerson: noOfPeopleController.text,
            fare: fareController.text,
            ingredients: availableIngController.text,
            clientId: user!.uid,
            acceptedChiefId: 'noChiefSelected',
            chefResponses: [],
            timestamp: Timestamp.now(),
            orderStatus: 'notAssigned',
          ),
        );

        // Show success dialog
        Navigator.pop(context); // Dismiss loading dialog
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 50.sp,
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'Request Submitted Successfully!',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Your request has been sent to available chefs.',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20.h),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Dismiss success dialog
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const UserDashboardRequestForm(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 30.w,
                          vertical: 12.h,
                        ),
                      ),
                      child: Text(
                        'OK',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      } catch (e) {
        // Show error dialog
        Navigator.pop(context); // Dismiss loading dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 50.sp,
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'Error',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Failed to submit request. Please try again.',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20.h),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 30.w,
                          vertical: 12.h,
                        ),
                      ),
                      child: Text(
                        'OK',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
    }
  }

  Future<bool> _showExitDialog() async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Exit Form',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange.shade700,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Are you sure you want to exit? Your changes will be lost.',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDialogButton(
                    'Cancel',
                    () => Navigator.of(context).pop(false),
                    isCancel: true,
                  ),
                  _buildDialogButton(
                    'Exit',
                    () => Navigator.of(context).pop(true),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return shouldPop ?? false;
  }

  Widget _buildDialogButton(String text, VoidCallback onTap,
      {bool isCancel = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: isCancel ? Colors.grey.shade200 : Colors.deepOrange.shade400,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isCancel ? Colors.black87 : Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  getClientDetails() async {
    clientDetailModel = await database.getUserById(docId: user!.uid);
  }

  String formatTimeOfDay(TimeOfDay tod) {
    final hour = tod.hour % 12 == 0
        ? 12
        : tod.hour % 12; // Convert 24-hour time to 12-hour
    final minute = tod.minute.toString().padLeft(2, '0');
    final period = tod.hour >= 12 ? 'PM' : 'AM';
    return "$hour:$minute $period";
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.deepOrange.shade400,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        dateController.text =
            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
    }
  }

  void _selectTime() async {
    if (selectedEventTime == null) {
      Fluttertoast.showToast(msg: 'Please select the event time first');
      return;
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.deepOrange.shade400,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Check if arrival time is at least 1 hour before event time
      final now = DateTime.now();
      final eventTime = DateTime(
        now.year,
        now.month,
        now.day,
        selectedEventTime!.hour,
        selectedEventTime!.minute,
      );
      final arrivalTime = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );

      if (arrivalTime.isBefore(eventTime.subtract(const Duration(hours: 1)))) {
        setState(() {
          selectedArrivalTime = picked;
          arrivalTimeController.text = formatTimeOfDay(picked);
        });
      } else {
        Fluttertoast.showToast(
          msg: 'Arrival time must be at least 1 hour before event time',
        );
      }
    }
  }

  Future<void> _selectEventTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.deepOrange.shade400,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedEventTime = picked;
        eventTimeController.text = formatTimeOfDay(picked);
      });
    }
  }
}
