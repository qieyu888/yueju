import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' show launchUrl, LaunchMode;
import 'package:yueplayer/models/contact.dart';
import 'package:yueplayer/services/app_storage.dart';
import 'package:yueplayer/theme/app_colors.dart';
import 'package:yueplayer/widgets/dialog_escape.dart';
import 'package:yueplayer/widgets/letter_avatar.dart';

String _digitsOnly(String s) => s.replaceAll(RegExp(r'\D'), '');

/// 仅保留 ASCII 数字，便于与存储的 11 位号码比对（忽略空格、横线等）。
String _asciiDigitsOnly(String s) => s.replaceAll(RegExp(r'[^0-9]'), '');

bool _isCnMobile11(String digits) => RegExp(r'^1[3-9]\d{9}$').hasMatch(digits);

String _formatPhoneDisplay(String raw) {
  final d = _digitsOnly(raw);
  if (d.length != 11) return raw.trim();
  return '${d.substring(0, 3)} ${d.substring(3, 7)} ${d.substring(7)}';
}

class ContactsTab extends StatefulWidget {
  const ContactsTab({super.key});

  @override
  State<ContactsTab> createState() => _ContactsTabState();
}

class _ContactsTabState extends State<ContactsTab> {
  final _search = TextEditingController();
  List<Contact> _all = [];

  @override
  void initState() {
    super.initState();
    _reload();
    _search.addListener(_onSearchTextChanged);
  }

  void _onSearchTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _search.removeListener(_onSearchTextChanged);
    _search.dispose();
    super.dispose();
  }

  void _reload() {
    _all = AppStorage.instance.loadAddressBook();
  }

  List<Contact> get _filtered {
    final q = _search.text.trim();
    if (q.isEmpty) return _all;
    final qLower = q.toLowerCase();
    final qDigits = _asciiDigitsOnly(q);
    return _all.where((c) {
      if (c.name.toLowerCase().contains(qLower)) return true;
      if (c.bio.toLowerCase().contains(qLower)) return true;
      if (qDigits.isEmpty) return false;
      return _asciiDigitsOnly(c.phone).contains(qDigits);
    }).toList();
  }

  bool _phoneTakenByOther(String digits11, {String? exceptId}) {
    for (final c in _all) {
      if (c.id == exceptId) continue;
      if (_digitsOnly(c.phone) == digits11) return true;
    }
    return false;
  }

  Future<void> _launch(Uri uri) async {
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('无法打开系统拨号或短信')),
        );
      }
    }
  }

  Future<void> _showContactForm({Contact? existing}) async {
    final isEdit = existing != null;
    final name = TextEditingController(text: existing?.name ?? '');
    final phone = TextEditingController(
      text: existing == null ? '' : _formatPhoneDisplay(existing.phone),
    );
    final bio = TextEditingController(text: existing?.bio ?? '');

    void scheduleDispose() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        name.dispose();
        phone.dispose();
        bio.dispose();
      });
    }

    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => dialogCancelEscape(
        ctx,
        AlertDialog(
          title: Text(isEdit ? '编辑好友' : '新增好友'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: '昵称', hintText: '必填'),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phone,
                  decoration: const InputDecoration(
                    labelText: '手机号',
                    hintText: '11 位大陆手机号',
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bio,
                  decoration: const InputDecoration(labelText: '个性签名 / 备注', hintText: '选填'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('取消')),
            FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('保存')),
          ],
        ),
      ),
    );

    final n = ok == true ? name.text.trim() : '';
    final pRaw = ok == true ? phone.text.trim() : '';
    final b = ok == true ? bio.text.trim() : '';
    scheduleDispose();

    if (ok != true || !mounted) return;

    final p = _digitsOnly(pRaw);
    if (n.isEmpty || p.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请填写昵称与手机号')));
      return;
    }
    if (!_isCnMobile11(p)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入正确的 11 位手机号')));
      return;
    }
    if (_phoneTakenByOther(p, exceptId: existing?.id)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('该手机号已在通讯录中')));
      return;
    }

    if (existing != null) {
      await AppStorage.instance.updateContact(
        existing.copyWith(name: n, phone: p, bio: b.isEmpty ? '新朋友' : b),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已保存')));
      }
    } else {
      await AppStorage.instance.addContact(
        Contact(
          id: 'c_${DateTime.now().millisecondsSinceEpoch}',
          name: n,
          phone: p,
          bio: b.isEmpty ? '新朋友' : b,
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已添加 $n')));
      }
    }
    setState(() => _reload());
  }

  Future<void> _confirmDelete(Contact c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => dialogCancelEscape(
        ctx,
        AlertDialog(
          title: const Text('删除好友'),
          content: Text('确定删除「${c.name}」？此操作不可恢复。'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('取消')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('删除'),
            ),
          ],
        ),
      ),
    );
    if (ok != true || !mounted) return;
    await AppStorage.instance.deleteContactById(c.id);
    setState(() => _reload());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已删除 ${c.name}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20, MediaQuery.paddingOf(context).top + 8, 20, 0),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    '我的朋友',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_all.length} 人',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: TextField(
              controller: _search,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: '搜索姓名、手机号或备注…',
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                suffixIcon: _search.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: '清除',
                        icon: const Icon(Icons.clear, color: AppColors.textMuted),
                        onPressed: () {
                          _search.clear();
                          setState(() {});
                        },
                      ),
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Text(
                      _all.isEmpty ? '暂无好友，可点击下方添加' : '无匹配结果',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 88),
                    itemCount: list.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final c = list[i];
                      return Container(
                        padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.cardBorder),
                          boxShadow: const [
                            BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
                          ],
                        ),
                        child: Row(
                          children: [
                            LetterAvatar(name: c.name, size: 48, radius: 14),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatPhoneDisplay(c.phone),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    c.bio,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.textMuted),
                              tooltip: '编辑',
                              onPressed: () => _showContactForm(existing: c),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline, size: 20, color: Colors.red.shade400),
                              tooltip: '删除',
                              onPressed: () => _confirmDelete(c),
                            ),
                            IconButton.filledTonal(
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                foregroundColor: AppColors.primary,
                              ),
                              onPressed: () => _launch(Uri(scheme: 'sms', path: c.phone)),
                              icon: const Icon(Icons.sms_outlined, size: 20),
                              tooltip: '短信',
                            ),
                            IconButton.filledTonal(
                              style: IconButton.styleFrom(
                                backgroundColor: const Color(0xFFE8F5E9),
                                foregroundColor: const Color(0xFF2E7D32),
                              ),
                              onPressed: () => _launch(Uri(scheme: 'tel', path: c.phone)),
                              icon: const Icon(Icons.phone_outlined, size: 20),
                              tooltip: '电话',
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showContactForm(),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('添加好友'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
