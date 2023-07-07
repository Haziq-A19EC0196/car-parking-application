import 'package:car_parking_application/Logics/user_model.dart';
import 'package:car_parking_application/Screens/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../Logics/reg_exp.dart';
import '../custom_widgets.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final formKey = GlobalKey<FormState>();

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
          child: Form(
            key: formKey,
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
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person_outline),
                    hintText: "Enter your name",
                  ),
                  validator: (value) {
                    if(value!.isEmpty || !RegularExpressions.nameRegExp.hasMatch(value)) {
                      return "Ensure your name is spelled correctly";
                    } else {
                      return null;
                    }
                  },
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.phone_outlined),
                    hintText: "Enter your phone number",
                  ),
                  validator: (value) {
                    if(value!.isEmpty || !RegularExpressions.phoneRegExp.hasMatch(value)) {
                      return "Enter a correct phone number";
                    } else {
                      return null;
                    }
                  },
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.email_outlined),
                    hintText: "Enter your email address",
                  ),
                  validator: (value) {
                    if(value!.isEmpty || !RegularExpressions.emailRegExp.hasMatch(value)) {
                      return "Enter a correct email address";
                    } else {
                      return null;
                    }
                  },
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.key),
                    hintText: "Enter your password",
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Password cannot be empty";
                    }
                  },
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
                      if (formKey.currentState!.validate()) {
                        final name = nameController.text.trim();
                        final phone = phoneController.text.trim();
                        final email = emailController.text.trim();
                        final pass = passwordController.text.trim();

                        await signup(name, phone, email, pass);
                      }
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
      ),
    );
  }

  Future createUser(String userId, String name, String phone, String email) async {
    final user = FirebaseFirestore.instance.collection("customers").doc(userId);

    final userData = UserModel(
      name: name,
      email: email,
      phone: phone,
      parkingRef: [],
      inside: false,
      balance: 0.00,
      isAdmin: false,
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
            Fluttertoast.showToast(msg: "Successfully signed up",),
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginPage())),
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