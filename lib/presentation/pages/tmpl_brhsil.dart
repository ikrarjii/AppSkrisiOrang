import 'package:flutter/material.dart';
import '../resources/warna.dart';

class Berhasil extends StatefulWidget {
  const Berhasil({Key? key}) : super(key: key);

  @override
  State<Berhasil> createState() => _BerhasilState();
}

class _BerhasilState extends State<Berhasil> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              Icons.done,
              color: Warna.hijau2,
              size: 50.0,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Presensi Berhasil",
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 24,
                color: Warna.htam,
              ),
            ),
            SizedBox(
              height: 300,
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Warna.daftar,
                  padding: EdgeInsets.symmetric(vertical: 20),
                ),
                child: Text("Masuk"),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
