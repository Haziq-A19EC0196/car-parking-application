import 'package:car_parking_application/Screens/fpx_screen.dart';
import 'package:flutter/material.dart';

import 'dart:convert';

import 'package:car_parking_application/Logics/user_model.dart';
import 'package:car_parking_application/Screens/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class PaymentMethodScreen extends StatefulWidget {
  final int amount;
  const PaymentMethodScreen({Key? key, required this.amount}) : super(key: key);

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Top up Credits"),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
        physics: const BouncingScrollPhysics(),
        children: [
          Card(
            child: ListTile(
              title: const Text("Pay with FPX"),
              leading: const Icon(Icons.attach_money),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                _pay(context);
                // Navigator.of(context).push(MaterialPageRoute(builder: (context) => FPXScreen(amount: widget.amount,)));
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _createPaymentIntent() async {
    var apiKey = 'sk_test_51NBDk2IAWGSq2YIwnEZKJltI0lHzngUySYl4SA0eiPySnqDUpZxohF0tiXkOoXoFB1JCfW5g5W7oc3J6O31XD0W100kYTHwD6v';
    var auth = 'Basic ${base64Encode(utf8.encode('$apiKey:'))}';

    var headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': auth,
    };

    var data = 'amount=${widget.amount*100}&currency=myr&payment_method_types[]=fpx';

    var url = Uri.parse('https://api.stripe.com/v1/payment_intents');
    var res = await http.post(url, headers: headers, body: data);

    return json.decode(res.body);
  }

  Future _pay(BuildContext context) async {
    showProgressDialog();

    final result = await _createPaymentIntent();
    final clientSecret = await result['client_secret'];

    try {
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: const PaymentMethodParams.fpx(
          paymentMethodData: PaymentMethodDataFpx(
            testOfflineBank: false,
          ),
        ),
      );

      var snapshot = await FirebaseFirestore.instance.collection("customers").doc(FirebaseAuth.instance.currentUser!.uid).get();
      UserModel user = UserModel.fromJson(snapshot.data()!);
      user.userId = FirebaseAuth.instance.currentUser!.uid;

      await updateUserBalance()
          .then((value) => {
        Fluttertoast.showToast(
          msg: "Payment successfully completed",
          toastLength: Toast.LENGTH_LONG,
        ),

        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen(user: user))),
      });
    } on Exception catch (e) {
      if (e is StripeException) {
        if(mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error from Stripe: ${e.error.localizedMessage}'),
            ),
          );
        }
      } else {
        if(mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Unforeseen error: $e'),
            ),
          );
        }
      }
    }
  }

  Future updateUserBalance() async {
    final userRef = FirebaseFirestore.instance.collection("customers").doc(FirebaseAuth.instance.currentUser!.uid);
    await userRef.update({'balance': FieldValue.increment(widget.amount)});
  }

  void showProgressDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
