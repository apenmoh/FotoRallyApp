import 'package:flutter/material.dart';

class ParticipantTabNav extends StatefulWidget {
  ParticipantTabNav({super.key}); 
  @override
  State<ParticipantTabNav> createState() => _ParticipantTabNavState();
}

class _ParticipantTabNavState extends State<ParticipantTabNav> {
  int currentIndex = 0; 
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
          switch (currentIndex) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/galeria');
              break;
            case 2:
              Navigator.pushNamed(context, '/perfil');
              break;
            default:
              Navigator.pushNamed(context, '/home');
              break;
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: "Galería",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Perfil",
          ),
        ],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        backgroundColor: Color(0xFF1A56DB),
      );
  }
}