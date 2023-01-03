import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Utils/Utils.dart';
import 'package:flutter_application_1/presentation/widgets/formcuxtom.dart';
import 'package:intl/intl.dart';
import '../resources/warna.dart';

class TambhKasbon extends StatefulWidget {
  const TambhKasbon({Key? key}) : super(key: key);

  @override
  State<TambhKasbon> createState() => _TambhKasbonState();
}

class _TambhKasbonState extends State<TambhKasbon> {
  DateTime selectedDate = DateTime.now();
  bool isSelected = false;
  bool showDate = false;
  final keteranganController = TextEditingController();
  final jumlahController = TextEditingController();

  Future<DateTime> _selectDate(BuildContext context) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (selected != null && selected != selectedDate) {
      setState(() {
        selectedDate = selected;
      });
    }
    return selectedDate;
  }

  String getDate() {
    // ignore: unnecessary_null_comparison
    if (!isSelected) {
      return '';
    } else {
      return DateFormat('dd MMMM yyyy').format(selectedDate);
    }
  }

  Future sendData() async {
    final user = FirebaseAuth.instance.currentUser;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final docUser = await FirebaseFirestore.instance
          .collection("users")
          .where("email", isEqualTo: user!.email)
          .get();

      String nama = docUser.docs[0]["nama"];

      final doc = FirebaseFirestore.instance.collection("pengajuan");
      final json = {
        "email": user.email,
        "created_at": DateTime.now(),
        "biaya": jumlahController.text.trim(),
        "tanggal": selectedDate,
        "keterangan": keteranganController.text.trim(),
        "status": "0",
        "month": DateFormat("MMMM").format(DateTime.now()),
        "tipe_pengajuan": 'Kasbon',
        "tanggal_mulai": "-",
        "tanggal_selesai": '-',
        "jenis": '-',
        "image": '-',
        "nama": nama
      };

      await doc.add(json);

      Utils.showSnackBar("Berhasil Tambah Kasbon.", Colors.green);
      keteranganController.clear();
      jumlahController.clear();
      setState(() {
        selectedDate = DateTime.now();
        isSelected = false;
      });
      Navigator.of(context, rootNavigator: true).pop('dialog');
      // navigatorKey.currentState!.pop();
    } on FirebaseAuthException catch (e) {
      Navigator.of(context, rootNavigator: true).pop('dialog');
      Utils.showSnackBar(e.message, Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Warna.hijau2,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 45),
          ),
          SizedBox(
            height: 5,
          ),
        ],
        title: Text(
          "Pengajuan Kasbon",
          style: TextStyle(
              fontSize: 18, color: Warna.putih, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: 20),
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      child: Text(
                        "Jumlah",
                        textAlign: TextAlign.left,
                      ),
                    ),
                    FormCustom(
                      text: 'Rp.',
                      controller: jumlahController,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      child: Text(
                        "Tanggal",
                        textAlign: TextAlign.left,
                      ),
                    ),
                    FormCustom(
                      suffixicon: Icon(Icons.date_range),
                      text: 'Tanggal Kasbon',
                      readOnly: true,
                      onTap: () {
                        _selectDate(context);
                        showDate = true;
                        isSelected = true;
                      },
                      controller: TextEditingController(text: getDate()),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      child: Text(
                        "Keterangan",
                        textAlign: TextAlign.left,
                      ),
                    ),
                    FormCustom(
                      text: 'Keterangan',
                      controller: keteranganController,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                width: double.infinity,
                padding: EdgeInsets.all(3),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Warna.hijau2,
                    padding: EdgeInsets.symmetric(vertical: 20),
                  ),
                  child: Text("Kirim"),
                  onPressed: () {
                    sendData();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
