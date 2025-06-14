import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foto_rally/Services/alert_service.dart';
import 'package:foto_rally/Services/firestore_service.dart';
import 'package:foto_rally/Services/user_service.dart';
import 'package:foto_rally/Widgets/TabNavigation.dart';
import 'package:foto_rally/Widgets/PhotoCard.dart';

class Galeria extends StatefulWidget {
  const Galeria({super.key});

  @override
  State<Galeria> createState() => _GaleriaParticipanteState();
}

class _GaleriaParticipanteState extends State<Galeria> {
  FirestoreService firestoreService = FirestoreService();
  UserService userService = UserService();
  AlertService alertService = AlertService();

  bool isLoading = true;
  late Future<List<Map<String, dynamic>>> photosFuture;
  List<Map<String, dynamic>> photos = [];
  bool isAdmin = false;
  Map<String, dynamic> currentUser = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadPhotos();
  }

  void _loadPhotos() async {
    setState(() {
      isLoading = true;
    });
    photosFuture = firestoreService.getApprovedPhotos();
    photosFuture.then((fotos) {
      setState(() {
        photos = fotos;
      });
    });
    
    final u = await userService.getUsuarioLogueado();
    isAdmin = (u['isAdmin'] ?? false) as bool;
    setState(() {
      isLoading = false;
      currentUser = u;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Galería",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF1A56DB),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: photosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (photos.isEmpty) {
            return Center(child: Text("No hay fotos para mostrar."));
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: photos.length,
            itemBuilder: (context, i) {
              final photo = photos[i];
              return FutureBuilder<Map<String, dynamic>>(
                future: userService.getUserById(photo['userId']),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      height: 100,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (userSnapshot.hasError) {
                    return Text("Error cargando usuario");
                  }
                  return PhotoCard(
                    id: photo["photoId"],
                    titulo: photo["title"],
                    location: photo["location"],
                    user: userSnapshot.data!,
                    imagenUrl: photo["url"],
                    status: photo["status"],
                    category: photo["category"],
                    descripcion: photo["description"],
                    isParticipantGallery: false,
                    showActions: false,
                    isAdmin: isAdmin,
                    photoOwner: photo["userId"] == currentUser["userId"],
                    votes: photo["votes"] ?? 0,
                    onVote: (photoId) => VotePhoto(photoId, currentUser['userId']),
                    );
                },
              );
            },
          );
        },
      ),
    );
  }

  void VotePhoto(String id, String userId) async {
    try {
      setState(() {
        isLoading = true;
      });
      
      final rallyRules = await firestoreService.getRallyRules();
      if (!rallyRules['isRallyActive'] ||(rallyRules['endDate'] as Timestamp).toDate().isBefore(DateTime.now())) {
        alertService.error(context,'El rally no está activo. No se pueden Votar.');
        setState(() {
          isLoading = false;
        });
        return;
      }
      await firestoreService.votePhoto(id, userId);
      alertService.success(context, "Voto registrado correctamente.");
      _loadPhotos();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      alertService.error(context, "$e");
      setState(() {
        isLoading = false;
      });
    }
  }
}
