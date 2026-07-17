class LearnSession {
  final String id;
  final int samplesCollected;

  const LearnSession({required this.id, required this.samplesCollected});

  factory LearnSession.fromJson(Map<String, dynamic> json) {
    return LearnSession(
      id: json['id'] as String? ?? '',
      samplesCollected: (json['samples_collected'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'samples_collected': samplesCollected,
      };
}

class LearnAnalysis {
  final String movement;
  final String orientation;
  final int indexState;
  final int middleState;

  const LearnAnalysis({
    required this.movement,
    required this.orientation,
    required this.indexState,
    required this.middleState,
  });

  factory LearnAnalysis.fromJson(Map<String, dynamic> json) {
    return LearnAnalysis(
      movement: json['movement'] as String? ?? 'NONE',
      orientation: json['orientation'] as String? ?? 'ANY',
      indexState: (json['index_state'] as num?)?.toInt() ?? 0,
      middleState: (json['middle_state'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'movement': movement,
        'orientation': orientation,
        'index_state': indexState,
        'middle_state': middleState,
      };
}
