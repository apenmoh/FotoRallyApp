import 'package:flutter/material.dart';
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
  final FirebaseAuth _auth = FirebaseAuth.instance;
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
                  backgroundColor: Colors.green[900]!,
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
                  onPressed: () {},
                  text: "Registrarme",
                  backgroundColor: Colors.black,
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
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final userId = userCredential.user?.uid;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al autenticar usuario.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }
      print('UID del usuario: $userId');

      // Verificar si es Participante
      final participantDoc =
          await _firestore.collection('Participantes').doc(userId).get();
      if (participantDoc.exists) {
        final participantData = participantDoc.data() as Map<String, dynamic>;
        final status = participantData['status'] as String;
        if (status == 'active') {
          Navigator.pushNamed(context, '/home-participante');
        } else {
          // Si no está activo (pending o inactive), puede entrar pero con acceso limitado
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                status == 'pending'
                    ? 'Tu cuenta está pendiente de aprobación. Solo puedes ver las fotos.'
                    : 'Tu cuenta está inactiva. Solo puedes ver las fotos.',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
          Navigator.pushNamed(context, '/home-participante');
        }
        return;
      }

      // Verificar si es Administrador

      final adminDoc =
          await _firestore.collection('Administradores').doc(userId).get();
      if (adminDoc.exists) {
        Navigator.pushNamed(context, '/home_admin');
        return;
      }

      // Si no es ni participante ni administrador
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Usuario no encontrado en Participantes ni Administradores.',
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    } on FirebaseAuthException catch (error) {
      String errorMessage;
      switch (error.code) {
        case 'user-not-found':
          errorMessage = 'No existe un usuario con ese correo.';
          break;
        case 'wrong-password':
          errorMessage = 'Contraseña incorrecta.';
          break;
        case 'invalid-email':
          errorMessage = 'El correo electrónico no es válido.';
          break;
        default:
          errorMessage = 'Error al iniciar sesión: ${error.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error inesperado: $error'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}
