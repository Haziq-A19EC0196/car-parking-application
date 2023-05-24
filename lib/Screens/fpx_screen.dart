import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class FPXScreen extends StatefulWidget {
  final int amount;
  const FPXScreen({Key? key, required this.amount}) : super(key: key);

  @override
  State<FPXScreen> createState() => _FPXScreenState();
}

class _FPXScreenState extends State<FPXScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "FPX Payment",
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
        child: Column(
          children: [
            RawMaterialButton(
              fillColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)
              ),
              onPressed: () async {
                await _pay(context);
              },
              child: const Text(
                "Pay Now",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _createPaymentIntent() async {
    var uname = 'sk_test_51NBDk2IAWGSq2YIwnEZKJltI0lHzngUySYl4SA0eiPySnqDUpZxohF0tiXkOoXoFB1JCfW5g5W7oc3J6O31XD0W100kYTHwD6v';
    var pass = '';
    var auth = 'Basic ${base64Encode(utf8.encode('$uname:$pass'))}';

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

      await updateUserBalance()
        .then((value) => {
        Fluttertoast.showToast(msg: "Payment successfully completed")
      });
    } on Exception catch (e) {
      if (e is StripeException) {
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error from Stripe: ${e.error.localizedMessage}'),
            ),
          );
        }
      } else {
        if(mounted) {
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
}
