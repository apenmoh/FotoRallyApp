import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foto_rally/Services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  // Guardar usuario registrado en Firestore
  Future<void> saveUser(String uid, Map<String, dynamic> userData) async {
    await _firestore.collection('Participantes').doc(uid).set(userData);
  }

  Future<List> getUsuarios() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('Participantes').get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error al obtener usuarios: $e');
      return [];
    }
  }

  Future<List> getUsuariosPendientes() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore
              .collection('Participantes')
              .where('status', isEqualTo: 'pendiente')
              .get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error al obtener usuarios pendientes: $e');
      return [];
    }
  }

  // Obtener Usuario por Id
  Future<Map<String, dynamic>> getUserById(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('Participantes').doc(uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        return {};
      }
    } catch (e) {
      print('Error al obtener usuario: $e');
      return {};
    }
  }

  Future<void> updateUserStatus(String uid, String status) async {
    try {
      await _firestore.collection('Participantes').doc(uid).update({
        'status': status,
      });
    } catch (e) {
      print('Error al actualizar el estado del usuario: $e');
    }
  }

  Future<Map<String, Object>> getUsuarioLogueado() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, Object> user = {
      'userId': prefs.getString('userId') ?? '',
      'email': prefs.getString('email') ?? '',
      'isAdmin': prefs.getBool('isAdmin') ?? false,
    };
    return user;
  }

  Future<String> getUserId() async {
    return await _authService.getUserId();
  }

  Future<List> getUsuariosBaja() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore
              .collection('Participantes')
              .where('baja', isEqualTo: true)
              .get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error al obtener usuarios pendientes: $e');
      return [];
    }
  }

  Future<void> updateUserBaja(String uid, bool baja) async {
    try {
      await _firestore.collection('Participantes').doc(uid).update({
        'baja': baja,
      });
    } catch (e) {
      print('Error al actualizar el estado del usuario: $e');
    }
  }

  Future<void> updateUser(String uid, Map<String, dynamic> userData) async {
    try {
      await _firestore.collection('Participantes').doc(uid).update(userData);
    } catch (e) {
      print('Error al actualizar el usuario: $e');
    }
  }
}
