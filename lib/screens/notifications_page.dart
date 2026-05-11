import 'package:flutter/material.dart';
import 'package:yueplayer/models/inbox_message.dart';
import 'package:yueplayer/services/app_storage.dart';
import 'package:yueplayer/theme/app_colors.dart';
import 'package:yueplayer/widgets/dialog_escape.dart';

String inboxRelativeTime(int createdAtMs) {
  final d = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(createdAtMs));
  if (d.inSeconds < 45) return '刚刚';
  if (d.inMinutes < 60) return '${d.inMinutes} 分钟前';
  if (d.inHours < 24) return '${d.inHours} 小时前';
  if (d.inDays == 1) return '昨天';
  if (d.inDays < 7) return '${d.inDays} 天前';
  final t = DateTime.fromMillisecondsSinceEpoch(createdAtMs);
  return '${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';
}

IconData _inboxIcon(String kind) {
  switch (kind) {
    case 'moment':
      return Icons.favorite_outline;
    case 'nearby':
      return Icons.place_outlined;
    case 'system':
      return Icons.info_outline_rounded;
    case 'activity':
    default:
      return Icons.celebration_outlined;
  }
}

Color _inboxColor(String kind) {
  switch (kind) {
    case 'moment':
      return const Color(0xFFEC4899);
    case 'nearby':
      return const Color(0xFF059669);
    case 'system':
      return AppColors.primary;
    case 'activity':
    default:
      return const Color(0xFFEA580C);
  }
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<InboxMessage> _list = [];

  void _reload() {
    _list = AppStorage.instance.loadInboxMessages();
  }

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _markAllRead() async {
    await AppStorage.instance.markAllInboxRead();
    if (mounted) {
      setState(_reload);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已全部标为已读')));
    }
  }

  Future<void> _confirmClear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => dialogCancelEscape(
        ctx,
        AlertDialog(
          title: const Text('清空通知'),
          content: const Text('确定清空全部通知？此操作不可恢复。'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('清空'),
            ),
          ],
        ),
      ),
    );
    if (ok != true || !mounted) return;
    await AppStorage.instance.clearInbox();
    if (mounted) {
      setState(_reload);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已清空')));
    }
  }

  Future<void> _onTapItem(InboxMessage m) async {
    if (!m.read) {
      await AppStorage.instance.markInboxMessageRead(m.id);
      if (mounted) setState(_reload);
    }
  }

  @override
  Widget build(BuildContext context) {
    final unread = _list.where((e) => !e.read).length;
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text('通知', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: _list.isEmpty || unread == 0 ? null : _markAllRead,
            child: const Text('一键已读'),
          ),
          TextButton(
            onPressed: _list.isEmpty ? null : _confirmClear,
            child: Text('一键清空', style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: _list.isEmpty
          ? Center(
              child: Text(
                '暂无通知',
                style: TextStyle(fontSize: 15, color: AppColors.textMuted.withValues(alpha: 0.9)),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: _list.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final m = _list[i];
                final ic = _inboxIcon(m.kind);
                final cc = _inboxColor(m.kind);
                return Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => _onTapItem(m),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: cc.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(ic, color: cc, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        m.title,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: m.read ? FontWeight.w600 : FontWeight.w800,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    if (!m.read)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        margin: const EdgeInsets.only(left: 6, top: 4),
                                        decoration: const BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  m.body,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    height: 1.45,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  inboxRelativeTime(m.createdAtMs),
                                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
