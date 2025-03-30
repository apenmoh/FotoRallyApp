import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener reglas del rally
  Future<String> getRallyRules() async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('Configuracion').doc('rallyRules').get();
      if (doc.exists) {
        return doc['rules'] as String;
      } else {
        return 'No hay reglas disponibles.';
      }
    } catch (e) {
      print('Error al obtener reglas: $e');
      return 'Error al obtener reglas.';
    }
  }

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
}
