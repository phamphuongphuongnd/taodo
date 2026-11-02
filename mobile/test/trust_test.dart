import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toado/coords.dart';
import 'package:toado/language_store.dart';
import 'package:toado/location_screen.dart';
import 'package:toado/location_service.dart';
import 'package:toado/manual_entry_screen.dart';
import 'package:toado/result_screen.dart';
import 'package:toado/strings.dart';
import 'package:toado/thien_cung.dart';

import 'test_support.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget home, {
  AppLanguage language = AppLanguage.vi,
}) async {
  tester.view.physicalSize = const Size(390, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    LanguageScope(
      language: language,
      onChanged: (_) {},
      child: CupertinoApp(locale: const Locale('en'), home: home),
    ),
  );
  await tester.pump();
}

Conclusion _conclusion(List<String> pairs) =>
    buildConclusion(matchPairs(pairs));

void main() {
  group('CoordsSmoother', () {
    test('lần đo đầu giữ nguyên', () {
      expect(CoordsSmoother().add(21, 105), (21.0, 105.0));
    });

    test('dao động vài mét quanh một chỗ thì số đứng yên', () {
      final smoother = CoordsSmoother();
      final first = smoother.add(21.0343, 105.7683);
      // 0.00005 độ khoảng 5,5 m, đổi số giây nếu hiện thẳng số thô.
      for (var index = 0; index < 60; index++) {
        final offset = index.isEven ? 0.00005 : -0.00005;
        expect(
          smoother.add(21.0343 + offset, 105.7683 - offset),
          first,
          reason: 'lần đo $index',
        );
      }
    });

    test('đi bộ thật thì số đi theo', () {
      final smoother = CoordsSmoother();
      final first = smoother.add(21.0343, 105.7683);
      var last = first;
      // Mỗi giây khoảng 1,5 m về phía bắc, trong 60 giây.
      for (var index = 1; index <= 60; index++) {
        last = smoother.add(21.0343 + index * 0.0000135, 105.7683);
      }
      expect(last.$1, greaterThan(first.$1 + 0.0004));
    });

    test('nhảy xa thì lấy ngay số mới, bỏ số cũ', () {
      final smoother = CoordsSmoother()..add(21, 105);
      expect(smoother.add(10, 40), (10.0, 40.0));
    });

    test('reset thì quên số cũ', () {
      final smoother = CoordsSmoother()..add(21, 105);
      smoother.reset();
      expect(smoother.add(21.00005, 105), (21.00005, 105.0));
    });
  });

  testWidgets('nút Tiếp đi qua đủ 6 ô, không dừng ở công tắc bán cầu', (
    tester,
  ) async {
    await _pump(tester, const ManualEntryScreen());
    final fields = tester
        .widgetList<CupertinoTextField>(find.byType(CupertinoTextField))
        .toList();
    fields.first.focusNode!.requestFocus();
    await tester.pump();

    for (final field in fields.skip(1)) {
      FocusManager.instance.primaryFocus!.nextFocus();
      await tester.pump();
      expect(field.focusNode!.hasFocus, isTrue);
    }
  });

  group('Nhập tay để trống', () {
    testWidgets('cả 6 ô trống thì báo chưa nhập, không sang Kết quả', (
      tester,
    ) async {
      await _pump(tester, const ManualEntryScreen());
      await tester.tap(find.text('Xem'));
      await tester.pumpAndSettle();

      expect(find.byType(ResultScreen), findsNothing);
      expect(
        find.text(AppStrings.of(AppLanguage.vi).emptyCoords),
        findsOneWidget,
      );
    });

    testWidgets('gõ một ô thì hết báo lỗi', (tester) async {
      await _pump(tester, const ManualEntryScreen());
      await tester.tap(find.text('Xem'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(CupertinoTextField).first, '21');
      await tester.pump();

      expect(
        find.text(AppStrings.of(AppLanguage.vi).emptyCoords),
        findsNothing,
      );
    });

    testWidgets('gõ số 0 là đã nhập, vẫn xem được', (tester) async {
      await _pump(tester, const ManualEntryScreen());
      await tester.enterText(find.byType(CupertinoTextField).first, '0');
      await tester.tap(find.text('Xem'));
      await tester.pumpAndSettle();

      expect(find.byType(ResultScreen), findsOneWidget);
    });
  });

  group('Kết quả cho thấy cặp số bị bỏ qua', () {
    for (final language in AppLanguage.values) {
      final strings = AppStrings.of(language);

      testWidgets('${language.name}: nêu mọi cặp và cặp bị bỏ', (tester) async {
        await _pump(
          tester,
          const ResultScreen(coordsText: '21°01\'43"N 105°48\'12"E'),
          language: language,
        );

        expect(
          find.text(
            strings.pairsLine(['12', '48', '05', '31', '14', '10', '02']),
          ),
          findsOneWidget,
        );
        expect(
          find.text(strings.skippedLine(['48', '05', '10', '02'])),
          findsOneWidget,
        );
      });
    }

    testWidgets('cặp lặp lại chỉ nêu một lần trong phần bỏ qua', (
      tester,
    ) async {
      await _pump(
        tester,
        const ResultScreen(coordsText: '21°01\'43"N 10°05\'05"E'),
      );

      final strings = AppStrings.of(AppLanguage.vi);
      expect(
        find.text(strings.skippedLine(['05', '10', '01'])),
        findsOneWidget,
      );
    });

    testWidgets('không khớp số nào vẫn nêu các cặp', (tester) async {
      await _pump(
        tester,
        const ResultScreen(coordsText: '10°20\'30"N 40°50\'10"E'),
      );

      expect(
        find.text(
          AppStrings.of(AppLanguage.vi)
              .pairsLine(['10', '50', '40', '30', '20', '10']),
        ),
        findsOneWidget,
      );
    });
  });

  group('Giải thích căn nguyên', () {
    testWidgets('gặp Thần Linh Trời Định thì có một dòng giải thích', (
      tester,
    ) async {
      await _pump(
        tester,
        const ResultScreen(coordsText: '20°59\'16"N 105°50\'27"E'),
      );

      expect(find.text(AppStrings.of(AppLanguage.vi).rootNote), findsOneWidget);
    });

    testWidgets('không gặp thì không hiện', (tester) async {
      await _pump(
        tester,
        const ResultScreen(coordsText: '21°01\'43"N 105°48\'12"E'),
      );

      expect(find.text(AppStrings.of(AppLanguage.vi).rootNote), findsNothing);
    });
  });

  group('Số giữ lại', () {
    for (final (isStale, label) in [
      (true, 'SỐ ĐO TRƯỚC · ĐANG ĐO LẠI'),
      (false, 'GPS ĐANG ĐO'),
    ]) {
      testWidgets('isStale=$isStale hiện nhãn $label', (tester) async {
        final service = FakeLocationService();
        await _pump(tester, LocationScreen(locationService: service));
        service.emit(LocationAvailable(21, 105, isStale: isStale));
        await tester.pump();

        expect(find.text(label), findsOneWidget);
      });
    }
  });

  group('Kết luận', () {
    final vi = AppStrings.of(AppLanguage.vi);
    final en = AppStrings.of(AppLanguage.en);

    test('không có cảnh báo thì thuận lợi', () {
      expect(vi.overallVerdict(_conclusion(['13'])), 'Nhìn chung: thuận lợi');
      expect(en.overallVerdict(_conclusion(['13'])), 'Overall: favorable');
    });

    test('vừa tốt vừa cảnh báo thì nêu cả hai', () {
      expect(
        vi.overallVerdict(_conclusion(['13', '89'])),
        'Nhìn chung: có thuận lợi, nhưng cần thận trọng',
      );
      expect(
        en.overallVerdict(_conclusion(['13', '89'])),
        'Overall: favorable, with some cautions',
      );
    });

    test('chỉ có cảnh báo thì cần thận trọng', () {
      expect(
        vi.overallVerdict(_conclusion(['89'])),
        'Nhìn chung: cần thận trọng',
      );
      expect(en.overallVerdict(_conclusion(['89'])), 'Overall: take care');
    });

    test('mỗi cung một lần thì không gọi là nổi bật', () {
      final sentence = vi.conclusionSentence(_conclusion(['13', '19']));
      expect(sentence, startsWith('Vị trí này có 2 cung, mỗi cung một lần:'));
      expect(sentence, isNot(contains('nổi bật')));
      expect(
        en.conclusionSentence(_conclusion(['13', '19'])),
        startsWith('This location has 2 themes, once each:'),
      );
    });

    test('chỉ lặp "thiên về" ở cung đầu', () {
      final sentence = vi.conclusionSentence(_conclusion(['13', '19', '12']));
      expect('thiên về'.allMatches(sentence), hasLength(1));
    });
  });
}
