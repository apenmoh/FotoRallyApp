import 'package:flutter/material.dart';

class ValidarFotos extends StatelessWidget {
  const ValidarFotos({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar:  AppBar(
        title: Text('Home Admin'),
        centerTitle: true,
        backgroundColor: Color(0xFF1A56DB),
      ),
      body: Text("Hola ValidarFotos"),
    );
  }
}