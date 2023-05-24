import 'package:car_parking_application/Logics/user_model.dart';
import 'package:car_parking_application/Screens/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Sign Up"),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: MediaQuery.of(context).size.height * 0.025,),
              const Text(
                "AEON Parking App",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.025,),
              const Text(
                "Welcome!\nFill in your details to register",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                    fontWeight: FontWeight.normal
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              customTextField(
                  "Enter your name",
                  Icons.person,
                  false,
                  nameController
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
              ),
              customTextField(
                  "Enter your phone number",
                  Icons.phone,
                  false,
                  phoneController
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
              ),
              customTextField(
                  "Enter your email",
                  Icons.mail,
                  false,
                  emailController
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
              ),
              customTextField(
                  "Enter your password",
                  Icons.key,
                  true,
                  passwordController
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.075,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.75,
                child: RawMaterialButton(
                  fillColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)
                  ),
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final phone = phoneController.text.trim();
                    final email = emailController.text.trim();
                    final pass = passwordController.text.trim();

                    await signup(name, phone, email, pass);
                  },
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
                        Navigator.pop(context);
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
        ),
      ),
    );
  }

  Future createUser(String userId, String name, String phone, String email) async {
    final user = FirebaseFirestore.instance.collection("customers").doc(userId);

    final userData = UserModel(
      name: name,
      phone: phone,
      email: email,
      inside: false,
    );

    await user.set(userData.toJson());
  }

  Future signup(String name, String phone, String email, String password) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password)
          .then((value) => {
            value.user?.sendEmailVerification(),

            createUser(value.user!.uid, name, phone, email),
            Fluttertoast.showToast(
                msg: "Successfully signed up",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                fontSize: 16.0
            ),
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginPage()))
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        Fluttertoast.showToast(
            msg: "Your password is too weak",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            fontSize: 16.0
        );
      } else if (e.code == 'email-already-in-use') {
        Fluttertoast.showToast(
          msg: "This email is already registered",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          fontSize: 16.0
        );
      }
    }
  }
}