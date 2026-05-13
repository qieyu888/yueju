import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yueplayer/screens/agreement_gate_page.dart';
import 'package:yueplayer/navigation/entry_navigation.dart';
import 'package:yueplayer/services/app_storage.dart';
import 'package:yueplayer/theme/app_colors.dart';

/// 应用启动页：主色渐变、品牌文案，与产品「久遇」视觉一致。
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  static const _minDisplay = Duration(milliseconds: 2200);

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.primaryDark,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) => _goHome());
  }

  Future<void> _goHome() async {
    await Future<void>.delayed(_minDisplay);
    if (!mounted) return;
    if (!AppStorage.instance.isTermsAndPrivacyAccepted()) {
      await Navigator.of(context).pushReplacement<void, void>(
        PageRouteBuilder<void>(
          settings: const RouteSettings(name: '/agreement'),
          transitionDuration: const Duration(milliseconds: 420),
          pageBuilder: (context, animation, secondaryAnimation) => const AgreementGatePage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
              child: child,
            );
          },
        ),
      );
      return;
    }
    replaceWithPostAgreementApp(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
              Color(0xFF312E81),
            ],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _SoftOrbitPainter(color: Colors.white.withValues(alpha: 0.06)),
                  ),
                ),
              ),
              Center(
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 24,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.groups_rounded,
                            size: 46,
                            color: Colors.white.withValues(alpha: 0.95),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          '久遇',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                            height: 1.1,
                            color: Colors.white.withValues(alpha: 0.98),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '场景化轻社交',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                            color: Colors.white.withValues(alpha: 0.78),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 28,
                child: FadeTransition(
                  opacity: _fade,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white.withValues(alpha: 0.45),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '正在加载…',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 背景轻装饰，与久遇卡片的柔和气质呼应。
class _SoftOrbitPainter extends CustomPainter {
  _SoftOrbitPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width * 0.85, size.height * 0.12);
    canvas.drawCircle(c, size.width * 0.45, Paint()..color = color);
    final c2 = Offset(size.width * 0.08, size.height * 0.72);
    canvas.drawCircle(c2, size.width * 0.35, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _SoftOrbitPainter oldDelegate) => oldDelegate.color != color;
}
