import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:foto_rally/Services/auth_service.dart';
import 'package:foto_rally/Widgets/Admin/Aceptar_Alta.dart';
import 'package:foto_rally/Widgets/Admin/Aceptar_Baja.dart';
import 'package:foto_rally/pages/Configuration.dart';
import 'package:foto_rally/pages/Galeria.dart';
import 'package:foto_rally/pages/Galeria_Participante.dart';
import 'package:foto_rally/pages/Home.dart';
import 'package:foto_rally/pages/LogIn.dart';
import 'package:foto_rally/pages/Perfil.dart';
import 'package:foto_rally/pages/SignUp.dart';
import 'package:foto_rally/pages/SubirFoto.dart';
import 'package:foto_rally/pages/ValidatePhoto.dart';
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
    setState(() {
      isLoading = true;
    });
    verificarSesion();
  }

  Future<void> verificarSesion() async {
    var i = await authService.userLoogedIn();
    setState(() {
      iniciado = i;
      isLoading = false;
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
            '/subir_foto': (context) => SubirFoto(),
            '/perfil': (context) => Perfil(),
            '/validate': (context) => ValidatePhoto(),
            '/configuracion': (context) => Configuration(), 
            '/galeria_participante': (context) => GaleriaParticipante(),
          },
        );
  }
}
