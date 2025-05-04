import 'package:flutter/material.dart';
import 'package:foto_rally/Services/auth_service.dart';
import 'package:foto_rally/Services/user_service.dart';
import 'package:foto_rally/Widgets/CustomButton.dart';
import 'package:foto_rally/Widgets/ParticipantTabNav.dart';

class Perfil extends StatefulWidget {
  const Perfil({super.key});

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  AuthService authService = AuthService();
  UserService userService = UserService();
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
      print('Error obteniendo userData: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar los datos: $e'),
          duration: Duration(seconds: 2),
        ),
      );
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
        title: const Text('Perfil'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              logut();
            },
          ),
        ],
      ),
      bottomNavigationBar: ParticipantTabNav(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              CustomButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/galeria');
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
      await userService.updateUser(userId, userData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Datos guardados correctamente'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al guardar los datos'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void solicitarBaja() async {
    try {
      await userService.updateUserBaja(userId, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitud de baja enviada'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al enviar la solicitud de baja'),
          duration: Duration(seconds: 2),
        ),
      );
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
    Navigator.pushNamed(context, '/login');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sesión cerrada'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
