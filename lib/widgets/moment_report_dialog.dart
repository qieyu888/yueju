import 'package:flutter/material.dart';
import 'package:yueplayer/services/app_storage.dart';
import 'package:yueplayer/theme/app_colors.dart';
import 'package:yueplayer/widgets/dialog_escape.dart';

Future<void> showMomentReportFlow(BuildContext context, String momentId) async {
  final category = await showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '举报 / 投诉',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
              ),
              const SizedBox(height: 4),
              Text(
                '请选择原因，便于我们核查与处理',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 12),
              _reasonTile(ctx, '垃圾信息 / 广告', 'spam'),
              _reasonTile(ctx, '不实或误导内容', 'misleading'),
              _reasonTile(ctx, '骚扰或人身攻击', 'harassment'),
              _reasonTile(ctx, '违法违规内容', 'illegal'),
              _reasonTile(ctx, '其他', 'other'),
            ],
          ),
        ),
      );
    },
  );
  if (category == null || !context.mounted) return;

  final detail = TextEditingController();
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => dialogCancelEscape(
      ctx,
      AlertDialog(
        title: const Text('补充说明（选填）'),
        content: TextField(
          controller: detail,
          maxLines: 3,
          decoration: const InputDecoration(hintText: '可补充具体情况…'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('提交'),
          ),
        ],
      ),
    ),
  );
  final extra = ok == true ? detail.text.trim() : '';
  WidgetsBinding.instance.addPostFrameCallback((_) => detail.dispose());
  if (ok != true || !context.mounted) return;

  await AppStorage.instance.addMomentReport(momentId, category, extra);
  if (context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('已收到你的反馈，感谢监督')));
  }
}

Widget _reasonTile(BuildContext ctx, String label, String value) {
  return ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
    onTap: () => Navigator.pop(ctx, value),
  );
}
