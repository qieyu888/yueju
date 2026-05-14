import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';

/// iOS 14+ 应用跟踪透明度：在系统允许时弹出授权框（需在 Info.plist 配置说明文案）。
Future<void> requestAppTrackingAuthorizationIfNeeded() async {
  if (!Platform.isIOS) return;
  await Future<void>.delayed(const Duration(milliseconds: 400));
  try {
    final status = await AppTrackingTransparency.trackingAuthorizationStatus;
    if (status == TrackingStatus.notDetermined) {
      await AppTrackingTransparency.requestTrackingAuthorization();
    }
  } catch (_) {
    // 模拟器或旧系统可能无 ATT API，忽略即可。
  }
}
