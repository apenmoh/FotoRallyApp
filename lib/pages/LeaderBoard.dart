import 'package:flutter/material.dart';
import 'package:foto_rally/Services/user_service.dart';
import 'package:foto_rally/Widgets/TabNavigation.dart';

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

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Color(0xFF1A56DB),
      ),
      bottomNavigationBar: Tabnavigation(),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                child: Text(
                  'Error: $_errorMessage',
                  textAlign: TextAlign.center,
                ),
              )
              : _topParticipants.isEmpty
              ? const Center(child: Text('No hay participantes todavía.'))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _topParticipants.length,
                itemBuilder: (context, index) {
                  final participant = _topParticipants[index];
                  return _buildParticipantCard(participant, index + 1);
                },
              ),
    );
  }

  Widget _buildParticipantCard(Map<String, dynamic> participant, int rank) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Text(
            '$rank',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
        title: Text(participant['nombre'] ?? 'Nombre desconocido'),
        subtitle: Text(participant['localidad'] ?? 'Localidad desconocida'),
        trailing: Text(
          '${participant['totalVotes'] ?? 0} votos',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }
}
