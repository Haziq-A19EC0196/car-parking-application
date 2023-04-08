import 'package:car_parking_application/Screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../custom_widgets.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // Text controllers
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Text(
              "AEON Parking App",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold
              ),
            ),
            const Text(
              "Welcome!",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 25.0,
                  fontWeight: FontWeight.normal
              ),
            ),
            const Text(
              "Fill in your details to register",
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
                "Enter your email",
                Icons.mail,
                false,
                emailController
            ),
            const SizedBox(
              height: 35.0,
            ),
            customTextField(
                "Enter your password",
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
                onPressed: signup,
                child: const Text(
                  "Sign Up",
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
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    "Already have an account? ",
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                    },
                    child: const Text(
                      "Sign In",
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

  Future signup() async {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim())
    .then((value) => {
      Fluttertoast.showToast(
          msg: "Successfully signed up",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          fontSize: 16.0
      ),
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginPage()))
    })
    .catchError((onError) {
      Fluttertoast.showToast(msg: onError!.message);
    });
  }
}