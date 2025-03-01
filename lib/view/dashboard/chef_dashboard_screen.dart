import 'package:chief/global_custom_widgets/custom_small_buttons.dart';
import 'package:chief/global_custom_widgets/custom_text_form_field.dart';
import 'package:chief/model/app_database.dart';
import 'package:chief/model/request_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../global_custom_widgets/custom_product_small_container.dart';
import '../../global_custom_widgets/custom_userinfo_section.dart';
import '../drawer/chef_drawer.dart';

class ChefDashboardScreen extends StatefulWidget {
  const ChefDashboardScreen({super.key});
  static const String tag = "ChefDashboardScreen";

  @override
  State<ChefDashboardScreen> createState() => _ChefDashboardScreenState();
}

class _ChefDashboardScreenState extends State<ChefDashboardScreen> {
  AppDatabase database = AppDatabase();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController fareController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;
  int fare = 0;

  void _submitNewFare(String chefId, String newFare) async {
    Fluttertoast.showToast(
        msg: "Fare $newFare updated. Please approve the request!");
  }

  void _showFareUpdateDialog(String documentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Submit New Fare"),
          content: CustomTextField(
            controller: fareController,
            hintText: "Enter new fare",
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          actions: <Widget>[
            CustomSmallButton(
              title: "Cancel",
              ontap: () => Navigator.of(context).pop(),
            ),
            CustomSmallButton(
              title: "Submit",
              ontap: () {
                String newFare = fareController.text.trim();
                if (newFare.isNotEmpty) {
                  fare = int.parse(newFare);
                  _submitNewFare(documentId, newFare);
                  Navigator.of(context).pop();
                } else {
                  Fluttertoast.showToast(msg: "Please enter a fare");
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
          Navigator.of(context).pop();
          return false;
        } else {
          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Colors.deepOrange.shade200,
              title: const Text(
                'Exit App',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontSize: 20),
              ),
              content: const Text(
                'Do you really want to exit the app?',
                style: TextStyle(color: Colors.white, fontSize: 14),
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
                          SystemNavigator.pop();
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
        backgroundColor: Colors.deepOrange.shade200,
        drawer: const ChefDrawer(),
        appBar: AppBar(
          title: const Text('Requests',
              style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.deepOrange.shade200,
        ),
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('food_orders')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  // Filter documents on the client side
                  final filteredDocs = snapshot.data!.docs.where((doc) {
                    final chefResponses =
                        (doc['chefResponses'] as List<dynamic>?) ?? [];
                    return !chefResponses
                        .any((response) => response['userId'] == user!.uid);
                  }).toList();

                  return ListView.builder(
                    itemCount: filteredDocs.length,
                    itemBuilder: (BuildContext context, int index) {
                      final request = RequestModel.fromJson(
                        filteredDocs[index].data() as Map<String, dynamic>,
                      );
                      return _buildRequestCard(
                          context, request, filteredDocs[index].id);
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Colors.pink.shade200,
                    ),
                  );
                }
              },
            )),
      ),
    );
  }

  Widget _buildRequestCard(
      BuildContext context, RequestModel request, String documentId) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          UserInfoSection(image: ''),
                          CustomProductDetailSmallContainer(
                            label: "Food Name",
                            title: request.itemName,
                          ),
                          CustomProductDetailSmallContainer(
                            label: "Arrival",
                            title: request.arrivalTime,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomProductDetailSmallContainer(
                              label: "Name", title: 'get by client id'),
                          CustomProductDetailSmallContainer(
                              label: "Number", title: 'get by client id'),
                          CustomProductDetailSmallContainer(
                              label: "Event Time", title: request.eventTime),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomProductDetailSmallContainer(
                            label: "People",
                            title: request.totalPerson,
                          ),
                          CustomProductDetailSmallContainer(
                            label: "Date",
                            title: request.date,
                          ),
                          GestureDetector(
                            onTap: () {
                              _showFareUpdateDialog(documentId);
                            },
                            child: CustomProductDetailSmallContainer(
                              label: "Fare",
                              title: request.fare,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.height * 0.006),
                    child: Container(
                        height: MediaQuery.of(context).size.height * 0.1,
                        width: MediaQuery.of(context).size.width * 0.9,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.deepOrange.shade200,
                        ),
                        child: Center(
                            child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Available Ingredients ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(request.ingredients),
                            ],
                          ),
                        ))),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange.shade200,
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          database.rejectByChief(
                              docId: documentId, userId: user!.uid);
                        },
                        child: const Icon(
                          Icons.close,
                          color: Colors.black,
                          applyTextScaling: true,
                        ),
                      ),
                      CustomProductDetailSmallContainer(title: request.fare),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange.shade200,
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          AppDatabase().acceptByChief(
                              docId: documentId, userId: user!.uid);
                        },
                        child: const Icon(
                          Icons.check,
                          color: Colors.black,
                          applyTextScaling: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
