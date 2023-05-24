import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({Key? key}) : super(key: key);

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  final Stream<QuerySnapshot> _stream = FirebaseFirestore.instance.collection("parkingLot").snapshots();

  @override
  Widget build(BuildContext context) {

    Widget availabilityWidget = Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: _stream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          } else if (snapshot.hasData) {
            var data = snapshot.data!;

            var parking1 = data.docs[0]["isEmpty"];
            var parking2 = data.docs[1]["isEmpty"];

            Widget img = Image.asset("assets/car-transparent.png", scale: 5,);

            Widget row = Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  color: parking1 ? Colors.green : Colors.red,
                  child: img,
                ),
                Container(
                  color: parking2 ? Colors.green : Colors.red,
                  child: img,
                ),

              ],
            );

            Widget scaffold = Scaffold(
              appBar: AppBar(
                title: const Text("Availability"),
                centerTitle: true,
              ),
              body: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.15,),
                  Text("Parking 1 is ${parking1 ? "empty" : "not empty"}"),
                  Text("Parking 2 is ${parking2 ? "empty" : "not empty"}"),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1,),
                  row,
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1,),
                ],
              ),
            );

            return scaffold;
          } else {
            return const Center(child: CircularProgressIndicator(),);
          }
        },
      ),
    );

    return availabilityWidget;
  }
}
