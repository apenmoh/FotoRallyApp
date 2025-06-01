import 'package:flutter/material.dart';
import 'package:foto_rally/Services/alert_service.dart';
import 'package:foto_rally/Services/auth_service.dart';
import 'package:foto_rally/Services/user_service.dart';
import 'package:foto_rally/Widgets/CustomButton.dart';
import 'package:foto_rally/Widgets/TabNavigation.dart';

class Perfil extends StatefulWidget {
  const Perfil({super.key});

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  AuthService authService = AuthService();
  UserService userService = UserService();
  AlertService alertService = AlertService();
  late String userId = '';
  late Map<String, dynamic> userData = {};
  bool isLoading = true;
  int _currentIndex = 0; // Índice de la pestaña seleccionada

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  getData() async {
    try {
      userId = await userService.getUserId();
      if (userId.isEmpty) {
        throw Exception('El ID de usuario está vacío');
      }
      print('UserId: $userId');
      final value = await userService.getUserById(userId);
      if (value == null) {
        throw Exception('No se encontraron datos para el usuario');
      }
      setState(() {
        isLoading = false;
        userData = value;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      alertService.error(context, "Error al cargar los datos: $e");
    }
    print('UserData: $userData');
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil',style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Color(0xFF1A56DB),
        actions: [
          IconButton(
            icon:  Icon(Icons.logout,color: Colors.white,),
            onPressed: () {
              logut();
            },
          ),
        ],
      ),
      bottomNavigationBar: Tabnavigation(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              CustomButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/galeria_participante');
                },
                text: "Ver Mis Fotos",
                backgroundColor: Color(0xFF047857),
                textColor: Colors.white,
                width: 200,
                height: 70.0,
                borderRadius: 10.0,
              ),
              const SizedBox(height: 20),
              Container(
                height: 697,
                padding: const EdgeInsets.all(16),
                color: Color(0xFF1A56DB),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildField('Nombre', userData['nombre']),
                    buildField('Email', userData['email']),
                    buildField('Localidad', userData['localidad']),
                    Spacer(),
                    Center(
                      child: CustomButton(
                        onPressed: guardarDatos,
                        text: "Guardar Cambios",
                        backgroundColor: Color(0xFF047857),
                        textColor: Colors.white,
                        width: 300,
                        height: 40,
                        borderRadius: 20,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Center(
                      child: CustomButton(
                        onPressed: solicitarBaja,
                        text: "Solicitar Baja",
                        backgroundColor: Color(0xFFDC2626),
                        textColor: Colors.white,
                        width: 300,
                        height: 40,
                        borderRadius: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void guardarDatos() async {
    try {
      if(userData['nombre'] == null || userData['email'] == null || userData['localidad'] == null) {
        alertService.error(context, "Por favor, completa todos los campos antes de guardar.");
        return;
      }
      await userService.updateUser(userId, userData);
      alertService.success(context, "Datos guardados correctamente");
      final user = await userService.getUsuarioLogueado();
      if(user['email'] != userData['email']) {
        await authService.updateEmail(userData['email']);
        alertService.notify(context, "Cambios de correo deben ser confirmados en el correo electrónico.");
      }
    } catch (e) {
      alertService.error(context, "Error al guardar los datos: $e");
    }
  }

  void solicitarBaja() async {
    try {
      final confirm = await alertService.confirm(context, "Estas seguro de que quieres solicitar la baja? Esto eliminará tu cuenta y todas tus fotos.");
      if (!confirm) return;
      await userService.updateUserBaja(userId, true);
      alertService.success(context, "Solicitud de baja enviada");
    } catch (e) {
      alertService.error(context, "Error al enviar la solicitud de baja: $e");
    }
  }

  Widget buildField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: TextFormField(
                  initialValue: value,
                  onChanged: (newValue) {
                    setState(() {
                      userData[label.toLowerCase()] = newValue;
                    });
                  },
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),
      ],
    );
  }

  void logut() async {
    await authService.logout();
    Navigator.pushNamedAndRemoveUntil(context,'/login',(Route<dynamic> route) => false,);
    alertService.success(context,"Sesión cerrada correctamente");
  }
}
