import 'package:flutter/material.dart';
import 'package:yueplayer/data/sample_data.dart';
import 'package:yueplayer/models/activity.dart';
import 'package:yueplayer/services/app_storage.dart';
import 'package:yueplayer/theme/app_colors.dart';

class UpcomingTripsPage extends StatelessWidget {
  const UpcomingTripsPage({super.key});

  List<Activity> _resolve() {
    final joined = AppStorage.instance.getJoinedActivityIds();
    final all = [...AppStorage.instance.loadUserActivities(), ...buildSeedActivities()];
    final map = {for (final a in all) a.id: a};
    return joined.map((id) => map[id]).whereType<Activity>().toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _resolve();
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text('即将开始的行程'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
      ),
      body: list.isEmpty
          ? const Center(child: Text('暂无已报名的行程', style: TextStyle(color: AppColors.textSecondary)))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final a = list[i];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('${a.timeLabel} · ${a.location}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      const SizedBox(height: 6),
                      Text('局长：${a.hostName}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
