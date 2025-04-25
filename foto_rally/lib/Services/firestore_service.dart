import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener reglas del rally
  Future<DocumentSnapshot> getRallyRules() async {
  try {
    return await _firestore.collection('Configuracion').doc('rallyRules').get();
  } catch (e) {
    throw Exception('Error al obtener las reglas: $e');
  }
  }

 
}
