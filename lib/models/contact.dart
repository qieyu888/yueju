import 'dart:convert';

class Contact {
  const Contact({
    required this.id,
    required this.name,
    required this.phone,
    required this.bio,
  });

  final String id;
  final String name;
  final String phone;
  final String bio;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'bio': bio,
      };

  factory Contact.fromJson(Map<String, dynamic> m) {
    return Contact(
      id: m['id'] as String,
      name: m['name'] as String,
      phone: m['phone'] as String,
      bio: m['bio'] as String,
    );
  }

  Contact copyWith({String? id, String? name, String? phone, String? bio}) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
    );
  }

  static String encodeList(List<Contact> list) {
    return jsonEncode(list.map((e) => e.toJson()).toList());
  }

  static List<Contact> decodeList(String raw) {
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => Contact.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
