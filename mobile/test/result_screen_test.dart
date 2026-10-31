import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toado/language_store.dart';
import 'package:toado/result_screen.dart';
import 'package:toado/strings.dart';
import 'package:toado/thien_cung.dart';

/// Tách ra 12, 48, 05, 31, 14, 10, 02; chỉ 12, 31, 14 có trong bảng.
const _exampleCoords = '21°01\'43"N 105°48\'12"E';

/// Tách ra 10, 50, 40, 30, 20, 10; không số nào có trong bảng.
const _emptyCoords = '10°20\'30"N 40°50\'10"E';

/// Tách ra 89, 00, 96, 21, 12, 10; 89 thuộc Cung Tai Họa.
const _warningCoords = '10°12\'21"N 96°00\'89"E';

/// Có số 16, thuộc cả nhóm Tai họa của Đào Hoa lẫn Cung Tai Họa.
const _twoWarningsCoords = '10°20\'30"N 40°50\'16"E';

/// Có số 27, thuộc ba cung.
const _multiPalaceCoords = '10°20\'30"N 40°50\'27"E';

/// Có số 14, thuộc một cung chưa có dữ liệu.
const _noDataCoords = '10°20\'30"N 40°50\'14"E';

Future<void> _pumpResult(
  WidgetTester tester,
  String coordsText, {
  AppLanguage language = AppLanguage.vi,
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    LanguageScope(
      language: language,
      onChanged: (_) {},
      child: const CupertinoApp(locale: Locale('en'), home: SizedBox()),
    ),
  );
  // Nút quay lại cần một route có thể pop, giống lúc mở từ màn hình chính.
  final navigator = tester.state<NavigatorState>(find.byType(Navigator));
  unawaited(
    navigator.push(
      CupertinoPageRoute<void>(
        builder: (_) => ResultScreen(coordsText: coordsText),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find.byType(Scrollable).last,
  );
}

void main() {
  testWidgets('hiện tọa độ, cặp số, cung, nhóm và ý nghĩa theo thứ tự', (
    tester,
  ) async {
    await _pumpResult(tester, _exampleCoords);

    expect(find.text(_exampleCoords), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('31'), findsOneWidget);
    expect(find.text('14'), findsOneWidget);
    expect(find.text('Chăm Chỉ'), findsOneWidget);
    expect(find.text('Chưa có dữ liệu'), findsNWidgets(2));
    expect(find.text('Thiên Tài (Đại tài)'), findsOneWidget);
    expect(find.text('Tích Lũy Tài Sản'), findsOneWidget);
    expect(find.text(lookupPair('31').single.meaningVi), findsOneWidget);

    final y12 = tester.getTopLeft(find.text('12')).dy;
    final y31 = tester.getTopLeft(find.text('31')).dy;
    final y14 = tester.getTopLeft(find.text('14')).dy;
    expect(y12, lessThan(y31));
    expect(y31, lessThan(y14));
  });

  testWidgets('số không có trong bảng bị ẩn', (tester) async {
    await _pumpResult(tester, _exampleCoords);

    for (final hidden in ['48', '05', '10', '02']) {
      expect(find.text(hidden), findsNothing);
    }
  });

  testWidgets('một số thuộc nhiều cung thì hiện đủ', (tester) async {
    await _pumpResult(tester, _multiPalaceCoords);

    expect(find.text('27'), findsNWidgets(3));
    expect(find.text('Thiên Tài (Tiểu tài)'), findsOneWidget);
    expect(find.text('Thông Minh (IQ cao)'), findsOneWidget);
    expect(find.text('Thần Linh Trời Định (Số trời)'), findsOneWidget);
  });

  testWidgets('phần Kết luận nằm cuối trang', (tester) async {
    await _pumpResult(tester, _exampleCoords);

    final sentence = find.text(
      'Vị trí này nổi bật về Thiên Tài (Đại tài), 1 lần.',
    );
    await _scrollTo(tester, sentence);

    expect(find.text('Kết luận'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Kết luận')).dy,
      greaterThan(tester.getTopLeft(find.text('14')).dy),
    );
    expect(find.textContaining('Lưu ý'), findsNothing);
  });

  testWidgets('tiếng Anh dùng trường En', (tester) async {
    await _pumpResult(tester, _exampleCoords, language: AppLanguage.en);

    final talent = lookupPair('31').single;
    final diligence = lookupPair('12').single;
    final talentLabel = '${talent.palaceEn} (${talent.groupEn})';
    expect(find.text(talentLabel), findsOneWidget);
    expect(find.text(diligence.palaceEn), findsOneWidget);
    expect(find.text(talent.meaningEn), findsOneWidget);

    final sentence = find.text(
      'This location stands out for $talentLabel, 1 time.',
    );
    await _scrollTo(tester, sentence);
    expect(find.text('Conclusion'), findsOneWidget);
  });

  group('chỉ có cung chưa có dữ liệu', () {
    testWidgets('vẫn hiện cặp số và báo chưa thể kết luận', (tester) async {
      await _pumpResult(tester, _noDataCoords);

      expect(find.text('14'), findsOneWidget);
      expect(find.text('Tích Lũy Tài Sản'), findsOneWidget);
      expect(find.text('Chưa có dữ liệu'), findsOneWidget);
      expect(find.text('Kết luận'), findsOneWidget);
      expect(find.text('Chưa có dữ liệu để kết luận'), findsOneWidget);
    });

    testWidgets('tiếng Anh', (tester) async {
      await _pumpResult(tester, _noDataCoords, language: AppLanguage.en);

      expect(find.text('No data yet'), findsOneWidget);
      expect(find.text('Not enough data for a conclusion'), findsOneWidget);
    });
  });

  group('không có số nào trong bảng', () {
    testWidgets('chỉ hiện tọa độ và một câu', (tester) async {
      await _pumpResult(tester, _emptyCoords);

      expect(find.text(_emptyCoords), findsOneWidget);
      expect(
        find.text('Tọa độ này không có số nào trong bảng'),
        findsOneWidget,
      );
      expect(find.text('Kết luận'), findsNothing);
      expect(
        find.descendant(of: find.byType(ListView), matching: find.byType(Text)),
        findsNWidgets(2),
      );
    });

    testWidgets('tiếng Anh', (tester) async {
      await _pumpResult(tester, _emptyCoords, language: AppLanguage.en);

      expect(
        find.text('These coordinates have no numbers in the table'),
        findsOneWidget,
      );
      expect(find.text('Conclusion'), findsNothing);
    });
  });

  group('lưu ý', () {
    testWidgets('có Tai Họa dù không phải cung nhiều nhất', (tester) async {
      await _pumpResult(tester, _warningCoords);

      final warning = find.text('Lưu ý: vị trí này có Tai Họa.');
      await _scrollTo(tester, warning);

      expect(
        find.text('Vị trí này nổi bật về Bảo Vệ và Tai Họa, mỗi cung 1 lần.'),
        findsOneWidget,
      );
      expect(warning, findsOneWidget);
    });

    testWidgets('nêu tên từng dòng lưu ý', (tester) async {
      await _pumpResult(tester, _twoWarningsCoords);

      final warning = find.text(
        'Lưu ý: vị trí này có Đào Hoa (Tai họa) và Tai Họa.',
      );
      await _scrollTo(tester, warning);
      expect(warning, findsOneWidget);
    });

    testWidgets('tiếng Anh', (tester) async {
      await _pumpResult(tester, _warningCoords, language: AppLanguage.en);

      final misfortune = lookupPair('89').single;
      final warning = find.text(
        'Note: this location includes ${misfortune.palaceEn}.',
      );
      await _scrollTo(tester, warning);
      expect(warning, findsOneWidget);
    });
  });

  group('không overflow', () {
    for (final size in const [Size(390, 844), Size(320, 568)]) {
      for (final language in AppLanguage.values) {
        for (final coords in const [
          _exampleCoords,
          _emptyCoords,
          _twoWarningsCoords,
          _multiPalaceCoords,
          _noDataCoords,
        ]) {
          testWidgets('$size ${language.name} $coords', (tester) async {
            await _pumpResult(tester, coords, language: language, size: size);

            expect(tester.takeException(), isNull);
            expect(
              tester.getBottomRight(find.text(coords)).dx,
              lessThanOrEqualTo(size.width),
            );
            await tester.fling(
              find.byType(ListView),
              const Offset(0, -600),
              800,
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          });
        }
      }
    }
  });
}
