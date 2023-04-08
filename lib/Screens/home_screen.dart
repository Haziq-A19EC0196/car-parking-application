import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  String? email = FirebaseAuth.instance.currentUser?.email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
              "Welcome to the application"
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Email: $email",
                ),
              ]
          ),
          const SizedBox(height: 40.0,),
          SizedBox(
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
          ),
        ]
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
}