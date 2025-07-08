import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/session_model.dart';

class SessionPage extends StatefulWidget {
  const SessionPage({super.key});

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  final SupabaseService _supabaseService = SupabaseService();
  final SupabaseClient supabase = Supabase.instance.client;

  List<SessionModel> sessions = [];

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final result = await _supabaseService.fetchUserSessions(user.id);
    setState(() {
      sessions = result.map((data) => SessionModel.fromMap(data)).toList();
    });
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes}m ${secs}s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des sessions'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: sessions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                final date = session.timestamp;
                return ListTile(
                  title: Text(session.type),
                  subtitle: Text('${date.day}/${date.month}/${date.year} - '
                      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}'),
                  trailing: Text(_formatDuration(session.duration)),
                );
              },
            ),
    );
  }
}
