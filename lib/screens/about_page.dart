import 'package:flutter/material.dart';
import 'package:yueplayer/theme/app_colors.dart';

/// 关于应用与「联系我们」（演示：不联网提交）。
class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final _feedback = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _feedback.dispose();
    super.dispose();
  }

  Future<void> _fakeSend() async {
    final text = _feedback.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请先输入要发送的内容')));
      return;
    }
    setState(() => _sending = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _sending = false);
    _feedback.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已收到您的反馈（演示模式，未实际发送）')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text('关于觅伴', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.groups_rounded, color: AppColors.primary, size: 40),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              '觅伴',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              '版本 1.0.0',
              style: TextStyle(fontSize: 14, color: AppColors.textMuted.withValues(alpha: 0.95)),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '场景化轻社交：发现聚会、记录动态、维护朋友联系。',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, height: 1.55, color: AppColors.textSecondary.withValues(alpha: 0.95)),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text('© 2026', style: TextStyle(fontSize: 12, color: AppColors.textMuted.withValues(alpha: 0.9))),
          ),
          const SizedBox(height: 32),
          const Text('联系我们', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(
            '如有问题或建议，可直接在下方输入并发送（当前为演示，不会上传到服务器）。',
            style: TextStyle(fontSize: 13, height: 1.45, color: AppColors.textSecondary.withValues(alpha: 0.95)),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _feedback,
            maxLines: 6,
            minLines: 4,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              hintText: '请输入您要反馈的内容…',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: _sending ? null : _fakeSend,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _sending
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('发送', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}
