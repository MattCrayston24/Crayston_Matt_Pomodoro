class SessionModel {
  final int? id;
  final String userId;
  final String type;
  final int duration; // durée en secondes
  final DateTime timestamp;

  SessionModel({
    this.id,
    required this.userId,
    required this.type,
    required this.duration,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'type': type,
      'duration': duration,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory SessionModel.fromMap(Map<String, dynamic> map) {
    return SessionModel(
      id: map['id'] as int?,
      userId: map['user_id'],
      type: map['type'],
      duration: map['duration'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
