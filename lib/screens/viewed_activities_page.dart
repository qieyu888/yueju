import 'package:flutter/material.dart';
import 'package:yueplayer/data/sample_data.dart';
import 'package:yueplayer/models/activity.dart';
import 'package:yueplayer/services/app_storage.dart';
import 'package:yueplayer/theme/app_colors.dart';

class ViewedActivitiesPage extends StatelessWidget {
  const ViewedActivitiesPage({super.key});

  List<Activity> _resolve() {
    final viewed = AppStorage.instance.getViewedActivityIds();
    final all = [...AppStorage.instance.loadUserActivities(), ...buildSeedActivities()];
    final map = {for (final a in all) a.id: a};
    return viewed.map((id) => map[id]).whereType<Activity>().toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _resolve();
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text('我看过的聚会'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
      ),
      body: list.isEmpty
          ? const Center(child: Text('滑动首页卡片即可记录浏览', style: TextStyle(color: AppColors.textSecondary)))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final a = list[i];
                return ListTile(
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  title: Text(a.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text('${a.category} · ${a.timeLabel}', style: const TextStyle(fontSize: 12)),
                );
              },
            ),
    );
  }
}
