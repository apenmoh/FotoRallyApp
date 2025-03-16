import 'package:flutter/material.dart';
import 'package:foto_rally/Widgets/CustomButton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('No se encontraron reglas.'));
          }

          // Datos de Configuracion
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final startDate = (data['startDate'] as Timestamp).toDate();
          final endDate = (data['endDate'] as Timestamp).toDate();
          final voteLimit = data['voteLimit'];
          final rules = data['rules'] as List<dynamic>;

          return Column(
            children: [
              SizedBox(height: 30.0),
              Center(
                child: Text(
                  "Bienvenido al Rally de Fotos",
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 30.0),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "A continuación se muestran las normas y reglas del rally para este año:",
                      style: TextStyle(fontSize: 15.0),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
                      child: Text(
                        "1. Fecha Inicio/Fin: ${startDate.toLocal()} - ${endDate.toLocal()}.",
                        style: TextStyle(fontSize: 15.0),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(16.0, 5.5, 16.0, 0.0),
                      child: Text(
                        "2. Límite de votos totales por usuario: $voteLimit.",
                        style: TextStyle(fontSize: 15.0),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(16.0, 5.5, 16.0, 0.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "3. Reglas:",
                            style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ...rules
                              .map(
                                (rule) => Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    16.0,
                                    5.5,
                                    16.0,
                                    0.0,
                                  ),
                                  child: Text(
                                    "- $rule",
                                    style: TextStyle(fontSize: 15.0),
                                  ),
                                ),
                              )
                              .toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30.0),
              Center(
                child: Text(
                  "¿Quieres Ver las fotos y votar?",
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
              ),
              CustomButton(
                onPressed: () {},
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
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
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
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Contraseña',
                  ),
                ),
              ),
              CustomButton(
                onPressed: () {},
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
            ],
          );
        },
      ),
    );
  }
}
