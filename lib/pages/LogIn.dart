import 'package:flutter/material.dart';
import 'package:foto_rally/Services/alert_service.dart';
import 'package:foto_rally/Services/auth_service.dart';
import 'package:foto_rally/Services/firestore_service.dart';
import 'package:foto_rally/Widgets/CustomButton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  final AlertService _alertService = AlertService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  DateFormat dateFormatter = DateFormat('dd/MM/yyyy');

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
        backgroundColor: Color(0xFF1A56DB),
      ),
      backgroundColor: Colors.grey[100],
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestoreService.getRallyRules(),
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
          
          final  startDate = (data['startDate'] as Timestamp?)?.toDate() != null
              ? dateFormatter.format((data['startDate'] as Timestamp).toDate())
              : null;

          final  endDate = (data['endDate'] as Timestamp?)?.toDate() != null
              ? dateFormatter.format((data['endDate'] as Timestamp).toDate())
              : null;
          final photoLimit = data['photoLimit'] as int?;
          final voteLimit = data['voteLimit'] as int?;
          final isRallyActive = data['isRallyActive'] as bool?;
          final allowedCategories = data['allowedCategories'] as List<dynamic>?;
          final theme = data['theme'] as String?;
          final timeFrame = data['timeFrame'] as String?;

          // Construir la lista de reglas
          final List<String> rulesList = [];
          if (allowedCategories != null && allowedCategories.isNotEmpty) {
            final categoriesString = allowedCategories.join(', ');
            rulesList.add('Categorías permitidas: $categoriesString');
          }
          if (startDate != null) {
            rulesList.add('Fecha de inicio: ${startDate.toString().split(' ')[0]}');
          }
          if (endDate != null) {
            rulesList.add('Fecha de fin: ${endDate.toString().split(' ')[0]}');
          }
          if (photoLimit != null) {
            rulesList.add('Límite de fotos por participante: $photoLimit');
          }
          if (voteLimit != null) {
            rulesList.add('Límite de votos por participante: $voteLimit');
          }
          if (isRallyActive != null) {
            rulesList.add('Estado del rally: ${isRallyActive ? 'Activo' : 'Inactivo'}');
          }
          if (theme != null && theme.isNotEmpty) {
            rulesList.add('Tema del rally: $theme');
          }
          if (timeFrame != null && timeFrame.isNotEmpty) {
            rulesList.add('Marco temporal: $timeFrame');
          }

          // Si no hay reglas para mostrar, mostramos un mensaje por defecto
          if (rulesList.isEmpty) {
            rulesList.add('No hay reglas definidas para este rally.');
          }

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
                      SizedBox(height: 30.0),

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
                            children: rulesList.map((rule) {
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
                SizedBox(height: 50.0),
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
        _alertService.error(context, "Error al iniciar sesión: Usuario no encontrado.");
        break;
      case 'Participante_Activo':
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 'Participante_Pendiente':
        _alertService.error(context, "Usuario pendiente de aprobación.");
        break;
      case 'Participante_Inactivo':
        _alertService.error(context, "Usuario Inactivo.");
        break;
      case 'Admin_Activo':
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 'Usuario no encontrado en Participantes ni Administradores.':
        _alertService.error(context, "Correo o contraseña incorrecta.");
        break;
      case 'Error inesperado.':
       _alertService.error(context, "Error al iniciar sesion.");
        break;
      default:
        _alertService.error(context, "Error al iniciar sesión: $mensaje");
        break;
    }
  }
}
