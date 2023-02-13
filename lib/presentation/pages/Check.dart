import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/Utils/Utils.dart';
import 'package:flutter_application_1/presentation/pages/Lembur.dart';
import 'package:flutter_application_1/presentation/pages/Scan.dart';
import 'package:flutter_application_1/presentation/pages/data_presensi.dart';
import 'package:flutter_application_1/presentation/pages/my_page.dart';
import 'package:flutter_application_1/presentation/resources/warna.dart';
import 'package:flutter_application_1/presentation/widgets/attendance_card.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import '../resources/gambar.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:intl/intl.dart';

class CheckPage extends StatefulWidget {
  const CheckPage({Key? key}) : super(key: key);

  @override
  State<CheckPage> createState() => _CheckPageState();
}

class _CheckPageState extends State<CheckPage> {
  Future<void> scanQR() async {
    String barcodeScanRes;

    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser!.uid;

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    CollectionReference<Map<String, dynamic>> cPresent =
        await firestore.collection("users").doc(uid).collection("present");

    DocumentSnapshot<Map<String, dynamic>> Gaji =
        await firestore.collection("users").doc(uid).get();

    log(Gaji.data().toString());

    QuerySnapshot<Map<String, dynamic>> snapPrensent = await cPresent.get();

    DateTime now = DateTime.now();
    String todayDocID = DateFormat().add_yMd().format(now).replaceAll("/", "-");

    int lembur = 50000;
    // Utils.showSnackBar("Maaf, Waktu Absen Telah Habis.", Colors.green);
    // if (now.hour >= 8 && now.hour <= 4) {

    if (snapPrensent.docs.length == 0) {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      await scanner.scan();

      if (now.hour >= 9 && now.hour <= 10) {
        print(now);
        log("terlambat");
        await cPresent.doc(todayDocID).set({
          "date": now.toIso8601String(),
          "masuk": {
            "date": now.toIso8601String(),
            "late": 100,

            // "user": user!.email,
          }
        });
      } else {
        log("terlambat");
        log("tidak terlambat");
        await cPresent.doc(todayDocID).set({
          "date": now.toIso8601String(),
          "masuk": {
            "date": now.toIso8601String(),
            "late": 0,

            // "user": user!.email,
          }
        });
      }
    } else {
      DocumentSnapshot<Map<String, dynamic>> absenn =
          await cPresent.doc(todayDocID).get();

      if (absenn.exists == true) {
        Map<String, dynamic>? dataPresentTod = absenn.data();

        if (dataPresentTod?["keluar"] != null) {
          Utils.showSnackBar(
              "Sukses Sudah Absen Masuk && Keluar.", Colors.green);
        } else {
          //absen Keluar
          barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
              '#ff6666', 'Cancel', true, ScanMode.QR);
          await scanner.scan();
          int gajiDay = 0;
          final _gajiDay = gajiDay + 150000;
          await cPresent.doc(todayDocID).update({
            "bulan": todayDocID,
            "gajiDay": _gajiDay,
            "keluar": {
              "date": now.toIso8601String(),
            }
          });
        }
      } else {
        //masuk
        barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
            '#ff6666', 'Cancel', true, ScanMode.QR);
        await scanner.scan();
        await cPresent.doc(todayDocID).set({
          "date": now.toIso8601String(),
          "masuk": {
            "date": now.toIso8601String(),
          }
        });
      }
    }

    // showDialog(
    //   context: context,
    //   barrierDismissible: false,
    //   builder: (context) => Center(
    //     child: CircularProgressIndicator(),
    //   ),
    // );

    // }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamUser() async* {
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser!.uid;
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    yield* firestore
        .collection("users")
        .doc(uid)
        .collection("present")
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser!.uid;

    return Scaffold(
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: streamUser(),
          builder: (context, snapPresence) {
            return SingleChildScrollView(
              // scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  Container(
                    child: StreamBuilder(
                        stream: streamUser(),
                        builder: (context, snap) {
                          return Stack(
                            children: [
                              Container(
                                  child: Image.asset(
                                Gambar.lmbur,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height:
                                    MediaQuery.of(context).size.height * 0.4,
                              )),
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.4,
                                child: Container(),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 20),
                                width: double.infinity,
                                padding: EdgeInsets.only(),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          IconButton(
                                              icon: Icon(Icons.arrow_back),
                                              color: Warna.putih,
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            MyPages()));
                                              }),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Title(
                                      color: Warna.putih,
                                      child: Text(
                                        (DateFormat('KK:mm')
                                            .format(DateTime.now())),
                                        style: TextStyle(
                                          color: Warna.putih,
                                          fontSize: 32,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Title(
                                      color: Warna.hijau2,
                                      child: Text(
                                        (DateFormat('dd MMMM yyyy')
                                            .format(DateTime.now())),
                                        style: TextStyle(
                                          color: Warna.putih,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 2,
                              ),
                              Container(
                                  margin: EdgeInsets.only(top: 180, bottom: 10),
                                  width: double.infinity,
                                  padding: EdgeInsets.all(25),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      primary: Warna.kuning,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 20),
                                    ),
                                    child: Text("Check In"),
                                    onPressed: () {
                                      scanQR();
                                      // Navigator.push(context,
                                      //     MaterialPageRoute(builder: (context) => Csan()));
                                    },
                                  ))
                            ],
                          );
                        }

                        // batass

                        ),
                  ),
                  SizedBox(
                    height: 10,
                  ),

                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: streamUser(),
                    builder: ((context, snapPresent) {
                      if (snapPresence.data?.docs.length == 0 ||
                          snapPresence.data == null) {
                        return const SizedBox(
                          height: 400,
                          child: Center(
                            child:
                                Text("Maaf, History absen anda belum ada!!!"),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapPresence.data!.docs.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> data =
                              snapPresence.data!.docs[index].data();

                          // totalGaji = ambil gaji yang bulan 1 lalu jumlahkan (tG)
                          //total lembur (tL)
                          //total bonus (tB)
                          //mines keterlambatan (mK)

                          //gaji bulan ini.bulan =  tG + tL + tb - mK

                          return AttendanceCard(
                            date:
                                "${DateFormat.yMMMEd().format(DateTime.parse(data['date'].toString()))}",
                            checkIn: data['masuk']?['date'] == null
                                ? "-"
                                : "${DateFormat.jms().format(DateTime.parse(data['masuk']['date'].toString()))}",
                            checkout: data['keluar']?['date'] == null
                                ? "-"
                                : "${DateFormat.jms().format(DateTime.parse(data['keluar']['date'].toString()))}",
                          );

                          //btasss
                        },
                      );
                    }),
                  )

                  // batsss ko
                ],
              ),
            );

            //Builderrr
          }),
    );
  }

  //dd
}
