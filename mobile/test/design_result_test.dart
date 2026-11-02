import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toado/language_store.dart';
import 'package:toado/result_screen.dart';
import 'package:toado/strings.dart';
import 'package:toado/thien_cung.dart';
import 'package:toado/thien_cung_data.dart';
import 'package:toado/theme.dart';
import 'package:toado/widgets.dart';

/// Tách ra 12, 48, 05, 31, 14, 10, 02; bảng thật khớp 3 dòng (12, 31, 14...).
const _exampleCoords = '21°01\'43"N 105°48\'12"E';

/// Mẫu cảnh báo trong thiết kế: 27 và 61 có nhiều dòng.
const _warningCoords = '20°59\'16"N 105°50\'27"E';

/// Mẫu không khớp số nào trong thiết kế.
const _emptyCoords = '20°50\'50"N 105°50\'50"E';

/// Tách ra 14, 50, 40, 30, 20, 10; với bảng giả chỉ khớp một dòng chưa có dữ liệu.
const _noDataCoords = '10°20\'30"N 40°50\'14"E';

/// Dòng giả chưa có dữ liệu (bảng thật nay đã điền hết ý nghĩa).
ThienCungGroup _blankRow(List<String> numbers) => ThienCungGroup(
  palaceOrder: 99,
  palaceVi: 'Thử',
  palaceEn: 'Test',
  numbers: numbers,
  meaningVi: '',
  meaningEn: '',
);

Future<void> _pumpResult(
  WidgetTester tester,
  String coordsText, {
  AppLanguage language = AppLanguage.vi,
  Size size = const Size(390, 2400),
  double textScale = 1,
  List<ThienCungGroup>? table,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  await tester.pumpWidget(
    LanguageScope(
      language: language,
      onChanged: (_) {},
      child: const CupertinoApp(locale: Locale('en'), home: SizedBox()),
    ),
  );
  final navigator = tester.state<NavigatorState>(find.byType(Navigator));
  unawaited(
    navigator.push(
      CupertinoPageRoute<void>(
        builder: (_) => ResultScreen(
          coordsText: coordsText,
          table: table ?? thienCungTable,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _pair(String pair) => find.byWidgetPredicate(
  (widget) => widget is PairBox && widget.pair == pair,
);

Color _pairColor(WidgetTester tester, String pair) => tester
    .widget<Text>(
      find.descendant(of: _pair(pair).first, matching: find.byType(Text)),
    )
    .style!
    .color!;

void main() {
  testWidgets('thứ tự: tọa độ, Kết luận, chi tiết', (tester) async {
    await _pumpResult(tester, _exampleCoords);

    final coords = tester.getTopLeft(find.byType(CoordsDisplay)).dy;
    final conclusion = tester.getTopLeft(find.text('KẾT LUẬN')).dy;
    final details = tester.getTopLeft(find.text('CHI TIẾT THEO CẶP SỐ')).dy;
    final firstRow = tester.getTopLeft(_pair('12')).dy;

    expect(coords, lessThan(conclusion));
    expect(conclusion, lessThan(details));
    expect(details, lessThan(firstRow));
  });

  testWidgets('đếm số dòng chi tiết', (tester) async {
    await _pumpResult(tester, _exampleCoords);
    expect(find.text('3 dòng'), findsOneWidget);
  });

  testWidgets('tiếng Anh đếm số dòng', (tester) async {
    await _pumpResult(tester, _exampleCoords, language: AppLanguage.en);

    expect(find.text('3 rows'), findsOneWidget);
    expect(find.text('DETAILS BY NUMBER PAIR'), findsOneWidget);
    expect(find.text('CONCLUSION'), findsOneWidget);
  });

  testWidgets('mẫu cảnh báo: có nhãn, hộp lưu ý nằm trong Kết luận', (
    tester,
  ) async {
    await _pumpResult(tester, _warningCoords);

    expect(find.text('CẢNH BÁO'), findsNWidgets(2));
    final note = find.text('Lưu ý: vị trí này có Đào Hoa (Tai họa) và Tai Họa.');
    expect(note, findsOneWidget);
    expect(
      tester.getTopLeft(note).dy,
      lessThan(tester.getTopLeft(find.text('CHI TIẾT THEO CẶP SỐ')).dy),
    );
    expect(_pairColor(tester, '61'), AppColors.warning);
  });

  testWidgets('tiếng Anh dùng nhãn WARNING', (tester) async {
    // Kết luận tiếng Anh dài hơn, nên cần màn cao để ListView dựng đủ cả hai dòng cảnh báo.
    await _pumpResult(
      tester,
      _warningCoords,
      language: AppLanguage.en,
      size: const Size(390, 4000),
    );

    expect(find.text('WARNING'), findsNWidgets(2));
  });

  testWidgets('màu ô số theo loại dòng', (tester) async {
    // 31 có dữ liệu thường (thật), 12 chưa có dữ liệu (giả).
    await _pumpResult(
      tester,
      _exampleCoords,
      table: [...lookupPair('31'), _blankRow(['12'])],
    );

    expect(_pairColor(tester, '31'), AppColors.accent);
    expect(_pairColor(tester, '12'), AppColors.muted);
    expect(find.text('CẢNH BÁO'), findsNothing);

    // 61 là dòng cảnh báo (bảng thật).
    await tester.pumpWidget(const SizedBox());
    await _pumpResult(tester, _warningCoords);
    expect(_pairColor(tester, '61'), AppColors.warning);
  });

  testWidgets('dòng chưa có dữ liệu chữ nghiêng', (tester) async {
    await _pumpResult(
      tester,
      _exampleCoords,
      table: [...lookupPair('31'), _blankRow(['12'])],
    );

    final text = tester.widget<Text>(find.text('Chưa có dữ liệu').first);
    expect(text.style!.fontStyle, FontStyle.italic);
    expect(text.style!.color, AppColors.muted);
    final box = tester.widget<PairBox>(_pair('12'));
    expect(box.hasData, isFalse);
  });

  testWidgets('ô cặp số đổi cỡ theo máy', (tester) async {
    await _pumpResult(tester, _exampleCoords);
    Size box() => tester.getSize(
      find
          .ancestor(of: find.text('31'), matching: find.byType(Container))
          .first,
    );
    expect(box(), const Size(56, 56));

    await tester.pumpWidget(const SizedBox());
    await _pumpResult(tester, _exampleCoords, size: const Size(360, 2400));
    expect(box(), const Size(52, 52));
  });

  testWidgets('không khớp số nào: chỉ tọa độ và một câu', (tester) async {
    await _pumpResult(tester, _emptyCoords, size: const Size(390, 844));

    final coords = tester.widget<CoordsDisplay>(find.byType(CoordsDisplay));
    expect(coords.centered, isTrue);
    expect(find.text('Tọa độ này không có số nào trong bảng'), findsOneWidget);
    expect(find.text('KẾT LUẬN'), findsNothing);
    expect(find.text('VĨ ĐỘ'), findsNothing);
  });

  testWidgets('chỉ khớp dòng chưa có dữ liệu', (tester) async {
    await _pumpResult(tester, _noDataCoords, table: [_blankRow(['14'])]);

    expect(find.text('KẾT LUẬN'), findsOneWidget);
    expect(find.text('Chưa có dữ liệu để kết luận'), findsOneWidget);
    expect(find.text('1 dòng'), findsOneWidget);
  });

  testWidgets('trình đọc màn hình đọc gộp từng dòng', (tester) async {
    final handle = tester.ensureSemantics();
    await _pumpResult(tester, _warningCoords);

    expect(find.bySemanticsLabel(RegExp(r'61[\s\S]*CẢNH BÁO')), findsWidgets);
    handle.dispose();
  });

  group('không tràn', () {
    for (final size in const [
      Size(390, 844),
      Size(360, 800),
      Size(320, 568),
    ]) {
      for (final language in AppLanguage.values) {
        for (final coords in const [
          _exampleCoords,
          _warningCoords,
          _emptyCoords,
          _noDataCoords,
        ]) {
          testWidgets('$size ${language.name} chữ x2 $coords', (tester) async {
            await _pumpResult(
              tester,
              coords,
              language: language,
              size: size,
              textScale: 2,
              table: coords == _noDataCoords ? [_blankRow(['14'])] : null,
            );

            expect(tester.takeException(), isNull);
            await tester.fling(
              find.byType(Scrollable).last,
              const Offset(0, -1200),
              1000,
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          });
        }
      }
    }
  });
}
