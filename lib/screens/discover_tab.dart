import 'package:flutter/material.dart';
import 'package:yueplayer/data/activity_gradients.dart';
import 'package:yueplayer/data/sample_data.dart';
import 'package:yueplayer/models/activity.dart';
import 'package:yueplayer/screens/notifications_page.dart';
import 'package:yueplayer/services/app_storage.dart';
import 'package:yueplayer/theme/app_colors.dart';
import 'package:yueplayer/utils/activity_participant_labels.dart';
import 'package:yueplayer/widgets/letter_avatar.dart';

class DiscoverTab extends StatefulWidget {
  const DiscoverTab({super.key});

  @override
  State<DiscoverTab> createState() => _DiscoverTabState();
}

class _DiscoverTabState extends State<DiscoverTab> {
  late PageController _pageController;
  String _filter = '全部';
  List<Activity> _activities = [];
  Set<String> _joined = {};
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _loadAll();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final list = _filtered;
      if (list.isNotEmpty) _markViewed(list[0]);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _loadAll() {
    final user = AppStorage.instance.loadUserActivities();
    final seed = buildSeedActivities();
    _activities = [...user, ...seed];
    _joined = AppStorage.instance.getJoinedActivityIds();
  }

  List<Activity> get _filtered {
    if (_filter == '全部') return _activities;
    return _activities.where((a) => a.category == _filter).toList();
  }

  Color _typeChipColor(Activity a) {
    const palette = <Color>[
      Color(0xFFEA580C),
      Color(0xFF3B82F6),
      Color(0xFF22C55E),
      Color(0xFF6366F1),
      Color(0xFFEC4899),
      Color(0xFFA855F7),
      Color(0xFFF97316),
    ];
    return palette[a.typeAccentIndex % palette.length];
  }

  Future<void> _join(Activity a) async {
    if (a.isFull(_joined)) return;
    await AppStorage.instance.addJoinedActivityId(a.id);
    await AppStorage.instance.bumpJoinedStat();
    if (!mounted) return;
    setState(() {
      _joined.add(a.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已报名「${a.title}」')),
    );
  }

  Future<void> _markViewed(Activity a) async {
    await AppStorage.instance.addViewedActivityId(a.id);
  }

  Future<void> _openNotifications() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const NotificationsPage()),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    final unread = AppStorage.instance.inboxUnreadCount();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20, MediaQuery.paddingOf(context).top + 8, 20, 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '发现聚会',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _filter == '全部'
                          ? '共 ${_filtered.length} 场聚会 · 左右滑动挑选'
                          : '「$_filter」${_filtered.length} 场 · 左右滑动',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                onPressed: _openNotifications,
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications_none, size: 28, color: AppColors.textPrimary),
                    if (unread > 0)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: unread > 9 ? 5 : 0, vertical: 1),
                          constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade500,
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
        ),
        SizedBox(
          height: 40,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: activityFilters.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final f = activityFilters[i];
              final sel = _filter == f;
              return FilterChip(
                label: Text(f),
                selected: sel,
                onSelected: (_) {
                  setState(() {
                    _filter = f;
                    _page = 0;
                  });
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!_pageController.hasClients) return;
                    final n = _filtered.length;
                    if (n > 0) _pageController.jumpToPage(0);
                  });
                },
                showCheckmark: false,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: sel ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                backgroundColor: Colors.white,
                side: BorderSide(color: sel ? AppColors.primary : AppColors.cardBorder),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 4),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: list.isEmpty
              ? const Center(child: Text('该分类下暂无聚会'))
              : PageView.builder(
                  controller: _pageController,
                  itemCount: list.length,
                  onPageChanged: (i) {
                    setState(() => _page = i);
                    if (i < list.length) _markViewed(list[i]);
                  },
                  itemBuilder: (context, index) {
                    final a = list[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                      child: _ActivityHeroCard(
                        activity: a,
                        joinedIds: _joined,
                        typeColor: _typeChipColor(a),
                        onJoin: () => _join(a),
                        onOpen: () => _markViewed(a),
                      ),
                    );
                  },
                ),
        ),
        if (list.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                list.length,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == _page ? AppColors.primary : AppColors.textMuted.withValues(alpha: 0.35),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ActivityHeroCard extends StatelessWidget {
  const _ActivityHeroCard({
    required this.activity,
    required this.joinedIds,
    required this.typeColor,
    required this.onJoin,
    required this.onOpen,
  });

  final Activity activity;
  final Set<String> joinedIds;
  final Color typeColor;
  final VoidCallback onJoin;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final full = activity.isFull(joinedIds);
    final joined = activity.effectiveJoined(joinedIds);
    final alreadyJoined = joinedIds.contains(activity.id);
    final hasImage = activity.coverImageUrl != null && activity.coverImageUrl!.isNotEmpty;
    final avatarNames = activityParticipantLabels(activity, joined, joinedIds);

    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: Material(
        color: Colors.grey.shade900,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: InkWell(
                onTap: onOpen,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (hasImage)
                      Image.network(
                        activity.coverImageUrl!,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        errorBuilder: (context, error, stackTrace) =>
                            _GradientBg(index: activity.fallbackGradientIndex),
                        loadingBuilder: (c, child, p) {
                          if (p == null) return child;
                          return const ColoredBox(
                            color: Color(0xFF111827),
                            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          );
                        },
                      )
                    else
                      _GradientBg(index: activity.fallbackGradientIndex),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.35),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.78),
                          ],
                          stops: const [0, 0.45, 1],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.22),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
                                    child: Row(
                                      children: [
                                        LetterAvatar(name: activity.hostName, size: 32, radius: 10),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '发起人',
                                                style: TextStyle(
                                                  color: Colors.white.withValues(alpha: 0.75),
                                                  fontSize: 10,
                                                ),
                                              ),
                                              Text(
                                                activity.hostName,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  color: typeColor.withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                                  boxShadow: const [
                                    BoxShadow(color: Color(0x33000000), blurRadius: 6),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  child: Text(
                                    activity.category,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            activity.title,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              height: 1.15,
                              shadows: [Shadow(color: Color(0x66000000), blurRadius: 8)],
                            ),
                          ),
                          const SizedBox(height: 12),
                          _line(Icons.calendar_today_outlined, activity.timeLabel),
                          const SizedBox(height: 6),
                          _line(Icons.location_on_outlined, activity.location),
                          const SizedBox(height: 16),
                          const Divider(color: Color(0x33FFFFFF), height: 1),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ColoredBox(
              color: Colors.black.withValues(alpha: 0.55),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '已加入 ($joined/${activity.maxPeople})',
                            style: TextStyle(
                              color: Colors.grey.shade300,
                              fontSize: 10,
                              letterSpacing: 0.6,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              for (var i = 0; i < avatarNames.length; i++)
                                Transform.translate(
                                  offset: Offset(-8.0 * i, 0),
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
                                      color: Colors.grey.shade700,
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: LetterAvatar(
                                      name: avatarNames[i],
                                      size: 28,
                                      radius: 8,
                                    ),
                                  ),
                                ),
                              if (joined > 3)
                                Container(
                                  margin: EdgeInsets.only(left: avatarNames.isEmpty ? 0 : 4),
                                  width: 28,
                                  height: 28,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.black.withValues(alpha: 0.45),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                                  ),
                                  child: Text(
                                    '+${joined - 3}',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.85),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: (full || alreadyJoined)
                            ? Colors.white.withValues(alpha: 0.2)
                            : Colors.white,
                        foregroundColor: (full || alreadyJoined) ? Colors.white54 : Colors.black,
                        disabledBackgroundColor: Colors.white24,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      onPressed: (full || alreadyJoined) ? null : onJoin,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            alreadyJoined ? '已报名' : (full ? '已满员' : '我要去'),
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          if (!full && !alreadyJoined) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.chevron_right, size: 20),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _line(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.75)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade200,
              fontSize: 13,
              shadows: const [Shadow(color: Color(0x44000000), blurRadius: 4)],
            ),
          ),
        ),
      ],
    );
  }
}

class _GradientBg extends StatelessWidget {
  const _GradientBg({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(gradient: activityLinearGradient(index)),
    );
  }
}
