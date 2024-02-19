import 'package:chief/global_custom_widgets/custom_drawer.dart';
import 'package:chief/global_custom_widgets/custom_small_buttons.dart';
import 'package:chief/model/app_database.dart';
import 'package:chief/view/user_dashboard.dart';
import 'package:flutter/material.dart';

class ChiefDashboardScreen extends StatelessWidget {
  ChiefDashboardScreen({super.key});
  static const String tag = "dashboardRequestScreen";

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
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
        drawer: const CustomDrawer(),
        appBar: AppBar(
            title: const Text('Request',
                style: TextStyle(fontWeight: FontWeight.bold)),
            centerTitle: true,
            backgroundColor: Colors.pink.shade200),
        body: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: RequestCard(),
        ),
      ),
    );
  }
}

class RequestCard extends StatefulWidget {
  const RequestCard({super.key});

  @override
  State<RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<RequestCard> {
  List requests = [];
  AppDatabase database = AppDatabase();

  initialise() {
    database.readChiefrequest().then((value) => {
          setState(() {
            requests = value;
          })
        });
  }

  @override
  void initState() {
    super.initState();
    initialise();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: requests.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          UserInfoSection(image: requests[index]['image']),
                        ],
                      ),
                      Column(
                        children: [
                          CustomProductDetailSmallContainer(
                            title: requests[index]['Item_Name'],
                          ),
                          CustomProductDetailSmallContainer(
                            title: requests[index]['No_of_People'],
                          ),
                          CustomProductDetailSmallContainer(
                            title: requests[index]['Arrivel_Time'],
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          CustomProductDetailSmallContainer(
                            title: requests[index]['Fare'],
                          ),
                          CustomProductDetailSmallContainer(
                            title: requests[index]['Date'],
                          ),
                          CustomProductDetailSmallContainer(
                            title: requests[index]['Event_Time'],
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
                        width: MediaQuery.of(context).size.width * 0.8,
                        decoration:
                            const BoxDecoration(color: Colors.pinkAccent),
                        child: Center(
                            child:
                                Text(requests[index]['Availabe_Ingredients']))),
                  ),
                  RequestActionsSection(name: requests[index]['Name']),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ignore: must_be_immutable
class RequestActionsSection extends StatelessWidget {
  RequestActionsSection({super.key, required this.name});
  String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Container(
          color: Colors.pinkAccent,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () {},
          ),
        ),
        CustomProductDetailSmallContainer(
          title: name,
        ),
        Container(
          color: Colors.pinkAccent,
          child: IconButton(
            icon: const Icon(Icons.check, color: Colors.black),
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}
