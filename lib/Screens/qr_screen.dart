import 'dart:io';

import 'package:car_parking_application/Logics/user_model.dart';
import 'package:car_parking_application/Screens/topup_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScreen extends StatefulWidget {
  final UserModel user;
  const QRScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  late final Stream<DocumentSnapshot> _stream = FirebaseFirestore.instance.collection("customers").doc(widget.user.userId).snapshots();

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  Barcode? result;

  FirebaseFirestore db = FirebaseFirestore.instance;
  late QuerySnapshot<Map<String, dynamic>> entryList, exitList;
  // late UserModel user;

  @override
  void reassemble() async {
    super.reassemble();

    if(Platform.isAndroid) {
      await controller!.pauseCamera();
    }

    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("hello");
    Widget qrWidget = Scaffold(
      appBar: AppBar(
        title: const Text("QR Scan"),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: _stream,
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if(snapshot.hasError) {
            return const Text("Something went wrong!");
          } else if(snapshot.hasData) {
            var data = snapshot.data;

            Widget qrScanWidget = Scaffold(
              body: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  QRView(
                    key: qrKey,
                    onQRViewCreated: _onQRViewCreated,
                    overlay: QrScannerOverlayShape(
                      cutOutSize: MediaQuery.of(context).size.width * 0.8,
                      borderRadius: 10,
                      borderWidth: 5,
                      borderColor: Colors.blue,
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.1,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white38,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        !data!['inside'] ? "Scan code at the entrance" : "Scan code at the exit",
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    )
                  ),
                ],
              ),
            );

            return qrScanWidget;
          } else {
            return const Center(child: CircularProgressIndicator(),);
          }
        },
      ),
    );

    return qrWidget;
  }

  void _onQRViewCreated(QRViewController controller) async {
    this.controller = controller;
    String userId = FirebaseAuth.instance.currentUser!.uid;
    bool docFound = false;

    var snapshot = await db.collection("customers").doc(userId).get();
    var user = UserModel.fromJson(snapshot.data()!);

    entryList = await db.collection("parkingEntry").get();
    exitList = await db.collection("parkingExit").get();
    
    final userStream = FirebaseFirestore.instance.collection("customers").doc(userId).snapshots();
    userStream.listen((event) {
      user = UserModel.fromJson(event.data()!);
    });
    final entryStream = FirebaseFirestore.instance.collection("parkingEntry").snapshots();
    entryStream.listen((event) {
      entryList = event;
    });
    final exitStream = FirebaseFirestore.instance.collection("parkingExit").snapshots();
    exitStream.listen((event) {
      exitList = event;
    });

    controller.scannedDataStream.listen((scanData) {
      setState(() {
        if(!user.inside) {
          for(var doc in entryList.docs) {
            if(scanData.code == doc.id && doc.data()["userIdRef"] == null) {
              docFound = true;
              updateEntry(doc.id, userId);
              break;
            }
          }
          if(!docFound) {
            Fluttertoast.showToast(msg: "Invalid QR Code. Please try again.");
          }
        } else {
          for(var doc in exitList.docs) {
            if(scanData.code == doc.id && !docFound) {
              docFound = true;
              updateExit(doc.id, userId);
              break;
            }
          }
          if(!docFound) {
            Fluttertoast.showToast(msg: "Invalid QR Code. Please try again.");
          }
        }
      });
    });
    
    controller.pauseCamera();
    controller.resumeCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future updateEntry(String parkingEntryId, String userId) async {
    final entryRef = db.collection("parkingEntry").doc(parkingEntryId);
    final userRef = db.collection("customers").doc(userId);

    var entryData = {
      'userIdRef' : userId,
      'entryTime' : FieldValue.serverTimestamp(),
    };
    var userData = {
      'inside' : true,
      'parkingEntryRef' : FieldValue.arrayUnion([parkingEntryId]),
    };

    await entryRef.update(entryData);
    await userRef.update(userData);

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Balance"),
            content: const Text("Ensure you have sufficient balance before exiting."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Ok'),
              ),
            ],
          );
        },
        barrierDismissible: false,
      );
    }
  }

  Future updateExit(String parkingExitId, String userId) async {
    final exitRef = db.collection("parkingExit").doc(parkingExitId);
    final userRef = db.collection("customers").doc(userId);

    var snapshot = await userRef.get();
    List<dynamic> list = snapshot.data()!['parkingEntryRef'];
    final parkingEntryId = list.last;

    final entryRef = db.collection("parkingEntry").doc(parkingEntryId);

    var entryData = {
      'exitTime' : FieldValue.serverTimestamp(),
    };

    await entryRef.update(entryData);
    await exitRef.delete();

    final entrySnapshot = await entryRef.get();
    Timestamp entryTime = entrySnapshot.data()!["entryTime"];
    Timestamp exitTime = entrySnapshot.data()!["exitTime"];
    DateTime entryDateTime = entryTime.toDate();
    DateTime exitDateTime = exitTime.toDate();
    double currBalance = widget.user.balance;

    final parkDurationInMinutes = exitDateTime.difference(entryDateTime).inMinutes;
    final double totalFee = parkDurationInMinutes.toDouble(); // RM1 per minute for testing, change accordingly

    if (currBalance < totalFee) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Insufficient Balance"),
              content: Text("You have insufficient balance, please top-up first.\nTotal fee: RM ${totalFee.toStringAsFixed(2)}"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const TopUpScreen()));
                  },
                  child: const Text('Ok'),
                ),
              ],
            );
          },
          barrierDismissible: false,
        );
      }
      // Fluttertoast.showToast(
      //   msg: "You have insufficient balance, please top-up before exiting.",
      //   toastLength: Toast.LENGTH_LONG
      // );
    } else {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Exit"),
              content: Text("Total fee: RM ${totalFee.toStringAsFixed(2)},\nApprove payment?"),
              actions: [
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  onPressed: () async {
                    var durationData = {
                      'totalDurationInMinutes' : parkDurationInMinutes,
                      'totalFee': totalFee,
                    };

                    var userData = {
                      'inside': false,
                      'balance': FieldValue.increment(-totalFee),
                    };

                    await entryRef.update(durationData);
                    await userRef.update(userData);

                    if (mounted) {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    }
                    // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const TopUpScreen()));
                  },
                  child: const Text('Approve'),
                ),
              ],
            );
          },
          barrierDismissible: false,
        );
      }
    }
  }
}
