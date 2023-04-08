import 'package:car_parking_application/Screens/signup_screen.dart';
import 'package:car_parking_application/Screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../custom_widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Text controllers
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // Login function
  static Future<User?> loginWithEmailPassword({
    required String email,
    required String password,
    required BuildContext context
  }) async {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    User? user;
    try {
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(
          email: email,
          password: password);
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        print("No user associated with that email.");
      }
    }

    return user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "AEON Parking App",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold
              ),
            ),
            const Text(
              "Welcome! Please log in to enter",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 25.0,
                  fontWeight: FontWeight.normal
              ),
            ),
            const SizedBox(
              height: 50.0,
            ),
            customTextField(
                "Email",
                Icons.mail,
                false,
                emailController
            ),
            const SizedBox(
              height: 35.0,
            ),
            customTextField(
                "Password",
                Icons.key,
                true,
                passwordController
            ),
            const SizedBox(
              height: 50.0,
            ),
            SizedBox(
              width: 150.0,
              child: RawMaterialButton(
                fillColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)
                ),
                onPressed: login,
                child: const Text(
                  "Login",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 40.0,
            ),
            GestureDetector(
              onTap: () {},
              child: const Text(
                "Forgot password?",
                style: TextStyle(
                  color: Colors.blue
                ),
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Don't have an account yet? ",
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupPage()));
                  },
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(
                      color: Colors.blue
                    ),
                  ),
                )
              ]
            ),
          ],
        ),
      )
    );
  }

  Future login() async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim())
    .then((value) => {
      Fluttertoast.showToast(
          msg: "You have signed in",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          fontSize: 16.0
      ),
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const HomeScreen()))
    })
    .catchError((onError) {
      Fluttertoast.showToast(msg: onError!.message);
    });
  }
}