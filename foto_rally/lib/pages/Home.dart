import 'package:flutter/material.dart';
import 'package:foto_rally/Services/user_service.dart';
import 'package:foto_rally/Widgets/Admin/Home_Admin.dart';
import 'package:foto_rally/Widgets/Home_Participante.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final UserService userService = UserService();
  late Future<Map<String, Object>> userFuture;

  @override
  void initState() {
    super.initState();
    userFuture =
        userService.getUsuarioLogueado(); // Carga los datos del usuario
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, Object>>(
        future: userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Muestra un indicador de carga mientras se obtienen los datos
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Muestra un mensaje de error si ocurre un problema
            return Center(
              child: Text('Error al cargar los datos del usuario.'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Muestra un mensaje si no hay datos
            return Center(child: Text('No se encontraron datos del usuario.'));
          }

          // Los datos del usuario están disponibles
          final user = snapshot.data!;
          final bool isAdmin = user['isAdmin'] as bool;

          // Renderiza la vista correspondiente
          return isAdmin ? Home_Admin() : Home_Participante();
        },
      ),
    );
  }
}
