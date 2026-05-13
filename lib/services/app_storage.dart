import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:yueplayer/data/sample_data.dart';
import 'package:yueplayer/models/activity.dart';
import 'package:yueplayer/models/contact.dart';
import 'package:yueplayer/models/inbox_message.dart';
import 'package:yueplayer/models/moment.dart';

/// 应用偏好与本地数据存储。
class AppStorage {
  AppStorage._();

  static final AppStorage instance = AppStorage._();

  static const _kJoinedActivityIds = 'joined_activity_ids';
  static const _kViewedActivityIds = 'viewed_activity_ids';
  static const _kLikedMomentIds = 'liked_moment_ids';
  static const _kMomentExtraComments = 'moment_extra_comments';
  static const _kUserActivities = 'user_published_activities';
  static const _kUserMoments = 'user_published_moments';
  static const _kStealthMode = 'stealth_mode';
  static const _kDisplayName = 'display_name';
  static const _kHostedCount = 'stats_hosted';
  static const _kJoinedCount = 'stats_joined';
  static const _kFriendsCount = 'stats_friends';
  static const _kCustomContacts = 'custom_contacts_json';
  static const _kAddressBook = 'address_book_contacts_v1';
  static const _kMomentReports = 'moment_reports_json';
  static const _kOnboardingDone = 'onboarding_done_v1';
  static const _kTermsPrivacyAccepted = 'terms_privacy_accepted_v1';
  static const _kNotifyMomentReplies = 'notify_moment_replies_v1';
  static const _kNotifyActivityTips = 'notify_activity_tips_v1';
  static const _kInboxMessages = 'inbox_messages_v1';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _bootstrapAddressBookIfNeeded();
    await _bootstrapInboxIfNeeded();
  }

  Future<void> _bootstrapInboxIfNeeded() async {
    if (_p.containsKey(_kInboxMessages)) return;
    await _persistInbox(_buildSeedInbox());
  }

  List<InboxMessage> _buildSeedInbox() {
    final now = DateTime.now().millisecondsSinceEpoch;
    const hour = 60 * 60 * 1000;
    const min = 60 * 1000;
    return [
      InboxMessage(
        id: 'seed_n1',
        title: '有人报名你的聚会',
        body: '阿豪 报名了「周末城市骑行 · 滨江线」，去看看成员列表吧。',
        createdAtMs: now - 3 * min,
        read: false,
        kind: 'activity',
      ),
      InboxMessage(
        id: 'seed_n2',
        title: '新动态互动',
        body: '小鹿 赞了你的动态：「散场路上还在回味梗…」',
        createdAtMs: now - 28 * min,
        read: false,
        kind: 'moment',
      ),
      InboxMessage(
        id: 'seed_n3',
        title: '附近新局上线',
        body: '距离你约 1km 内新发布了「咖啡拉花体验 · 小班课」，可能感兴趣。',
        createdAtMs: now - 2 * hour,
        read: false,
        kind: 'nearby',
      ),
      InboxMessage(
        id: 'seed_n4',
        title: '聚会提醒',
        body: '明晚 19:00「桌游交友夜」即将开始，别忘了带身份证签到。',
        createdAtMs: now - 5 * hour,
        read: true,
        kind: 'activity',
      ),
      InboxMessage(
        id: 'seed_n5',
        title: '觅伴小贴士',
        body: '在「朋友」页可快速拨号或发短信，聚会结束后也能保持联系。',
        createdAtMs: now - 26 * hour,
        read: true,
        kind: 'system',
      ),
      InboxMessage(
        id: 'seed_n6',
        title: '评论了你的动态',
        body: 'Jason：哈哈哈哈下次还约！',
        createdAtMs: now - 48 * hour,
        read: false,
        kind: 'moment',
      ),
    ];
  }

  Future<void> _persistInbox(List<InboxMessage> list) async {
    await _p.setString(_kInboxMessages, InboxMessage.encodeList(list));
  }

  List<InboxMessage> loadInboxMessages() {
    final raw = _p.getString(_kInboxMessages);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = InboxMessage.decodeList(raw);
      list.sort((a, b) => b.createdAtMs.compareTo(a.createdAtMs));
      return list;
    } catch (_) {
      return [];
    }
  }

  int inboxUnreadCount() => loadInboxMessages().where((e) => !e.read).length;

  Future<void> markInboxMessageRead(String id) async {
    final list = loadInboxMessages();
    final i = list.indexWhere((e) => e.id == id);
    if (i < 0 || list[i].read) return;
    list[i] = list[i].copyWith(read: true);
    await _persistInbox(list);
  }

  Future<void> markAllInboxRead() async {
    final list = loadInboxMessages().map((e) => e.copyWith(read: true)).toList();
    await _persistInbox(list);
  }

  Future<void> clearInbox() async {
    await _persistInbox([]);
  }

  /// 首次启动时写入默认通讯录，并与历史数据合并。
  Future<void> _bootstrapAddressBookIfNeeded() async {
    final existing = _p.getString(_kAddressBook);
    if (existing != null && existing.isNotEmpty) {
      return;
    }
    final seed = buildDefaultAddressBook();
    final legacy = _readLegacyCustomContacts();
    final seen = <String>{};
    String normPhone(String p) => p.replaceAll(RegExp(r'\D'), '');
    final merged = <Contact>[];
    for (final c in [...legacy, ...seed]) {
      final k = normPhone(c.phone);
      if (k.length != 11 || seen.contains(k)) continue;
      seen.add(k);
      merged.add(Contact(id: c.id, name: c.name, phone: k, bio: c.bio));
    }
    await _p.setString(_kAddressBook, Contact.encodeList(merged));
    await _p.setInt(_kFriendsCount, merged.length);
    await _p.remove(_kCustomContacts);
  }

  List<Contact> _readLegacyCustomContacts() {
    final raw = _p.getString(_kCustomContacts);
    if (raw == null || raw.isEmpty) return [];
    try {
      return Contact.decodeList(raw);
    } catch (_) {
      return [];
    }
  }

  SharedPreferences get _p {
    final v = _prefs;
    if (v == null) {
      throw StateError('AppStorage.init() must be called before use');
    }
    return v;
  }

  Set<String> getJoinedActivityIds() {
    return Set<String>.from(_p.getStringList(_kJoinedActivityIds) ?? []);
  }

  Future<void> addJoinedActivityId(String id) async {
    final s = getJoinedActivityIds()..add(id);
    await _p.setStringList(_kJoinedActivityIds, s.toList());
  }

  Set<String> getViewedActivityIds() {
    return Set<String>.from(_p.getStringList(_kViewedActivityIds) ?? []);
  }

  Future<void> addViewedActivityId(String id) async {
    final s = getViewedActivityIds()..add(id);
    await _p.setStringList(_kViewedActivityIds, s.toList());
  }

  Set<String> getLikedMomentIds() {
    return Set<String>.from(_p.getStringList(_kLikedMomentIds) ?? []);
  }

  Future<void> toggleLikedMoment(String id) async {
    final s = getLikedMomentIds();
    if (s.contains(id)) {
      s.remove(id);
    } else {
      s.add(id);
    }
    await _p.setStringList(_kLikedMomentIds, s.toList());
  }

  int extraCommentsFor(String momentId) {
    final raw = _p.getString(_kMomentExtraComments);
    if (raw == null || raw.isEmpty) return 0;
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return (map[momentId] as num?)?.toInt() ?? 0;
  }

  Future<void> incrementMomentComment(String momentId) async {
    final raw = _p.getString(_kMomentExtraComments);
    final map = <String, dynamic>{};
    if (raw != null && raw.isNotEmpty) {
      map.addAll(jsonDecode(raw) as Map<String, dynamic>);
    }
    final cur = (map[momentId] as num?)?.toInt() ?? 0;
    map[momentId] = cur + 1;
    await _p.setString(_kMomentExtraComments, jsonEncode(map));
  }

  List<Activity> loadUserActivities() {
    final raw = _p.getString(_kUserActivities);
    if (raw == null || raw.isEmpty) return [];
    try {
      return Activity.decodeList(raw);
    } catch (_) {
      return [];
    }
  }

  Future<void> saveUserActivities(List<Activity> list) async {
    await _p.setString(_kUserActivities, Activity.encodeList(list));
  }

  Future<void> prependUserActivity(Activity a) async {
    final list = loadUserActivities()..insert(0, a);
    await saveUserActivities(list);
  }

  List<Moment> loadUserMoments() {
    final raw = _p.getString(_kUserMoments);
    if (raw == null || raw.isEmpty) return [];
    try {
      return Moment.decodeList(raw);
    } catch (_) {
      return [];
    }
  }

  Future<void> prependUserMoment(Moment m) async {
    final list = loadUserMoments()..insert(0, m);
    await _p.setString(_kUserMoments, Moment.encodeList(list));
  }

  bool getStealthMode() => _p.getBool(_kStealthMode) ?? false;

  Future<void> setStealthMode(bool v) async {
    await _p.setBool(_kStealthMode, v);
  }

  String getDisplayName() => _p.getString(_kDisplayName) ?? 'Jason';

  Future<void> setDisplayName(String name) async {
    await _p.setString(_kDisplayName, name);
  }

  int getHostedCount() => _p.getInt(_kHostedCount) ?? 12;

  int getJoinedStatCount() => _p.getInt(_kJoinedCount) ?? 24;

  int getFriendsCount() {
    final raw = _p.getString(_kAddressBook);
    if (raw != null && raw.isNotEmpty) {
      try {
        return Contact.decodeList(raw).length;
      } catch (_) {}
    }
    return _p.getInt(_kFriendsCount) ?? 86;
  }

  Future<void> bumpHosted() async {
    await _p.setInt(_kHostedCount, getHostedCount() + 1);
  }

  Future<void> bumpJoinedStat() async {
    await _p.setInt(_kJoinedCount, getJoinedStatCount() + 1);
  }

  List<Contact> loadAddressBook() {
    final raw = _p.getString(_kAddressBook);
    if (raw == null || raw.isEmpty) {
      return buildDefaultAddressBook();
    }
    try {
      return Contact.decodeList(raw);
    } catch (_) {
      return buildDefaultAddressBook();
    }
  }

  Future<void> _persistAddressBook(List<Contact> list) async {
    await _p.setString(_kAddressBook, Contact.encodeList(list));
    await _p.setInt(_kFriendsCount, list.length);
  }

  Future<void> addContact(Contact c) async {
    final list = loadAddressBook()..insert(0, c);
    await _persistAddressBook(list);
  }

  Future<void> updateContact(Contact updated) async {
    final list = loadAddressBook();
    final i = list.indexWhere((e) => e.id == updated.id);
    if (i < 0) return;
    list[i] = updated;
    await _persistAddressBook(list);
  }

  Future<void> deleteContactById(String id) async {
    final list = loadAddressBook()..removeWhere((e) => e.id == id);
    await _persistAddressBook(list);
  }

  /// 是否已看过新功能引导。
  bool isOnboardingDone() => _p.getBool(_kOnboardingDone) ?? false;

  Future<void> setOnboardingDone() async {
    await _p.setBool(_kOnboardingDone, true);
  }

  /// 是否已同意《用户协议》和《隐私政策》。
  bool isTermsAndPrivacyAccepted() => _p.getBool(_kTermsPrivacyAccepted) ?? false;

  Future<void> setTermsAndPrivacyAccepted() async {
    await _p.setBool(_kTermsPrivacyAccepted, true);
  }

  bool getNotifyMomentReplies() => _p.getBool(_kNotifyMomentReplies) ?? true;

  Future<void> setNotifyMomentReplies(bool v) async {
    await _p.setBool(_kNotifyMomentReplies, v);
  }

  bool getNotifyActivityTips() => _p.getBool(_kNotifyActivityTips) ?? true;

  Future<void> setNotifyActivityTips(bool v) async {
    await _p.setBool(_kNotifyActivityTips, v);
  }

  /// 注销本机账号：清空本地存储并恢复默认通讯录与通知示例（需重新同意协议与引导）。
  Future<void> deleteAccountLocal() async {
    await _p.clear();
    await _bootstrapAddressBookIfNeeded();
    await _bootstrapInboxIfNeeded();
  }

  /// 记录用户提交的动态举报信息。
  Future<void> addMomentReport(String momentId, String category, String? detail) async {
    final raw = _p.getString(_kMomentReports);
    final list = <Map<String, dynamic>>[];
    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw) as List<dynamic>;
      for (final e in decoded) {
        list.add(Map<String, dynamic>.from(e as Map));
      }
    }
    list.add({
      'momentId': momentId,
      'category': category,
      'detail': detail ?? '',
      'at': DateTime.now().toIso8601String(),
    });
    await _p.setString(_kMomentReports, jsonEncode(list));
  }
}
