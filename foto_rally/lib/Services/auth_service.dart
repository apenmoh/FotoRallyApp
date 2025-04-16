import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foto_rally/Services/firestore_service.dart';
import 'package:foto_rally/Services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      String userId = userCredential.user!.uid.toString();
      if (userId == null) {
        return "Usuraio No encontrado";
      }

      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // Verificar si es Participante
      final participantDoc =
          await _firestore.collection('Participantes').doc(userId).get();
      if (participantDoc.exists) {
        final participantData = participantDoc.data() as Map<String, dynamic>;
        final status = participantData['status'] as String;

        // Guardar datos en localStorage
        await prefs.setString('userId', userId);
        await prefs.setString('email', email);
        await prefs.setBool('isAdmin', false); // No es administrador

        print(prefs);

        if (status == 'activo') {
          return "Participante_Activo";
        } else if (status == 'pendiente') {
          return "Participante_Pendiente";
        } else {
          return "Participante_Inactivo";
        }
      }

      // Verificar si es Administrador
      final adminDoc =
          await _firestore.collection('Administradores').doc(userId).get();
      if (adminDoc.exists) {
        // Guardar datos en localStorage
        await prefs.setString('userId', userId);
        await prefs.setString('email', email);
        await prefs.setBool('isAdmin', true); // Es administrador

        return "Admin_Activo";
      }

      // Si no es ni participante ni administrador
      return 'Usuario no encontrado en Participantes ni Administradores.';
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e.code));
    }
  }

  Future<UserCredential?> register(
    String email,
    String password,
    String nombre,
    String localidad,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );

      // Guardar datos en Firestore
      UserService userService = UserService();
      Map<String, dynamic> userData = {
        "nombre": nombre,
        "email": email,
        "localidad": localidad,
        "userId": userCredential.user?.uid,
        "status": "activo",
        "createdAt": DateTime.now(),
      };
      await userService.saveUser(userCredential.user!.uid, userData);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e.code));
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  String _handleAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No existe un usuario con ese correo.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'email-already-in-use':
        return 'El correo ya está registrado.';
      case 'invalid-email':
        return 'El correo electrónico no es válido.';
      default:
        return 'Error inesperado.';
    }
  }
}
