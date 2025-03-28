import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:foto_rally/pages/Galeria.dart';
import 'package:foto_rally/pages/Admin/Home_Admin.dart';
import 'package:foto_rally/pages/Home_Participante.dart';
import 'package:foto_rally/pages/LogIn.dart';
import 'package:foto_rally/pages/SignUp.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/login',
      routes: {
        '/galeria': (context) => Galeria(),
        '/login': (context) => Login(),
        '/signup': (context) => SignUp(),
        '/home-participante': (context) => Home_Participante(),
        '/home_admin': (context) => Home_Admin(),
      },
    );
  }
}
