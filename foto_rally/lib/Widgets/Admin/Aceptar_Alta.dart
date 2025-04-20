import 'dart:math';

import 'package:flutter/material.dart';
import 'package:foto_rally/Services/firestore_service.dart';
import 'package:foto_rally/Services/user_service.dart';
import 'package:foto_rally/Widgets/CustomButton.dart';
import 'package:foto_rally/Widgets/UsuariosCard.dart';

class Alta extends StatefulWidget {
  const Alta({super.key});

  @override
  State<Alta> createState() => _AltaState();
}

class _AltaState extends State<Alta> {
  UserService userService = UserService();
  late Future<List> usuariosPendientes;

  @override
  void initState() {
    super.initState();
    usuariosPendientes =
        userService
            .getUsuariosPendientes(); // Llama al método para obtener los usuarios pendientes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dar de Alta'),
        centerTitle: true,
        backgroundColor: Color(0xFF1A56DB),
      ),
      body: Builder(usuariosPendientes: usuariosPendientes),
    );
  }
}

class Builder extends StatelessWidget {
  const Builder({super.key, required this.usuariosPendientes});

  final Future<List> usuariosPendientes;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List>(
      future: usuariosPendientes,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // Muestra un mensaje de error si ocurre un problema
          return Center(
            child: Text('Error al obtener los datos: ${snapshot.error}'),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // Muestra un mensaje si no hay usuarios pendientes
          return Center(child: Text('No hay usuarios pendientes.'));
        } else {
          // Muestra los datos cuando están disponibles
          final usuarios = snapshot.data!;
          return Lista(usuarios: usuarios);
        }
      },
    );
  }
}

class Lista extends StatelessWidget {
  const Lista({super.key, required this.usuarios});

  final List usuarios;

  @override
  Widget build(BuildContext context) {
    return UsuariosCard(usuarios: usuarios,baja: false,);
  }
}
