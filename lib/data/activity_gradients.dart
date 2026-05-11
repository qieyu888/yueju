import 'package:flutter/material.dart';

/// 活动无配图时使用的渐变色对。
final List<List<Color>> activityFallbackGradients = [
  [const Color(0xFF22C55E), const Color(0xFF065F46)],
  [const Color(0xFF1F2937), const Color(0xFF581C87)],
  [const Color(0xFFFB923C), const Color(0xFFDC2626)],
  [const Color(0xFFEC4899), const Color(0xFF4F46E5)],
  [const Color(0xFF60A5FA), const Color(0xFF4F46E5)],
  [const Color(0xFF93C5FD), const Color(0xFF1E40AF)],
  [const Color(0xFFFB923C), const Color(0xFFB45309)],
  [const Color(0xFFF472B6), const Color(0xFF7C3AED)],
];

LinearGradient activityLinearGradient(int index) {
  final i = index.clamp(0, activityFallbackGradients.length - 1);
  final pair = activityFallbackGradients[i];
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: pair,
  );
}
