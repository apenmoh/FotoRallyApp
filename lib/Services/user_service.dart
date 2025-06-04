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

  //Obtener AmdminPorId
  Future<Map<String, dynamic>> getAdminById(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('Administradores').doc(uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        return {};
      }
    } catch (e) {
      print('Error al obtener administrador: $e');
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

  Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection('Participantes').doc(uid).delete();
    } catch (e) {
      print('Error al eliminar el usuario: $e');
    }
  }

  // Obtener la cantidad de fotos de un usuario
  Future<int> getUserPhotoCount(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('Participantes').doc(uid).get();
      if (doc.exists) {
        return doc['fotosCount'] ?? 0;
      } else {
        return 0;
      }
    } catch (e) {
      print('Error al obtener la cantidad de fotos del usuario: $e');
      return 0;
    }
  }

  //icrement user photo count
  Future<void> incrementUserPhotoCount(String uid) async {
    try {
      await _firestore.collection('Participantes').doc(uid).update({
        'fotosCount': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error al incrementar el contador de fotos: $e');
    }
  }

  // Decrement user photo count
  Future<void> decrementUserPhotoCount(String uid) async {
    try {
      await _firestore.collection('Participantes').doc(uid).update({
        'fotosCount': FieldValue.increment(-1),
      });
    } catch (e) {
      print('Error al decrementar el contador de fotos: $e');
    }
  }

  // Incrementar el contador de votos de un usuario
  Future<void> incrementUserVoteCount(String uid) async {
    try {
      await _firestore.collection('Participantes').doc(uid).update({
        'voteCount': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error al incrementar el contador de votos: $e');
    }
  }

  // Decrementar el contador de votos de un usuario
  Future<void> decrementUserVoteCount(String uid) async {
    try {
      await _firestore.collection('Participantes').doc(uid).update({
        'voteCount': FieldValue.increment(-1),
      });
    } catch (e) {
      print('Error al decrementar el contador de votos: $e');
    }
  }

  // Obtener el contador de votos de un usuario
  Future<int> getUserVoteCount(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('Participantes').doc(uid).get();
      if (doc.exists) {
        return doc['voteCount'] ?? 0;
      } else {
        return 0;
      }
    } catch (e) {
      print('Error al obtener el contador de votos del usuario: $e');
      return 0;
    }
  }

  //Obtener top 3 Usuarios con más votos
  Future<List<Map<String, dynamic>>> getTopParticipantsByVotes() async {
    try {
      // 1. Obtener todas las fotos y agrupar votos por userId
      final QuerySnapshot photosSnapshot =
          await _firestore
              .collection('Fotos')
              .where('status', isEqualTo: 'aprobada')
              .get();

      Map<String, int> userVotes = {};

      for (var doc in photosSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final userId = data['userId'] as String?;
        final votes =
            (data['votes'] as num?)?.toInt() ??
            0; // Asegura que los votos sean enteros

        if (userId != null) {
          userVotes.update(
            userId,
            (value) => value + votes,
            ifAbsent: () => votes,
          );
        }
      }

      // 2. Crear una lista de IDs de usuario ordenados por sus votos (de mayor a menor)
      List<String> sortedUserIds =
          userVotes.keys.toList()
            ..sort((a, b) => userVotes[b]!.compareTo(userVotes[a]!));

      // 3. Limitar a los top 3 (o menos si hay menos de 3)
      List<String> top3UserIds = sortedUserIds.take(3).toList();

      List<Map<String, dynamic>> topParticipants = [];

      // 4. Obtener la información de cada participante del top 3
      if (top3UserIds.isNotEmpty) {
        final QuerySnapshot participantsSnapshot =
            await _firestore
                .collection('Participantes')
                .where('userId', whereIn: top3UserIds)
                .get();

        Map<String, Map<String, dynamic>> participantData = {};
        for (var doc in participantsSnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          participantData[data['userId']] = data;
        }

        // 5. Construir la lista final con los votos asignados y ordenados
        for (String userId in top3UserIds) {
          if (participantData.containsKey(userId)) {
            final participant = participantData[userId]!;
            topParticipants.add({
              'userId': userId,
              'nombre': participant['nombre'],
              'localidad': participant['localidad'],
              'totalVotes': userVotes[userId], // Añadir los votos calculados
            });
          }
        }
      }

      return topParticipants;
    } catch (e) {
      print('Error al obtener top participantes: $e');
      throw Exception('No se pudo cargar el leaderboard: $e');
    }
  }

  Future<void> updateFotoCount(String uid, int count) async {
    try {
      await _firestore.collection('Participantes').doc(uid).update({
        'fotosCount': count,
      });
    } catch (e) {
      print('Error al actualizar el contador de fotos: $e');
    }
  }

  //Dar Baja a un usuario implica que se borra de la colección Participantes, Se borran las fotos asociadas,Se borran los votos asociados y se actualiza el estado a baja en la colección Fotos
  Future<void> darBaja(String uid) async {
    try {
      // 1. Desactivar al usuario
      await updateUserBaja(uid, false);
      await updateUserStatus(uid, 'inactivo');

      // 2. Buscar todas las fotos del usuario
      final photosSnapshot =
          await _firestore
              .collection('Fotos')
              .where('userId', isEqualTo: uid)
              .get();

      // Set para acumular todos los voterIds únicos
      final Set<String> allVoterIds = {};

      for (var photoDoc in photosSnapshot.docs) {
        final photoId = photoDoc.id;

        // 3. Eliminar todos los votos asociados a la foto
        final votesSnapshot =
            await _firestore
                .collection('Votos')
                .where('photoId', isEqualTo: photoId)
                .get();

        for (var voteDoc in votesSnapshot.docs) {
          final voterId = voteDoc['voterId'] as String;
          allVoterIds.add(voterId);
          await voteDoc.reference.delete();
        }

        // 4. Eliminar la foto
        await photoDoc.reference.delete();
      }

      // 5. Actualizar voteCount de todos los votantes
      for (final voterId in allVoterIds) {
        await updateUserVoteCount(voterId);
      }

      // 6. Actualizar fotosCount del usuario dado de baja
      await updateFotoCount(uid, 0);

      print('Usuario dado de baja correctamente.');
    } catch (e) {
      print('Error al dar de baja al usuario: $e');
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
}
