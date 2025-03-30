import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foto_rally/Services/firestore_service.dart';

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

      // Verificar si es Participante
      final participantDoc =
          await _firestore.collection('Participantes').doc(userId).get();
      if (participantDoc.exists) {
        final participantData = participantDoc.data() as Map<String, dynamic>;
        final status = participantData['status'] as String;

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
      FirestoreService db = FirestoreService();
      Map<String, dynamic> userData = {
        "nombre": nombre,
        "email": email,
        "localidad": localidad,
        "userId": userCredential.user?.uid,
        "status": "activo",
        "createdAt": DateTime.now(),
      };
      db.saveUser(userCredential.user!.uid, userData);
      await _firestore
          .collection("Participantes")
          .doc(userCredential.user?.uid)
          .set({
            "nombre": nombre,
            "email": email,
            "localidad": localidad,
            "userId": userCredential.user?.uid,
            "status": "pendiente",
            "createdAt": DateTime.now(),
          });

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
