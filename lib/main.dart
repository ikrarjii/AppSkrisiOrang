import 'package:flutter/material.dart';
import 'package:flutter_application_1/Utils/Utils.dart';

import 'package:flutter_application_1/presentation/pages/data_presensi.dart';
import 'package:flutter_application_1/presentation/pages/lembur.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:month_year_picker/month_year_picker.dart';
import 'presentation/pages/Check.dart';
import 'presentation/pages/Izin.dart';
import 'presentation/pages/lembur.dart';
import 'presentation/pages/scan.dart';
//import 'package:flutter_application_1/presentation/pages/Izin.dart';
//import 'package:flutter_application_1/presentation/pages/Scan.dart';
import 'package:flutter_application_1/presentation/pages/Tmbh_Izin.dart';
import 'package:flutter_application_1/presentation/pages/kasbon.dart';
import 'package:flutter_application_1/presentation/pages/login.dart';
import 'package:flutter_application_1/presentation/pages/my_page.dart';
import 'package:flutter_application_1/presentation/pages/regis.dart';
import 'package:flutter_application_1/presentation/pages/tmbh_Kasbon.dart';
import 'package:flutter_application_1/presentation/pages/login.dart';
import 'package:flutter_application_1/presentation/pages/tmpl_brhsil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: MainPage(),
        scaffoldMessengerKey: Utils.messengerKey,
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          GlobalWidgetsLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          // MonthYearPickerLocalizations.delegate,
        ]);
  }
}

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        body: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return MyPages();
              } else {
                return Login();
              }
            }),
      );
}
