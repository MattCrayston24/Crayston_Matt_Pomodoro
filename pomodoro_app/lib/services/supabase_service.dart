import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> saveSession(Map<String, dynamic> sessionData) async {
    final response = await _supabase.from('sessions').insert(sessionData);
    if (response.error != null) {
      throw Exception('Erreur lors de l’enregistrement : ${response.error!.message}');
    }
  }

  Future<List<Map<String, dynamic>>> fetchUserSessions(String userId) async {
    final response = await _supabase
        .from('sessions')
        .select()
        .eq('user_id', userId)
        .order('start_time', ascending: false);

    if (response is List) {
      return List<Map<String, dynamic>>.from(response);
    } else {
      return [];
    }
  }
}
