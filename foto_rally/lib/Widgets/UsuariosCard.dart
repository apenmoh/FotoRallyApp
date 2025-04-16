import 'package:flutter/material.dart';
import 'package:foto_rally/Services/admin_service.dart';
import 'package:foto_rally/Widgets/CustomButton.dart' show CustomButton;

class UsuariosCard extends StatelessWidget {
  const UsuariosCard({super.key, required this.usuarios});

  final List usuarios;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20),
      child: ListView.builder(
        itemCount: usuarios.length,
        itemBuilder: (context, index) {
          final usuario = usuarios[index];
          return Card(
            elevation: 10,
            child: ListTile(
              title: Text('Usuario: ${usuario['nombre']}'),
              titleTextStyle: TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              subtitleTextStyle: TextStyle(
                fontSize: 15,
                color: Colors.blueGrey,
                fontWeight: FontWeight.w400,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email: ${usuario['email']}'),
                  SizedBox(height: 2),
                  Text('Localidad: ${usuario['localidad']}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomButton(
                    onPressed:
                        () =>
                            rechazarParticipante((context), usuario['userId']),
                    text: "Rechazar",
                    backgroundColor: Colors.red[800] ?? Colors.red,
                    textColor: Colors.white,
                    width: 40,
                    height: 40,
                    borderRadius: 20,
                  ),
                  SizedBox(width: 5),
                  CustomButton(
                    onPressed:
                        () => aceptarParticipante(context, usuario['userId']),
                    text: "Aceptar",
                    backgroundColor: Colors.green[800] ?? Colors.green,
                    textColor: Colors.white,
                    width: 40,
                    height: 40,
                    borderRadius: 20,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> aceptarParticipante(BuildContext context, String userId) async {
    AdminService adminService = AdminService();
    await adminService.aceptarParticipante(userId);
    // SnackBar para mostrar mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Usuario aceptado correctamente.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> rechazarParticipante(BuildContext context, String userId) async {
    AdminService adminService = AdminService();
    await adminService.rechazarParticipante(userId);
    // SnackBar para mostrar mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Usuario rechazado correctamente.'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
