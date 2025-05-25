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

  Future<void> updateRallyRules(Map<String, dynamic> rules) async {
    try {
      await _firestore
          .collection('Configuracion')
          .doc('rallyRules')
          .set(rules, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Error al actualizar las reglas: $e');
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
              .collection('Fotos')
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

  // Obtener todas las fotos con estado 'aprobada'
  Future<List<Map<String, dynamic>>> getApprovedPhotos() async {
    try {
      QuerySnapshot snapshot =
          await _firestore.collection('Fotos').where('status', isEqualTo: 'aprobada').get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw Exception('Error al obtener las fotos aprobadas: $e');
    }
  }

  // Obtener Foto por ID
  Future<Map<String, dynamic>?> getPhotoById(String photoId) async {
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('Fotos').doc(photoId).get();
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Error al obtener la foto: $e');
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

  // Eliminar una foto
  Future<void> deletePhoto(String photoId) async {
  try {
    final photoDoc = await _firestore.collection('Fotos').doc(photoId).get();

    if (!photoDoc.exists) {
      throw Exception('La foto no existe');
    }

    final photoData = photoDoc.data()!;
    final uploaderId = photoData['userId'] as String;

    // Eliminar la foto
    await _firestore.collection('Fotos').doc(photoId).delete();

    // Buscar todos los votos asociados a la foto
    final votesSnapshot = await _firestore
        .collection('Votos')
        .where('photoId', isEqualTo: photoId)
        .get();

    // Obtener los IDs de los votantes únicos
    final Set<String> voterIds = {};

    for (var voteDoc in votesSnapshot.docs) {
      final voterId = voteDoc['voterId'] as String;
      voterIds.add(voterId);

      // Eliminar el voto
      await voteDoc.reference.delete();
    }

    // Actualizar el voteCount de cada votante
    for (final voterId in voterIds) {
      await updateUserVoteCount(voterId);
    }

    // Actualizar el fotosCount del usuario que subió la foto
    await userService.decrementUserPhotoCount(uploaderId);

  } catch (e) {
    throw Exception('Error al eliminar la foto: $e');
  }
}


  Future<void> updateUserVoteCount(String userId) async {
    final votesSnapshot =
        await _firestore
            .collection('Votos')
            .where('voterId', isEqualTo: userId)
            .get();

    final voteCount = votesSnapshot.size;

    await _firestore.collection('Participantes').doc(userId).update({
      'voteCount': voteCount,
    });
  }

  // Votar una Foto
  Future<void> votePhoto(String photoId, String userId) async {
    try {
      // Verificar si el usuario ya ha votado por esta foto
      final existingVote = await _firestore
          .collection('Votos')
          .where('voterId', isEqualTo: userId)
          .where('photoId', isEqualTo: photoId)
          .get();
      if (existingVote.docs.isNotEmpty) {
        throw Exception('El usuario ya ha votado por esta foto.');
      }
      //Verificar que el user puede votar
      final currentUserId = await userService.getUserId();
      final voteCount = await userService.getUserVoteCount(currentUserId);
      final rules = await getRallyRules();
      if (voteCount >= rules['voteLimit']) {
        throw Exception('El usuario ha alcanzado el límite de votos.');
      }

      final doc = await _firestore.collection('Votos').doc();
      final vote = {
        'id':doc.id,
        'voterId': currentUserId,
        'photoId': photoId,
        'voteDate':Timestamp.fromDate(DateTime.now()),
      };
      await doc.set(vote);

      // Actualizar el contador de votos del usuario
      await userService.incrementUserVoteCount(currentUserId);
      // Actualizar el contador de votos de la foto
      await _firestore.collection('Fotos').doc(photoId).update({
        'votes': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Obtener votos de una foto ( el vote es un campo en la tabla de Fotos)
  Future<int> getPhotoVotes(String photoId) async {
  try {
    final snapshot = await _firestore.collection('Fotos').doc(photoId).get();
    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      return data['votes'] ?? 0;
    } else {
      throw Exception('La foto con ID $photoId no existe.');
    }
  } catch (e) {
    throw Exception('Error al obtener los votos de la foto: $e');
  }
}
  
}
