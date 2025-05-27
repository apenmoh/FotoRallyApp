// foto_rally/Pages/leader_board.dart (o donde la tengas)
import 'package:flutter/material.dart';
import 'package:foto_rally/Services/user_service.dart'; // Asegúrate de importar tu UserService
import 'package:foto_rally/Widgets/Admin/Admin_TabNav.dart';
import 'package:foto_rally/Widgets/TabNavigation.dart'; // Si usas el mismo Nav

class LeaderBoard extends StatefulWidget {
  const LeaderBoard({super.key});

  @override
  State<LeaderBoard> createState() => _LeaderBoardState();
}

class _LeaderBoardState extends State<LeaderBoard> {
  final UserService _userService = UserService();
  List<Map<String, dynamic>> _topParticipants = [];
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
    _getUserData();
  }
  Future<void> _getUserData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      final userData = await _userService.getUsuarioLogueado();
      setState(() {
        _userData = userData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadLeaderboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final participants = await _userService.getTopParticipantsByVotes();
      setState(() {
        _topParticipants = participants;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF1A56DB);
    const Color darkBlue = Color(0xFF1E3A8A); 
    const Color successGreen = Color(0xFF047857); 
    const Color textColor = Colors.white;
    const Color blackText = Colors.black87;
    const Color cardColor = Colors.white; 

    return Scaffold(
      backgroundColor: Colors.grey.shade50, 
      appBar: AppBar(
        title: const Text('Tabla de Posiciones',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: primaryBlue,
        elevation: 0, 
        iconTheme: const IconThemeData(color: textColor),
      ),
      bottomNavigationBar: Tabnavigation(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryBlue))
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 60, color: Colors.red.shade400),
                        const SizedBox(height: 20),
                        Text(
                          'Error al cargar el leaderboard: $_errorMessage',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: blackText),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton.icon(
                          onPressed: _loadLeaderboard,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            foregroundColor: textColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : _topParticipants.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.emoji_events_outlined, size: 60, color: Colors.amber.shade600),
                            const SizedBox(height: 20),
                            Text(
                              'Aún no hay participantes en el leaderboard. ¡Sé el primero en subir una foto y conseguir votos!',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 18, color: blackText),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 10),
                          Text(
                            '¡Los Participantes Más Votados!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: darkBlue,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 25),
                          // Tarjetas para el Top 3
                          _buildLeaderCard(
                            _topParticipants[0],
                            '🥇',
                            cardColor,
                            primaryBlue,
                            Colors.amber.shade700,
                            0, // Primer lugar
                          ),
                          const SizedBox(height: 20),
                          if (_topParticipants.length > 1)
                            _buildLeaderCard(
                              _topParticipants[1],
                              '🥈',
                              cardColor,
                              primaryBlue,
                              Colors.grey.shade600,
                              5, // Segundo lugar, un poco más de margen y menos sombra
                            ),
                          const SizedBox(height: 20),
                          if (_topParticipants.length > 2)
                            _buildLeaderCard(
                              _topParticipants[2],
                              '🥉',
                              cardColor,
                              primaryBlue,
                              Colors.brown.shade400,
                              10, // Tercer lugar, aún más margen y menos sombra
                            ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildLeaderCard(
      Map<String, dynamic> participant,
      String rankEmoji,
      Color bgColor,
      Color accentColor,
      Color rankColor,
      double topMargin // Para ajustar la posición visual
      ) {
    return Container(
      margin: EdgeInsets.only(top: topMargin),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1 + (0.05 * (3 - (topMargin / 5)))), // Sombra decreciente
            spreadRadius: 1,
            blurRadius: 10 + (5 * (3 - (topMargin / 5))), // Mayor blur para el primero
            offset: Offset(0, 5 + (2 * (3 - (topMargin / 5)))), // Mayor offset para el primero
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 25.0),
      child: Row(
        children: [
          // Medalla o emoji de posición
          Text(
            rankEmoji,
            style: TextStyle(fontSize: 40, color: rankColor),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participant['nombre'] ?? 'Nombre Desconocido',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  participant['localidad'] ?? 'Localidad Desconocida',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          // Votos
          Column(
            children: [
              Text(
                '${participant['totalVotes'] ?? 0}',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF047857),
                ),
              ),
              Text(
                'votos',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}