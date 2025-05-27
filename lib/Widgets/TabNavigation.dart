import 'package:flutter/material.dart';
import 'package:foto_rally/Services/user_service.dart';

class Tabnavigation extends StatefulWidget {
  Tabnavigation({super.key}); 
  @override
  State<Tabnavigation> createState() => _TabNavigation();  
}



class _TabNavigation extends State<Tabnavigation> {
  
  final UserService userService = UserService();
  late bool isAdmin = false;

  @override
  void initState()  {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    try {
      final user = await userService.getUsuarioLogueado();
      if (user.isNotEmpty) {
        setState(() {
          isAdmin = (user['isAdmin'] as bool?) ?? false;
        });
      } else {
        print("No se encontraron datos del usuario.");
      }

    } catch (e) {
      print("Error al obtener los datos del usuario: $e");
    }
  }
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
               isAdmin? Navigator.pushNamed(context, '/configuracion'): Navigator.pushNamed(context, '/perfil');
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
          if (isAdmin)
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: "Configuración",
            )
          else
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