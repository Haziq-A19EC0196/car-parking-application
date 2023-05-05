import 'package:car_parking_application/Logics/user_model.dart';
import 'package:car_parking_application/Screens/availability_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'login_screen.dart';

final dbRef = FirebaseFirestore.instance.collection("customers");

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {

    Widget menuScreen = Scaffold(
      appBar: AppBar(
        title: const Text("Parking Application"),
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
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const AvailabilityScreen()));
                      debugPrint(FirebaseAuth.instance.currentUser!.uid);
                    },
                    child: const SizedBox(
                      width: 50,
                      height: 30,
                      child: Text('A card that can be tapped!'),
                    ),
                  ),
                ),
                Card(
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                    splashColor: Colors.blue.withAlpha(30),
                    child: const Text("another card"),
                    onTap: () {
                      debugPrint(FirebaseAuth.instance.currentUser!.uid);
                    },
                  ),
                )
              ];

              Widget gridMenu = SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  width: MediaQuery.of(context).size.width,
                  child: GridView.count(
                    crossAxisCount: 1,
                    childAspectRatio: 2.5,
                    padding: const EdgeInsets.all(10.0),
                    children: menuItems,
                  )
              );

              Widget logoutButton = SizedBox(
                width: 150.0,
                child: RawMaterialButton(
                  fillColor: Colors.blue,
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
                    const SizedBox(height: 30.0,),
                    welcomeMessage,
                    const SizedBox(height: 40.0,),
                    gridMenu,
                    const SizedBox(height: 40.0,),
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
      return UserModel.fromJson(snapshot.data()!);
    }

    return null;
  }
}