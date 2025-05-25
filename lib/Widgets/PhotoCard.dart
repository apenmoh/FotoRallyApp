import 'package:flutter/material.dart';
import 'package:foto_rally/Services/alert_service.dart';
import 'package:foto_rally/Services/firestore_service.dart';
import 'package:foto_rally/Widgets/CustomButton.dart';

class PhotoCard extends StatelessWidget {
  final String id;
  final String titulo;
  final String location;
  final Map<String, dynamic> user;
  final String imagenUrl;
  final String category;
  final String descripcion;
  final String status;
  final int votes;
  final void Function(String)? onAccept;
  final void Function(String)? onDeny;
  final void Function(String)? onDelete;
  final void Function(String)? onVote;
  final bool showActions;
  final bool isParticipantGallery;
  final bool photoOwner;
  final bool isAdmin;
  

  final firestoreService = FirestoreService();
  final alertService = AlertService();

  PhotoCard({
    super.key,
    required this.id,
    required this.titulo,
    required this.location,
    required this.user,
    required this.imagenUrl,
    required this.category,
    required this.status,
    required this.descripcion,
    required this.isParticipantGallery,
    this.photoOwner = true,
    this.isAdmin = false,
    this.votes = 0,
    this.onAccept,
    this.onDeny,
    this.onDelete,
    this.onVote,
    this.showActions = true,
  });

  Future<void> _handleStatusChange(BuildContext context, String status) async {
    try {
      await firestoreService.updatePhotoStatus(id, status);
      alertService.success(
        context,
        "Foto ${status == 'aprobada' ? 'aceptada' : 'rechazada'} correctamente.",
      );
      if (status == 'aprobada' && onAccept != null) onAccept!(id);
      if (status == 'rechazada' && onDeny != null) onDeny!(id);
    } catch (e) {
      alertService.error(context, "Error al actualizar el estado: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            color: const Color(0xFFFDF6FF),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['nombre'],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(category),
              ],
            ),
          ),
          Image.network(
            imagenUrl,
            height: 250,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Container(
            padding: const EdgeInsets.all(12),
            color: const Color(0xFFFDF6FF),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(location),
                SizedBox(height: 12),
                Text(descripcion, style: TextStyle(color: Colors.black54)),
                if (showActions) ...[
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment:
                        isParticipantGallery
                            ? MainAxisAlignment.spaceBetween
                            : MainAxisAlignment.end,
                    children: [
                      if (isParticipantGallery) ...[
                        Container(
                          alignment: Alignment.bottomLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                status.toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  color:
                                      status == 'aprobada'
                                          ? Color(0xFF047857)
                                          : status == 'rechazada'
                                          ? Colors.red
                                          : Colors.orange,
                                ),
                              ),
                              if(status == 'aprobada')
                              Text(
                                "Votada por ${votes} personas",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CustomButton(
                          onPressed: () => onDelete?.call(id),
                          text: "Eliminar",
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          borderRadius: 10,
                          width: 100,
                          height: 30,
                        ),
                      ] else ...[
                        CustomButton(
                          onPressed:
                              () => _handleStatusChange(context, 'rechazada'),
                          text: "Rechazar",
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          borderRadius: 10,
                          width: 100,
                          height: 30,
                        ),
                        SizedBox(width: 12),
                        CustomButton(
                          onPressed:
                              () => _handleStatusChange(context, 'aprobada'),
                          text: "Aceptar",
                          backgroundColor: Color(0xFF047857),
                          textColor: Colors.white,
                          borderRadius: 10,
                          width: 100,
                          height: 30,
                        ),
                      ],
                    ],
                  ),
                ] else ...[
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween, // Space between votes and buttons
                    children: [
                      // Votes on the left
                      Text(
                        "$votes votos",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      // Buttons on the right
                      Row(
                        children: [
                          if(photoOwner)
                          CustomButton(
                            onPressed: () {
                              // Navigate to user profile
                              Navigator.pushNamed(
                                context,
                                '/galeria_participante',
                              );
                            },
                            text: "Galería",
                            backgroundColor: Color(0xFF047857),
                            textColor: Colors.white,
                            borderRadius: 15,
                            width: 130,
                            height: 40,
                          ),
                          SizedBox(width: 10),
                          if (!photoOwner && !isAdmin)
                            CustomButton(
                            onPressed: () => onVote?.call(id),
                            text: "Votar",
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            borderRadius: 15,
                            width: 120,
                            height: 30,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
