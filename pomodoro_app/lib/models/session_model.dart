class SessionModel {
  final int? id;
  final String userId;
  final DateTime startTime;
  final DateTime endTime;
  final int duration; // en secondes
  final String type;

  SessionModel({
    this.id,
    required this.userId,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'duration': duration,
      'type': type,
    };
  }

  factory SessionModel.fromMap(Map<String, dynamic> map) {
    return SessionModel(
      id: map['id'] as int?,
      userId: map['user_id'],
      startTime: DateTime.parse(map['start_time']),
      endTime: DateTime.parse(map['end_time']),
      duration: map['duration'],
      type: map['type'],
    );
  }
}
