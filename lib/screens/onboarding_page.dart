import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yueplayer/screens/home_shell.dart';
import 'package:yueplayer/services/app_storage.dart';
import 'package:yueplayer/theme/app_colors.dart';

class _Slide {
  const _Slide({
    required this.icon,
    required this.title,
    required this.body,
    required this.tint,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color tint;
}

/// 首次进入应用时的功能引导。
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static const _slides = <_Slide>[
    _Slide(
      icon: Icons.explore_rounded,
      title: '发现身边的局',
      body: '按场景滑动浏览活动，找到感兴趣的局，随时加入。',
      tint: Color(0xFF6366F1),
    ),
    _Slide(
      icon: Icons.photo_outlined,
      title: '记录真实动态',
      body: '发动态、看朋友分享，用图文留住当下的聚会与心情。',
      tint: Color(0xFF3B82F6),
    ),
    _Slide(
      icon: Icons.groups_rounded,
      title: '朋友与联系',
      body: '维护通讯录、搜索好友，一键拨号或发短信延续缘分。',
      tint: AppColors.primary,
    ),
  ];

  final _pageController = PageController();
  int _page = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: AppColors.scaffoldBg,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _isLast => _page >= _slides.length - 1;

  Future<void> _complete() async {
    await AppStorage.instance.setOnboardingDone();
    if (!mounted) return;
    await Navigator.of(context).pushReplacement<void, void>(
      PageRouteBuilder<void>(
        settings: const RouteSettings(name: '/home'),
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) => const HomeShell(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          );
        },
      ),
    );
  }

  void _onPrimaryTap() {
    if (_isLast) {
      _complete();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _complete,
                  child: const Text('跳过', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (context, i) {
                    final s = _slides[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: s.tint.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(color: s.tint.withValues(alpha: 0.2)),
                            ),
                            child: Icon(s.icon, size: 56, color: s.tint),
                          ),
                          const SizedBox(height: 36),
                          Text(
                            s.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            s.body,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.55,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_slides.length, (i) {
                        final active = i == _page;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: active ? 22 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: active ? AppColors.primary : AppColors.cardBorder,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: _onPrimaryTap,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: Text(
                          _isLast ? '进入约局' : '下一步',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
