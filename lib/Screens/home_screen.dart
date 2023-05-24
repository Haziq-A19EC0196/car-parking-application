import 'package:car_parking_application/Logics/user_model.dart';
import 'package:car_parking_application/Screens/availability_screen.dart';
import 'package:car_parking_application/Screens/qr_screen.dart';
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

    Widget menuScreen = Scaffold(
      appBar: AppBar(
        title: const Text("Parking Application"),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          children: const [
            ListTile(
              iconColor: Colors.redAccent,
              leading: Icon(Icons.logout),
              title: Text(
                "Logout",
                style: TextStyle(
                  fontSize: 15.0,
                ),
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder<UserModel?> (
        future: getUserData(),
        builder: (context, snapshot) {
          if(snapshot.hasError) {
            return Text("Something went wrong! ${snapshot.error.toString()}");
          } else if(snapshot.hasData) {
            final user = snapshot.data;

            if(user==null) {
              return const Text("Something went wrong!");
            } else {
              Widget welcomeMessage = Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        "Welcome to the application, ${user.name}"
                    ),
                    Text(
                      "Email: ${user.email}",
                    ),
                  ]
              );

              List<Widget> menuItems = [
                Card(
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                    splashColor: Colors.blue.withAlpha(30),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AvailabilityScreen()));
                    },
                    child: const Text(
                      'Check parking availability',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15.0,
                      ),
                    ),
                  ),
                ),
                Card(
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                    splashColor: Colors.blue.withAlpha(30),
                    child: const Text("Scan QR Code"),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => QRScreen(user: user,)));
                      // await testFunc();
                    },
                  ),
                ),
                Card(
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                    splashColor: Colors.blue.withAlpha(30),
                    child: const Text("Top up credit"),
                    onTap: () {},
                  ),
                )
              ];

              Widget gridMenu = SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  width: MediaQuery.of(context).size.width,
                  child: ListView(
                    children: menuItems,
                  )
                  // GridView.count(
                  //   crossAxisCount: 1,
                  //   childAspectRatio: 2,
                  //   padding: EdgeInsets.symmetric(
                  //     // vertical: 10.0,
                  //     horizontal: MediaQuery.of(context).size.width * 0.05,
                  //   ),
                  //   children: menuItems,
                  // )
              );

              Widget logoutButton = SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: RawMaterialButton(
                  fillColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)
                  ),
                  onPressed: logout,
                  child: const Text(
                    "Log Out",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0
                    ),
                  ),
                ),
              );

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.025,),
                    welcomeMessage,
                    SizedBox(height: MediaQuery.of(context).size.height * 0.025,),
                    gridMenu,
                    SizedBox(height: MediaQuery.of(context).size.height * 0.025,),
                    logoutButton
                  ],
                ),
              );
            }
          } else {
            return const Center(child: CircularProgressIndicator(),);
          }
        },
      ),
    );
    
    return menuScreen;
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