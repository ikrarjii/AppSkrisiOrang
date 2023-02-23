// ignore_for_file: file_names, sort_child_properties_last, non_constant_identifier_names, unnecessary_brace_in_string_interps

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/presentation/pages/Tmbh_Izin.dart';
import 'package:intl/intl.dart';
import '../resources/warna.dart';

class Izin extends StatefulWidget {
  const Izin({Key? key}) : super(key: key);

  @override
  State<Izin> createState() => _IzinState();
}

class _IzinState extends State<Izin> {
  DateTime selectedPeriod = DateTime.now();
  bool show = false;

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

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Warna.hijau2,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 20),
            child: IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const TambhIzin()));
              },
              icon: const Icon(
                Icons.add,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
        ],
        title: Text(
          "Pengajuan Izin",
          style: TextStyle(
              fontSize: 18, color: Warna.putih, fontWeight: FontWeight.w700),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 20),
        // padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Title(
                      child: Text(
                        DateFormat('MMMM yyyy').format(selectedPeriod),
                        style: TextStyle(
                          color: Warna.hijau2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      color: Warna.hijau2),
                  IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down),
                      color: Warna.hijau2,
                      onPressed: () {
                        _selectPeriod(context);
                        show = true;
                      }),
                ],
              ),
            ),
            Flexible(
                child: Container(
              padding: const EdgeInsets.only(bottom: 25),
              child: StreamBuilder<QuerySnapshot>(
                stream: firestore
                    .collection("pengajuan")
                    .where("tipe_pengajuan", isEqualTo: "Izin")
                    .where("email", isEqualTo: user!.email)
                    .where("month",
                        isEqualTo: DateFormat("MMMM").format(selectedPeriod))
                    .snapshots(),
                builder: (context, snapshot) {
                  return !snapshot.hasData
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            DocumentSnapshot data = snapshot.data!.docs[index];
                            return ItemCard(
                                jenis: data['jenis'],
                                status: data['status'],
                                ket: data['keterangan'],
                                approve: data['status'],
                                created_at: DateFormat('EEEE dd MMMM yyyy')
                                    .format(data['created_at'].toDate())
                                    .toString(),
                                mulai: DateFormat('dd MMMM yyyy')
                                    .format(data['tanggal_mulai'].toDate())
                                    .toString(),
                                selesai: DateFormat('dd MMMM yyyy')
                                    .format(data['tanggal_selesai'].toDate())
                                    .toString());
                          },
                        );
                },
              ),
            )),
          ],
        ),
      ),
    );
  }

  Container ItemCard(
      {String? jenis,
      String? status,
      String? ket,
      String? approve,
      String? created_at,
      String? mulai,
      String? selesai}) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25), //border corner radius
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5), //color of shadow
            spreadRadius: 1, //spread radius
            blurRadius: 7, // blur radius
            offset: const Offset(0, 2),
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
              Text(
                "Pengajuan Lembur",
                style: TextStyle(
                    backgroundColor: Warna.hijau2,
                    fontSize: 15,
                    color: Warna.htam),
              ),
              const SizedBox(
                width: 30,
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  status == "0"
                      ? "Belum Disetujui"
                      : status == "1"
                          ? "Disetujui"
                          : "Ditolak",
                  style: TextStyle(
                    backgroundColor: status == "0"
                        ? Colors.amber
                        : status == "1"
                            ? Warna.hijau2
                            : Warna.mrah,
                    fontSize: 15,
                    color: Warna.htam,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              Text(
                created_at ?? "",
                style: TextStyle(
                  fontSize: 14,
                  color: Warna.htam,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          Row(
            children: [
              Icon(
                Icons.date_range,
                color: Warna.htam,
                size: 20.0,
              ),
              Text(
                '${mulai} - ${selesai}',
                style: TextStyle(
                  fontSize: 15,
                  color: Warna.abuabu,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 7,
          ),
          Row(
            children: [
              Text(
                jenis ?? "",
                style: TextStyle(
                  fontSize: 15,
                  color: Warna.htam,
                ),
              ),
              const SizedBox(
                width: 30,
              ),
              Text(
                ket ?? "",
                style: TextStyle(
                  fontSize: 15,
                  color: Warna.abuabu,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
