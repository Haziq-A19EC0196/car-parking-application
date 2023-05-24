import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../custom_widgets.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Widget resetPasswordWidget = Scaffold(
      appBar: AppBar(
        title: const Text("Reset your Password"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.05,),
            const Text(
              "Enter your email address below and we'll email you the reset link",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20.0,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05,),

            customTextField(
                "Email",
                Icons.mail,
                false,
                emailController
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05,),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: RawMaterialButton(
                fillColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)
                ),
                onPressed: () async {
                  final email = emailController.text.trim();
                  await FirebaseAuth.instance.sendPasswordResetEmail(email: email)
                      .then((value) => {
                    Fluttertoast.showToast(msg: "Check your email to reset your password"),
                    Navigator.pop(context)
                  });
                },
                child: const Text(
                  "Reset Password",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0
                  ),
                ),
              ),
            ),
          ],
        ),
      )
    );

    return resetPasswordWidget;
  }
}
