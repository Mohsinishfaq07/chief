// ignore_for_file: must_be_immutable, deprecated_member_use, file_names

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

class _UserDashboardRequestFormState extends State<UserDashboardRequestForm> {
  TextEditingController itemNameController = TextEditingController();

  TextEditingController dateController = TextEditingController();

  TextEditingController arrivalTimeController = TextEditingController();

  TextEditingController eventTimeController = TextEditingController();

  TextEditingController noOfPeopleController = TextEditingController();

  TextEditingController fareController = TextEditingController();

  TextEditingController availableIngController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  AppDatabase database = AppDatabase();
  User? user = FirebaseAuth.instance.currentUser;
  String image = '';
  String name = '';
  ClientDetailModel? clientDetailModel;
  getClientDetails() async {
    clientDetailModel = await database.getUserById(docId: user!.uid);
  }

  @override
  void initState() {
    getClientDetails();
    super.initState();
  }

  @override
  void dispose() {
    // Dispose controllers when the widget is disposed
    super.dispose();
    itemNameController.dispose();
    dateController.dispose();
    arrivalTimeController.dispose();
    eventTimeController.dispose();
    noOfPeopleController.dispose();
    fareController.dispose();
    availableIngController.dispose();
  }

  TimeOfDay? selectedArrivalTime;
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
      initialDate: DateTime.now(), // Current date
      firstDate: DateTime.now(), // No past dates
      lastDate: DateTime(2101), // Optional: Future limit
    );
    if (pickedDate != null && pickedDate != DateTime.now()) {
      setState(() {
        dateController.text =
            pickedDate.toString().split(' ')[0]; // Formatting the date
      });
    }
  }

  void _selectTime() async {
    if (selectedEventTime == null) {
      Fluttertoast.showToast(msg: 'Please select the event time first.');
      return;
    }

    final DateTime currentDate = DateTime.now();
    final DateTime? selectedDate = DateTime.tryParse(dateController.text);

    final TimeOfDay currentTime = TimeOfDay.now();
    final DateTime eventDateTime = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
      selectedEventTime!.hour,
      selectedEventTime!.minute,
    );

    final DateTime fourHoursBeforeEvent =
        eventDateTime.subtract(const Duration(hours: 1));
    TimeOfDay initialTime = TimeOfDay(
      hour: fourHoursBeforeEvent.hour,
      minute: fourHoursBeforeEvent.minute,
    );

    if (selectedDate != null && selectedDate.isAtSameMomentAs(currentDate)) {
      final TimeOfDay oneHourFromNow = TimeOfDay(
        hour: (currentTime.hour + 1) % 24,
        minute: currentTime.minute,
      );
      initialTime = oneHourFromNow;
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      final DateTime pickedDateTime = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
        picked.hour,
        picked.minute,
      );

      if (pickedDateTime.isAfter(fourHoursBeforeEvent)) {
        Fluttertoast.showToast(
            msg:
                'Arrival time must be at least 4 hours before the event time.');
      } else {
        setState(() {
          selectedArrivalTime = picked;
          arrivalTimeController.text = formatTimeOfDay(picked);
        });
      }
    }
  }

  TimeOfDay? selectedEventTime;

// Function to show time picker for event time
  Future<void> _selectEventTime(BuildContext context) async {
    final DateTime currentDate = DateTime.now();
    final DateTime? selectedDate = DateTime.tryParse(dateController.text);

    TimeOfDay initialTime = TimeOfDay.now();
    if (selectedDate != null && selectedDate.isAtSameMomentAs(currentDate)) {
      initialTime = TimeOfDay(
        hour: (initialTime.hour + 4) % 24,
        minute: initialTime.minute,
      );
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      setState(() {
        selectedEventTime = picked;
        eventTimeController.text = formatTimeOfDay(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          // Check if the drawer is open
          if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
            // Close the drawer
            Navigator.of(context).pop();
            return false;
          } else {
            // Show the exit confirmation dialog
            final shouldPop = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: Colors.pinkAccent,
                title: Text(
                  'Exit App',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontSize: 20.sp),
                ),
                content: Text(
                  'Do you really want to exit the app?',
                  style: TextStyle(color: Colors.white, fontSize: 14.sp),
                ),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CustomSmallButton(
                          title: "No",
                          ontap: () {
                            Navigator.of(context).pop(false);
                          }),
                      CustomSmallButton(
                          title: "Yes",
                          ontap: () {
                            Navigator.of(context).pop(true);
                          }),
                    ],
                  ),
                ],
              ),
            );
            return shouldPop ?? false;
          }
        },
        child: Scaffold(
          key: _scaffoldKey,
          drawer: const UserDrawer(),
          appBar: AppBar(
            backgroundColor: Colors.deepOrange.shade200,
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomLargeButton(
              title: 'Add',
              ontap: () {
                if (itemNameController.text.isEmpty ||
                    dateController.text.isEmpty ||
                    arrivalTimeController.text.isEmpty ||
                    eventTimeController.text.isEmpty ||
                    noOfPeopleController.text.isEmpty ||
                    fareController.text.isEmpty ||
                    availableIngController.text.isEmpty) {
                  Fluttertoast.showToast(msg: 'Fill the above field');
                } else {
                  database.addRequest(
                    context: context,
                    requestModel: RequestModel(
                      itemName: itemNameController.text,
                      date: dateController.text,
                      arrivalTime: arrivalTimeController.text,
                      eventTime: eventTimeController.text,
                      totalPerson: noOfPeopleController.text,
                      fare: fareController.text,
                      ingredients: availableIngController.text,
                      clientId: FirebaseAuth.instance.currentUser!.uid,
                      acceptedChiefId: 'noChiefSelected',
                      chefResponses: [],
                      timestamp: Timestamp.now(),
                      orderStatus: 'notAssigned',
                    ),
                  );
                }
              },
            ),
          ),
          body: SingleChildScrollView(
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
                                'Request', // Only the text parameter is required
                          ),
                          const Spacer(),
                          // FutureBuilder<DocumentSnapshot>(
                          //   future: FirebaseFirestore.instance
                          //       .collection('users')
                          //       .doc(user!.uid)
                          //       .get(),
                          //   builder: (context, userSnapshot) {
                          //     if (userSnapshot.connectionState ==
                          //         ConnectionState.waiting) {
                          //       return const Center(
                          //           child: CircularProgressIndicator(
                          //         color: Colors.pink,
                          //       )); // Show loading indicator while waiting for user data
                          //     }
                          //     if (userSnapshot.hasError) {
                          //       return Center(
                          //           child: Text(
                          //               'Error: ${userSnapshot.error}')); // Show error message if user data retrieval failed
                          //     }
                          //     // User data is available, display it
                          //     if (userSnapshot.hasData &&
                          //         userSnapshot.data!.exists) {
                          //       final userData = userSnapshot.data!.data()
                          //           as Map<String, dynamic>;
                          //       image = userData['image'] ?? "";
                          //       name = userData['Name'] ?? "No Name";
                          //       return CircleAvatar(
                          //           radius: 40,
                          //           child: ClipOval(
                          //             child: image.isEmpty
                          //                 ? const Icon(
                          //                     Icons.person,
                          //                     size: 30,
                          //                   )
                          //                 : Image.network(
                          //                     image,
                          //                     fit: BoxFit.cover,
                          //                     width: 80,
                          //                     height: 80,
                          //                   ),
                          //           ));
                          //     }
                          //     return _userImageIcon();
                          //   },
                          // ),
                          CustomSize(
                            width: 4.w,
                          ),
                        ],
                      ),
                      CustomTextField(
                        label: "Food Item Name",
                        controller: itemNameController,
                        hintText: "Food Item Name",
                        maxLength: 10,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical:
                                MediaQuery.of(context).size.height * 0.01.h),
                        child: CustomTextField(
                          onPressedSuffix: () => _selectDate(context),
                          readOnly: true,
                          label: "Date",
                          controller: dateController,
                          hintText: "Date",
                          formatTime: true,
                          suffix: Icons.calendar_month,
                        ),
                      ),
                      CustomTextField(
                        onPressedSuffix:
                            selectedEventTime == null ? null : _selectTime,
                        readOnly: true,
                        formatTime: true,
                        label: "Arrival Time ",
                        controller: arrivalTimeController,
                        hintText: "Arrival Time ",
                        suffix: Icons.lock_clock,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical:
                                MediaQuery.of(context).size.height * 0.01.h),
                        child: CustomTextField(
                          label: "Event Time",
                          controller: eventTimeController,
                          hintText: "Select Event Time",
                          readOnly: true, // to prevent manual editing
                          onPressedSuffix: () => _selectEventTime(context),
                          suffix: Icons.lock_clock,
                        ),
                      ),
                      CustomTextField(
                        maxLength: 4,
                        label: "No of People",
                        keyboardType: TextInputType.number,
                        controller: noOfPeopleController,
                        hintText: "No of People",
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical:
                                MediaQuery.of(context).size.height * 0.01.h),
                        child: CustomTextField(
                          maxLength: 6,
                          label: 'Fare',
                          keyboardType: TextInputType.number,
                          controller: fareController,
                          hintText: 'Fare',
                        ),
                      ),
                      CustomTextField(
                        label: "Available Ingredients",
                        controller: availableIngController,
                        hintText: "Available Ingredients",
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.01.h,
                      bottom: MediaQuery.of(context).size.height * 0.01.h),
                  child: const CustomHorizontalDivider(),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _userImageIcon() {
    return Container(
      height: 80,
      width: 80,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(69.r), color: Colors.white),
      child: Padding(
        padding: const EdgeInsets.all(17.0),
        child: Column(
          children: [
            Container(
              height: 12,
              width: 12,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(69.r),
                  color: Colors.grey),
            ),
            Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(69.r),
                  color: Colors.grey),
            )
          ],
        ),
      ),
    );
  }
}
