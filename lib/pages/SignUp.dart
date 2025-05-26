import 'package:flutter/material.dart';
import 'package:foto_rally/Services/alert_service.dart';
import 'package:foto_rally/Widgets/CustomButton.dart';
import 'package:foto_rally/Services/auth_service.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final AuthService _authService = AuthService();
  final TextEditingController _nombre = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _localidad = TextEditingController();

  AlertService  alertService = AlertService();

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
                crossAxisAlignment: CrossAxisAlignment.center,
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
                _handleSignUp();
              },
              text: "Enviar Solicitud",
              backgroundColor: Color(0xFF047857),
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

  void _handleSignUp() async {
    if (_email.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _nombre.text.isEmpty ||
        _localidad.text.isEmpty) {
      alertService.error(context, "Por favor, complete todos los campos.");
      return;
    }

    try {
      final userCredential = await _authService.register(
        _email.text,
        _passwordController.text,
        _nombre.text,
        _localidad.text,
      );

      if (userCredential != null) {
        alertService.success(context, "Registro exitoso");

        // Limpiar campos
        _nombre.clear();
        _email.clear();
        _passwordController.clear();
        _localidad.clear();

        Navigator.pushNamed(context, "/login");
      }else{
        alertService.error(context, "Usuario existe con ese correo/contraseña Utiliza otra.");
      }
    } catch (e) {
      alertService.error(context, "Error al registrarse: $e");
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
