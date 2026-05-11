import 'dart:convert';

class MomentUser {
  MomentUser({required this.name});

  final String name;

  Map<String, dynamic> toJson() => {'name': name};

  factory MomentUser.fromJson(Map<String, dynamic> m) {
    return MomentUser(name: m['name'] as String);
  }
}

class Moment {
  Moment({
    required this.id,
    required this.user,
    required this.timeLabel,
    required this.content,
    required this.imageUrls,
    required this.likesBase,
    required this.commentsBase,
    this.activityRef,
  });

  final String id;
  final MomentUser user;
  final String timeLabel;
  final String content;
  final List<String> imageUrls;
  final int likesBase;
  final int commentsBase;
  final String? activityRef;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'timeLabel': timeLabel,
      'content': content,
      'imageUrls': imageUrls,
      'likesBase': likesBase,
      'commentsBase': commentsBase,
      'activityRef': activityRef,
    };
  }

  factory Moment.fromJson(Map<String, dynamic> m) {
    return Moment(
      id: m['id'] as String,
      user: MomentUser.fromJson(Map<String, dynamic>.from(m['user'] as Map)),
      timeLabel: m['timeLabel'] as String,
      content: m['content'] as String,
      imageUrls: List<String>.from(m['imageUrls'] as List<dynamic>? ?? []),
      likesBase: (m['likesBase'] as num).toInt(),
      commentsBase: (m['commentsBase'] as num).toInt(),
      activityRef: m['activityRef'] as String?,
    );
  }

  static String encodeList(List<Moment> list) {
    return jsonEncode(list.map((e) => e.toJson()).toList());
  }

  static List<Moment> decodeList(String raw) {
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => Moment.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
