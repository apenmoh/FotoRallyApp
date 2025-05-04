import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:foto_rally/Services/auth_service.dart';
import 'package:foto_rally/Widgets/Admin/Aceptar_Alta.dart';
import 'package:foto_rally/Widgets/Admin/Aceptar_Baja.dart';
import 'package:foto_rally/Widgets/Admin/Validar_Fotos.dart';
import 'package:foto_rally/pages/Galeria.dart';
import 'package:foto_rally/pages/Home.dart';
import 'package:foto_rally/pages/LogIn.dart';
import 'package:foto_rally/pages/Perfil.dart';
import 'package:foto_rally/pages/SignUp.dart';
import 'package:foto_rally/pages/SubirFoto.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AuthService authService = AuthService();
  bool iniciado = true;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    isLoading = true;
    verificarSesion();
    isLoading = false;
  }

  Future<void> verificarSesion() async {
    var i = await authService.userLoogedIn();
    setState(() {
      iniciado = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : MaterialApp(
          initialRoute: iniciado ? '/home' : '/login',
          routes: {
            '/galeria': (context) => Galeria(),
            '/login': (context) => Login(),
            '/signup': (context) => SignUp(),
            '/home': (context) => Home(),
            '/alta': (context) => Alta(),
            '/baja': (context) => Baja(),
            '/validar': (context) => ValidarFotos(),
            '/subir_foto': (context) => SubirFoto(),
            '/perfil': (context) => Perfil(),
          },
        );
  }
}
