import 'package:car_parking_application/Logics/reg_exp.dart';
import 'package:car_parking_application/Logics/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final formKey = GlobalKey<FormState>();

  bool editEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection("customers").doc(FirebaseAuth.instance.currentUser!.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"),);
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(),);
          }

          UserModel user = UserModel.fromJson(snapshot.data!.data()!);

          TextEditingController nameController = TextEditingController(text: user.name);
          TextEditingController emailController = TextEditingController(text: user.email);
          TextEditingController phoneController = TextEditingController(text: user.phone);

          return SingleChildScrollView(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
            child: Center(
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.025,),
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 30,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
                    Text(
                      user.email,
                      style: const TextStyle(
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width * 0.05,),
                    TextFormField(
                      controller: nameController,
                      enabled: editEnabled,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if(value!.isEmpty || !RegularExpressions.nameRegExp.hasMatch(value)) {
                          return "Ensure your name is spelled correctly";
                        } else {
                          return null;
                        }
                      },
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03,),
                    GestureDetector(
                      onDoubleTap: () {
                        if (editEnabled) {
                          Fluttertoast.showToast(
                            msg: "You cannot edit your email",
                          );
                        }
                      },
                      child: TextFormField(
                        controller: emailController,
                        enabled: false,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03,),
                    TextFormField(
                      controller: phoneController,
                      enabled: editEnabled,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: (value) {
                        if(value!.isEmpty || !RegularExpressions.phoneRegExp.hasMatch(value)) {
                          return "Enter a correct phone number";
                        } else {
                          return null;
                        }
                      },
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                editEnabled = !editEnabled;
                              });
                            },
                            child: Text(editEnabled ? "Cancel" : "Edit Profile"),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: RawMaterialButton(
                            fillColor: editEnabled ? Colors.blue : Colors.grey,
                            onPressed: () async {
                              if (editEnabled) {
                                if(formKey.currentState!.validate()) {
                                  var userData = {
                                    'name': nameController.text,
                                    'phone': phoneController.text,
                                  };

                                  if (userData['name'] == user.name && userData['phone'] == user.phone) {
                                    Fluttertoast.showToast(msg: "No change");
                                  } else {
                                    editEnabled = false;
                                    await FirebaseFirestore.instance.collection("customers").doc(FirebaseAuth.instance.currentUser!.uid).update(userData)
                                        .then((value) => {
                                      Fluttertoast.showToast(msg: "Profile updated"),
                                    }).catchError((error) {
                                      Fluttertoast.showToast(msg: "Unable to update profile: ${error.toString()}");
                                    });
                                  }
                                }
                              }
                            },
                            child: const Text(
                              "Save",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
