import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yueplayer/legal/legal_texts.dart';
import 'package:yueplayer/navigation/entry_navigation.dart';
import 'package:yueplayer/services/app_storage.dart';
import 'package:yueplayer/theme/app_colors.dart';
import 'package:yueplayer/widgets/dialog_escape.dart';

/// 使用应用前需同意《用户协议》与《隐私政策》。
class AgreementGatePage extends StatefulWidget {
  const AgreementGatePage({super.key});

  @override
  State<AgreementGatePage> createState() => _AgreementGatePageState();
}

class _AgreementGatePageState extends State<AgreementGatePage> {
  bool _agreeUser = false;
  bool _agreePrivacy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: AppColors.scaffoldBg,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );
    });
  }

  bool get _canEnter => _agreeUser && _agreePrivacy;

  Future<void> _enter() async {
    if (!_canEnter) return;
    await AppStorage.instance.setTermsAndPrivacyAccepted();
    if (!mounted) return;
    replaceWithPostAgreementApp(context);
  }

  void _showFullDoc(String title, String body) {
    showDialog<void>(
      context: context,
      builder: (ctx) => dialogCancelEscape(
        ctx,
        AlertDialog(
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: SelectableText(body, style: const TextStyle(fontSize: 14, height: 1.5)),
            ),
          ),
          actions: [
            FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('我已了解')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.groups_rounded, size: 38, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  '欢迎使用久遇',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),
                Text(
                  '为符合法律法规要求，请先阅读并同意以下协议。',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, height: 1.5, color: AppColors.textSecondary.withValues(alpha: 0.95)),
                ),
                const SizedBox(height: 28),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    children: [
                      CheckboxListTile(
                        value: _agreeUser,
                        onChanged: (v) => setState(() => _agreeUser = v ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        title: const Text('我已阅读并同意《用户协议》', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        subtitle: TextButton(
                          onPressed: () => _showFullDoc(kUserAgreementTitle, kUserAgreementBody),
                          style: TextButton.styleFrom(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('查看全文'),
                        ),
                      ),
                      const Divider(height: 1),
                      CheckboxListTile(
                        value: _agreePrivacy,
                        onChanged: (v) => setState(() => _agreePrivacy = v ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        title: const Text('我已阅读并同意《隐私政策》', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        subtitle: TextButton(
                          onPressed: () => _showFullDoc(kPrivacyPolicyTitle, kPrivacyPolicyBody),
                          style: TextButton.styleFrom(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('查看全文'),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _canEnter ? _enter : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.cardBorder,
                    disabledForegroundColor: AppColors.textMuted,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('进入应用', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(height: 12),
                Text(
                  '阅读并勾选协议后，轻点「进入应用」即可开始。',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted.withValues(alpha: 0.9)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
