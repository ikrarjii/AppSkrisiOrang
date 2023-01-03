import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/Utils/Utils.dart';
import 'package:flutter_application_1/presentation/pages/Lembur.dart';
import 'package:flutter_application_1/presentation/pages/Scan.dart';
import 'package:flutter_application_1/presentation/resources/warna.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import '../resources/gambar.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:intl/intl.dart';

class Check_lemburPage extends StatefulWidget {
  const Check_lemburPage({Key? key}) : super(key: key);

  @override
  State<Check_lemburPage> createState() => _Check_lemburPageState();
}

class _Check_lemburPageState extends State<Check_lemburPage> {
  Future scanQR() async {
    //String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      // barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
      //     '#ff6666', 'Cancel', true, ScanMode.QR);
      await scanner.scan();
      final user = FirebaseAuth.instance.currentUser;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        final doc = FirebaseFirestore.instance.collection("presensi");
        DateTime now = DateTime.now();
        final json = {
          "email": user!.email,
          "created_at": now,
          "check_in": now,
          "check_out": "",
          "month": DateFormat("MMMM").format(now),
          "tanggal": DateFormat("EEEE, dd MMMM yyyy").format(now)
        };

        await doc.add(json);

        Utils.showSnackBar("Berhasil Check In.", Colors.green);

        Navigator.of(context, rootNavigator: true).pop('dialog');
        // navigatorKey.currentState!.pop();
      } on FirebaseAuthException catch (e) {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        Utils.showSnackBar(e.message, Colors.red);
      }
      // print(barcodeScanRes);
    } on PlatformException {
      //barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    //print(barcodeScanRes);
  }

  Future scanQROut(String? id) async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      // barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
      //     '#ff6666', 'Cancel', true, ScanMode.QR);
      await scanner.scan();
      final user = FirebaseAuth.instance.currentUser;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        final doc = FirebaseFirestore.instance.collection("presensi").doc(id);
        DateTime now = DateTime.now();
        final json = {
          "check_out": now,
        };

        await doc.update(json);

        Utils.showSnackBar("Berhasil Check Out.", Colors.green);

        Navigator.of(context, rootNavigator: true).pop('dialog');
        // navigatorKey.currentState!.pop();
      } on FirebaseAuthException catch (e) {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        Utils.showSnackBar(e.message, Colors.red);
      }
      // print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    //print(barcodeScanRes);
  }

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
          stream: firestore
              .collection("presensi")
              .where("email", isEqualTo: user!.email)
              .where("tanggal",
                  isEqualTo:
                      DateFormat("EEEE, dd MMMM yyyy").format(DateTime.now()))
              .snapshots(),
          builder: (context, snapshot) {
            bool isCheckIn = snapshot.data!.docs.length > 0;
            bool isCheckOut = snapshot.data!.docs.length > 0 &&
                snapshot.data!.docs[0]["check_out"] != "";
            return Column(
              children: <Widget>[
                Container(
                  child: Stack(
                    children: [
                      Container(
                          child: Image.asset(
                        Gambar.lmbur,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.4,
                      )),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: Container(),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 20),
                        width: double.infinity,
                        padding: EdgeInsets.only(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Container(
                            //   child: Row(
                            //     mainAxisAlignment: MainAxisAlignment.start,
                            //     children: [
                            //       IconButton(
                            //           icon: Icon(Icons.arrow_back),
                            //           color: Warna.putih,
                            //           onPressed: () {
                            //             Navigator.push(
                            //                 context,
                            //                 MaterialPageRoute(
                            //                     builder: (context) =>
                            //                         Lembur()));
                            //           }),
                            //     ],
                            //   ),
                            // ),
                            SizedBox(
                              height: 20,
                            ),
                            Title(
                              color: Warna.hijau2,
                              child: Text(
                                'Lembur',
                                style: TextStyle(
                                  color: Warna.putih,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Title(
                              color: Warna.putih,
                              child: Text(
                                (DateFormat('KK:mm').format(DateTime.now())),
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
                          child: !isCheckIn
                              ? ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: Warna.kuning,
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                  ),
                                  child: Text("Check In"),
                                  onPressed: () {
                                    scanQR();
                                    // Navigator.push(context,
                                    //     MaterialPageRoute(builder: (context) => Csan()));
                                  },
                                )
                              : isCheckIn && !isCheckOut
                                  ? ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        primary: Warna.mrah,
                                        padding:
                                            EdgeInsets.symmetric(vertical: 20),
                                      ),
                                      child: Text("Check Out"),
                                      onPressed: () {
                                        scanQROut(snapshot.data!.docs[0].id);
                                        // Navigator.push(context,
                                        //     MaterialPageRoute(builder: (context) => Csan()));
                                      },
                                    )
                                  : Container())
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot data = snapshot.data!.docs[index];
                        return ItemCard1(data);
                      }),
                ),
              ],
            );
          }),
    );
  }
}

Container ItemCard1(DocumentSnapshot? data) {
  return Container(
    alignment: Alignment.centerLeft,
    margin: EdgeInsets.all(20),
    padding: EdgeInsets.symmetric(horizontal: 20),
    height: 150,
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(25), //border corner radius
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5), //color of shadow
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
              data!["tanggal"],
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
            DateFormat("HH mm").format(data["check_in"].toDate()),
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
              data["check_out"] != ""
                  ? DateFormat("HH mm").format(data["check_out"].toDate())
                  : "-",
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
}
