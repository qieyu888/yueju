import 'dart:convert';

/// 应用内通知列表中的一条。
class InboxMessage {
  const InboxMessage({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAtMs,
    required this.read,
    required this.kind,
  });

  final String id;
  final String title;
  final String body;
  final int createdAtMs;
  final bool read;

  /// activity | moment | system | nearby
  final String kind;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'createdAtMs': createdAtMs,
        'read': read,
        'kind': kind,
      };

  factory InboxMessage.fromJson(Map<String, dynamic> m) {
    return InboxMessage(
      id: m['id'] as String,
      title: m['title'] as String,
      body: m['body'] as String,
      createdAtMs: (m['createdAtMs'] as num).toInt(),
      read: m['read'] as bool,
      kind: m['kind'] as String,
    );
  }

  InboxMessage copyWith({bool? read}) {
    return InboxMessage(
      id: id,
      title: title,
      body: body,
      createdAtMs: createdAtMs,
      read: read ?? this.read,
      kind: kind,
    );
  }

  static String encodeList(List<InboxMessage> list) {
    return jsonEncode(list.map((e) => e.toJson()).toList());
  }

  static List<InboxMessage> decodeList(String raw) {
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((e) => InboxMessage.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }
}
