import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toado/about_screen.dart';
import 'package:toado/language_store.dart';
import 'package:toado/location_screen.dart';
import 'package:toado/location_service.dart';
import 'package:toado/result_screen.dart';
import 'package:toado/strings.dart';
import 'package:toado/thien_cung.dart';

import 'test_support.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget home, {
  AppLanguage language = AppLanguage.vi,
}) async {
  tester.view.physicalSize = const Size(390, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    LanguageScope(
      language: language,
      onChanged: (_) {},
      child: CupertinoApp(
        locale: const Locale('en'),
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: home,
      ),
    ),
  );
  await tester.pump();
}

String _sentence(AppLanguage language, List<String> pairs) =>
    AppStrings.of(language)
        .conclusionSentence(buildConclusion(matchPairs(pairs)));

void main() {
  for (final language in AppLanguage.values) {
    final strings = AppStrings.of(language);

    testWidgets('${language.name}: chờ GPS có gợi ý và giới thiệu app', (
      tester,
    ) async {
      final service = FakeLocationService();
      await _pump(
        tester,
        LocationScreen(locationService: service),
        language: language,
      );
      service.emit(const LocationWaiting());
      await tester.pump();

      expect(find.text(strings.waitingHint), findsOneWidget);
      expect(find.text(strings.appIntro), findsOneWidget);
    });

    testWidgets('${language.name}: có tọa độ vẫn giới thiệu, không có gợi ý', (
      tester,
    ) async {
      final service = FakeLocationService();
      await _pump(
        tester,
        LocationScreen(locationService: service),
        language: language,
      );
      service.emit(const LocationAvailable(21, 105));
      await tester.pump();

      expect(find.text(strings.appIntro), findsOneWidget);
      expect(find.text(strings.waitingHint), findsNothing);
    });

    testWidgets(
      '${language.name}: Kết quả có lưu ý sai số, ngay dưới Kết luận',
      (tester) async {
        await _pump(
          tester,
          const ResultScreen(coordsText: '21°01\'43"N 105°48\'12"E'),
          language: language,
        );

        final notice = find.text(strings.resultNotice);
        expect(notice, findsOneWidget);
        expect(
          tester.getTopLeft(find.text(strings.conclusionTitle)).dy,
          lessThan(tester.getTopLeft(notice).dy),
        );
        expect(
          tester.getTopLeft(notice).dy,
          lessThan(tester.getTopLeft(find.text(strings.detailsTitle)).dy),
        );
      },
    );

    testWidgets('${language.name}: Thông tin giải thích Bảng số', (
      tester,
    ) async {
      await _pump(tester, const AboutScreen(), language: language);

      expect(find.text(strings.tableTitle), findsOneWidget);
      expect(find.text(strings.tableBody), findsOneWidget);
    });
  }

  group('Đào Hoa trong Kết luận', () {
    test('nhóm Tai họa không dùng ý tốt của cung', () {
      final vi = _sentence(AppLanguage.vi, ['16', '12']);
      expect(vi, contains('sóng gió tình cảm cần giữ gìn'));
      expect(vi, isNot(contains('nhân duyên và tình cảm')));

      final en = _sentence(AppLanguage.en, ['16', '12']);
      expect(en, contains('relationship troubles that need care'));
      expect(en, isNot(contains('relationships and affection')));
    });

    test('nhóm May mắn giữ ý tốt', () {
      final vi = _sentence(AppLanguage.vi, ['38']);
      expect(vi, contains('nhân duyên và tình cảm'));
      expect(vi, isNot(contains('sóng gió')));
    });

    test('gặp cả hai nhóm thì nêu cả hai ý', () {
      expect(
        _sentence(AppLanguage.vi, ['38', '16']),
        contains(
          'nhân duyên và tình cảm, nhưng có sóng gió tình cảm cần giữ gìn',
        ),
      );
      expect(
        _sentence(AppLanguage.en, ['38', '16']),
        contains(
          'relationships and affection, but also relationship troubles '
          'that need care',
        ),
      );
    });
  });
}
