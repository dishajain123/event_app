import '../../../../../core/utils/flexible_decimal.dart';

/// Mirrors `app/modules/funnels/models.py`'s `StageType` StrEnum exactly.
enum StageType {
  juryReview('jury_review'),
  publicVote('public_vote'),
  topNCutoff('top_n_cutoff'),
  manualReview('manual_review');

  final String wireValue;
  const StageType(this.wireValue);

  static StageType fromWire(String value) {
    return StageType.values.firstWhere(
      (t) => t.wireValue == value,
      orElse: () => throw FormatException('Unknown stage type from backend: $value'),
    );
  }

  String get label => switch (this) {
        StageType.juryReview => 'Jury Review',
        StageType.publicVote => 'Public Vote',
        StageType.topNCutoff => 'Top-N Cutoff',
        StageType.manualReview => 'Manual Review',
      };
}

/// Mirrors `EntryStatus` exactly.
enum EntryStatus {
  active('active'),
  advanced('advanced'),
  eliminated('eliminated'),
  completed('completed');

  final String wireValue;
  const EntryStatus(this.wireValue);

  static EntryStatus fromWire(String value) {
    return EntryStatus.values.firstWhere(
      (s) => s.wireValue == value,
      orElse: () => throw FormatException('Unknown entry status from backend: $value'),
    );
  }
}

/// Mirrors `CompetitionStageOut` exactly.
class CompetitionStage {
  final String id;
  final String eventId;
  final String name;
  final StageType stageType;
  final int orderIndex;
  final int? threshold;

  const CompetitionStage({
    required this.id,
    required this.eventId,
    required this.name,
    required this.stageType,
    required this.orderIndex,
    required this.threshold,
  });

  factory CompetitionStage.fromJson(Map<String, dynamic> json) {
    return CompetitionStage(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      name: json['name'] as String,
      stageType: StageType.fromWire(json['stage_type'] as String),
      orderIndex: json['order_index'] as int,
      threshold: json['threshold'] as int?,
    );
  }
}

/// Mirrors `EntryOut` exactly.
class FunnelEntry {
  final String id;
  final String eventId;
  final String registrationId;
  final String? currentStageId;
  final EntryStatus status;
  final double? score;
  final int voteCount;
  final String? notes;

  const FunnelEntry({
    required this.id,
    required this.eventId,
    required this.registrationId,
    required this.currentStageId,
    required this.status,
    required this.score,
    required this.voteCount,
    required this.notes,
  });

  factory FunnelEntry.fromJson(Map<String, dynamic> json) {
    return FunnelEntry(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      registrationId: json['registration_id'] as String,
      currentStageId: json['current_stage_id'] as String?,
      status: EntryStatus.fromWire(json['status'] as String),
      score: parseFlexibleDecimal(json['score']),
      voteCount: json['vote_count'] as int,
      notes: json['notes'] as String?,
    );
  }
}
