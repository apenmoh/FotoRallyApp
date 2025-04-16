import 'package:flutter/material.dart';

class Baja extends StatelessWidget {
  const Baja({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar:  AppBar(
        title: Text('Home Admin'),
        centerTitle: true,
        backgroundColor: Color(0xFF1A56DB),
      ),
      body: Text("Hola Baja"),
    );
  }
}