import 'dart:async';

import 'package:car_parking_application/Logics/user_model.dart';
import 'package:car_parking_application/Screens/admin_screen.dart';
import 'package:car_parking_application/Screens/availability_screen.dart';
import 'package:car_parking_application/Screens/history_screen.dart';
import 'package:car_parking_application/Screens/profile_screen.dart';
import 'package:car_parking_application/Screens/qr_screen.dart';
import 'package:car_parking_application/Screens/topup_screen.dart';
import 'package:car_parking_application/Screens/total_revenue_screen.dart';
import 'package:car_parking_application/custom_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'login_screen.dart';

final dbRef = FirebaseFirestore.instance.collection("customers");

class HomeScreen extends StatefulWidget {
  final UserModel user;
  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    // final Stream<DocumentSnapshot<Map<String, dynamic>>> userStream = FirebaseFirestore.instance.collection("customers").doc(widget.user.userId).snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Parking Application"),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ProfileScreen()));
              },
              child: const ListTile(
                iconColor: Colors.black,
                leading: Icon(Icons.person),
                title: Text(
                  "Profile",
                  style: TextStyle(
                    fontSize: 15.0,
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => HistoryScreen(user: widget.user)));
              },
              child: const ListTile(
                leading: Icon(Icons.history),
                title: Text(
                  "History",
                  style: TextStyle(
                    fontSize: 15.0,
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: logout,
              child: const ListTile(
                iconColor: Colors.redAccent,
                leading: Icon(Icons.logout),
                title: Text(
                  "Logout",
                  style: TextStyle(
                    fontSize: 15.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>> (
        stream: FirebaseFirestore.instance.collection("customers").doc(FirebaseAuth.instance.currentUser!.uid).snapshots(),
        builder: (context, snapshot) {
          if(snapshot.hasError) {
            return Text("Something went wrong! ${snapshot.error.toString()}");
          } else if(snapshot.hasData) {
            final user = UserModel.fromJson(snapshot.data!.data()!);
            user.userId = FirebaseAuth.instance.currentUser!.uid;

            final List menuList = ["Parking\navailability", "Scan\nQR"];
            final List navigation = [
              (context) => const AvailabilityScreen(),
              (context) => QRScreen(user: user),
            ];
            final List icons = [const Icon(Icons.local_parking, size: 40, color: Colors.blueAccent,), const Icon(Icons.qr_code, size: 40, color: Colors.black54,)];

            if (user.isAdmin) {
              // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const AdminScreen()));
              return const AdminScreen();
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.025,),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      homeScreenText("Balance"),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.2,
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: const LinearGradient(
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                                colors: [
                                  Colors.blue,
                                  Colors.red
                                ]
                              )
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Positioned(
                                  left: 30,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      const Text(
                                        "Your balance:",
                                        style: TextStyle(
                                            color: Colors.white
                                        ),
                                      ),
                                      const SizedBox(height: 10,),
                                      Text(
                                        user.balance.toStringAsFixed(2),
                                        style: const TextStyle(
                                            fontSize: 40,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: -3,
                                            color: Colors.white70
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  right: 30,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const TopUpScreen()));
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                      backgroundColor: Colors.grey.shade400,
                                    ),
                                    child: const Text(
                                      "+ Reload",
                                      style: TextStyle(
                                          color: Colors.black87
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.025,),
                      homeScreenText("Parking Status"),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.2,
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: user.inside ? FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                            future: FirebaseFirestore.instance.collection("parkingEntry").doc(user.parkingRef.last).get(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return const Text("Error");
                              }
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              Timestamp entryTime = snapshot.data!.data()!['entryTime'];
                              DateTime entryDateTime = entryTime.toDate();

                              String convertedEntryTime = "${entryDateTime.hour.toString()}:${entryDateTime.minute.toString().padLeft(2, '0')}  ${entryDateTime.day.toString()}/${entryDateTime.month.toString()}/${entryDateTime.year.toString()}";
                              // String convertedEntryTime = "${entryDateTime.hour.toString()}:${entryDateTime.minute.toString().padLeft(2, '0')}  23/${entryDateTime.month.toString()}/${entryDateTime.year.toString()}";
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.lightGreen,
                                      Colors.white70
                                    ]
                                  )
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Positioned(
                                      // left: 20,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.check_circle_outline, color: Colors.lightGreen, size: 60),
                                          const SizedBox(width: 10,),
                                          Text(
                                            "Entry time: $convertedEntryTime",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ) :
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.redAccent.shade100,
                                  Colors.white24
                                ]
                              )
                            ),
                            child: const Stack(
                              alignment: Alignment.center,
                              children: [
                                Positioned(
                                  // left: 20,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.close, color: Colors.redAccent, size: 60),
                                      SizedBox(width: 10,),
                                      Text(
                                        "You are currently not parked",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.025,),
                      homeScreenText("Menu"),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
                      // SizedBox(height: MediaQuery.of(context).size.height * 0.025,),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.175,
                        width: MediaQuery.of(context).size.width,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          scrollDirection: Axis.horizontal,
                          itemCount: menuList.length,
                          itemBuilder: (_, int index) {
                            return MenuButton(icon: icons[index], text: menuList[index], route: navigation[index]);
                          }
                        )
                      ),
                    ]
                  ),
                ],
              ),
            );

          } else {
            return const Center(child: CircularProgressIndicator(),);
          }
        },
      ),
    );
  }

  Future logout() async {
    await FirebaseAuth.instance.signOut()
    .then((value) => {
      Fluttertoast.showToast(
          msg: "You have signed out",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          fontSize: 16.0
      ),
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginPage()))
    });
  }

  Future<UserModel?> getUserData() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    final docUser = FirebaseFirestore.instance.collection("customers").doc(userId);
    final snapshot = await docUser.get();

    if(snapshot.exists) {
      UserModel user = UserModel.fromJson(snapshot.data()!);
      user.userId = userId;

      return user;
    }

    return null;
  }

  Future testFunc() async {
    var entryList = await FirebaseFirestore.instance.collection("parkingEntry").get();

    final entryStream = FirebaseFirestore.instance.collection("parkingEntry").snapshots();
    entryStream.listen((event) {
      entryList = event;
    });

    for(var doc in entryList.docs) {
      if(doc.data()["userIdRef"] == null) {
        debugPrint(doc.id);
      }
    }

    debugPrint("List contains ${entryList.docs.length} docs");
  }
}