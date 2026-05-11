import 'package:flutter/material.dart';

/// 根据昵称生成头像底色。
Color avatarColorForName(String name) {
  const palette = <Color>[
    Color(0xFFF87171),
    Color(0xFF60A5FA),
    Color(0xFF4ADE80),
    Color(0xFFFACC15),
    Color(0xFFC084FC),
    Color(0xFFF472B6),
    Color(0xFF818CF8),
    Color(0xFF2DD4BF),
    Color(0xFFFB923C),
  ];
  var hash = 0;
  for (var i = 0; i < name.length; i++) {
    hash = name.codeUnitAt(i) + ((hash << 5) - hash);
  }
  return palette[hash.abs() % palette.length];
}

class LetterAvatar extends StatelessWidget {
  const LetterAvatar({
    super.key,
    required this.name,
    this.size = 40,
    this.radius = 12,
  });

  final String name;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final initial = name.isEmpty ? '?' : String.fromCharCode(name.runes.first).toUpperCase();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: avatarColorForName(name.isEmpty ? '?' : name),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.38,
        ),
      ),
    );
  }
}
