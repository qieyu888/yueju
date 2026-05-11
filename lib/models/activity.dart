import 'dart:convert';

/// 聚会活动（无 freezed / 无 part）
class Activity {
  Activity({
    required this.id,
    required this.hostName,
    required this.title,
    required this.category,
    required this.timeLabel,
    required this.location,
    required this.joinedBase,
    required this.maxPeople,
    this.coverImageUrl,
    required this.fallbackGradientIndex,
    required this.badgeStatus,
    this.typeAccentIndex = 0,
  });

  final String id;
  final String hostName;
  final String title;
  final String category;
  final String timeLabel;
  final String location;
  final int joinedBase;
  final int maxPeople;
  final String? coverImageUrl;
  /// 对应 [activityFallbackGradients] 下标
  final int fallbackGradientIndex;
  /// open | hot | full
  final String badgeStatus;
  final int typeAccentIndex;

  bool isFull(Set<String> userJoinedIds) {
    final j = effectiveJoined(userJoinedIds);
    return j >= maxPeople || badgeStatus == 'full';
  }

  int effectiveJoined(Set<String> userJoinedIds) {
    final extra = userJoinedIds.contains(id) ? 1 : 0;
    final v = joinedBase + extra;
    if (v > maxPeople) return maxPeople;
    return v;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hostName': hostName,
      'title': title,
      'category': category,
      'timeLabel': timeLabel,
      'location': location,
      'joinedBase': joinedBase,
      'maxPeople': maxPeople,
      'coverImageUrl': coverImageUrl,
      'fallbackGradientIndex': fallbackGradientIndex,
      'badgeStatus': badgeStatus,
      'typeAccentIndex': typeAccentIndex,
    };
  }

  factory Activity.fromJson(Map<String, dynamic> m) {
    return Activity(
      id: m['id'] as String,
      hostName: m['hostName'] as String,
      title: m['title'] as String,
      category: m['category'] as String,
      timeLabel: m['timeLabel'] as String,
      location: m['location'] as String,
      joinedBase: (m['joinedBase'] as num).toInt(),
      maxPeople: (m['maxPeople'] as num).toInt(),
      coverImageUrl: m['coverImageUrl'] as String?,
      fallbackGradientIndex: (m['fallbackGradientIndex'] as num).toInt(),
      badgeStatus: m['badgeStatus'] as String? ?? 'open',
      typeAccentIndex: (m['typeAccentIndex'] as num?)?.toInt() ?? 0,
    );
  }

  static String encodeList(List<Activity> list) {
    return jsonEncode(list.map((e) => e.toJson()).toList());
  }

  static List<Activity> decodeList(String raw) {
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => Activity.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
