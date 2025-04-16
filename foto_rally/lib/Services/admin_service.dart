import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foto_rally/Services/user_service.dart';

class AdminService {
  FirebaseFirestore db = FirebaseFirestore.instance;
  UserService userService = UserService();

  Future<void> aceptarParticipante(String uid) async {
    userService
        .updateUserStatus(uid, 'activo')
        .then((value) {
          print("Usuario Aceptado");
        })
        .catchError((error) => print("Error al aceptar usuario: $error"));
  }

  Future<void> rechazarParticipante(String uid) async {
    userService
        .updateUserStatus(uid, 'inactivo')
        .then((value) {
          print("Usuario Rechazado");
        })
        .catchError((error) => print("Error al rechazar usuario: $error"));
  }
}
