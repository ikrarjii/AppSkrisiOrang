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

    final user = firestore.collection("users");

    QuerySnapshot<Map<String, dynamic>> snapPrensent = await cPresent.get();
    // print("ffff");
    // print("masuk = ${snapPrensent.docs.length}");

    // print(uid);
    DateTime now = DateTime.now();
    String todayDocID = DateFormat().add_yMd().format(now).replaceAll("/", "-");

    if (snapPrensent.docs.length == 0) {
      await cPresent.doc(todayDocID).set({
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
          await cPresent.doc(todayDocID).update({
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

    // DateTime now = DateTime.now();

    // String _status = "";

    // if (now.hour >= 6 && now.hour <= 8) {
    //   setState(() {
    //     _status = "Normal";
    //   });
    // } else if (now.hour >= 8 && now.hour <= 5) {
    //   setState(() {
    //     _status = "terlambat";
    //   });
    // }

    // await FirebaseFirestore.instance.collection('users').doc().update({
    //   "status": _status,
    // });

    // try {
    //   final docUser = await FirebaseFirestore.instance
    //       .collection("users")
    //       .where("email", isEqualTo: user!.email)
    //       .get();

    //   String nama = docUser.docs[0]["nama"];
    //   final doc = FirebaseFirestore.instance.collection("absen");

    //   await FirebaseFirestore.instance.collection('users').doc().update({
    //     "check_in": now,
    //   });

    // print(now);

    // final json = {
    //   "nama": nama,
    //   "email": user.email,
    //   "created_at": now,
    //   "check_in": now,
    //   "check_out": "",
    //   "month": DateFormat("MMMM").format(now),
    //   "tanggal": DateFormat("EEEE, dd MMMM yyyy").format(now),
    // };

    // await doc.add(json);

    //   Utils.showSnackBar("Berhasil Check In.", Colors.green);

    //   Navigator.of(context, rootNavigator: true).pop('dialog');
    //   // navigatorKey.currentState!.pop();
    // } on FirebaseAuthException catch (e) {
    //   Navigator.of(context, rootNavigator: true).pop('dialog');
    //   Utils.showSnackBar(e.message, Colors.red);
    // }
    // print(barcodeScanRes);,

    // print(barcodeScanRes);
  }

  // Future scanQROut(String? id) async {
  //   String barcodeScanRes;
  //   int absen;
  //   // Platform messages may fail, so we use a try/catch PlatformException.
  //   try {
  //     barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
  //         '#ff6666', 'Cancel', true, ScanMode.QR);
  //     await scanner.scan();
  //     final user = FirebaseAuth.instance.currentUser;

  //     // showDialog(
  //     //   context: context,
  //     //   barrierDismissible: false,
  //     //   builder: (context) => Center(
  //     //     child: CircularProgressIndicator(),
  //     //   ),
  //     // );

  //     try {
  //       final doc = FirebaseFirestore.instance.collection("users").doc(id);
  //       DateTime now = DateTime.now();
  //       // String _StatusC = "";

  //       final user = FirebaseAuth.instance.currentUser;

  //       // if (now.hour >= 16 && now.hour <= 17) {
  //       //   _StatusC = "Pulang tepat waktu";
  //       // } else {
  //       //   _StatusC = "Lembur";
  //       // }

  //       // await FirebaseFirestore.instance.collection('users').doc().update({
  //       //   "statusD": _StatusC,
  //       // });

  //       final json = {
  //         "check_out": now,
  //         // "statusOut": _StatusC,
  //         // 'gaji': _StatusGaji,
  //       };

  //       await doc.set(json);

  //       // final docUser = FirebaseFirestore.instance.collection('users').doc(id);

  //       // final jsonn = {
  //       //   'gaji': _StatusGaji,
  //       // };

  //       // await docUser.set(jsonn);

  //       Utils.showSnackBar("Berhasil Check Out.", Colors.green);

  //       Navigator.of(context, rootNavigator: true).pop('dialog');
  //       // navigatorKey.currentState!.pop();
  //     } on FirebaseAuthException catch (e) {
  //       Navigator.of(context, rootNavigator: true).pop('dialog');
  //       Utils.showSnackBar(e.message, Colors.red);
  //     }
  //     // print(barcodeScanRes);
  //   } on PlatformException {
  //     barcodeScanRes = 'Failed to get platform version.';
  //   }

  //   // If the widget was removed from the tree while the asynchronous platform
  //   // message was in flight, we want to discard the reply rather than calling
  //   // setState to update our non-existent appearance.
  //   if (!mounted) return;

  //   //print(barcodeScanRes);
  // }

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser!.uid;

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
          stream: firestore
              .collection("users")
              .doc(uid)
              .collection("presence")
              .orderBy("date")
              .limitToLast(5)
              .snapshots(),
          builder: (context, snapshot) {
            return Container();

            //fff

            //batass
          }),
    );
  }
}
