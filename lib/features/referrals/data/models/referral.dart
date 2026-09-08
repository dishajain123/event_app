import '../../../../core/utils/flexible_decimal.dart';

/// Mirrors `app/modules/referrals/models.py`'s `ReferralRewardStatus`
/// StrEnum exactly.
enum ReferralRewardStatus {
  tracked('tracked'),
  qualified('qualified'),
  issued('issued'),
  flagged('flagged');

  final String wireValue;
  const ReferralRewardStatus(this.wireValue);

  static ReferralRewardStatus fromWire(String value) {
    return ReferralRewardStatus.values.firstWhere(
      (s) => s.wireValue == value,
      orElse: () => throw FormatException(
          'Unknown referral reward status from backend: $value'),
    );
  }

  String get label => switch (this) {
        ReferralRewardStatus.tracked => 'Tracked',
        ReferralRewardStatus.qualified => 'Qualified',
        ReferralRewardStatus.issued => 'Reward issued',
        ReferralRewardStatus.flagged => 'Under review',
      };
}

/// Mirrors `ReferralOut` exactly.
class ReferralProfile {
  final String id;
  final String eventId;
  final String referrerUserId;
  final String referralCode;
  final bool isActive;
  final double rewardValue;
  final int totalRewardsIssued;

  const ReferralProfile({
    required this.id,
    required this.eventId,
    required this.referrerUserId,
    required this.referralCode,
    required this.isActive,
    required this.rewardValue,
    required this.totalRewardsIssued,
  });

  factory ReferralProfile.fromJson(Map<String, dynamic> json) {
    return ReferralProfile(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      referrerUserId: json['referrer_user_id'] as String,
      referralCode: json['referral_code'] as String,
      isActive: json['is_active'] as bool,
      rewardValue: parseFlexibleDecimal(json['reward_value']) ?? 0,
      totalRewardsIssued: json['total_rewards_issued'] as int,
    );
  }
}

/// Mirrors `ReferralRewardOut` exactly.
class ReferralReward {
  final String id;
  final String referralId;
  final String referredUserId;
  final String? registrationId;
  final double rewardValue;
  final ReferralRewardStatus status;
  final DateTime? qualifiedAt;
  final DateTime? issuedAt;
  final DateTime createdAt;

  const ReferralReward({
    required this.id,
    required this.referralId,
    required this.referredUserId,
    required this.registrationId,
    required this.rewardValue,
    required this.status,
    required this.qualifiedAt,
    required this.issuedAt,
    required this.createdAt,
  });

  factory ReferralReward.fromJson(Map<String, dynamic> json) {
    return ReferralReward(
      id: json['id'] as String,
      referralId: json['referral_id'] as String,
      referredUserId: json['referred_user_id'] as String,
      registrationId: json['registration_id'] as String?,
      rewardValue: parseFlexibleDecimal(json['reward_value']) ?? 0,
      status: ReferralRewardStatus.fromWire(json['status'] as String),
      qualifiedAt: json['qualified_at'] != null
          ? DateTime.parse(json['qualified_at'] as String)
          : null,
      issuedAt: json['issued_at'] != null
          ? DateTime.parse(json['issued_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

/// Mirrors `ReferralMineOut` exactly.
class MyReferral {
  final ReferralProfile profile;
  final List<ReferralReward> rewards;

  const MyReferral({required this.profile, required this.rewards});

  factory MyReferral.fromJson(Map<String, dynamic> json) {
    final rawRewards = json['rewards'] as List<dynamic>? ?? [];
    return MyReferral(
      profile:
          ReferralProfile.fromJson(json['profile'] as Map<String, dynamic>),
      rewards: rawRewards
          .map((r) => ReferralReward.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }
}
