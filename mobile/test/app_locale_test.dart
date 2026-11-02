import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show MaterialLocalizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:toado/location_screen.dart';
import 'package:toado/main.dart';
import 'package:toado/strings.dart';

import 'test_support.dart';

BuildContext _context(WidgetTester tester) =>
    tester.element(find.byType(LocationScreen));

Locale _locale(WidgetTester tester) =>
    Localizations.localeOf(_context(tester));

CupertinoLocalizations _cupertino(WidgetTester tester) =>
    CupertinoLocalizations.of(_context(tester));

MaterialLocalizations _material(WidgetTester tester) =>
    MaterialLocalizations.of(_context(tester));

Future<void> _pumpFollowingDevice(WidgetTester tester) async {
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  await tester.pumpWidget(
    ToaDoApp(
      locationService: FakeLocationService(),
      languageStore: FakeLanguageStore(null),
    ),
  );
  await tester.pump();
}

void main() {
  group('locale của CupertinoApp theo ngôn ngữ app', () {
    testWidgets('tiếng Việt: nhãn hệ thống ra tiếng Việt', (tester) async {
      await pumpToaDoApp(tester);

      expect(_locale(tester), const Locale('vi'));
      expect(_cupertino(tester).copyButtonLabel, 'Sao chép');
      expect(_cupertino(tester).pasteButtonLabel, 'Dán');
      expect(_cupertino(tester).selectAllButtonLabel, 'Chọn tất cả');
    });

    testWidgets('tiếng Anh: nhãn hệ thống ra tiếng Anh', (tester) async {
      await pumpToaDoApp(tester, language: AppLanguage.en);

      expect(_locale(tester), const Locale('en'));
      expect(_cupertino(tester).pasteButtonLabel, 'Paste');
    });

    testWidgets('nhãn Material dùng ở SelectionArea cũng theo ngôn ngữ', (
      tester,
    ) async {
      await pumpToaDoApp(tester);

      expect(_material(tester).pasteButtonLabel, 'Dán');
    });

    testWidgets('đổi ngôn ngữ thì locale đổi theo, cả hai chiều', (
      tester,
    ) async {
      await pumpToaDoApp(tester);

      await tester.tap(find.text('English'));
      await tester.pump();
      expect(_locale(tester), const Locale('en'));
      expect(_cupertino(tester).pasteButtonLabel, 'Paste');

      await tester.tap(find.text('Tiếng Việt'));
      await tester.pump();
      expect(_locale(tester), const Locale('vi'));
      expect(_cupertino(tester).pasteButtonLabel, 'Dán');
    });

    testWidgets('chưa chọn: locale đi theo ngôn ngữ máy báo đến', (
      tester,
    ) async {
      tester.platformDispatcher.localesTestValue = const [Locale('en')];
      await _pumpFollowingDevice(tester);

      tester.platformDispatcher.localesTestValue = const [Locale('vi', 'VN')];
      await tester.pump();
      expect(_locale(tester), const Locale('vi'));

      tester.platformDispatcher.localesTestValue = const [Locale('ja')];
      await tester.pump();
      expect(_locale(tester), const Locale('en'));
    });

    testWidgets('menu chọn chữ của ô nhập hiện tiếng Việt', (tester) async {
      await pumpToaDoApp(tester);
      await tapButton(tester, 'Nhập tay');

      final field = find.byType(CupertinoTextField).first;
      await tester.enterText(field, '12');
      await tester.pump();
      await tester.longPress(field);
      await tester.pumpAndSettle();

      // Nhấn giữ đã chọn hết chữ nên menu không có mục chọn tất cả.
      expect(find.text('Sao chép'), findsOneWidget);
      expect(find.text('Copy'), findsNothing);
    });
  });
}
