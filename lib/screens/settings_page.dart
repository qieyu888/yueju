import 'package:flutter/material.dart';
import 'package:yueplayer/screens/settings_flows.dart';
import 'package:yueplayer/screens/splash_page.dart';
import 'package:yueplayer/widgets/dialog_escape.dart';
import 'package:yueplayer/services/app_storage.dart';
import 'package:yueplayer/theme/app_colors.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _stealth = false;
  bool _cacheCleared = false;

  @override
  void initState() {
    super.initState();
    _stealth = AppStorage.instance.getStealthMode();
  }

  Future<void> _setStealth(bool v) async {
    await AppStorage.instance.setStealthMode(v);
    if (mounted) setState(() => _stealth = v);
  }

  Future<void> _renameDisplayName() async {
    final c = TextEditingController(text: AppStorage.instance.getDisplayName());
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => dialogCancelEscape(
        ctx,
        AlertDialog(
          title: const Text('修改昵称'),
          content: TextField(
            controller: c,
            decoration: const InputDecoration(hintText: '例如：小聚'),
            textCapitalization: TextCapitalization.words,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('保存')),
          ],
        ),
      ),
    );
    final newName = ok == true ? c.text.trim() : '';
    WidgetsBinding.instance.addPostFrameCallback((_) => c.dispose());
    if (ok == true && newName.isNotEmpty) {
      await AppStorage.instance.setDisplayName(newName);
      if (mounted) setState(() {});
    }
  }

  Future<void> _confirmClearCache() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => dialogCancelEscape(
        ctx,
        AlertDialog(
          title: const Text('清除缓存'),
          content: const Text(
            '将释放动态与活动封面等图片的内存缓存，不影响通讯录与已发布内容。下次浏览时会重新加载图片。',
            style: TextStyle(height: 1.45),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('清除')),
          ],
        ),
      ),
    );
    if (ok != true || !mounted) return;
    await clearAppImageCache();
    setState(() => _cacheCleared = true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('缓存已清理')));
    }
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: '约局',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.groups_rounded, color: AppColors.primary, size: 28),
      ),
      applicationLegalese: '© 2026',
      children: [
        const SizedBox(height: 8),
        Text(
          '场景化轻社交：发现聚会、记录动态、维护朋友联系。',
          style: TextStyle(fontSize: 13, height: 1.5, color: AppColors.textSecondary.withValues(alpha: 0.95)),
        ),
      ],
    );
  }

  void _push(Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  Future<void> _confirmDeleteAccount() async {
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => dialogCancelEscape(
        ctx,
        AlertDialog(
          title: const Text('注销账号'),
          content: const Text(
            '将删除本机上的昵称、通讯录、动态与活动草稿、报名与浏览记录、通知与举报等全部数据，且无法恢复。\n\n当前为本地使用，无独立云端账号；注销后需重新同意用户协议并进入应用。',
            style: TextStyle(height: 1.45),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('确认注销'),
            ),
          ],
        ),
      ),
    );
    if (ok != true || !mounted) return;
    await AppStorage.instance.deleteAccountLocal();
    await clearAppImageCache();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil<void>(
      MaterialPageRoute<void>(builder: (_) => const SplashPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: MediaQuery.paddingOf(context).top),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.chevron_left, color: AppColors.primary, size: 28),
                    label: const Text('返回', style: TextStyle(color: AppColors.primary, fontSize: 16)),
                  ),
                ),
                const Text(
                  '设置与隐私',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                _group(
                  children: [
                    _tile(
                      '我的昵称',
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppStorage.instance.getDisplayName(),
                            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                          ),
                          const Icon(Icons.chevron_right, color: AppColors.textMuted),
                        ],
                      ),
                      onTap: _renameDisplayName,
                    ),
                    const Divider(height: 1),
                    _tile(
                      '账号与安全',
                      trailing: _chevronTrail('查看说明'),
                      onTap: () => _push(const SettingsSecurityPage()),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      title: Text(
                        '注销账号',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.red.shade700),
                      ),
                      subtitle: const Text(
                        '清除本机全部个人数据',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                      onTap: _confirmDeleteAccount,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _group(
                  children: [
                    _tile(
                      '新消息通知',
                      trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
                      onTap: () => _push(const SettingsNotificationsPage()),
                    ),
                    const Divider(height: 1),
                    _tile(
                      '黑名单与权限',
                      trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
                      onTap: () => _push(const SettingsBlockedPage()),
                    ),
                    const Divider(height: 1),
                    SwitchListTile.adaptive(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      title: const Text('隐身模式 (不被推荐给朋友)', style: TextStyle(fontSize: 15)),
                      subtitle: const Text('减少在好友侧的曝光，规则会随版本更新', style: TextStyle(fontSize: 12)),
                      value: _stealth,
                      onChanged: _setStealth,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _group(
                  children: [
                    _tile(
                      '清除缓存',
                      trailing: Text(
                        _cacheCleared ? '已清理' : '图片预览等',
                        style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                      ),
                      onTap: _confirmClearCache,
                    ),
                    const Divider(height: 1),
                    _tile(
                      '关于约局',
                      trailing: _chevronTrail('1.0.0'),
                      onTap: _showAbout,
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Center(
                  child: Text(
                    '约局',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted.withValues(alpha: 0.85), letterSpacing: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _group({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _tile(String title, {Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 15, color: AppColors.textPrimary)),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: AppColors.textMuted),
      onTap: onTap,
    );
  }

  Widget _chevronTrail(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        const Icon(Icons.chevron_right, color: AppColors.textMuted),
      ],
    );
  }
}
