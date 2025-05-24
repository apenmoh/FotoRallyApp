import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foto_rally/Services/auth_service.dart';
import 'package:foto_rally/Services/user_service.dart';
import 'package:foto_rally/Widgets/Admin/Admin_TabNav.dart';
import 'package:foto_rally/Widgets/ParticipantTabNav.dart';

class Home_Admin extends StatefulWidget {
  const Home_Admin({super.key});

  @override
  State<Home_Admin> createState() => _Home_AdminState();
}

class _Home_AdminState extends State<Home_Admin> {
  final AuthService authService = AuthService();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Admin'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              logut();
            },
          ),
        ],
        backgroundColor: Color(0xFF1A56DB),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text(
              "¿Qué te gustaría hacer?",
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(
                    "https://images.unsplash.com/photo-1542038784456-1ea8e935640e?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8Zm90b2dyYWYlQzMlQURhfGVufDB8fDB8fHww",
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              margin: EdgeInsets.all(17),
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Color(0xFF1A56DB),
              ),
              child: Column(
                children: [
                  Opcion(
                    icon: Icons.person_add_alt_1,
                    text: "Dar de alta",
                    onPressed: () {
                      Navigator.pushNamed(context, '/alta');
                    },
                  ),
                  Divider(color: Colors.white70),
                  Opcion(
                    icon: Icons.person_off_rounded,
                    text: "Dar de baja",
                    onPressed: () {
                      Navigator.pushNamed(context, '/baja');
                    },
                  ),
                  Divider(color: Colors.white70),
                  Opcion(
                    icon: Icons.photo,
                    text: "Ver Galería",
                    onPressed: () {
                      Navigator.pushNamed(context, '/galeria');
                    },
                  ),
                  Divider(color: Colors.white70),
                  Opcion(
                    icon: Icons.done,
                    text: "Validar fotos",
                    onPressed: () {
                      Navigator.pushNamed(context, '/validate');
                    },
                  ),
                  Divider(color: Colors.white70),
                  Opcion(
                    icon: Icons.leaderboard,
                    text: "Ver Estadística",
                    onPressed: () {},
                  ),
                  Divider(color: Colors.white70),
                  Opcion(
                    icon: Icons.settings_applications_sharp,
                    text: "Configuración",
                    onPressed: () { Navigator.pushNamed(context, '/configuracion');},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AdminTabNav(),
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

class Opcion extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  const Opcion({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 30),
            SizedBox(width: 15),
            Text(
              text,
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
