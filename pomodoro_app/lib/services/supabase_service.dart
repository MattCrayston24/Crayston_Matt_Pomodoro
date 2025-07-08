import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Sauvegarde une session Pomodoro dans Supabase
  Future<void> saveSession(Map<String, dynamic> sessionData) async {
    try {
      await _supabase
          .from('session_historique')
          .insert(sessionData)
          .execute();
    } catch (e) {
      throw Exception('Erreur lors de l’enregistrement : $e');
    }
  }

  // Récupère les sessions d’un utilisateur depuis Supabase
  Future<List<Map<String, dynamic>>> fetchUserSessions(String userId) async {
    try {
      final response = await _supabase
          .from('session_historique')
          .select()
          .eq('user_id', userId)
          .order('timestamp', ascending: false)
          .execute();

      // Si response.data n'est pas une liste, retourne vide
      if (response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Erreur lors du chargement des sessions : $e');
    }
  }
}
