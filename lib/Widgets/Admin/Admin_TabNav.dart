import 'package:flutter/material.dart';

class AdminTabNav extends StatefulWidget {
  AdminTabNav({super.key}); 
  @override
  State<AdminTabNav> createState() => _AdminTabNav();
}

class _AdminTabNav extends State<AdminTabNav> {
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
              Navigator.pushNamed(context, '/configuracion');
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
            icon: Icon(Icons.settings),
            label: "Configuración",
          ),
        ],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        backgroundColor: Color(0xFF1A56DB),
      );
  }
}