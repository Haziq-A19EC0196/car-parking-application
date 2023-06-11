import 'package:car_parking_application/Logics/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  final UserModel user;
  const HistoryScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("History"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection("parkingEntry").where('userIdRef', isEqualTo: widget.user.userId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("error");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          var docList = snapshot.data!.docs;

          if (docList.isEmpty) {
            debugPrint("doclist empty");
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    color: Colors.black,
                    size: 40,
                  ),
                  Text(
                    "No user history found",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: docList.length,
            itemBuilder: (context, int index) {
              Timestamp entryTime = docList[index].data()['entryTime'];
              Timestamp exitTime;
              String exitTimeStr;
              String duration;
              String fee;

              if (docList[index].data()['exitTime'] != null) {
                exitTime = docList[index].data()['exitTime'];
                exitTimeStr = exitTime.toDate().toString();

                duration = docList[index].data()['totalDurationInMinutes'].toString();
                fee = docList[index].data()['totalFee'].toString();
              } else {
                exitTimeStr = "-";
                duration = "-";
                fee = "-";
              }

              return Container(
                margin: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                padding: const EdgeInsets.all(15),
                color: Colors.grey.shade300,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Entry time: ${entryTime.toDate().toString()}"),
                    Text("Exit time: $exitTimeStr"),
                    Text("Duration: $duration"),
                    Text("Total fee: $fee"),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
