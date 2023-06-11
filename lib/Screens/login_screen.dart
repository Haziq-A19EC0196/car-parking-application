import 'package:car_parking_application/Screens/reset_password_screen.dart';
import 'package:car_parking_application/Screens/signup_screen.dart';
import 'package:car_parking_application/Screens/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../Logics/local_auth_api.dart';
import '../Logics/user_model.dart';
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

  bool userExist = false;

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser != null) {
      userExist = true;
      authenticateUser();
    } else {
      userExist = false;
    }
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Login"),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
                "Welcome!\nPlease log in to enter",
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
                  "Email",
                  Icons.mail,
                  false,
                  emailController
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
              ),
              customTextField(
                  "Password",
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
                    final email = emailController.text.trim();
                    final pass = passwordController.text.trim();

                    await login(email, pass);
                  },
                  child: const Text(
                    "Login",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.025,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.75,
                child: RawMaterialButton(
                  fillColor: userExist ? Colors.blue : Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)
                  ),
                  onPressed: userExist ? authenticateUser : () {Fluttertoast.showToast(msg: "No user session found");},
                  child: const Text(
                    "Login with Fingerprint",
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
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ResetPasswordScreen()));
                },
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
      )
    );

  }

  Future login(String email, String password) async {

    try {
      UserCredential userCred = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password);

      final snapshot = await FirebaseFirestore.instance.collection("customers").doc(userCred.user!.uid).get();
      final user = UserModel.fromJson(snapshot.data()!);
      user.userId = userCred.user!.uid;

      if (userCred.user!.emailVerified && mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen(user: user,)));
      } else {
        Fluttertoast.showToast(
            msg: "Check your email and verify your account",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            fontSize: 16.0
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Fluttertoast.showToast(
            msg: "Email not found",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            fontSize: 16.0
        );
      } else if (e.code == 'wrong-password') {
        Fluttertoast.showToast(
            msg: "Wrong email or password",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            fontSize: 16.0
        );
      } else {
        Fluttertoast.showToast(
          msg: e.message!,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    }
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

  Future<void> authenticateUser() async {
    final isAuthenticated = await LocalAuthApi.authenticateWithBiometrics();
    var data = await FirebaseFirestore.instance.collection("customers").doc(FirebaseAuth.instance.currentUser!.uid).get();

    if (isAuthenticated && mounted) {
      UserModel user = UserModel.fromJson(data.data()!);
      user.userId = FirebaseAuth.instance.currentUser!.uid;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen(user: user)));
    }
  }
}