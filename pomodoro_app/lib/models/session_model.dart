class SessionModel {
  final String type;       // Exemple : "Pomodoro", "Pause courte", "Pause longue"
  final int duration;      // Durée de la session en minutes
  final DateTime timestamp; // Horodatage de la session

  SessionModel({
    required this.type,
    required this.duration,
    required this.timestamp,
  });

  // Création d’un objet à partir d’une Map (ex: depuis la base de données)
  factory SessionModel.fromMap(Map<String, dynamic> map) {
    return SessionModel(
      type: map['type'] ?? 'Pomodoro', 
      duration: map['duration'] ?? 0,
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  Map<String, dynamic> toMap(String userId) {
    return {
      'type': type,                  
      'duration': duration,
      'timestamp': timestamp.toIso8601String(),
      'user_id': userId,
    };
  }
}
