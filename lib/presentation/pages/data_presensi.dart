import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_application_1/presentation/pages/home.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_application_1/Utils/Utils.dart';
// import 'package:month_picker_dialog/month_picker_dialog.dart';

import '../resources/warna.dart';
import '../widgets/ItemPresensi.dart';
import 'package:image_picker/image_picker.dart';

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
  Map<String, dynamic> gaji = {
    "gaji": 0,
    "lembur": 0,
    "bonus": 0,
    "keterlambatan": 0,
    "total": 0,
    "nama": "",
  };

  Future<void> _selectPeriod(BuildContext context) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser!.uid;

    QuerySnapshot<Map<String, dynamic>> object = await firestore
        .collection("users")
        .doc(uid)
        .collection('present')
        .get();

    log("okokk = $object");

    List<Map<String, dynamic>> objectList =
        object.docs.map((e) => e.data()).toList();

    log("List nya = $objectList");

    final selected = await showDatePicker(
            context: context,
            initialDate: selectedPeriod,
            firstDate: DateTime(2000),
            lastDate: DateTime(2025))
        .then((selected) {
      if (selected != null && selected != selectedPeriod) {
        setState(() {
          String selectedMonth =
              DateFormat().add_MMM().format(selected).replaceAll("/", "-");
          log("$selected");

          List<Map<String, dynamic>> absen = [];

          objectList.forEach((e) {
            DateTime waktu = DateTime.parse(e['date'].toString());

            String userMonth =
                DateFormat().add_MMM().format(waktu).replaceAll("/", "-");

            if (userMonth == selectedMonth) {
              absen.add(e);
            }
          });

          selectedPeriod = selected;
          gaji['gaji'] = 0;
          gaji['lembur'] = 0;
          gaji['keterlambatan'] = 0;
          gaji['nama'] = "";

          absen.forEach((e) {
            gaji['gaji'] = gaji['gaji'] + e['gajiDay'];
            gaji['lembur'] = gaji['lembur'] + e['waktuLembur'];
            gaji['keterlambatan'] = gaji['keterlambatan'] + e['late'];
            gaji['nama'] = e['nama'];
          });
        });
      }
    });
    log(gaji['nama']);
  }

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

    final collectionReference = FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("present");

    collectionReference.orderBy("date").get().then((QuerySnapshot snapshot) {
      snapshot.docs.forEach((DocumentSnapshot document) {});
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
            // .where("bulan", isEqualTo: tgl)
            .snapshots(),
        builder: (context, snapPresence) {
          if (snapPresence.hasData) {
            return Column(
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: streamUser(),
                  builder: ((context, snapPresent) {
                    return ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: 1,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> data =
                            snapPresence.data!.docs[index].data();

                        return Container(
                          width: double.infinity,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 250,
                                child: home(),
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
                                  text2: 'Rp. ${gaji['gaji']}'),
                              ItemPresensi(
                                text1: 'Lembur',
                                text2: 'Rp. ${gaji['lembur'] * 40000}',
                              ),
                              ItemPresensi(
                                  text1: 'Bonus',
                                  text2: 'Rp. ${gaji['bonus']}'),
                              ItemPresensi(
                                  text1: 'Keterlambatan',
                                  text2:
                                      "Rp. ${gaji['keterlambatan'] * 100000}"),
                              ItemPresensi(
                                  text1: 'Gaji Bulan ini',
                                  text2:
                                      'Rp. ${gaji['gaji'] + gaji['lembur'] + gaji['bonus'] - gaji['keterlambatan']}'),
                            ],
                          ),
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

            //okok
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
