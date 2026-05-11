import 'package:flutter/material.dart';
import 'package:yueplayer/data/sample_data.dart';
import 'package:yueplayer/models/moment.dart';
import 'package:yueplayer/screens/compose_moment_page.dart';
import 'package:yueplayer/screens/moment_detail_page.dart';
import 'package:yueplayer/services/app_storage.dart';
import 'package:yueplayer/theme/app_colors.dart';
import 'package:yueplayer/widgets/letter_avatar.dart';
import 'package:yueplayer/widgets/moment_report_dialog.dart';

class MomentsTab extends StatefulWidget {
  const MomentsTab({super.key});

  @override
  State<MomentsTab> createState() => _MomentsTabState();
}

class _MomentsTabState extends State<MomentsTab> {
  List<Moment> _moments = [];
  Set<String> _liked = {};

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    final mine = AppStorage.instance.loadUserMoments();
    _moments = [...mine, ...buildSeedMoments()];
    _liked = AppStorage.instance.getLikedMomentIds();
  }

  int _likes(Moment m) {
    final bump = _liked.contains(m.id) ? 1 : 0;
    return m.likesBase + bump;
  }

  int _comments(Moment m) {
    return m.commentsBase + AppStorage.instance.extraCommentsFor(m.id);
  }

  Future<void> _toggleLike(Moment m) async {
    await AppStorage.instance.toggleLikedMoment(m.id);
    if (!mounted) return;
    setState(() {
      _refresh();
    });
  }

  Future<void> _openComments(Moment m) async {
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
                maxLines: 3,
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
      await AppStorage.instance.incrementMomentComment(m.id);
      if (!mounted) return;
      setState(() => _refresh());
    }
    controller.dispose();
  }

  Future<void> _openDetail(Moment m) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MomentDetailPage(moment: m)),
    );
    if (mounted) setState(() => _refresh());
  }

  Future<void> _compose() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const ComposeMomentPage()),
    );
    if (created == true && mounted) setState(() => _refresh());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20, MediaQuery.paddingOf(context).top + 12, 12, 12),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  '朋友动态',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: _compose,
                icon: const Icon(Icons.photo_outlined, size: 26, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            // 避免默认再套一层 MediaQuery 垂直安全区（与标题栏已处理的 top 重复，会出现一大块空白）
            padding: const EdgeInsets.only(bottom: 8),
            itemCount: _moments.length,
            separatorBuilder: (context, index) => const Divider(height: 1, thickness: 0.5),
            itemBuilder: (context, i) {
              final m = _moments[i];
              return _MomentTile(
                moment: m,
                likes: _likes(m),
                comments: _comments(m),
                liked: _liked.contains(m.id),
                onLike: () => _toggleLike(m),
                onComment: () => _openComments(m),
                onOpenDetail: () => _openDetail(m),
                onReport: () => showMomentReportFlow(context, m.id),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MomentTile extends StatelessWidget {
  const _MomentTile({
    required this.moment,
    required this.likes,
    required this.comments,
    required this.liked,
    required this.onLike,
    required this.onComment,
    required this.onOpenDetail,
    required this.onReport,
  });

  final Moment moment;
  final int likes;
  final int comments;
  final bool liked;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onOpenDetail;
  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LetterAvatar(name: moment.user.name, size: 40, radius: 12),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: onOpenDetail,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 4, bottom: 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              moment.user.name,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              moment.content,
                              style: const TextStyle(fontSize: 14, height: 1.45, color: AppColors.textPrimary),
                            ),
                            if (moment.imageUrls.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              _MomentImages(urls: moment.imageUrls),
                            ],
                            if (moment.activityRef != null) ...[
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.explore_outlined, size: 14, color: AppColors.primary.withValues(alpha: 0.9)),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        '参与了：${moment.activityRef}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    moment.timeLabel,
                                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: onLike,
                                  icon: Icon(
                                    liked ? Icons.favorite : Icons.favorite_border,
                                    size: 18,
                                    color: liked ? Colors.redAccent : AppColors.textMuted,
                                  ),
                                  label: Text('$likes', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                  style: TextButton.styleFrom(foregroundColor: AppColors.textMuted),
                                ),
                                TextButton.icon(
                                  onPressed: onComment,
                                  icon: const Icon(Icons.chat_bubble_outline, size: 18, color: AppColors.textMuted),
                                  label: Text('$comments', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.more_horiz, color: AppColors.textMuted, size: 22),
                    onSelected: (v) {
                      if (v == 'report') onReport();
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'report', child: Text('举报 / 投诉')),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MomentImages extends StatelessWidget {
  const _MomentImages({required this.urls});

  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    final cross = urls.length == 1 ? 1 : 2;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: urls.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cross,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        mainAxisExtent: 120,
      ),
      itemBuilder: (c, i) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            urls[i],
            fit: BoxFit.cover,
            alignment: Alignment.center,
            errorBuilder: (context, error, stackTrace) => Container(
              color: AppColors.cardBorder,
              alignment: Alignment.center,
              child: const Icon(Icons.broken_image_outlined, color: AppColors.textMuted),
            ),
          ),
        );
      },
    );
  }
}
