import 'package:car_parking_application/Screens/total_revenue_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'login_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
        child: Center(
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.03,),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: RawMaterialButton(
                  padding: const EdgeInsets.all(10),
                  fillColor: Colors.blue,
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const TotalRevenueScreen()));
                  },
                  child: const Text(
                    "See Revenue",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03,),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: RawMaterialButton(
                  padding: const EdgeInsets.all(10),
                  fillColor: Colors.blue,
                  onPressed: logout,
                  child: const Text(
                    "Log out",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
