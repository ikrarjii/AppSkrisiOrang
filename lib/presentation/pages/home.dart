import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/presentation/pages/Profil.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_application_1/Utils/Utils.dart';
// import 'package:month_picker_dialog/month_picker_dialog.dart';
import '../resources/gambar.dart';
import '../resources/warna.dart';
import '../widgets/ItemPresensi.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:month_year_picker/month_year_picker.dart';

class home extends StatefulWidget {
  home({Key? key}) : super(key: key);

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  DateTime selectedPeriod = DateTime.now();
  bool show = false;
  File? image;

  Future<DateTime> _selectPeriod(BuildContext context) async {
    final selected = await showDatePicker(
        context: context,
        initialDate: selectedPeriod,
        firstDate: DateTime(2000),
        lastDate: DateTime(2025));
    if (selected != null && selected != selectedPeriod) {
      setState(() {
        selectedPeriod = selected;
      });
    }
    return selectedPeriod;
  }

  Future<void> doSomeAsyncStuff() async {}

  Future pikcImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final imgTmp = File(image.path);
      setState(() => this.image = imgTmp);
    } on PlatformException catch (e) {
      print("failed pick image.");
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

      var snapshot = await FirebaseStorage.instance
          .ref()
          .child("images")
          .child('${DateTime.now()}-bukti.jpg')
          .putFile(image!);
      var downloadUrl = await snapshot.ref.getDownloadURL();

      // final doc = FirebaseFirestore.instance.collection("pengajuan");
      // final json = {
      //   "email": user!.email,
      //   // "created_at": DateTime.now(),
      //   // "jenis": dropDownValue,
      //   // "tanggal_mulai": selectedDate,
      //   // "tanggal_selesai": selectedDate1,
      //   // "keterangan": keteranganController.text.trim(),
      //   // "status": "0",
      //   "image": downloadUrl,
      //   // "month": DateFormat("MMMM").format(DateTime.now()),
      //   // "tipe_pengajuan": 'Izin',
      //   // "biaya": "-",
      //   // "tanggal": '-',
      //   // "nama": nama
      // };

      // await doc.add(json);

      // Utils.showSnackBar("Berhasil Tambah Izin.", Colors.green);
      // keteranganController.clear();
      // setState(() {

      //   image = null;

      // });
      Navigator.of(context, rootNavigator: true).pop('dialog');
      // navigatorKey.currentState!.pop();
    } on FirebaseAuthException catch (e) {
      Navigator.of(context, rootNavigator: true).pop('dialog');
      Utils.showSnackBar(e.message, Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;
    return Container(
      child: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection("users")
            .where("email", isEqualTo: user!.email)
            .snapshots(),
        builder: (context, snapshot) {
          return !snapshot.hasData
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot data = snapshot.data!.docs[index];
                    return ItemCard(nama: data['nama']);
                  },
                );
        },
      ),
    );
  }

  Container ItemCard({
    String? nama,
  }) {
    return Container(
      // color: Colors.amberAccent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: Image.asset(Gambar.home1),
                ),
                Container(
                  margin: EdgeInsets.only(top: 15),
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 129, vertical: 20),
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.white,
                        backgroundImage: AssetImage(Gambar.logouin),
                      ),
                      image != null
                          ? InkWell(
                              onTap: () {
                                pikcImage();
                              },
                              child: Image.file(
                                image!,
                                height: 150,
                                width: 150,
                                fit: BoxFit.cover,
                              ))
                          : Container(
                              padding: EdgeInsets.only(top: 50, left: 60),
                              child: IconButton(
                                  icon: Icon(Icons.add_a_photo),
                                  iconSize: 25,
                                  color: Warna.htam,
                                  onPressed: () {
                                    pikcImage();
                                  }),
                            ),
                      // Positioned(

                      //     bottom: 0,
                      //     right: 20,
                      //     child: InkWell(
                      //       child: Icon(Icons.camera_alt),
                      //       onTap: () {

                      //       },
                      //     )),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 115, left: 138),
                  //width: 150,
                  child: Column(
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Profil()));
                        },
                        child: Text(
                          nama ?? "",
                          style: TextStyle(
                            fontSize: 25,
                            color: Warna.putih,
                          ),
                        ),
                      ),
                      Text(
                        "Karyawan",
                        style: TextStyle(
                          fontSize: 18,
                          color: Warna.kuning,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
