import 'package:flutter/material.dart';
import 'package:yueplayer/services/app_storage.dart';
import 'package:yueplayer/theme/app_colors.dart';

/// 账号与安全说明
class SettingsSecurityPage extends StatelessWidget {
  const SettingsSecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text('账号与安全', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(
            title: '登录与账号',
            child: const Text(
              '手机号登录与更多安全能力会陆续上线。现在可在「设置」里修改展示昵称；不再需要本应用时，请使用「注销账号」清除本机数据。',
              style: TextStyle(fontSize: 14, height: 1.5, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 12),
          _card(
            title: '隐私与数据',
            child: const Text(
              '我们按照《隐私政策》说明的方式处理您的信息。您可通过系统「设置」管理本应用的各项系统权限。',
              style: TextStyle(fontSize: 14, height: 1.5, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 12),
          _card(
            title: '设备与会话',
            child: const Text(
              '远程退出其他设备登录等功能会逐步提供。请妥善保管手机锁屏密码，避免他人擅自使用。',
              style: TextStyle(fontSize: 14, height: 1.5, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

/// 新消息通知（偏好写入本地）
class SettingsNotificationsPage extends StatefulWidget {
  const SettingsNotificationsPage({super.key});

  @override
  State<SettingsNotificationsPage> createState() => _SettingsNotificationsPageState();
}

class _SettingsNotificationsPageState extends State<SettingsNotificationsPage> {
  late bool _moment;
  late bool _activity;

  @override
  void initState() {
    super.initState();
    _moment = AppStorage.instance.getNotifyMomentReplies();
    _activity = AppStorage.instance.getNotifyActivityTips();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text('新消息通知', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  title: const Text('动态互动提醒', style: TextStyle(fontSize: 15)),
                  subtitle: const Text('动态里的点赞、评论等', style: TextStyle(fontSize: 12)),
                  value: _moment,
                  onChanged: (v) async {
                    await AppStorage.instance.setNotifyMomentReplies(v);
                    if (mounted) setState(() => _moment = v);
                  },
                ),
                const Divider(height: 1),
                SwitchListTile.adaptive(
                  title: const Text('聚会与活动提醒', style: TextStyle(fontSize: 15)),
                  subtitle: const Text('报名成功、活动变更等', style: TextStyle(fontSize: 12)),
                  value: _activity,
                  onChanged: (v) async {
                    await AppStorage.instance.setNotifyActivityTips(v);
                    if (mounted) setState(() => _activity = v);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '推送服务上线后，会按你的选择发送提醒；目前先保存这些偏好。',
            style: TextStyle(fontSize: 12, height: 1.45, color: AppColors.textMuted.withValues(alpha: 0.95)),
          ),
        ],
      ),
    );
  }
}

/// 黑名单与权限说明
class SettingsBlockedPage extends StatelessWidget {
  const SettingsBlockedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text('黑名单与权限', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('屏蔽名单', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      '暂无屏蔽用户',
                      style: TextStyle(fontSize: 14, color: AppColors.textMuted.withValues(alpha: 0.9)),
                    ),
                  ),
                ),
                Text(
                  '遇到骚扰请优先使用举报。在动态或个人页一键屏蔽的能力正在筹备。',
                  style: TextStyle(fontSize: 13, height: 1.5, color: AppColors.textSecondary.withValues(alpha: 0.95)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('系统权限说明', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                _bullet('网络：加载活动封面与动态图片。'),
                _bullet('电话 / 短信：在朋友页跳转系统拨号或短信应用。'),
                _bullet('存储：保存偏好与本地草稿（随系统策略可能合并为「文件与媒体」）。'),
                const SizedBox(height: 8),
                Text(
                  '可在手机系统设置中随时管理本应用权限。',
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted.withValues(alpha: 0.95)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('· ', style: TextStyle(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w800)),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13, height: 1.45, color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}

/// 清除图片内存缓存（网络预览等）
Future<void> clearAppImageCache() async {
  PaintingBinding.instance.imageCache.clear();
  PaintingBinding.instance.imageCache.clearLiveImages();
}
