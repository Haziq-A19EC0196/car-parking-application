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
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _stream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          } else if (snapshot.hasData) {
            var data = snapshot.data!;

            var parking1 = data.docs[0]["isEmpty"];
            var parking2 = data.docs[1]["isEmpty"];

            Widget img = Image.asset("assets/car-transparent.png", scale: 4,);

            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                title: const Text("Availability"),
                centerTitle: true,
              ),
              body: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.15,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                        decoration: const BoxDecoration(
                          border: Border(top: BorderSide(width: 1), left: BorderSide(width: 1), right: BorderSide(width: 0.5)),
                        ),
                        child: Container(
                          color: parking1 ? Colors.green : Colors.red,
                          child: img,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                        decoration: const BoxDecoration(
                          border: Border(top: BorderSide(width: 1), left: BorderSide(width: 0.5), right: BorderSide(width: 1)),
                        ),
                        child: Container(
                          color: parking2 ? Colors.green : Colors.red,
                          child: img,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.025,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(parking1 ? "Empty" : "Occupied"),
                      const SizedBox(width: 55,),
                      Text(parking2 ? "Empty" : "Occupied"),
                    ],
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator(),);
          }
        },
      ),
    );
  }
}
