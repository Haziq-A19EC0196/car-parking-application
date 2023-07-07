import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EntryDetailScreen extends StatefulWidget {
  final String entryId;
  final String customerName;

  const EntryDetailScreen(
      {Key? key, required this.entryId, required this.customerName})
      : super(key: key);

  @override
  State<EntryDetailScreen> createState() => _EntryDetailScreenState();
}

class _EntryDetailScreenState extends State<EntryDetailScreen> {
  final formKey = GlobalKey<FormState>();
  bool editEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Entry Detail"),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection("parkingEntry")
            .doc(widget.entryId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Something went wrong"),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          bool exitExist = (snapshot.data!.data()!['exitTime'] != null);
          TextStyle attributeStyle = const TextStyle(
            fontSize: 16,
          );

          TextStyle dataStyle = const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          );

          double height = 0.025;

          DateTime entryDateTime = snapshot.data!.data()!['entryTime'].toDate();
          String entryTimeString = "${entryDateTime.hour.toString()}:${entryDateTime.minute.toString().padLeft(2, '0')}  ${entryDateTime.day.toString()}/${entryDateTime.month.toString()}/${entryDateTime.year.toString()}";

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: MediaQuery.of(context).size.width * 0.1),
            child: Center(
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                    width: MediaQuery.of(context).size.width,
                  ),
                  Text(
                    "Detail for entry on\n$entryTimeString",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 20,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                        width: MediaQuery.of(context).size.width,
                      ),
                      Text(
                        "Customer name:",
                        style: attributeStyle,
                      ),
                      Text(
                        widget.customerName,
                        style: dataStyle,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * height,
                      ),
                      Text(
                        "Entry time:",
                        style: attributeStyle,
                      ),
                      Text(
                        snapshot.data!.data()!['entryTime'].toDate().toString(),
                        style: dataStyle,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * height,
                      ),
                      Text(
                        "Exit time:",
                        style: attributeStyle,
                      ),
                      Text(
                        exitExist ? snapshot.data!.data()!['exitTime'].toDate().toString() : "-",
                        style: dataStyle,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * height,
                      ),
                      Text(
                        "Duration:",
                        style: attributeStyle,
                      ),
                      Text(
                        exitExist ? "${snapshot.data!.data()!['totalDurationInMinutes'].toString()} minutes" : "-",
                        style: dataStyle,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * height,
                      ),
                      Text(
                        "Total fee:",
                        style: attributeStyle,
                      ),
                      Text(
                        exitExist ? "RM ${snapshot.data!.data()!['totalFee'].toStringAsFixed(2)}" : "-",
                        style: dataStyle,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * height,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
