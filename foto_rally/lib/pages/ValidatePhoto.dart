import 'package:flutter/material.dart';
import 'package:foto_rally/Services/alert_service.dart';
import 'package:foto_rally/Services/firestore_service.dart';
import 'package:foto_rally/Services/user_service.dart';
import 'package:foto_rally/Widgets/ParticipantTabNav.dart';
import 'package:foto_rally/Widgets/PhotoCard.dart';

class ValidatePhoto extends StatefulWidget {
  @override
  _ValidatePhotoState createState() => _ValidatePhotoState();
}

class _ValidatePhotoState extends State<ValidatePhoto> {
  final firestoreService = FirestoreService();
  final userService = UserService();
  final alertService = AlertService();
  late Future<List<Map<String, dynamic>>> _fotosFuture;
  List<Map<String, dynamic>> _fotos = [];

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  void _loadPhotos() {
    _fotosFuture = firestoreService.getPendingPhotos();
    _fotosFuture.then((fotos) {
      setState(() {
        _fotos = fotos;
      });
    });
  }

  void _removePhoto(String id) {
    setState(() {
      _fotos.removeWhere((foto) => foto['photoId'] == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Validar Fotos"),
        centerTitle: true,
        backgroundColor: Color(0xFF1A56DB),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fotosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (_fotos.isEmpty) {
            return Center(child: Text("No hay fotos para validar."));
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: _fotos.length,
            itemBuilder: (context, i) {
              final foto = _fotos[i];
              return FutureBuilder<Map<String, dynamic>>(
                future: userService.getUserById(foto['userId']),
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
                    id: foto['photoId'],
                    titulo: foto['title'],
                    location: foto['location'],
                    user: userSnapshot.data!,
                    imagenUrl: foto['url'],
                    category: foto['category'],
                    descripcion: foto['description'],
                    onAccept: _removePhoto,
                    onDeny: _removePhoto,
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: ParticipantTabNav(),
    );
  }
}
