import 'package:flutter/material.dart';
import 'package:yueplayer/screens/home_shell.dart';
import 'package:yueplayer/screens/onboarding_page.dart';
import 'package:yueplayer/services/app_storage.dart';

/// 闪屏 / 协议页之后：进入引导或主页。
void replaceWithPostAgreementApp(BuildContext context) {
  final onboardingDone = AppStorage.instance.isOnboardingDone();
  final Widget next = onboardingDone ? const HomeShell() : const OnboardingPage();
  final String name = onboardingDone ? '/home' : '/onboarding';
  Navigator.of(context).pushReplacement<void, void>(
    PageRouteBuilder<void>(
      settings: RouteSettings(name: name),
      transitionDuration: const Duration(milliseconds: 420),
      reverseTransitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, animation, secondaryAnimation) => next,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        );
      },
    ),
  );
}
