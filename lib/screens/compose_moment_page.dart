import 'package:flutter/material.dart';
import 'package:yueplayer/models/moment.dart';
import 'package:yueplayer/services/app_storage.dart';
import 'package:yueplayer/theme/app_colors.dart';

class ComposeMomentPage extends StatefulWidget {
  const ComposeMomentPage({super.key});

  @override
  State<ComposeMomentPage> createState() => _ComposeMomentPageState();
}

class _ComposeMomentPageState extends State<ComposeMomentPage> {
  final _content = TextEditingController();
  final _activity = TextEditingController();
  final _img1 = TextEditingController();
  final _img2 = TextEditingController();

  @override
  void dispose() {
    _content.dispose();
    _activity.dispose();
    _img1.dispose();
    _img2.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    final text = _content.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('写点什么再发布吧')));
      return;
    }
    final imgs = <String>[];
    if (_img1.text.trim().isNotEmpty) imgs.add(_img1.text.trim());
    if (_img2.text.trim().isNotEmpty) imgs.add(_img2.text.trim());
    final ref = _activity.text.trim().isEmpty ? null : _activity.text.trim();
    final me = AppStorage.instance.getDisplayName();
    final m = Moment(
      id: 'm_${DateTime.now().millisecondsSinceEpoch}',
      user: MomentUser(name: me),
      timeLabel: '刚刚',
      content: text,
      imageUrls: imgs,
      likesBase: 0,
      commentsBase: 0,
      activityRef: ref,
    );
    await AppStorage.instance.prependUserMoment(m);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text('发布动态'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
        actions: [
          TextButton(
            onPressed: _publish,
            child: const Text('发布', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _content,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: '分享此刻…',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _activity,
            decoration: InputDecoration(
              labelText: '关联活动（可选）',
              hintText: '例如：周末郊区露营 ⛺️',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _img1,
            decoration: InputDecoration(
              labelText: '图片 URL 1（可选）',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _img2,
            decoration: InputDecoration(
              labelText: '图片 URL 2（可选）',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }
}
