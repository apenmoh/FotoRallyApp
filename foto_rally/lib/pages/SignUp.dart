import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foto_rally/Widgets/CustomButton.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _nombre = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _localidad = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Registrarse',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue[600],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 15),
            Center(
              child: Text(
                "Date de alta como participante en FotoRally",
                style: TextStyle(fontSize: 19, fontStyle: FontStyle.italic),
              ),
            ),
            SizedBox(height: 50),
            Container(
              height: 600,
              width: 350,
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.blue[800],
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Ensures content is centered
                children: [
                  SizedBox(height: 10),
                  TextForm(nombre: _nombre, value: "Nombre", password: false),
                  SizedBox(height: 30),
                  TextForm(nombre: _email, value: "Email", password: false),
                  SizedBox(height: 30),
                  TextForm(
                    nombre: _passwordController,
                    value: "Password",
                    password: true,
                  ),
                  SizedBox(height: 30),
                  TextForm(
                    nombre: _localidad,
                    value: "Localidad",
                    password: false,
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            CustomButton(
              onPressed: () {
                ManegarSolicitud();
              },
              text: "Enviar Solicitud",
              backgroundColor: Color(0xFF047857), // Updated color to #047857
              textColor: Colors.white,
              width: 350,
              height: 40,
              borderRadius: 10,
            ),
          ],
        ),
      ),
    );
  }

  void ManegarSolicitud() async {
    if (_email.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _nombre.text.isEmpty ||
        _localidad.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Todos los campos son obligatorios"),
          backgroundColor: Colors.red,
        ),
      );
      return; // Salir del método si los campos están vacíos
    }

    try {
      
      // Intentar iniciar sesión con el correo y la contraseña
      await _auth.signInWithEmailAndPassword(
        email: _email.text,
        password: _passwordController.text,
      );

      // Si el inicio de sesión es exitoso, el usuario ya existe
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("El usuario ya existe"),
          backgroundColor: Colors.orange,
        ),
      );
      return; // Salir del método si el usuario ya existe
      
   } catch (e) {
        // Continuar con el registro del usuario
        try {
          UserCredential userCredential =
              await _auth.createUserWithEmailAndPassword(
            email: _email.text,
            password: _passwordController.text,
          );

          final data = {
            "nombre": _nombre.text,
            "email": _email.text,
            "localidad": _localidad.text,
            "userId": userCredential.user?.uid, // Guardar el UID del usuario
            "status": "pendiente",
            "createdAt": DateTime.now(),
          };

          await _firestore.collection("Participantes").doc(userCredential.user?.uid).set(data);

          // Mostrar un mensaje de éxito
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Solicitud enviada correctamente. Espere a que su solicitud se procese.",
              ),
              backgroundColor: Colors.green,
            ),
          );

          // Limpiar los campos después de registrar
          _nombre.clear();
          _email.clear();
          _passwordController.clear();
          _localidad.clear();

          Navigator.pushNamed(context, "/login");
        } catch (e) {
          // Manejar errores durante el registro
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error al registrar: ${e.toString()}"),
              backgroundColor: Colors.red,
            ),
          );
        }
   }
  }
}

class TextForm extends StatelessWidget {
  const TextForm({
    super.key,
    required TextEditingController nombre,
    required String value,
    required bool password,
  }) : _nombre = nombre,
       _value = value,
       _password = password;

  final TextEditingController _nombre;
  final String _value;
  final bool _password;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_value, style: TextStyle(fontSize: 20)),
          SizedBox(height: 7),
          TextFormField(
            controller: _nombre,
            obscureText: _password,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.white,
              labelText: _value,
              labelStyle: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
