import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:yueplayer/iap/store_products.dart';
import 'package:yueplayer/services/app_storage.dart';
import 'package:yueplayer/services/points_iap_service.dart';
import 'package:yueplayer/theme/app_colors.dart';
import 'package:yueplayer/widgets/letter_avatar.dart';
import 'package:yueplayer/screens/notifications_page.dart';
import 'package:yueplayer/screens/settings_page.dart';
import 'package:yueplayer/screens/upcoming_trips_page.dart';
import 'package:yueplayer/screens/viewed_activities_page.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  late String _name;
  late int _hosted;
  late int _joined;

  void _onPointsFromIap() {
    if (!mounted) return;
    setState(_reload);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('购买成功，积分已到账')));
  }

  @override
  void initState() {
    super.initState();
    _reload();
    PointsIapService.instance.onPointsChanged = _onPointsFromIap;
    unawaited(
      PointsIapService.instance.ensureInitialized().then((_) {
        if (mounted) setState(() {});
      }),
    );
  }

  @override
  void dispose() {
    if (PointsIapService.instance.onPointsChanged == _onPointsFromIap) {
      PointsIapService.instance.onPointsChanged = null;
    }
    super.dispose();
  }

  void _reload() {
    _name = AppStorage.instance.getDisplayName();
    _hosted = AppStorage.instance.getHostedCount();
    _joined = AppStorage.instance.getJoinedStatCount();
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push(
      CupertinoPageRoute(builder: (_) => const SettingsPage()),
    );
    if (mounted) setState(() => _reload());
  }

  Future<void> _openNotifications() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const NotificationsPage()),
    );
    if (mounted) setState(() => _reload());
  }

  @override
  Widget build(BuildContext context) {
    final unread = AppStorage.instance.inboxUnreadCount();
    final points = AppStorage.instance.getUserPoints();
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(20, MediaQuery.paddingOf(context).top + 24, 20, 48),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        '我的主页',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _openNotifications,
                      icon: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(Icons.notifications_none, color: Colors.white),
                          if (unread > 0)
                            Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: unread > 9 ? 5 : 0, vertical: 1),
                                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade400,
                                  borderRadius: BorderRadius.circular(9),
                                  border: Border.all(color: Colors.white, width: 1.5),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  unread > 9 ? '9+' : '$unread',
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    LetterAvatar(name: _name, size: 80, radius: 18),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '社交达人 · 已参与 $_joined 场聚会',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.82),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -24),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _stat(_hosted.toString(), '发起的局'),
                        Container(width: 1, height: 36, color: AppColors.cardBorder),
                        _stat(_joined.toString(), '参与的局'),
                        Container(width: 1, height: 36, color: AppColors.cardBorder),
                        _stat(AppStorage.instance.getFriendsCount().toString(), '我的朋友'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _pointsAndIapCard(points),
                  const SizedBox(height: 16),
                  _menuCard(
                    children: [
                      _menuRow('即将开始的行程', () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(builder: (_) => const UpcomingTripsPage()),
                        );
                      }),
                      _divider(),
                      _menuRow('我看过的聚会', () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(builder: (_) => const ViewedActivitiesPage()),
                        );
                      }),
                      _divider(),
                      _menuRow('设置与隐私', _openSettings),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pointsAndIapCard(int points) {
    final svc = PointsIapService.instance;
    final err = svc.catalogError;
    final loaded = svc.catalogLoaded;

    ProductDetails? detailFor(String productId) {
      for (final p in svc.products) {
        if (p.id == productId) return p;
      }
      return null;
    }

    String priceLabel(String productId) {
      final d = detailFor(productId);
      if (d != null) return d.price;
      if (!loaded) return '…';
      return '—';
    }

    Future<void> buy(String productId) async {
      final d = detailFor(productId);
      if (d == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err ?? '该档位暂不可用，请稍后再试'),
          ),
        );
        await svc.refreshCatalog();
        if (mounted) setState(_reload);
        return;
      }
      try {
        final ok = await svc.buyPack(d);
        if (!ok && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('无法发起购买，请检查网络与商店登录状态')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('购买未完成，请稍后再试')));
        }
      }
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('我的积分', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text(
                      '$points',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              if (!loaded)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 14),
          const Text('充值积分', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var i = 0; i < kPointsPacks.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _IapPackButton(
                    label: priceLabel(kPointsPacks[i].productId),
                    sub: '+${kPointsPacks[i].bonusPoints} 分',
                    onTap: () => buy(kPointsPacks[i].productId),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _menuCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() => const Divider(height: 1, thickness: 0.5);

  Widget _menuRow(String title, VoidCallback onTap) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
      onTap: onTap,
    );
  }
}

class _IapPackButton extends StatelessWidget {
  const _IapPackButton({required this.label, required this.sub, required this.onTap});

  final String label;
  final String sub;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Column(
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.primary),
              ),
              const SizedBox(height: 2),
              Text(sub, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary.withValues(alpha: 0.9))),
            ],
          ),
        ),
      ),
    );
  }
}
