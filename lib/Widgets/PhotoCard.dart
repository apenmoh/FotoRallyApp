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
      if (status == 'aprobada') onAccept?.call(id);
      if (status == 'rechazada') onDeny?.call(id);
    } catch (e) {
      alertService.error(context, "Error al actualizar el estado: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF047857);
    final Color accentColor = Colors.red;
    final Color backgroundColor = const Color(0xFFFDF6FF);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header: usuario y categoría
          Container(
            color: backgroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    user['nombre'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  category,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),

          // Imagen
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              imagenUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) =>
                  loadingProgress == null
                      ? child
                      : const Center(child: CircularProgressIndicator()),
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey.shade200,
                alignment: Alignment.center,
                child: Icon(Icons.broken_image, color: Colors.grey.shade400, size: 80),
              ),
            ),
          ),

          // Información y botones
          Container(
            padding: const EdgeInsets.all(16),
            color: backgroundColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  location,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 12),
                Text(
                  descripcion,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),

                const SizedBox(height: 20),

                // Acciones
                if (showActions)
                  _buildActionButtons(context, primaryColor, accentColor)
                else
                  _buildVotingSection(context, primaryColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Color primary, Color accent) {
    if (isParticipantGallery) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                status.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: status == 'aprobada'
                      ? primary
                      : status == 'rechazada'
                          ? accent
                          : Colors.orange.shade700,
                ),
              ),
              if (status == 'aprobada')
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    "Votada por $votes personas",
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ),
            ],
          ),
          CustomButton(
            onPressed: () => onDelete?.call(id),
            text: "Eliminar",
            backgroundColor: accent,
            textColor: Colors.white,
            borderRadius: 10,
            width: 100,
            height: 35,
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CustomButton(
            onPressed: () => _handleStatusChange(context, 'rechazada'),
            text: "Rechazar",
            backgroundColor: accent,
            textColor: Colors.white,
            borderRadius: 10,
            width: 100,
            height: 35,
          ),
          const SizedBox(width: 12),
          CustomButton(
            onPressed: () => _handleStatusChange(context, 'aprobada'),
            text: "Aceptar",
            backgroundColor: primary,
            textColor: Colors.white,
            borderRadius: 10,
            width: 100,
            height: 35,
          ),
        ],
      );
    }
  }

  Widget _buildVotingSection(BuildContext context, Color primary) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "$votes votos",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        Row(
          children: [
            if (photoOwner)
              CustomButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/galeria_participante',
                    arguments: user['id'],
                  );
                },
                text: "Galería",
                backgroundColor: primary,
                textColor: Colors.white,
                borderRadius: 15,
                width: 130,
                height: 40,
              ),
            if (!photoOwner && !isAdmin)
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: CustomButton(
                  onPressed: () => onVote?.call(id),
                  text: "Votar",
                  backgroundColor: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  borderRadius: 15,
                  width: 120,
                  height: 40,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
