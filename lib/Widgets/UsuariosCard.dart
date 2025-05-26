import 'package:flutter/material.dart';
import 'package:foto_rally/Services/admin_service.dart';
import 'package:foto_rally/Services/alert_service.dart';
import 'package:foto_rally/Services/user_service.dart';
import 'package:foto_rally/Widgets/CustomButton.dart' show CustomButton;

class UsuariosCard extends StatefulWidget {
  const UsuariosCard({super.key, required this.usuarios, required this.baja});
  final List usuarios;
  final baja;

  @override
  State<UsuariosCard> createState() => _UsuariosCardState();
}

class _UsuariosCardState extends State<UsuariosCard> {
  final AdminService adminService = AdminService();
  final UserService userService = UserService();
  final AlertService alertService = AlertService();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: widget.usuarios.length,
        itemBuilder: (context, index) {
          final usuario = widget.usuarios[index];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.blueGrey[100],
                    child: Icon(Icons.person, size: 28, color: Colors.blueGrey[700]),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          usuario['nombre'] ?? 'Sin nombre',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.email, size: 18, color: Colors.grey[600]),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                usuario['email'] ?? '',
                                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 18, color: Colors.grey[600]),
                            SizedBox(width: 6),
                            Text(
                              usuario['localidad'] ?? '',
                              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Column(
                    children: [
                      if (!widget.baja) ...[
                        CustomButton(
                          onPressed: () => rechazarParticipante(context, usuario['userId']),
                          text: 'Rechazar',
                          backgroundColor: Colors.red[800] ?? Colors.red,
                          textColor: Colors.white,
                          width: 100,
                          height: 40,
                          borderRadius: 10,
                        ),
                        SizedBox(height: 6),
                        CustomButton(
                          onPressed: () => aceptarParticipante(context, usuario['userId']),
                          text: 'Aceptar',
                          backgroundColor: Colors.green[800] ?? Colors.green,
                          textColor: Colors.white,
                          width: 100,
                          height: 40,
                          borderRadius: 10,
                        ),
                      ] else ...[
                        CustomButton(
                          onPressed: () => darBaja(context, usuario['userId']),
                          text: 'Dar Baja',
                          backgroundColor: Colors.red[800] ?? Colors.red,
                          textColor: Colors.white,
                          width: 100,
                          height: 40,
                          borderRadius: 10,
                        ),
                      ],
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> aceptarParticipante(BuildContext context, String userId) async {
    await adminService.aceptarParticipante(userId);
    alertService.success(context, 'Usuario aceptado correctamente.');
    setState(() {
      // Refresh the list of users after accepting a participant
      widget.usuarios.removeWhere((usuario) => usuario['userId'] == userId);
    });
  }

  Future<void> rechazarParticipante(BuildContext context, String userId) async {
    await adminService.rechazarParticipante(userId);
    await userService.deleteUser(userId);
    alertService.success(context, 'Usuario rechazado correctamente.');
    setState(() {
      // Refresh the list of users after rejecting a participant
      widget.usuarios.removeWhere((usuario) => usuario['userId'] == userId);
    });
  }

  Future<void> darBaja(BuildContext context, String userId) async {
    await userService.updateUserStatus(userId, 'inactivo');
    await userService.updateUserBaja(userId, false);
    alertService.success(context, 'Usuario dado de baja correctamente.');
    setState(() {
      // Refresh the list of users after accepting a participant
      widget.usuarios.removeWhere((usuario) => usuario['userId'] == userId);
    });
  }
}
