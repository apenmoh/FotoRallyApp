import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foto_rally/Services/user_service.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserService userService = UserService();

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

  // Guardar metadatos de la foto en Firestore
  Future<void> addPhoto(Map<String, dynamic> photoData) async {
    try {
      // Verificar si el usuario tiene fotos subidas
      // y si no ha alcanzado el límite de fotos permitidas
      String id = await userService.getUserId();
      final rules = await getRallyRules();
      int numFotos = await userService.getUserPhotoCount(id);

      if (numFotos <= rules['photoLimit']) {
        final doc = await _firestore.collection('Fotos').doc();

        photoData['photoId'] = doc.id;

        await doc.set(photoData);

        // Actualizar el contador de fotos del usuario
        await userService.incrementUserPhotoCount(id);
      } else {
        throw Exception(
          'El usuario ha alcanzado el límite de fotos permitidas.',
        );
      }
    } catch (e) {
      throw Exception('Error al guardar la foto: $e');
    }
  }

  // Obtener fotos de un usuario específico
  Future<List<Map<String, dynamic>>> getUserPhotos(String userId) async {
    try {
      QuerySnapshot snapshot =
          await _firestore
              .collection('photos')
              .where('userId', isEqualTo: userId)
              .get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw Exception('Error al obtener las fotos del usuario: $e');
    }
  }

  // Update status of a photo
  Future<void> updatePhotoStatus(String photoId, String status) async {
    try {
      await _firestore.collection('Fotos').doc(photoId).update({
        'status': status,
      });
    } catch (e) {
      throw Exception('Error al actualizar el estado de la foto: $e');
    }
  }

  // Obtener todas las fotos
  Future<List<Map<String, dynamic>>> getAllPhotos() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('Fotos').get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw Exception('Error al obtener todas las fotos: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getPendingPhotos() async {
    try {
      final snapshot =
          await _firestore
              .collection('Fotos')
              .where('status', isEqualTo: 'pendiente')
              .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['photoId'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener las fotos pendientes: $e');
    }
  }
}
