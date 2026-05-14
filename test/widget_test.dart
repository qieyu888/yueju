import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:yueplayer/screens/home_shell.dart';
import 'package:yueplayer/services/app_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUpAll(() async {
    await AppStorage.instance.init();
  });

  testWidgets('Home shell shows discover header', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: HomeShell()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('发现聚会'), findsOneWidget);
  });
}
