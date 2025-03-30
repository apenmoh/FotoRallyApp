import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Alta extends StatefulWidget {
  const Alta({super.key});

  @override
  State<Alta> createState() => _AltaState();
}

class _AltaState extends State<Alta> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  late CollectionReference users;
  late Future<QuerySnapshot> snapshot;
  var userFields;


  @override
  void initState()  {
    // TODO: implement initState
    super.initState();
    users = db.collection('Participantes');
    fetchUserData();
  }
  Future<void> fetchUserData() async {
    try {
      snapshot = users.get();
      var data = await snapshot;
      userFields = data.docs.map((doc) => doc.data()).toList();
      print("Hola");
      print(userFields);
    } catch (e) {
      print("Error al obtener los datos: $e");
      rethrow; // Ensures the error is propagated
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dar de Alta'),
        centerTitle: true,
        backgroundColor: Color(0xFF1A56DB),
      ),
      body: Column(
        children: [
          Card(
            child: userFields != null
                ? Text('Datos del usuario: ${userFields.toString()}')
                : Text('Cargando datos...'),
          ),
        ],
      ),
    );
  }
}