import 'package:doctorapp_version1/pages/home_page.dart';
import 'package:doctorapp_version1/pages/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'pages/welcome_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

// Firebase başlatılıyor
  await Firebase.initializeApp();

// Türkçe tarih biçimlendirme (intl paketi)
  await initializeDateFormatting('tr', null);

  runApp(DoctorApp());
}

class DoctorApp extends StatelessWidget {
  const DoctorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DoctorApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomePage(),
        '/signup': (context) => SignUpPage(),
        '/home': (context) =>  HomePage(),
      },
    );
  }
}