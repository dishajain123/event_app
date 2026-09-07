class CompetitionSummary {
  final String id;
  final String name;
  final String? description;
  final String participationMode;
  final String status;
  final int? maxParticipants;

  const CompetitionSummary({
    required this.id,
    required this.name,
    required this.description,
    required this.participationMode,
    required this.status,
    required this.maxParticipants,
  });

  factory CompetitionSummary.fromJson(Map<String, dynamic> json) {
    return CompetitionSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      participationMode: json['participation_mode'] as String,
      status: json['status'] as String,
      maxParticipants: json['max_participants'] as int?,
    );
  }
}

class CompetitionStanding {
  final String entryId;
  final int position;
  final int played;
  final int wins;
  final int losses;
  final int draws;
  final int points;

  const CompetitionStanding({
    required this.entryId,
    required this.position,
    required this.played,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.points,
  });

  factory CompetitionStanding.fromJson(Map<String, dynamic> json) {
    return CompetitionStanding(
      entryId: json['entry_id'] as String,
      position: json['position'] as int,
      played: json['played'] as int,
      wins: json['wins'] as int,
      losses: json['losses'] as int,
      draws: json['draws'] as int,
      points: json['points'] as int,
    );
  }
}

class CompetitionMatchSummary {
  final String status;
  final int roundNumber;
  final int matchNumber;
  final int? scoreA;
  final int? scoreB;

  const CompetitionMatchSummary({
    required this.status,
    required this.roundNumber,
    required this.matchNumber,
    required this.scoreA,
    required this.scoreB,
  });

  factory CompetitionMatchSummary.fromJson(Map<String, dynamic> json) {
    return CompetitionMatchSummary(
      status: json['status'] as String,
      roundNumber: json['round_number'] as int,
      matchNumber: json['match_number'] as int,
      scoreA: json['score_a'] as int?,
      scoreB: json['score_b'] as int?,
    );
  }
}
