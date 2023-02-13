import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Utils/Utils.dart';
import 'package:flutter_application_1/presentation/pages/my_page.dart';
import 'package:flutter_application_1/presentation/resources/warna.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import '../resources/gambar.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:intl/intl.dart';

class check_lemburPage extends StatefulWidget {
  const check_lemburPage({Key? key}) : super(key: key);

  @override
  State<check_lemburPage> createState() => _check_lemburPageState();
}

class _check_lemburPageState extends State<check_lemburPage> {
  Future<void> scanQR() async {
    String barcodeScanRes;
    int lembur = 0;

    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser!.uid;

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    CollectionReference<Map<String, dynamic>> cPresent =
        await firestore.collection("users").doc(uid).collection("present");

    QuerySnapshot<Map<String, dynamic>> snapPrensent = await cPresent.get();
    DateTime now = DateTime.now();
    String todayDocID = DateFormat().add_yMd().format(now).replaceAll("/", "-");

    DateTime jamm = DateTime.now();
    log("jamnya ${jamm.hour}");

    String jam = DateFormat().add_yMd().format(jamm).replaceAll("/", "-");

    DocumentSnapshot<Map<String, dynamic>> absenn =
        await cPresent.doc(todayDocID).get();
    Map<String, dynamic>? dataPresentTod = absenn.data();

    if (jamm.hour >= 19 && jamm.hour <= 00) {
      if (dataPresentTod?["OutLembur"] != null &&
          dataPresentTod?["starLembur"] != null) {
        Utils.showSnackBar("Sukses Sudah Absen Masuk && Keluar.", Colors.green);
      } else if (dataPresentTod?["starLembur"] == null) {
        barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
            '#ff6666', 'Cancel', true, ScanMode.QR);
        await scanner.scan();
        await cPresent.doc(todayDocID).update({
          "starLembur": {
            "jamSLembur": jamm.toIso8601String(),
          }
        });
      } else {
        barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
            '#ff6666', 'Cancel', true, ScanMode.QR);
        await scanner.scan();
        await cPresent.doc(todayDocID).update({
          "OutLembur": {
            "JamOLembur": jamm.toIso8601String(),
          }
        });
      }
    } else {
      Utils.showSnackBar("Maaf Anda Belum Bisa Absen Lembur.", Colors.green);
    }

    var jamMulai = DateTime.parse(dataPresentTod!["starLembur"]["jamSLembur"]);

    var jamAkhir = DateTime.parse(dataPresentTod["OutLembur"]["JamOLembur"]);

    var jamLembur = jamAkhir.difference(jamMulai).inHours.round();

    lembur = jamLembur;

    await cPresent.doc(todayDocID).update({
      "waktuLembur": lembur,
    });
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
                                padding: const EdgeInsets.only(),
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
                                    const SizedBox(
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
                                    const SizedBox(
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
                              const SizedBox(
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
                                    child: const Text("Check In"),
                                    onPressed: () async {
                                      await scanQR();
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
                  const SizedBox(
                    height: 10,
                  ),

                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: streamUser(),
                    builder: ((context, snapPresent) {
                      if (snapPresence.data?.docs.length == 0 ||
                          snapPresence.data == null) {
                        return SizedBox(
                          height: 400,
                          child: const Center(
                            child:
                                Text("Maaf, History absen anda belum ada!!!"),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: snapPresence.data!.docs.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> data =
                              snapPresence.data!.docs[index].data();

                          return Container(
                            alignment: Alignment.centerLeft,
                            margin: const EdgeInsets.all(20),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                  25), //border corner radius
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey
                                      .withOpacity(0.5), //color of shadow
                                  spreadRadius: 1, //spread radius
                                  blurRadius: 7, // blur radius
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.date_range,
                                      color: Warna.htam,
                                      size: 20.0,
                                    ),
                                    Text(
                                      "${DateFormat.yMMMEd().format(DateTime.parse(data['date'].toString()))}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Warna.abuabu,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Row(children: [
                                  Text(
                                    "Check In",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Warna.htam,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 38,
                                  ),
                                  Text(
                                    data['masuk']?['date'] == null
                                        ? "-"
                                        : "${DateFormat.jms().format(DateTime.parse(data['masuk']['date'].toString()))}",
                                    // data["check_out"] != ""
                                    //     ? DateFormat("HH mm")
                                    //         .format(data["date"].toDate())
                                    //     : "-",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Warna.abuabu,
                                    ),
                                  ),
                                ]),
                                SizedBox(
                                  height: 7,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Check out",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Warna.htam,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 30,
                                    ),
                                    Text(
                                      data['keluar']?['date'] == null
                                          ? "-"
                                          : "${DateFormat.jms().format(DateTime.parse(data['keluar']['date'].toString()))}",
                                      // data["check_out"] != ""
                                      //     ? DateFormat("HH mm")
                                      //         .format(data["date"].toDate())
                                      //     : "-",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Warna.abuabu,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
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
