import 'package:car_parking_application/Screens/entry_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TotalRevenueScreen extends StatefulWidget {
  const TotalRevenueScreen({Key? key}) : super(key: key);

  @override
  State<TotalRevenueScreen> createState() => _TotalRevenueScreenState();
}

class _TotalRevenueScreenState extends State<TotalRevenueScreen> {
  Timestamp pastDay = Timestamp.fromDate(Timestamp.now().toDate().add(const Duration(hours: -24)));
  Timestamp pastWeek = Timestamp.fromDate(Timestamp.now().toDate().add(const Duration(days: -7)));
  Timestamp pastMonth = Timestamp.fromDate(Timestamp.now().toDate().add(const Duration(days: -30)));
  Timestamp pastYear = Timestamp.fromDate(Timestamp.now().toDate().add(const Duration(days: -365)));

  Timestamp selectedFilter = Timestamp.fromDate(Timestamp.now().toDate().add(const Duration(days: -30)));
  String filter = "(Past 30 days)";

  @override
  Widget build(BuildContext context) {
    double totalRevenue = 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Revenue Generated"),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (String result) {
              switch (result) {
                case 'day':
                  setState(() {
                    selectedFilter = pastDay;
                    filter = "(Past 24 hours)";
                  });
                  break;
                case 'week':
                  setState(() {
                    selectedFilter = pastWeek;
                    filter = "(Past 7 days)";
                  });
                  break;
                case 'month':
                  setState(() {
                    selectedFilter = pastMonth;
                    filter = "(Past 30 days)";
                  });
                  break;
                case 'pastYear':
                  setState(() {
                    selectedFilter = pastYear;
                    filter = "(Past 365 days)";
                  });
                  break;
                default:
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'day',
                child: Text('Past 24 hours'),
              ),
              const PopupMenuItem<String>(
                value: 'week',
                child: Text('Past 7 days'),
              ),
              const PopupMenuItem<String>(
                value: 'month',
                child: Text('Past 30 days'),
              ),
              const PopupMenuItem<String>(
                value: 'pastYear',
                child: Text('Past 365 days'),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance.collection("parkingEntry").where("entryTime", isGreaterThan: selectedFilter).orderBy("entryTime", descending: true).get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong! ${snapshot.error.toString()}");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(),);
          }
          return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
            future: FirebaseFirestore.instance.collection("customers").get(),
            builder: (context, snapshot1) {
              if (snapshot1.hasError) {
                return Text("Something went wrong! ${snapshot1.error.toString()}");
              }
              if (snapshot1.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(),);
              }

              List<QueryDocumentSnapshot<Map<String, dynamic>>> docList = snapshot.data!.docs;
              docList.removeWhere((element) => (element.data()['entryTime'] == null));

              for (var doc in docList) {
                if (doc.data()['totalFee'] != null) {
                  totalRevenue += doc.data()['totalFee'];
                }
              }

              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      "Total Revenue $filter:\nRM ${totalRevenue.toStringAsFixed(2)}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: docList.length,
                      padding: const EdgeInsets.all(10),
                      itemBuilder: (context, int index) {
                        DateTime entryDate = docList[index].data()['entryTime'].toDate();
                        String fee = docList[index].data()['totalFee'] != null ? docList[index].data()['totalFee'].toStringAsFixed(2) : "-";
                        String customerName = "Anonymous";

                        for (var userDoc in snapshot1.data!.docs) {
                          if (userDoc.id == docList[index].data()['userIdRef']) {
                            customerName = userDoc.data()['name'];
                            break;
                          }
                        }

                        TextStyle textStyle = const TextStyle(
                          fontSize: 15,
                        );

                        return Container(
                          margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                          padding: const EdgeInsets.all(12),
                          color: Colors.grey.shade300,
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Date: ${entryDate.day}/${entryDate.month}/${entryDate.year}", style: textStyle,),
                                    Text("Total fee: RM $fee", style: textStyle,),
                                    Text("Customer: $customerName", style: textStyle,),
                                  ],
                                ),
                              ),
                              RawMaterialButton(
                                fillColor: Colors.blue,
                                child: const Text(
                                  "Check\nDetails",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => EntryDetailScreen(entryId: docList[index].id, customerName: customerName,)));
                                }
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
