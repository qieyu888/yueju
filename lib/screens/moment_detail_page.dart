import 'package:flutter/material.dart';
import 'package:yueplayer/models/moment.dart';
import 'package:yueplayer/services/app_storage.dart';
import 'package:yueplayer/theme/app_colors.dart';
import 'package:yueplayer/widgets/letter_avatar.dart';
import 'package:yueplayer/widgets/moment_report_dialog.dart';

class MomentDetailPage extends StatefulWidget {
  const MomentDetailPage({super.key, required this.moment});

  final Moment moment;

  @override
  State<MomentDetailPage> createState() => _MomentDetailPageState();
}

class _MomentDetailPageState extends State<MomentDetailPage> {
  late Moment _m;
  Set<String> _liked = {};

  @override
  void initState() {
    super.initState();
    _m = widget.moment;
    _liked = AppStorage.instance.getLikedMomentIds();
  }

  void _sync() {
    _liked = AppStorage.instance.getLikedMomentIds();
  }

  int get _likes => _m.likesBase + (_liked.contains(_m.id) ? 1 : 0);

  int get _comments => _m.commentsBase + AppStorage.instance.extraCommentsFor(_m.id);

  bool get _likedHere => _liked.contains(_m.id);

  Future<void> _toggleLike() async {
    await AppStorage.instance.toggleLikedMoment(_m.id);
    if (!mounted) return;
    setState(() => _sync());
  }

  Future<void> _addComment() async {
    final controller = TextEditingController();
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final bottom = MediaQuery.viewInsetsOf(ctx).bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('写评论', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: '友善发言…',
                  filled: true,
                  fillColor: AppColors.scaffoldBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('发送'),
              ),
            ],
          ),
        );
      },
    );
    if (ok == true && controller.text.trim().isNotEmpty) {
      await AppStorage.instance.incrementMomentComment(_m.id);
      if (mounted) setState(() {});
    }
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('动态详情'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
        actions: [
          TextButton(
            onPressed: () => showMomentReportFlow(context, _m.id),
            child: const Text('举报', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      LetterAvatar(name: _m.user.name, size: 48, radius: 14),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _m.user.name,
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.textPrimary),
                            ),
                            Text(
                              _m.timeLabel,
                              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _m.content,
                    style: const TextStyle(fontSize: 16, height: 1.55, color: AppColors.textPrimary),
                  ),
                  if (_m.imageUrls.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _DetailImages(urls: _m.imageUrls),
                  ],
                  if (_m.activityRef != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.explore_outlined, size: 18, color: AppColors.primary.withValues(alpha: 0.95)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '参与了：${_m.activityRef}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () => showMomentReportFlow(context, _m.id),
                    icon: const Icon(Icons.flag_outlined, size: 20),
                    label: const Text('投诉 / 举报此条动态'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.cardBorder),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Material(
            elevation: 8,
            color: Colors.white,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _toggleLike,
                        icon: Icon(
                          _likedHere ? Icons.favorite : Icons.favorite_border,
                          color: _likedHere ? Colors.redAccent : AppColors.textMuted,
                          size: 22,
                        ),
                        label: Text('点赞 $_likes'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _addComment,
                        icon: const Icon(Icons.chat_bubble_outline, size: 20),
                        label: Text('评论 $_comments'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailImages extends StatelessWidget {
  const _DetailImages({required this.urls});

  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < urls.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: Image.network(
                urls[i],
                fit: BoxFit.cover,
                alignment: Alignment.center,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.cardBorder,
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image_outlined, color: AppColors.textMuted, size: 40),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
