import 'package:car_parking_application/Screens/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({Key? key}) : super(key: key);

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  final Stream<DocumentSnapshot> _parkingStream = FirebaseFirestore.instance.collection('parkingLot').doc("parking1").snapshots();

  @override
  Widget build(BuildContext context) {

    Widget availabilityWidget = Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: _parkingStream,
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading");
          }

          var data = snapshot.data!;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(data["isEmpty"] ? "The parking lot is empty" : "The parking lot is not empty"),
              SizedBox(
                width: 150.0,
                child: RawMaterialButton(
                  fillColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)
                  ),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const HomeScreen()));
                  },
                  child: const Text(
                    "Back",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return availabilityWidget;
  }
}
