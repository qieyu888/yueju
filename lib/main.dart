import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:yueplayer/screens/splash_page.dart';
import 'package:yueplayer/services/app_storage.dart';
import 'package:yueplayer/services/points_iap_service.dart';
import 'package:yueplayer/services/tracking_service.dart';
import 'package:yueplayer/theme/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    // ignore: deprecated_member_use
    await InAppPurchaseStoreKitPlatform.enableStoreKit1();
  }
  await AppStorage.instance.init();
  await PointsIapService.instance.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  runApp(const JiuyuApp());
}

class JiuyuApp extends StatefulWidget {
  const JiuyuApp({super.key});

  @override
  State<JiuyuApp> createState() => _JiuyuAppState();
}

class _JiuyuAppState extends State<JiuyuApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      requestAppTrackingAuthorizationIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
    );
    return MaterialApp(
      title: '久遇',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: scheme,
        scaffoldBackgroundColor: AppColors.scaffoldBg,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      ),
      home: const SplashPage(),
    );
  }
}
