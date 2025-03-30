import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e.code));
    }
  }

  Future<UserCredential?> register(
      String email, String password, String nombre, String localidad) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Guardar datos en Firestore
      await _firestore.collection("Participantes").doc(userCredential.user?.uid).set({
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
