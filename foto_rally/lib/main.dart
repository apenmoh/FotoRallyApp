import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:foto_rally/Widgets/Admin/Aceptar_Alta.dart';
import 'package:foto_rally/Widgets/Admin/Aceptar_Baja.dart';
import 'package:foto_rally/Widgets/Admin/Validar_Fotos.dart';
import 'package:foto_rally/pages/Galeria.dart';
import 'package:foto_rally/pages/Home.dart';
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
        '/home': (context) => Home(),
        '/alta': (context) => Alta(),
        '/baja': (context) => Baja(),
        '/validar': (context) => ValidarFotos(),
      },
    );
  }
}
