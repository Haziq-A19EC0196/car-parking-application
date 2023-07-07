import 'package:car_parking_application/Screens/paymentmethod_screen.dart';
import 'package:flutter/material.dart';

class TopUpScreen extends StatefulWidget {
  const TopUpScreen({Key? key}) : super(key: key);

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  final List _amounts = [10, 20, 30, 50, 70, 100];
  TextEditingController amountController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Top up Credits"),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: "Custom amount",
                    prefixText: "RM ",
                  ),
                  keyboardType: TextInputType.number,
                  controller: amountController,
                  validator: (value) {
                    if(value!.isEmpty || !RegExp(r'^\d+$').hasMatch(value)) {
                      return "Incorrect value";
                    } else {
                      if(int.parse(value) < 2) {
                        return "Enter minimum amount of RM2";
                      } else {
                        return null;
                      }
                    }
                  },
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.025,),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.25,
                  child: GridView.builder(
                    itemCount: _amounts.length,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1.5
                    ),
                    itemBuilder: (_, int index) {
                      return Card(
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => PaymentMethodScreen(amount: _amounts[index])));
                          },
                          child: Center(
                            child: Text(
                              "RM ${_amounts[index]}",
                              style: const TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                        )
                      );
                    }
                  )
                ),
                RawMaterialButton(
                  fillColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)
                  ),
                  onPressed: () {
                    if(formKey.currentState!.validate()) {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => PaymentMethodScreen(amount: int.parse(amountController.text))));
                    }
                  },
                  child: const Text(
                    "Proceed",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
