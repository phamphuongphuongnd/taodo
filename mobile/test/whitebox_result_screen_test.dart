// Kiểm thử hộp trắng (nhị phân) cho mobile/lib/result_screen.dart.
// Expected chép từ test-output/whitebox/ket-qua/result_screen/buoc-5-du-lieu-thu.md.
// Nguồn yêu cầu: docs/superpowers/specs/2026-10-31-toado-design.md, design-mobile/screens/README.md,
// bảng thien_cung_data.dart (do người dùng cung cấp). Dấu (*) = yêu cầu không nêu rõ, cần xác nhận.
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toado/language_store.dart';
import 'package:toado/result_screen.dart';
import 'package:toado/strings.dart';
import 'package:toado/theme.dart';
import 'package:toado/thien_cung.dart';
import 'package:toado/thien_cung_data.dart';
import 'package:toado/widgets.dart';

/// 12, 48, 05, 31, 14, 10, 02: khớp 12 (chưa có dữ liệu), 31 (Thiên Tài, Đại tài), 14 (chưa có dữ liệu).
const _example = '21°01\'43"N 105°48\'12"E';

/// Không số nào có trong bảng.
const _empty = '10°20\'30"N 40°50\'10"E';

/// Chỉ khớp 14 (Tích Lũy Tài Sản, chưa có dữ liệu).
const _onlyNoData = '10°20\'30"N 40°50\'14"E';

/// 00 và 11 đều thuộc Bảo Vệ (có dữ liệu, không nhóm, không cảnh báo).
const _twoProtection = '10°20\'30"N 40°11\'00"E';

/// 89 (Tai Họa, cảnh báo, không nhóm) đứng trước 00 (Bảo Vệ), rồi 96, 21, 12 (Chăm Chỉ, 3 dòng có dữ liệu ⇒ cung nổi bật).
const _taiHoaFirst = '10°12\'21"N 96°00\'89"E';

/// 27 (3 dòng), 61 (2 dòng cảnh báo: Đào Hoa nhóm Tai họa, Tai Họa), 91 (Quan Lộc, Đại quan, dòng cuối).
const _multiWarning = '20°59\'16"N 105°50\'27"E';

Future<void> _pumpResult(
  WidgetTester tester,
  String coordsText, {
  AppLanguage language = AppLanguage.vi,
  Size size = const Size(390, 2400),
  List<ThienCungGroup> table = thienCungTable,
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
  final navigator = tester.state<NavigatorState>(find.byType(Navigator));
  unawaited(
    navigator.push(
      CupertinoPageRoute<void>(
        builder: (_) => ResultScreen(coordsText: coordsText, table: table),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Bảng thật nhưng các dòng có tên nhóm (hoặc tên cung nếu không nhóm) thuộc [names] bị xóa ý nghĩa (meaningVi/meaningEn = ''),
/// để đi nhánh "dòng chưa có dữ liệu" (từ khi 6 nhóm đã được điền dữ liệu, bảng thật không còn dòng trống).
List<ThienCungGroup> _tableWithoutMeaning(Set<String> names) => [
  for (final g in thienCungTable)
    names.contains(g.groupVi ?? g.palaceVi)
        ? ThienCungGroup(
            palaceOrder: g.palaceOrder,
            palaceVi: g.palaceVi,
            palaceEn: g.palaceEn,
            groupVi: g.groupVi,
            groupEn: g.groupEn,
            numbers: g.numbers,
            meaningVi: '',
            meaningEn: '',
            isWarning: g.isWarning,
          )
        : g,
];

Future<void> _pumpPairBox(
  WidgetTester tester, {
  required bool isWarning,
  required bool hasData,
}) async {
  await tester.pumpWidget(
    CupertinoApp(
      locale: const Locale('en'),
      home: Center(
        child: PairBox(pair: '31', isWarning: isWarning, hasData: hasData),
      ),
    ),
  );
}

Finder _pairBoxes() => find.byType(PairBox);

PairBox _pairBoxAt(WidgetTester tester, int index) =>
    tester.widget<PairBox>(_pairBoxes().at(index));

/// Dòng thứ [index] trong danh sách chi tiết (MergeSemantics bọc quanh PairBox).
Finder _rowAt(int index) => find
    .ancestor(of: _pairBoxes().at(index), matching: find.byType(MergeSemantics))
    .first;

/// Text.rich đầu tiên trong dòng: tên cung (+ nhóm).
TextSpan _titleSpan(WidgetTester tester, int index) {
  final rich = find.descendant(
    of: _rowAt(index),
    matching: find.byWidgetPredicate(
      (w) => w is Text && w.textSpan != null && w.data == null,
    ),
  );
  return tester.widget<Text>(rich.first).textSpan! as TextSpan;
}

/// Text của ý nghĩa: Text có `data` và là Text cuối trong dòng.
Text _meaningText(WidgetTester tester, int index) {
  final plain = find.descendant(
    of: _rowAt(index),
    matching: find.byWidgetPredicate((w) => w is Text && w.data != null),
  );
  return tester.widget<Text>(plain.last);
}

Border _rowBorder(WidgetTester tester, int index) {
  final box = tester.widget<DecoratedBox>(
    find
        .descendant(of: _rowAt(index), matching: find.byType(DecoratedBox))
        .first,
  );
  return (box.decoration as BoxDecoration).border! as Border;
}

Color _pairColor(WidgetTester tester, int index) => tester
    .widget<Text>(
      find.descendant(of: _pairBoxes().at(index), matching: find.byType(Text)),
    )
    .style!
    .color!;

/// CustomPaint có painter (viền nét đứt) nằm trong PairBox [index].
Finder _dashed(int index) => find.descendant(
  of: _pairBoxes().at(index),
  matching: find.byWidgetPredicate((w) => w is CustomPaint && w.painter != null),
);

/// Container có BoxDecoration (ô cặp số có dữ liệu) trong PairBox [index].
BoxDecoration? _solidDecoration(WidgetTester tester, int index) {
  final containers = find.descendant(
    of: _pairBoxes().at(index),
    matching: find.byType(Container),
  );
  if (containers.evaluate().isEmpty) return null;
  return tester.widget<Container>(containers.first).decoration as BoxDecoration;
}

class _CountingCanvas implements Canvas {
  final strokes = <Paint>[];

  @override
  void drawPath(Path path, Paint paint) => strokes.add(paint);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  // Đơn vị ResultScreen.build: R1 (matches.isEmpty).
  testWidgets('6-1 không số nào trong bảng ⇒ chỉ tọa độ căn giữa và một câu', (
    tester,
  ) async {
    await _pumpResult(tester, _empty);

    expect(find.byType(ListView), findsNothing);
    expect(_pairBoxes(), findsNothing);
    final coords = tester.widget<CoordsDisplay>(find.byType(CoordsDisplay));
    expect(coords.coordsText, _empty);
    expect(coords.centered, isTrue);
    expect(find.text('Tọa độ này không có số nào trong bảng'), findsOneWidget);
    expect(find.text('KẾT LUẬN'), findsNothing);
    expect(find.text('CHI TIẾT THEO CẶP SỐ'), findsNothing);
    // (*) biểu tượng kính lúp lấy từ thiết kế Ket-qua-khong-khop
    expect(find.byIcon(CupertinoIcons.search), findsOneWidget);
  });

  // R1 S, C1 S, C2 S; _MatchRow: 12 (F,F,L=F,G=F), 31 (F,T,L=F,G=T), 14 (F,F,L=T,G=F).
  testWidgets('6-2 mẫu 3 dòng: 12 / 31 / 14 theo thứ tự, kết luận không lưu ý', (
    tester,
  ) async {
    await _pumpResult(tester, _example, table: _tableWithoutMeaning({'Chăm Chỉ', 'Tích Lũy Tài Sản'}));

    expect(find.byType(ListView), findsOneWidget);
    expect(_pairBoxes(), findsNWidgets(3));
    expect([for (var i = 0; i < 3; i++) _pairBoxAt(tester, i).pair], [
      '12',
      '31',
      '14',
    ]);
    expect(find.text('3 dòng'), findsOneWidget);
    expect(find.text('KẾT LUẬN'), findsOneWidget);
    expect(
      find.text(
        'Vị trí này nổi bật về Thiên Tài (Đại tài), '
        'thiên về tiền tài và cơ hội làm giàu.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Lưu ý'), findsNothing);
    expect(find.text('CẢNH BÁO'), findsNothing);

    // Dòng 12: chưa có dữ liệu, không nhóm ⇒ ô nét đứt, tên cung xám, "Chưa có dữ liệu" nghiêng.
    expect(_pairBoxAt(tester, 0).hasData, isFalse);
    expect(_pairBoxAt(tester, 0).isWarning, isFalse);
    expect(_dashed(0), findsOneWidget);
    expect(_pairColor(tester, 0), AppColors.muted);
    final title12 = _titleSpan(tester, 0);
    expect(title12.text, 'Chăm Chỉ');
    expect(title12.children, anyOf(isNull, isEmpty));
    expect(title12.style!.color, AppColors.label);
    final none12 = _meaningText(tester, 0);
    expect(none12.data, 'Chưa có dữ liệu');
    expect(none12.style!.fontStyle, FontStyle.italic);
    expect(none12.style!.color, AppColors.muted);

    // Dòng 31: có dữ liệu, có nhóm, không cảnh báo ⇒ ô đặc màu nhấn, nhóm màu nhãn.
    expect(_pairBoxAt(tester, 1).hasData, isTrue);
    expect(_dashed(1), findsNothing);
    expect(_pairColor(tester, 1), AppColors.accent);
    final deco31 = _solidDecoration(tester, 1)!;
    expect(deco31.color, AppColors.pairSurface);
    expect((deco31.border! as Border).top.color, AppColors.accentBorder);
    final title31 = _titleSpan(tester, 1);
    expect(title31.text, 'Thiên Tài');
    expect(title31.style!.color, AppColors.text);
    final group31 = title31.children!.single as TextSpan;
    expect(group31.text, ' (Đại tài)');
    expect(group31.style!.color, AppColors.label);
    final meaning31 = _meaningText(tester, 1);
    expect(meaning31.data, lookupPair('31').single.meaningVi);
    expect(meaning31.style!.color, AppColors.meaning);
    expect(meaning31.style!.fontStyle, isNull);

    // (*) đường kẻ dưới chỉ ở dòng cuối (thiết kế Ket-qua)
    expect(_rowBorder(tester, 0).bottom.width, 0);
    expect(_rowBorder(tester, 1).bottom.width, 0);
    expect(_rowBorder(tester, 2).bottom.width, greaterThan(0));
    expect(_rowBorder(tester, 2).bottom.color, AppColors.cardBorder);
    expect(_rowBorder(tester, 0).top.color, AppColors.cardBorder);
  });

  // C1 Đ; dòng duy nhất 14: (F,F,L=T,G=F).
  testWidgets('6-3 chỉ có dòng chưa có dữ liệu ⇒ "Chưa có dữ liệu để kết luận"', (
    tester,
  ) async {
    await _pumpResult(tester, _onlyNoData, table: _tableWithoutMeaning({'Tích Lũy Tài Sản'}));

    expect(_pairBoxes(), findsOneWidget);
    expect(find.text('KẾT LUẬN'), findsOneWidget);
    expect(find.text('Chưa có dữ liệu để kết luận'), findsOneWidget);
    expect(find.textContaining('nổi bật'), findsNothing);
    expect(find.textContaining('Lưu ý'), findsNothing);
    expect(find.text('1 dòng'), findsOneWidget);
    expect(find.text('Tích Lũy Tài Sản'), findsOneWidget);
    expect(_dashed(0), findsOneWidget);
    expect(_rowBorder(tester, 0).bottom.width, greaterThan(0));
  });

  // _MatchRow: 00 (F,T,L=F,G=F) và 11 (F,T,L=T,G=F).
  testWidgets('6-4 hai dòng Bảo Vệ (không nhóm, không cảnh báo): dòng cuối có đường kẻ dưới', (
    tester,
  ) async {
    await _pumpResult(tester, _twoProtection);

    expect(_pairBoxes(), findsNWidgets(2));
    expect([for (var i = 0; i < 2; i++) _pairBoxAt(tester, i).pair], [
      '00',
      '11',
    ]);
    expect(
      find.text(
        'Vị trí này nổi bật về Bảo Vệ, 2 lần, '
        'thiên về giữ gìn thành quả và sự bình ổn.',
      ),
      findsOneWidget,
    );
    expect(find.text('CẢNH BÁO'), findsNothing);
    for (var i = 0; i < 2; i++) {
      final title = _titleSpan(tester, i);
      expect(title.text, 'Bảo Vệ');
      expect(title.children, anyOf(isNull, isEmpty));
      expect(title.style!.color, AppColors.text);
      expect(_pairColor(tester, i), AppColors.accent);
      expect(_dashed(i), findsNothing);
    }
    // (*) đường kẻ dưới chỉ ở dòng cuối
    expect(_rowBorder(tester, 0).bottom.width, 0);
    expect(_rowBorder(tester, 1).bottom.width, greaterThan(0));
  });

  // C2 Đ; _MatchRow 89 (W=T,D=T,L=F,G=F) rồi 00 (F,T,L=F,G=F).
  testWidgets('6-5 Tai Họa (cảnh báo, không nhóm) không phải dòng cuối ⇒ nhãn, màu cam, câu lưu ý', (
    tester,
  ) async {
    await _pumpResult(tester, _taiHoaFirst);

    expect(_pairBoxAt(tester, 0).pair, '89');
    expect(_pairBoxAt(tester, 0).isWarning, isTrue);
    expect(_pairBoxAt(tester, 0).hasData, isTrue);
    expect(_pairBoxAt(tester, 1).pair, '00');
    expect(_pairBoxAt(tester, 1).isWarning, isFalse);

    expect(find.text('CẢNH BÁO'), findsOneWidget);
    expect(find.text('Lưu ý: vị trí này có Tai Họa.'), findsOneWidget);
    expect(
      find.text(
        'Vị trí này hội tụ 3 cung. Nổi bật nhất là Chăm Chỉ, 3 lần, '
        'thiên về sự cần cù và kiên trì. Bên cạnh đó, '
        'Bảo Vệ thiên về giữ gìn thành quả và sự bình ổn; '
        'Tai Họa thiên về vận hạn cần cẩn trọng.',
      ),
      findsOneWidget,
    );
    expect(_pairColor(tester, 0), AppColors.warning);
    final title = _titleSpan(tester, 0);
    expect(title.text, 'Tai Họa');
    expect(title.children, anyOf(isNull, isEmpty));
    expect(title.style!.color, AppColors.warning);
    expect(
      find.descendant(
        of: _rowAt(0),
        matching: find.byIcon(CupertinoIcons.exclamationmark_triangle_fill),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: _rowAt(1),
        matching: find.byIcon(CupertinoIcons.exclamationmark_triangle_fill),
      ),
      findsNothing,
    );
    expect(_meaningText(tester, 0).style!.color, AppColors.meaning);
    // PairBox cảnh báo: nền cam, viền cam 1.5
    final deco = _solidDecoration(tester, 0)!;
    expect(deco.color, AppColors.warningSurface);
    expect((deco.border! as Border).top.color, AppColors.warningBorder);
    expect((deco.border! as Border).top.width, 1.5);
  });

  // 27 ×3 (Tiểu tài; IQ cao; Số trời chưa có dữ liệu, đều có nhóm), 61 ×2 (Đào Hoa nhóm Tai họa; Tai Họa), 91 (dòng cuối).
  testWidgets('6-6 nhiều dòng cùng lúc: nhóm cảnh báo cam, nhóm thường xám, dòng chưa dữ liệu có nhóm', (
    tester,
  ) async {
    await _pumpResult(tester, _multiWarning, table: _tableWithoutMeaning({'Số trời'}));

    expect(_pairBoxes(), findsNWidgets(6));
    expect([for (var i = 0; i < 6; i++) _pairBoxAt(tester, i).pair], [
      '27',
      '27',
      '27',
      '61',
      '61',
      '91',
    ]);
    expect(find.text('6 dòng'), findsOneWidget);
    expect(find.text('CẢNH BÁO'), findsNWidgets(2));
    expect(
      find.text('Lưu ý: vị trí này có Đào Hoa (Tai họa) và Tai Họa.'),
      findsOneWidget,
    );
    // Số trời chưa có dữ liệu nên bị loại: còn 5 cung, mỗi cung 1 lần ⇒ không ghi số lần.
    expect(find.textContaining('hội tụ 5 cung ngang nhau'), findsOneWidget);
    expect(find.textContaining('mỗi cung'), findsNothing);

    // Dòng 3 (Số trời): chưa có dữ liệu, có nhóm, không cảnh báo ⇒ nhóm màu nhãn, nét đứt.
    expect(_pairBoxAt(tester, 2).hasData, isFalse);
    expect(_dashed(2), findsOneWidget);
    final soTroi = _titleSpan(tester, 2);
    expect(soTroi.text, 'Thần Linh Trời Định');
    expect((soTroi.children!.single as TextSpan).text, ' (Số trời)');
    expect((soTroi.children!.single as TextSpan).style!.color, AppColors.label);
    expect(_meaningText(tester, 2).data, 'Chưa có dữ liệu');
    expect(_rowBorder(tester, 2).bottom.width, 0);

    // Dòng 4 (Đào Hoa, Tai họa): cảnh báo + có nhóm ⇒ nhóm màu cam, không phải dòng cuối.
    expect(_pairBoxAt(tester, 3).isWarning, isTrue);
    final daoHoa = _titleSpan(tester, 3);
    expect(daoHoa.text, 'Đào Hoa');
    expect((daoHoa.children!.single as TextSpan).text, ' (Tai họa)');
    expect((daoHoa.children!.single as TextSpan).style!.color, AppColors.warning);
    expect(daoHoa.style!.color, AppColors.warning);
    expect(_rowBorder(tester, 3).bottom.width, 0);

    // Dòng 5 (Tai Họa): cảnh báo, không nhóm, không phải dòng cuối.
    expect(_pairBoxAt(tester, 4).isWarning, isTrue);
    expect(_titleSpan(tester, 4).children, anyOf(isNull, isEmpty));
    expect(_rowBorder(tester, 4).bottom.width, 0);

    // Dòng 6 (91, Quan Lộc): dòng cuối.
    expect(_pairBoxAt(tester, 5).isWarning, isFalse);
    expect(_rowBorder(tester, 5).bottom.width, greaterThan(0));

    // Dòng 1 (Tiểu tài): có dữ liệu, có nhóm, không cảnh báo.
    expect((_titleSpan(tester, 0).children!.single as TextSpan).text, ' (Tiểu tài)');
    expect(_pairColor(tester, 0), AppColors.accent);
    expect(_pairColor(tester, 3), AppColors.warning);
  });

  // PairBox: (isWarning, hasData) = (F,T), (F,F), (T,T) và (T,F) chỉ mức unit.
  group('PairBox', () {
    testWidgets('6-7 (không cảnh báo, có dữ liệu) ⇒ ô đặc, chữ nhấn, nền pairSurface', (
      tester,
    ) async {
      await _pumpPairBox(tester, isWarning: false, hasData: true);

      expect(_dashed(0), findsNothing);
      final text = tester.widget<Text>(
        find.descendant(of: _pairBoxes(), matching: find.byType(Text)),
      );
      expect(text.style!.color, AppColors.accent);
      final deco = _solidDecoration(tester, 0)!;
      expect(deco.color, AppColors.pairSurface);
      expect((deco.border! as Border).top.color, AppColors.accentBorder);
      // (*) chữ có dữ liệu đậm hơn chữ chưa có dữ liệu
      expect(text.style!.fontWeight, FontWeight.w800);
    });

    testWidgets('6-8 (không cảnh báo, chưa có dữ liệu) ⇒ viền nét đứt, chữ mờ', (
      tester,
    ) async {
      await _pumpPairBox(tester, isWarning: false, hasData: false);

      expect(_dashed(0), findsOneWidget);
      expect(
        find.descendant(of: _pairBoxes(), matching: find.byType(Container)),
        findsNothing,
      );
      final text = tester.widget<Text>(
        find.descendant(of: _pairBoxes(), matching: find.byType(Text)),
      );
      expect(text.style!.color, AppColors.muted);
      expect(text.style!.fontWeight, FontWeight.w700);
    });

    testWidgets('6-9 (cảnh báo, có dữ liệu) ⇒ ô đặc nền cam, viền cam 1.5, chữ cam', (
      tester,
    ) async {
      await _pumpPairBox(tester, isWarning: true, hasData: true);

      expect(_dashed(0), findsNothing);
      final deco = _solidDecoration(tester, 0)!;
      expect(deco.color, AppColors.warningSurface);
      final border = deco.border! as Border;
      expect(border.top.color, AppColors.warningBorder);
      expect(border.top.width, 1.5);
      final text = tester.widget<Text>(
        find.descendant(of: _pairBoxes(), matching: find.byType(Text)),
      );
      expect(text.style!.color, AppColors.warning);
    });

    // Chỉ khả thi mức unit: bảng không có dòng cảnh báo mà thiếu ý nghĩa.
    testWidgets('6-10 (*) (cảnh báo, chưa có dữ liệu) chỉ mức unit ⇒ vẫn nét đứt, không lỗi', (
      tester,
    ) async {
      await _pumpPairBox(tester, isWarning: true, hasData: false);

      expect(tester.takeException(), isNull);
      expect(_dashed(0), findsOneWidget);
      expect(
        find.descendant(of: _pairBoxes(), matching: find.byType(Container)),
        findsNothing,
      );
    });

    testWidgets('6-11 màn hẹp (<390) ⇒ ô cặp số 52, màn thường 56', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await _pumpPairBox(tester, isWarning: false, hasData: true);
      expect(tester.getSize(find.byType(Container).first), const Size(52, 52));
    });
  });

  // _DashedBoxPainter.paint: D1 (start < metric.length).
  group('_DashedBoxPainter', () {
    CustomPainter painterOf(WidgetTester tester) =>
        tester.widget<CustomPaint>(_dashed(0)).painter!;

    testWidgets('6-12 ô 56×56 ⇒ vòng nét đứt chạy nhiều lần rồi dừng, mỗi nét rộng 1.5 màu dashedBorder', (
      tester,
    ) async {
      await _pumpPairBox(tester, isWarning: false, hasData: false);
      final canvas = _CountingCanvas();

      painterOf(tester).paint(canvas, const Size(56, 56));

      expect(canvas.strokes.length, greaterThan(1));
      for (final paint in canvas.strokes) {
        expect(paint.style, PaintingStyle.stroke);
        expect(paint.strokeWidth, 1.5);
        expect(paint.color.toARGB32(), AppColors.dashedBorder.toARGB32());
      }
    });

    testWidgets('6-13 (*) kích thước 0 ⇒ không ném lỗi', (tester) async {
      await _pumpPairBox(tester, isWarning: false, hasData: false);
      final canvas = _CountingCanvas();

      painterOf(tester).paint(canvas, Size.zero);

      expect(tester.takeException(), isNull);
      // Nét vẽ (nếu có) vẫn đúng kiểu.
      for (final paint in canvas.strokes) {
        expect(paint.strokeWidth, 1.5);
      }
    });

    testWidgets('6-14 ô lớn hơn ⇒ nhiều nét hơn ô nhỏ (viền kín)', (tester) async {
      await _pumpPairBox(tester, isWarning: false, hasData: false);
      final small = _CountingCanvas();
      final large = _CountingCanvas();

      painterOf(tester).paint(small, const Size(56, 56));
      painterOf(tester).paint(large, const Size(112, 112));

      expect(large.strokes.length, greaterThan(small.strokes.length));
    });
  });

  // Đơn vị _ConclusionCard: C1 (conclusion.isEmpty) x C2 (warnings.isNotEmpty); C1=Đ & C2=Đ không khả thi.
  testWidgets('6-15 tiếng Anh: câu kết luận và lưu ý theo ngôn ngữ đang chọn', (
    tester,
  ) async {
    // Màn cao để ListView dựng đủ cả hai dòng cảnh báo dù Kết luận tiếng Anh dài.
    await _pumpResult(
      tester,
      _multiWarning,
      language: AppLanguage.en,
      size: const Size(390, 4000),
    );

    expect(find.text('CONCLUSION'), findsOneWidget);
    expect(find.text('WARNING'), findsNWidgets(2));
    expect(
      find.text(
        'This location brings together 6 equally strong palaces: '
        'Fortune (Minor Fortune) tied to wealth and opportunities to prosper; '
        'Career (High Office) tied to status and career path; '
        'Intelligence (High IQ) tied to intellect and the ability to learn; '
        'Divine Destiny (Heavenly Fate) tied to blessings ordained by heaven; '
        'Romance (Misfortune) tied to relationships and affection; '
        'Misfortune tied to misfortunes that call for caution.',
      ),
      findsOneWidget,
    );
    expect(
      find.text('Note: this location includes Romance (Misfortune) and Misfortune.'),
      findsOneWidget,
    );
  });
}
