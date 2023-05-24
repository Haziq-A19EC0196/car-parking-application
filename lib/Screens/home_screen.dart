import 'package:car_parking_application/Logics/user_model.dart';
import 'package:car_parking_application/Screens/availability_screen.dart';
import 'package:car_parking_application/Screens/qr_screen.dart';
import 'package:car_parking_application/Screens/topup_screen.dart';
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
    final Stream<DocumentSnapshot<Map<String, dynamic>>> userStream = FirebaseFirestore.instance.collection("customers").doc(widget.user.userId).snapshots();

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
                // Navigate to profile page
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
              onTap: () {
                // Navigate to History screen
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
        stream: userStream,
        builder: (context, snapshot) {
          if(snapshot.hasError) {
            return Text("Something went wrong! ${snapshot.error.toString()}");
          } else if(snapshot.hasData) {
            final user = UserModel.fromJson(snapshot.data!.data()!);
            // debugPrint("from snapshot: ${snapshot.data!.data().toString()}");
            // debugPrint("from UserModel: ${user.toJson()}");

            final List menuList = ["Check parking availability", "Scan QR Code", "Top up Credit"];
            final List navigation = [
              (context) => const AvailabilityScreen(),
              (context) => QRScreen(user: widget.user),
              (context) => const TopUpScreen()
            ];
            
            Widget timeLeft;
            
            if(user.inside) {
              final parkingRefStream = FirebaseFirestore.instance.collection("parkingEntry").doc(user.parkingRef.last).snapshots();

              parkingRefStream.listen((event) {
                debugPrint("parkingStream listen");
                Timestamp timestamp = event.data()!['entryTime'];
                DateTime dateTime = timestamp.toDate();
              });
            } else {
              timeLeft = const Text("data");
            }

            return Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.025,),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Welcome to the application, ${user.name}"
                    ),
                    Text(
                      "Email: ${user.email}",
                    ),
                  ]
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.025,),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  width: MediaQuery.of(context).size.width,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    physics: const BouncingScrollPhysics(),
                    itemCount: menuList.length,
                    itemBuilder: (_, int index) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.1,
                        child: Card(
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(builder: navigation[index]));
                            },
                            child: Text(
                              menuList[index],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15.0,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  )
                ),
              ],
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