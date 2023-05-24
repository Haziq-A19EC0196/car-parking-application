import 'package:car_parking_application/Screens/fpx_screen.dart';
import 'package:flutter/material.dart';

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
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => FPXScreen(amount: widget.amount,)));
              },
            ),
          ),
          // CardFormField(
          //   controller: CardFormEditController(),
          //   style: CardFormStyle(
          //     borderColor: Colors.blue,
          //     textColor: Colors.black,
          //   ),
          // )
        ],
      ),
    );
  }
}
