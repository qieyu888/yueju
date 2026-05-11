import 'package:yueplayer/models/activity.dart';
import 'package:yueplayer/services/app_storage.dart';

/// 为「已加入」头像区生成稳定昵称（发起人 + 伪名池；若当前用户已报名则优先展示「我」）
List<String> activityParticipantLabels(
  Activity activity,
  int joinedDisplay,
  Set<String> joinedIds,
) {
  final n = joinedDisplay.clamp(0, 3);
  if (n <= 0) return [];

  const pool = ['小陈', '阿伟', 'Momo', '小北', '青青', '老刘', 'Nina', '阿豪', '大壮', '小雨', '阿乐', '琪琪'];
  final names = <String>[activity.hostName];
  var h = activity.id.hashCode;
  for (var k = 1; k < n; k++) {
    h = (h * 17 + k * 13) & 0x7fffffff;
    names.add(pool[h % pool.length]);
  }

  if (joinedIds.contains(activity.id)) {
    final me = AppStorage.instance.getDisplayName();
    if (names.length >= 2) {
      names[1] = me;
    }
  }

  return names.take(n).toList();
}
