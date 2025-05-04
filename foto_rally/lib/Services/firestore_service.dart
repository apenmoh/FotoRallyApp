import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener reglas del rally
  Future<DocumentSnapshot> getRallyRules() async {
    try {
      return await _firestore
          .collection('Configuracion')
          .doc('rallyRules')
          .get();
    } catch (e) {
      throw Exception('Error al obtener las reglas: $e');
    }
  }

  Future<List<String>> getRallyCategories() async {
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('Configuracion').doc('rallyRules').get();
      if (snapshot.exists) {
        List<String> categories = List<String>.from(
          snapshot['allowedCategories'],
        );
        return categories;
      } else {
        throw Exception('No se encontraron categorías en la base de datos.');
      }
    } catch (e) {
      throw Exception('Error al obtener las categorías: $e');
    }
  }
}
