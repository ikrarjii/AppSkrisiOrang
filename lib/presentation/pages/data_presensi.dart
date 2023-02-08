import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/presentation/pages/Profil.dart';
import 'package:flutter_application_1/presentation/pages/home.dart';
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

import 'my_page.dart';
// import 'package:month_year_picker/month_year_picker.dart';

class DataPresensi extends StatefulWidget {
  DataPresensi({Key? key}) : super(key: key);

  @override
  State<DataPresensi> createState() => _DataPresensiState();
}

class _DataPresensiState extends State<DataPresensi> {
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

  Stream<QuerySnapshot<Map<String, dynamic>>> streamUser() async* {
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser!.uid;
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // var tgl = DateFormat('yMMMM').format(selectedPeriod);

    // yield* firestore
    //     .collection("users")
    //     .doc(uid)
    //     .collection("present")
    //     .where("bulan", isEqualTo: tgl)
    //     .snapshots();
    final collectionReference = FirebaseFirestore.instance.collection("users").doc(uid).collection("present");

collectionReference.orderBy("date").get().then((QuerySnapshot snapshot) {
  snapshot.docs.forEach((DocumentSnapshot document) {
    print("ffffffffffff ${document}");
  });
});


  }
 


  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser!.uid;
    var tgl = DateFormat('yMMMM').format(selectedPeriod);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: firestore
            .collection("users")
            .doc(uid)
            .collection("present")
            .where("bulan", isEqualTo: tgl)
            .snapshots(),
        builder: (context, snapPresence) {
          if (snapPresence.hasData) {
            return
                // scrollDirection: Axis.vertical,
                Column(
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: streamUser(),
                  builder: ((context, snapPresent) {
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
                          width: double.infinity,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 250,
                                child: Container(
                                  child: home(),
                                ),
                              ),
                              Container(
                                // margin: EdgeInsets.only(top: 10),
                                // margin: EdgeInsets.symmetric(horizontal: 30),
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      DateFormat('yMMMM')
                                          .format(selectedPeriod),
                                      style: TextStyle(
                                          color: Warna.hijau2,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    IconButton(
                                        icon: Icon(Icons.keyboard_arrow_down),
                                        color: Warna.hijau2,
                                        onPressed: () {
                                          _selectPeriod(context);
                                          show = true;
                                        }),
                                  ],
                                ),
                              ),
                              ItemPresensi(
                                text1: 'Gaji Pokok',
                                text2: '0 Hari',
                              ),
                              ItemPresensi(
                                text1: 'Lembur',
                                text2: '0 Hari',
                              ),
                              ItemPresensi(
                                text1: 'Bonus',
                                text2: '0 kali',
                              ),
                              ItemPresensi(
                                text1: 'Keterlambatan',
                                text2: '0 Hari',
                              ),
                              ItemPresensi(
                                text1: 'Gaji Bulan ini',
                                text2: 'Rp.0',
                              ),
                            ],
                          ),
                        )

                            //lll
                            );
                        //btasss
                      },
                    );

                    //plplp
                  }),
                )

                // batsss ko
              ],
            );
          } else {
            return Expanded(
                child: Center(
              child: CircularProgressIndicator(),
            ));
          }

          //Builderrr
        });
  }
}
