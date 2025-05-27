import 'package:flutter/material.dart';
import 'package:foto_rally/Services/alert_service.dart';
import 'package:foto_rally/Services/firestore_service.dart';
import 'package:foto_rally/Services/user_service.dart';
import 'package:foto_rally/Widgets/TabNavigation.dart';
import 'package:foto_rally/Widgets/PhotoCard.dart';

class GaleriaParticipante extends StatefulWidget {
  const GaleriaParticipante({super.key});

  @override
  State<GaleriaParticipante> createState() => _GaleriaParticipanteState();
}

class _GaleriaParticipanteState extends State<GaleriaParticipante> {
  FirestoreService firestoreService = FirestoreService();
  UserService userService = UserService();
  AlertService alertService = AlertService();

  bool isLoading = true;
  late Future<List<Map<String, dynamic>>> photosFuture;
  List<Map<String, dynamic>> photos = [];
  late Map<String, dynamic> user;

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
    final userId = await userService.getUserId();
    await userService.getUserById(userId).then((value) {
      setState(() {
        user = value;
      });
    });
    if (userId == null) {
      alertService.error(context, "Error al obtener el ID del usuario.");
      setState(() {
        isLoading = false;
      });
      return;
    }
    photosFuture = firestoreService.getUserPhotos(userId);
    photosFuture.then((fotos) {
      setState(() {
        photos = fotos;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (user == null) {
      return Center(child: Text("Error al cargar los datos del usuario."));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Galería de " + user['nombre'],
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF1A56DB),
        centerTitle: true,
      ),
      bottomNavigationBar: Tabnavigation(),
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
              return PhotoCard(
                id: photo["photoId"],
                titulo: photo["title"],
                location: photo["location"],
                user: user,
                imagenUrl: photo["url"],
                status: photo["status"],
                category: photo["category"],
                descripcion: photo["description"],
                votes: photo["votes"],
                isParticipantGallery: true,
                onDelete: (id) => deletePhoto(id),
              );
            },
          );
        },
      ),
    );
  }

  void deletePhoto(String id) async {
    try {
      final confirmed = await alertService.confirm(
        context,
        "¿Estás seguro de que deseas eliminar esta foto? Esta acción no se puede deshacer.",
      );
      if (!confirmed) return;
      setState(() {
        isLoading = true;
      });
      await firestoreService.deletePhoto(id);
      alertService.success(context, "Foto eliminada correctamente.");
      _loadPhotos();
    } catch (e) {
      alertService.error(context, "Error al eliminar la foto: $e");
      setState(() {
        isLoading = false;
      });
    }
  }
}
