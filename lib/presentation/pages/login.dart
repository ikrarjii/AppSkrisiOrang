import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Utils/Utils.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/presentation/widgets/formcuxtom.dart';
import 'regis.dart';
import '../resources/warna.dart';
import 'package:platform_device_id/platform_device_id.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final emailController = TextEditingController();
  final passworController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 30),
                width: double.infinity,
                height: 100,
                child: Image.asset("assets/logo.png"),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Welcome",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 24,
                    color: Warna.abuTr,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      child: Text(
                        "Email",
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    FormCustom(
                      text: 'Email',
                      controller: emailController,
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      child: Text(
                        "Password",
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    FormCustom(
                      text: 'Password',
                      controller: passworController,
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 10),
                alignment: Alignment.centerRight,
                child: TextButton(
                  child: Text("Lupa Password ?"),
                  style: TextButton.styleFrom(primary: Warna.borderside),
                  onPressed: () {},
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Warna.hijau2,
                    padding: EdgeInsets.symmetric(vertical: 20),
                  ),
                  child: Text("Masuk"),
                  onPressed: () {
                    signIn();
                  },
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Tidak Punya Akun ?",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: Warna.noaccount),
                    ),
                    TextButton(
                      //untuk tombol kembali di lembur
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Regis()),
                        );
                      },
                      child: Text(
                        "Daftar",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Warna.hijau2,
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future signIn() async {
    final user = await FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: emailController.text.trim())
        .get();

    if (user.docs.length > 0) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(),
        ),
      );

      String? e = user.docs[0]["email"];
      String? id = user.docs[0]["device_id"];
      String? device_id = await PlatformDeviceId.getDeviceId;

      if (id != device_id) {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        Utils.showSnackBar(
            "Device yang digunakan untuk login tidak sama dengan device untuk register.",
            Colors.red);
      } else {
        try {
          final res = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passworController.text.trim(),
          );

          Utils.showSnackBar("Berhasil Login.", Colors.green);
          navigatorKey.currentState!.popUntil((route) => route.isFirst);
        } on FirebaseAuthException catch (e) {
          Navigator.of(context, rootNavigator: true).pop('dialog');
          Utils.showSnackBar(e.message, Colors.red);
        }
      }
    } else {
      // Navigator.of(context, rootNavigator: true).pop('dialog');
      Utils.showSnackBar("User tidak ditemukan.", Colors.red);
    }
  }
}
