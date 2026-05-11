import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 桌面端（尤其 macOS）上，系统与路由层可能对 Escape 各处理一次，触发
/// `KeyUpEvent ... physical key is not pressed` 的 HardwareKeyboard 断言。
/// 用 [CallbackShortcuts] 在弹窗内优先消费 Escape，统一为「取消」并只 [pop] 一次。
Widget dialogCancelEscape(BuildContext dialogContext, Widget child) {
  return CallbackShortcuts(
    bindings: {
      const SingleActivator(LogicalKeyboardKey.escape): () {
        if (!Navigator.of(dialogContext).canPop()) return;
        Navigator.of(dialogContext).pop(false);
      },
    },
    child: child,
  );
}
