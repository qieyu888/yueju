import 'package:flutter/material.dart';
import 'package:yueplayer/data/sample_data.dart';
import 'package:yueplayer/iap/store_products.dart';
import 'package:yueplayer/models/activity.dart';
import 'package:yueplayer/services/app_storage.dart';
import 'package:yueplayer/theme/app_colors.dart';

class PublishActivityPage extends StatefulWidget {
  const PublishActivityPage({super.key});

  @override
  State<PublishActivityPage> createState() => _PublishActivityPageState();
}

class _PublishActivityPageState extends State<PublishActivityPage> {
  final _title = TextEditingController();
  final _time = TextEditingController();
  final _location = TextEditingController();
  final _max = TextEditingController(text: '6');
  final _imageUrl = TextEditingController();
  String _category = '约饭';

  @override
  void dispose() {
    _title.dispose();
    _time.dispose();
    _location.dispose();
    _max.dispose();
    _imageUrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _title.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请填写标题')));
      return;
    }
    if (AppStorage.instance.getUserPoints() < kPublishActivityPointsCost) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('积分不足，发布聚会需要消耗 $kPublishActivityPointsCost 分（可在「我的」内购充值）'),
        ),
      );
      return;
    }
    final maxPeople = int.tryParse(_max.text.trim()) ?? 6;
    final host = AppStorage.instance.getDisplayName();
    final id = 'u_${DateTime.now().millisecondsSinceEpoch}';
    final url = _imageUrl.text.trim();
    final act = Activity(
      id: id,
      hostName: host,
      title: title,
      category: _category,
      timeLabel: _time.text.trim().isEmpty ? '时间待定' : _time.text.trim(),
      location: _location.text.trim().isEmpty ? '地点待定' : _location.text.trim(),
      joinedBase: 1,
      maxPeople: maxPeople.clamp(2, 99),
      coverImageUrl: url.isEmpty ? null : url,
      fallbackGradientIndex: id.hashCode.abs() % 8,
      badgeStatus: 'open',
      typeAccentIndex: _category.hashCode.abs() % 7,
    );
    await AppStorage.instance.prependUserActivity(act);
    await AppStorage.instance.bumpHosted();
    await AppStorage.instance.applyPublishPointsDeduction();
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final cats = activityFilters.where((e) => e != '全部').toList();
    final pts = AppStorage.instance.getUserPoints();
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text('发起聚会'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                '$pts 分',
                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 14),
              ),
            ),
          ),
          TextButton(
            onPressed: _submit,
            child: const Text('发布', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            '发布消耗 $kPublishActivityPointsCost 分 · 当前 $pts 分',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 8),
          const Text('极简发布：标题、类型、时间、地点、人数与配图链接（可选）。', style: TextStyle(color: AppColors.textSecondary, height: 1.4)),
          const SizedBox(height: 20),
          TextField(
            controller: _title,
            decoration: _dec('标题', hint: '例如：周末奥森飞盘 🥏'),
          ),
          const SizedBox(height: 14),
          InputDecorator(
            decoration: _dec('类型'),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _category,
                isExpanded: true,
                items: cats
                    .map(
                      (c) => DropdownMenuItem(value: c, child: Text(c)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _category = v ?? _category),
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _time,
            decoration: _dec('时间', hint: '例如：周六 10:00'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _location,
            decoration: _dec('地点', hint: '例如：朝阳区…'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _max,
            keyboardType: TextInputType.number,
            decoration: _dec('人数上限', hint: '2 - 99'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _imageUrl,
            decoration: _dec('配图 URL（可选）', hint: 'https://…'),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _submit,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('发布聚会', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  InputDecoration _dec(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}
