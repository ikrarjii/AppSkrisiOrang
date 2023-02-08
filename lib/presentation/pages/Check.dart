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
    // int _StatusGaji = 123456;
    // Platform messages may fail, so we use a try/catch PlatformException.

    // final user = await FirebaseAuth.instance.currentUser;

    // String uid = await user!.uid;'
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser!.uid;

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    CollectionReference<Map<String, dynamic>> cPresent =
        await firestore.collection("users").doc(uid).collection("present");

    // print("fffffffff = ${usr.get()}");
    // Map<String, dynamic> data = cPresent.doc(uid).collection("users");

    // final data = userss.get();

    QuerySnapshot<Map<String, dynamic>> snapPrensent = await cPresent.get();
    // print("ffff");
    // print("masuk = ${snapPrensent.docs.length}");

    // print(uid);
    DateTime now = DateTime.now();
    String todayDocID =
        DateFormat().add_yMMMM().format(now).replaceAll("/", "-");

    String _status = "";

    int terLambat;
    int lembur = 50000;

    if (now.hour >= 6 && now.hour <= 12) {
      _status = "Normal";
    } else if (now.hour >= 8 && now.hour <= 5) {
      _status = "terlambat";
    }

    if (snapPrensent.docs.length == 0) {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      await scanner.scan();

      await cPresent.doc(todayDocID).set({
        "bulan": 0,
        "gajiDay": 0,
        "date": now.toIso8601String(),
        "masuk": {
          "date": now.toIso8601String(),

          // "user": user!.email,
        }
      });
    } else {
      DocumentSnapshot<Map<String, dynamic>> absenn =
          await cPresent.doc(todayDocID).get();

      print(absenn.exists);

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
              "gajiDay": gajiDay,
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
            "status": _status,
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
                        return SizedBox(
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
                        itemCount: snapPresence.data!.docs.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> data =
                              snapPresence.data!.docs[index].data();

                          // totalGaji = ambil gaji yang bulan 1 lalu jumlahkan (tG)
                          //total lembur (tL)
                          //total bonus (tB)
                          //mines keterlambatan (mK)

                          //gaji bulan ini.bulan =  tG + tL + tb - mK

                          return SingleChildScrollView(
                            child: Container(
                              alignment: Alignment.centerLeft,
                              margin: EdgeInsets.all(20),
                              padding: EdgeInsets.symmetric(horizontal: 20),
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
                                    offset: Offset(0, 2),
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
                                        "  ${DateFormat.yMMMEd().format(DateTime.parse(data['date']))}",
                                        // data!["tanggal"],
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
                                          : "${DateFormat.jms().format(DateTime.parse(data['masuk']['date']))}",
                                      // DateFormat("HH mm")
                                      //     .format(data["date"].toDate()),
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
                                            : "${DateFormat.jms().format(DateTime.parse(data['keluar']['date']))}",
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
