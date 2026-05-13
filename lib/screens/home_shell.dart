import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yueplayer/screens/contacts_tab.dart';
import 'package:yueplayer/screens/discover_tab.dart';
import 'package:yueplayer/screens/moments_tab.dart';
import 'package:yueplayer/screens/profile_tab.dart';
import 'package:yueplayer/screens/publish_activity_page.dart';
import 'package:yueplayer/theme/app_colors.dart';

/// 底部导航 + 中央发布入口
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  /// 0 觅伴 1 动态 2 朋友 3 我的
  int _tab = 0;
  int _activitiesReloadToken = 0;

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

  void _onPublish() async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const PublishActivityPage()),
    );
    if (changed == true && mounted) {
      setState(() => _activitiesReloadToken++);
    }
  }

  void _onBottomTap(int slot) {
    if (slot == 0) setState(() => _tab = 0);
    if (slot == 1) setState(() => _tab = 1);
    if (slot == 3) setState(() => _tab = 2);
    if (slot == 4) setState(() => _tab = 3);
  }

  bool _isSelected(int slot) {
    if (slot == 0) return _tab == 0;
    if (slot == 1) return _tab == 1;
    if (slot == 3) return _tab == 2;
    if (slot == 4) return _tab == 3;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: IndexedStack(
        index: _tab,
        children: [
          DiscoverTab(
            key: ValueKey('discover_$_activitiesReloadToken'),
          ),
          const MomentsTab(),
          const ContactsTab(),
          const ProfileTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
        boxShadow: [
          BoxShadow(
            color: Color(0x08000000),
            offset: Offset(0, -4),
            blurRadius: 12,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56 + (bottom > 0 ? 0 : 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.explore_outlined, '觅伴'),
              _navItem(1, Icons.photo_outlined, '动态'),
              _fabSlot(),
              _navItem(3, Icons.people_outline, '朋友'),
              _navItem(4, Icons.person_outline, '我的'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int slot, IconData icon, String label) {
    final selected = _isSelected(slot);
    return Expanded(
      child: InkWell(
        onTap: () => _onBottomTap(slot),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 26,
              color: selected ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.primary : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fabSlot() {
    return Expanded(
      child: Transform.translate(
        offset: const Offset(0, -18),
        child: Center(
          child: Material(
            color: AppColors.primary,
            shape: const CircleBorder(),
            elevation: 6,
            shadowColor: AppColors.primary.withValues(alpha: 0.35),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _onPublish,
              child: Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: const Icon(Icons.add_circle_outline, color: Colors.white, size: 30),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
