// Kiểm thử hộp trắng Bước 6 cho lib/manual_entry_screen.dart.
// Thiết kế: test-output/whitebox/nhap-tay/manual_entry_screen/buoc-5-du-lieu-thu.md
// Expected chép từ Bước 5 (nguồn: spec 2026-10-31-toado-design.md, design-mobile/screens/Nhap-*.dc.html,
// docs/compliance/bao-cao-tiep-can.md). Mục đánh dấu (*) là chỗ yêu cầu chưa nêu, cần xác nhận.
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toado/result_screen.dart';
import 'package:toado/theme.dart';

import 'test_support.dart';

const _invalidVi =
    'Tọa độ không hợp lệ. Phút và giây phải dưới 60, vĩ độ tối đa 90°, '
    'kinh độ tối đa 180°.';

Future<void> _open(
  WidgetTester tester, {
  Size? size,
  double textScale = 1,
}) async {
  await pumpToaDoApp(
    tester,
    size: size ?? const Size(390, 844),
    textScale: textScale,
  );
  await tapButton(tester, 'Nhập tay');
}

/// Ô theo thứ tự: 0-2 vĩ độ (độ, phút, giây), 3-5 kinh độ.
Future<void> _fill(WidgetTester tester, List<String> values) async {
  final fields = find.byType(CupertinoTextField);
  for (var i = 0; i < values.length; i++) {
    await tester.enterText(fields.at(i), values[i]);
  }
  await tester.pump();
}

CupertinoTextField _field(WidgetTester tester, int index) => tester
    .widget<CupertinoTextField>(find.byType(CupertinoTextField).at(index));

Color _borderColor(WidgetTester tester, int index) =>
    (_field(tester, index).decoration!.border! as Border).top.color;

Color? _fillColor(WidgetTester tester, int index) =>
    _field(tester, index).decoration!.color;

String _resultCoords(WidgetTester tester) =>
    tester.widget<ResultScreen>(find.byType(ResultScreen)).coordsText;

Text _text(WidgetTester tester, String value, [int at = 0]) =>
    tester.widgetList<Text>(find.text(value)).elementAt(at);

Color? _optionFill(WidgetTester tester, String label) {
  final container = tester.widget<Container>(
    find.ancestor(of: find.text(label), matching: find.byType(Container)).first,
  );
  return (container.decoration! as ShapeDecoration).color;
}

Finder _selectedSemantics(String label) => find.ancestor(
  of: find.text(label),
  matching: find.byWidgetPredicate(
    (w) => w is Semantics && w.properties.selected == true,
  ),
);

void main() {
  // ---- G1 _value (N1) ----
  testWidgets('6-01 N1=S: ô có số => dùng đúng số đó', (tester) async {
    await _open(tester);
    await _fill(tester, ['21']);
    await tapButton(tester, 'Xem');
    final shown = find.byType(ResultScreen).evaluate().isNotEmpty;
    expect(shown, isTrue);
    expect(_resultCoords(tester), '21°00\'00"N 00°00\'00"E');
  });

  testWidgets('6-02 N1=Đ: ô trống => tính là 0', (tester) async {
    await _open(tester);
    await tapButton(tester, 'Xem');
    final shown = find.byType(ResultScreen).evaluate().isNotEmpty;
    expect(shown, isTrue);
    expect(_resultCoords(tester), '00°00\'00"N 00°00\'00"E');
  });

  // ---- G2 _clearError (N2) ----
  testWidgets('6-03 N2=S: sửa ô khi không có lỗi => không hiện lỗi', (
    tester,
  ) async {
    await _open(tester);
    await _fill(tester, ['21']);
    final errorShown = find.text(_invalidVi).evaluate().isNotEmpty;
    final resultShown = find.byType(ResultScreen).evaluate().isNotEmpty;
    expect(errorShown, isFalse);
    expect(resultShown, isFalse);
    expect(_field(tester, 0).controller!.text, '21');
  });

  testWidgets('6-04 N2=Đ: đang lỗi, sửa ô => lỗi biến mất', (tester) async {
    await _open(tester);
    await _fill(tester, ['91']);
    await tapButton(tester, 'Xem');
    expect(find.text(_invalidVi), findsOneWidget);
    expect(_borderColor(tester, 0), AppColors.warningBorder);

    await _fill(tester, ['90']);
    expect(find.text(_invalidVi), findsNothing);
    expect(_borderColor(tester, 0), isNot(AppColors.warningBorder));
  });

  // ---- G3 _openResult (N3) ----
  testWidgets('6-05 N3=S: hợp lệ => mở kết quả đúng định dạng', (tester) async {
    await _open(tester);
    await _fill(tester, ['21', '1', '43', '105', '48', '12']);
    await tapButton(tester, 'Xem');
    final errorShown = find.text(_invalidVi).evaluate().isNotEmpty;
    final resultShown = find.byType(ResultScreen).evaluate().isNotEmpty;
    expect(resultShown, isTrue);
    expect(errorShown, isFalse);
    expect(_resultCoords(tester), '21°01\'43"N 105°48\'12"E');
  });

  testWidgets('6-06 N3=Đ: sai => báo lỗi, không mở kết quả', (tester) async {
    await _open(tester);
    await _fill(tester, ['21', '60']);
    await tapButton(tester, 'Xem');
    final resultShown = find.byType(ResultScreen).evaluate().isNotEmpty;
    expect(find.text(_invalidVi), findsOneWidget);
    expect(resultShown, isFalse);
    expect(_borderColor(tester, 1), AppColors.warningBorder);
  });

  // ---- G4 build (N4) ----
  testWidgets('6-07 N4=Đ: có ô sai => hiện hộp lỗi, nút Xem vẫn còn', (
    tester,
  ) async {
    await _open(tester);
    await _fill(tester, ['0', '0', '0', '181']);
    await tapButton(tester, 'Xem');
    expect(find.text(_invalidVi), findsOneWidget);
    expect(find.widgetWithText(CupertinoButton, 'Xem'), findsOneWidget);
  });

  testWidgets('6-08 N4=S: lúc đầu không có hộp lỗi', (tester) async {
    await _open(tester);
    expect(find.text(_invalidVi), findsNothing);
    expect(find.byIcon(CupertinoIcons.exclamationmark_triangle), findsNothing);
    expect(find.widgetWithText(CupertinoButton, 'Xem'), findsOneWidget);
  });

  // ---- G5, G6 chọn bán cầu ----
  testWidgets('6-09a G5: chọn S cho vĩ độ => kết quả có S', (tester) async {
    await _open(tester);
    await _fill(tester, ['21', '1', '43', '105', '48', '12']);
    await tester.tap(find.text('S'));
    await tester.pump();
    await tapButton(tester, 'Xem');
    expect(_resultCoords(tester), '21°01\'43"S 105°48\'12"E');
  });

  testWidgets('6-09b G5 (*): đổi bán cầu vĩ độ => hết lỗi', (tester) async {
    // (*) spec không nêu; nguồn: docs/chuc-nang-va-giao-dien.md (chưa commit)
    await _open(tester);
    await _fill(tester, ['91']);
    await tapButton(tester, 'Xem');
    expect(find.text(_invalidVi), findsOneWidget);
    await tester.tap(find.text('S'));
    await tester.pump();
    expect(find.text(_invalidVi), findsNothing);
  });

  testWidgets('6-10a G6: chọn W cho kinh độ => kết quả có W', (tester) async {
    await _open(tester);
    await _fill(tester, ['21', '1', '43', '105', '48', '12']);
    await tester.tap(find.text('W'));
    await tester.pump();
    await tapButton(tester, 'Xem');
    expect(_resultCoords(tester), '21°01\'43"N 105°48\'12"W');
  });

  testWidgets('6-10b G6 (*): đổi bán cầu kinh độ => hết lỗi', (tester) async {
    // (*) spec không nêu; nguồn: docs/chuc-nang-va-giao-dien.md (chưa commit)
    await _open(tester);
    await _fill(tester, ['0', '0', '0', '181']);
    await tapButton(tester, 'Xem');
    expect(find.text(_invalidVi), findsOneWidget);
    await tester.tap(find.text('W'));
    await tester.pump();
    expect(find.text(_invalidVi), findsNothing);
  });

  // ---- G7 _ErrorBox ----
  testWidgets('6-11 G7: hộp lỗi là live region, màu cảnh báo, có tam giác', (
    tester,
  ) async {
    await _open(tester);
    await _fill(tester, ['91']);
    await tapButton(tester, 'Xem');

    final live = find.ancestor(
      of: find.text(_invalidVi),
      matching: find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.liveRegion == true,
      ),
    );
    final box = tester.widget<Container>(
      find
          .ancestor(of: find.text(_invalidVi), matching: find.byType(Container))
          .first,
    );
    final decoration = box.decoration! as BoxDecoration;
    expect(live, findsOneWidget);
    expect(_text(tester, _invalidVi).style!.color, AppColors.warning);
    expect(decoration.color, AppColors.warningSurface);
    expect(
      (decoration.border! as Border).top.color,
      AppColors.warningBoxBorder,
    );
    expect(
      find.byIcon(CupertinoIcons.exclamationmark_triangle),
      findsOneWidget,
    );
  });

  // ---- G8 _CoordinateCard (N5, N6) ----
  testWidgets('6-12 G8: mỗi thẻ có 3 ô độ/phút/giây, giới hạn 3-2-2 chữ số', (
    tester,
  ) async {
    await _open(tester);
    expect(find.byType(CupertinoTextField), findsNWidgets(6));
    expect(find.text('°'), findsNWidgets(2));
    expect(find.text("'"), findsNWidgets(2));
    expect(find.text('"'), findsNWidgets(2));
    expect(find.text('Vĩ độ'), findsOneWidget);
    expect(find.text('Kinh độ'), findsOneWidget);

    // N6=Đ: giữa các ô cùng thẻ cách 8 (design: gap 8px); N6=S: ô đầu không có đệm trái.
    final fields = find.byType(CupertinoTextField);
    for (final i in [0, 1, 3, 4]) {
      final gap =
          tester.getTopLeft(fields.at(i + 1)).dx -
          tester.getTopRight(fields.at(i)).dx;
      expect(gap, closeTo(8, 0.001), reason: 'khoảng cách ô $i và ${i + 1}');
    }

    await _fill(tester, ['1234', '123', '123', '1234', '123', '123']);
    final texts = [
      for (var i = 0; i < 6; i++) _field(tester, i).controller!.text,
    ];
    expect(texts, ['123', '12', '12', '123', '12', '12']);
  });

  // ---- G9 _HemisphereSwitch ----
  testWidgets('6-13 G9: hai nút gọi onChanged(true)/(false) cho cả 2 thẻ', (
    tester,
  ) async {
    await _open(tester);
    await tester.tap(find.text('S'));
    await tester.pump();
    final southSelected = _selectedSemantics('S').evaluate().isNotEmpty;
    expect(southSelected, isTrue);
    await tester.tap(find.text('N'));
    await tester.pump();
    final northSelected = _selectedSemantics('N').evaluate().isNotEmpty;
    expect(northSelected, isTrue);
    await tester.tap(find.text('W'));
    await tester.pump();
    final westSelected = _selectedSemantics('W').evaluate().isNotEmpty;
    expect(westSelected, isTrue);
    await tester.tap(find.text('E'));
    await tester.pump();
    final eastSelected = _selectedSemantics('E').evaluate().isNotEmpty;
    expect(eastSelected, isTrue);
    await tapButton(tester, 'Xem');
    expect(_resultCoords(tester), '00°00\'00"N 00°00\'00"E');
  });

  // ---- G10 _HemisphereOption (N7, N8, N9) ----
  testWidgets('6-14 G10 selected=Đ: nút N đang chọn nền sáng, chữ đậm 800', (
    tester,
  ) async {
    await _open(tester);
    expect(_optionFill(tester, 'N'), AppColors.text);
    expect(_text(tester, 'N').style!.fontWeight, FontWeight.w800);
    expect(_text(tester, 'N').style!.color, AppColors.screen);
    expect(_selectedSemantics('N'), findsOneWidget);
  });

  testWidgets('6-15 G10 selected=S: nút S chưa chọn không nền, chữ 700', (
    tester,
  ) async {
    await _open(tester);
    expect(_optionFill(tester, 'S'), isNull);
    expect(_text(tester, 'S').style!.fontWeight, FontWeight.w700);
    expect(_text(tester, 'S').style!.color, AppColors.label);
    expect(_selectedSemantics('S'), findsNothing);
  });

  // ---- G11 _fittedDigitSize ----
  for (final size in const [Size(390, 844), Size(360, 800), Size(320, 568)]) {
    for (final scale in const [1.0, 2.0]) {
      testWidgets('6-16 G11: $size chữ x$scale => cỡ chữ vừa ô, thấy đủ 3 số', (
        tester,
      ) async {
        await _open(tester, size: size, textScale: scale);
        await _fill(tester, ['999', '99', '99', '999', '99', '99']);

        final sizes = {
          for (var i = 0; i < 6; i++) _field(tester, i).style!.fontSize,
        };
        final scroll = tester
            .state<EditableTextState>(find.byType(EditableText).at(0))
            .renderEditable
            .maxScrollExtent;
        expect(sizes, hasLength(1));
        expect(sizes.single, lessThanOrEqualTo(44)); // (nguồn: comment)
        // Không khẳng định "= 30 ở 390 x1": trong môi trường test font dự phòng
        // (Ahem, rộng 1em/chữ) khiến cỡ bị co xuống ~20; số 30 chỉ kiểm được trên máy thật.
        expect(sizes.single, greaterThan(0));
        expect(scroll, 0);
        expect(tester.takeException(), isNull);
      });
    }
  }

  // ---- G12 _buildField (N10..N13) ----
  testWidgets('6-17 G12 N10..N13=S: ô thường, không focus', (tester) async {
    await _open(tester);
    expect(_borderColor(tester, 0), const Color(0x00000000));
    expect(_field(tester, 0).style!.color, AppColors.text);
    expect(_fillColor(tester, 0), AppColors.field);
    expect(_field(tester, 0).placeholderStyle!.color, AppColors.fieldHint);
  });

  testWidgets('6-18 G12 N11=Đ: ô đang focus => viền accent', (tester) async {
    await _open(tester);
    await tester.tap(find.byType(CupertinoTextField).at(0));
    await tester.pump();
    expect(_borderColor(tester, 0), AppColors.accent);
    expect(_borderColor(tester, 1), const Color(0x00000000));
  });

  testWidgets('6-19 G12 N10,N12,N13=Đ: ô sai => viền/chữ/nền cảnh báo', (
    tester,
  ) async {
    await _open(tester);
    await _fill(tester, ['21', '61']);
    await tapButton(tester, 'Xem');
    expect(_borderColor(tester, 1), AppColors.warningBorder);
    expect(_field(tester, 1).style!.color, AppColors.warning);
    expect(_fillColor(tester, 1), AppColors.warningSurface);
    expect(_borderColor(tester, 0), isNot(AppColors.warningBorder));
    expect(_fillColor(tester, 0), AppColors.field);
  });

  // ---- G13 _NumberFieldState.build (N14, N15, N16) ----
  testWidgets('6-20 G13 hasError=S: nhãn/đơn vị muted, nhãn đọc không "sai"', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _open(tester);
    expect(_text(tester, 'phút').style!.color, AppColors.muted);
    expect(_text(tester, "'").style!.color, AppColors.muted);
    expect(_text(tester, 'phút').style!.fontWeight, FontWeight.w400); // (*)
    expect(find.bySemanticsLabel(RegExp('^Vĩ độ, phút')), findsWidgets);
    expect(find.bySemanticsLabel(RegExp('sai')), findsNothing);
    handle.dispose();
  });

  testWidgets('6-21 G13 hasError=Đ: nhãn/đơn vị cảnh báo, nhãn đậm, đọc "sai"', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _open(tester);
    await _fill(tester, ['21', '61']);
    await tapButton(tester, 'Xem');
    expect(_text(tester, 'phút').style!.color, AppColors.warning);
    expect(_text(tester, 'phút').style!.fontWeight, FontWeight.w700);
    expect(_text(tester, "'").style!.color, AppColors.warning);
    expect(_text(tester, 'phút', 1).style!.color, AppColors.muted);
    expect(find.bySemanticsLabel('Vĩ độ, phút, sai'), findsWidgets);
    handle.dispose();
  });
}
