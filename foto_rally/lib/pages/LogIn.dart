import 'package:flutter/material.dart';
import 'package:foto_rally/Services/auth_service.dart';
import 'package:foto_rally/Widgets/CustomButton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'FotoRally Login',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue[600],
      ),
      backgroundColor: Colors.grey[100],
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection('Configuracion').doc('rallyRules').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.blue[900]),
                  SizedBox(height: 10),
                  Text(
                    'Cargando reglas del rally...',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('No se encontraron reglas.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final rules = data['rules'] as String;

          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 30.0),
                Center(
                  child: Text(
                    "Bienvenido al Rally de Fotos",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 10.0),

                /// Sección de Reglas con Scroll
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "A continuación se muestran las normas y reglas del rally para este año:",
                        style: TextStyle(fontSize: 15.0),
                      ),
                      SizedBox(height: 10.0),

                      Container(
                        height: 170,
                        padding: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.white,
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:
                                rules.split(';').map((rule) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 5.0),
                                    child: Text(
                                      "• $rule",
                                      style: TextStyle(fontSize: 15.0),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30.0),
                Center(
                  child: Text(
                    "¿Quieres Ver las fotos y votar?",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                CustomButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/galeria');
                  },
                  text: "Ver Galería",
                  backgroundColor: Color(0xFF047857),
                  textColor: Colors.white,
                  width: 350,
                  height: 80,
                  borderRadius: 15.0,
                ),
                SizedBox(height: 30.0),
                Center(
                  child: Text(
                    "¿Quieres Participar?",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Correo Electrónico',
                      hintText: 'email@dominio.com',
                    ),
                    controller: _emailController,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Contraseña',
                    ),
                    controller: _passwordController,
                    obscureText: true,
                  ),
                ),
                CustomButton(
                  onPressed: () {
                    ValidarLogin(context);
                  },
                  text: "Iniciar Sesión",
                  backgroundColor: Colors.blue[900]!,
                  textColor: Colors.white,
                  width: 380,
                  height: 50,
                  borderRadius: 10.0,
                ),
                SizedBox(height: 10.0),
                CustomButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/signup");
                  },
                  text: "Registrarme",
                  backgroundColor: Color(0xFF111827),
                  textColor: Colors.white,
                  width: 380,
                  height: 50,
                  borderRadius: 10.0,
                ),
                SizedBox(height: 20.0),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> ValidarLogin(BuildContext context) async {
    final mensaje = await _authService.login(
      _emailController.text,
      _passwordController.text,
    );

    switch (mensaje) {
      case 'Usuraio No encontrado':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("ERROR DE INICIO SESION"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        break;
      case 'Participante_Activo':
        Navigator.pushReplacementNamed(context, '/home-participante');
        break;
      case 'Participante_Pendiente':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("USUARIO PENDIENTE DE DAR DE ALTA"),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        break;
      case 'Participante_Inactivo':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("USUARIO INACTIVO"),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        break;
      case 'Admin_Activo':
        Navigator.pushReplacementNamed(context, '/home_admin');
        break;
      case 'Usuario no encontrado en Participantes ni Administradores.':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Email o Password incorrectos"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
    }
  }
}
