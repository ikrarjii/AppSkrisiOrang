import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/presentation/pages/Tmbh_Izin.dart';
import 'package:flutter_application_1/Utils/Utils.dart';
import 'package:intl/intl.dart';
import '../widgets/formcuxtom.dart';
import 'package:flutter_application_1/presentation/pages/login.dart';
import 'package:flutter_application_1/presentation/resources/warna.dart';

import '../resources/gambar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

class Profil extends StatefulWidget {
  const Profil({Key? key}) : super(key: key);

  @override
  State<Profil> createState() => _profilState();
}

class _profilState extends State<Profil> {
  bool isSelected = false;
  File? image;

  // var _nama = "";
  // var _email = "";
  // var _alamat = "";
  // var _noHp = "";
  // var _noRek = "";

  final _nama = TextEditingController();
  final _email = TextEditingController();
  final _alamat = TextEditingController();
  final _noHp = TextEditingController();
  final _noRek = TextEditingController();

  // void dispose() {
  //   _nama.dispose();

  //   super.dispose();
  // }

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
      var snapshot = await FirebaseStorage.instance
          .ref()
          .child("images")
          .child('${DateTime.now()}-bukti.jpg')
          .putFile(image!);
      var downloadUrl = await snapshot.ref.getDownloadURL();

      final doc = FirebaseFirestore.instance.collection("profil");
      final json = {
        "image": downloadUrl,
      };

      await doc.add(json);

      setState(() {
        image = null;
      });
      Navigator.of(context, rootNavigator: true).pop('dialog');
    } on FirebaseAuthException catch (e) {
      Navigator.of(context, rootNavigator: true).pop('dialog');
      Utils.showSnackBar(e.message, Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Warna.hijau2,
        actions: [
          Container(
            margin: EdgeInsets.all(13),
            padding: EdgeInsets.symmetric(horizontal: 139),
            child: Text(
              "Profil",
              style: TextStyle(
                color: Warna.putih,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.only(bottom: 5),
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
                      TextEditingController controller =
                          TextEditingController();
                      DocumentSnapshot data = snapshot.data!.docs[index];

                      return ItemCard(
                          uid: data.id,
                          nama: data['nama'],
                          email: data['email'],
                          alamat: data['alamat'],
                          no_hp: data['no_hp'],
                          no_rekening: data['no_rekening']);
                    },
                  );
          },
        ),
      ),
    );
  } // SizedBox(

  Container ItemCard(
      {String? uid,
      String? nama,
      String? email,
      String? alamat,
      String? no_hp,
      String? no_rekening}) {
    return Container(
      padding: EdgeInsets.only(right: 6, left: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Nama",
            style: TextStyle(
              fontSize: 15,
              color: Warna.htam,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          FormCustom(
            text: nama ?? "",
            controller: _nama,
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            "Email",
            style: TextStyle(
              fontSize: 15,
              color: Warna.htam,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          FormCustom(
            text: email ?? "",
            controller: _email,
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            "Alamat",
            style: TextStyle(
              fontSize: 15,
              color: Warna.htam,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          FormCustom(
            text: alamat ?? "",
            controller: _alamat,
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            "No Hp",
            style: TextStyle(
              fontSize: 15,
              color: Warna.htam,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          FormCustom(
            text: no_hp ?? "",
            controller: _noHp,
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            "No Rekening",
            style: TextStyle(
              fontSize: 15,
              color: Warna.htam,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          FormCustom(
            text: no_rekening ?? "",
            controller: _noRek,
          ),
          SizedBox(
            height: 5,
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            width: double.infinity,
            padding: EdgeInsets.all(10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Warna.hijau2,
                padding: EdgeInsets.symmetric(vertical: 17),
              ),
              child: Text("Update"),
              onPressed: () {
                DateTime now = DateTime.now();
                String todayDocID =
                    DateFormat().add_yMd().format(now).replaceAll("/", "-");
                FirebaseFirestore firestore = FirebaseFirestore.instance;
                firestore.collection("users").doc(uid).update({
                  'nama': _nama.text,
                  'Email': _email.text,
                  'Alamat': _alamat.text,
                  'no_hp': _noHp.text,
                  'no_rekening': _noRek.text,
                });
              },
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            width: double.infinity,
            padding: EdgeInsets.all(10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Warna.mrah,
                padding: EdgeInsets.symmetric(vertical: 17),
              ),
              child: Text("Logout"),
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => Login()));
                Utils.showSnackBar("Berhasil Logout.", Colors.red);
              },
            ),
          )
        ],
      ),
    );
  }
}
