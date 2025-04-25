import 'package:flutter/material.dart';
import 'package:foto_rally/Services/user_service.dart';
import 'package:foto_rally/Widgets/ParticipantTabNav.dart';

class Home_Participante extends StatefulWidget {
  const Home_Participante({super.key});

  @override
  State<Home_Participante> createState() => _Home_ParticipanteState();
}

class _Home_ParticipanteState extends State<Home_Participante> {
  UserService userService = UserService();
  Map<String, dynamic>? userData;
  bool isLoading = true;
  int _currentIndex = 0; // Índice de la pestaña seleccionada
  @override
  void initState() {
    super.initState();
    userService.getUsuarioLogueado().then((value) {
      setState(() {
        userData = value;
        isLoading = false;
      });
    }).catchError((e) {
      setState(() {
        isLoading = false;
      });
      print('Error obteniendo userData: $e');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (userData == null) {
      return Scaffold(
        body: Center(child: Text('No se pudieron cargar los datos del usuario.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        centerTitle: true,
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
                    "https://images.pexels.com/photos/31630209/pexels-photo-31630209/free-photo-of-camara-de-pelicula-vintage-en-la-hierba-fotografia-monocromatica.jpeg?auto=compress&cs=tinysrgb&w=600",
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
                    icon: Icons.camera_alt_rounded,
                    text: "Subir foto",
                    onPressed: () {
                      Navigator.pushNamed(context, '/alta');
                    },
                  ),
                  Divider(color: Colors.white70),
                  Opcion(
                    icon: Icons.leaderboard,
                    text: "Estadistica",
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
                    icon: Icons.person_off,
                    text: "Solicitar Baja",
                    onPressed: () {
                      Navigator.pushNamed(context, '/validar');
                    },
                  ),
                  Divider(color: Colors.white70),
                  Opcion(
                    icon: Icons.person_outline,
                    text: "Perfil",
                    onPressed: () {Navigator.pushNamed(context, '/perfil');},
                  ),
                  Divider(color: Colors.white70),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ParticipantTabNav(),
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
  