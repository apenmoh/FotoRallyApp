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
}
