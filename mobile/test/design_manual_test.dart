import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toado/coords.dart';
import 'package:toado/manual_entry_screen.dart';
import 'package:toado/result_screen.dart';
import 'package:toado/strings.dart';
import 'package:toado/theme.dart';

import 'test_support.dart';

const _invalidVi =
    'Tọa độ không hợp lệ. Phút và giây phải dưới 60, vĩ độ tối đa 90°, '
    'kinh độ tối đa 180°.';

Set<ManualField> _invalid({
  int latDeg = 0,
  int latMin = 0,
  int latSec = 0,
  int lonDeg = 0,
  int lonMin = 0,
  int lonSec = 0,
}) {
  return invalidManualFields(
    latDeg: latDeg,
    latMin: latMin,
    latSec: latSec,
    lonDeg: lonDeg,
    lonMin: lonMin,
    lonSec: lonSec,
  );
}

Future<void> _openManual(WidgetTester tester) => tapButton(tester, 'Nhập tay');

Future<void> _fill(WidgetTester tester, List<String> values) async {
  final fields = find.byType(CupertinoTextField);
  for (var i = 0; i < values.length; i++) {
    await tester.enterText(fields.at(i), values[i]);
  }
  await tester.pump();
}

BoxDecoration _decorationOf(WidgetTester tester, int index) {
  final field = tester.widget<CupertinoTextField>(
    find.byType(CupertinoTextField).at(index),
  );
  return field.decoration!;
}

bool _isWarning(WidgetTester tester, int index) {
  final border = _decorationOf(tester, index).border! as Border;
  return border.top.color == AppColors.warningBorder;
}

double _contrast(Color foreground, Color background) {
  final a = foreground.computeLuminance();
  final b = background.computeLuminance();
  final light = a > b ? a : b;
  final dark = a > b ? b : a;
  return (light + 0.05) / (dark + 0.05);
}

void main() {
  group('invalidManualFields', () {
    test('hợp lệ thì rỗng', () {
      expect(_invalid(latDeg: 21, latMin: 1, latSec: 43), isEmpty);
      expect(_invalid(latDeg: 90, lonDeg: 180), isEmpty);
    });

    test('phút hoặc giây từ 60 chỉ đánh dấu đúng ô đó', () {
      expect(_invalid(latMin: 60), {ManualField.latMin});
      expect(_invalid(latSec: 75), {ManualField.latSec});
      expect(_invalid(lonMin: 99), {ManualField.lonMin});
      expect(_invalid(lonSec: 60), {ManualField.lonSec});
    });

    test('vượt 90° hoặc 180° đánh dấu ô độ', () {
      expect(_invalid(latDeg: 91), {ManualField.latDeg});
      expect(_invalid(lonDeg: 181), {ManualField.lonDeg});
      expect(_invalid(latDeg: 90, latSec: 1), {ManualField.latDeg});
      expect(_invalid(lonDeg: 180, lonMin: 1), {ManualField.lonDeg});
    });

    test('nhiều ô sai thì đánh dấu đủ', () {
      expect(_invalid(latDeg: 91, latMin: 60, lonSec: 61), {
        ManualField.latDeg,
        ManualField.latMin,
        ManualField.lonSec,
      });
    });

    test('luôn khớp với formatManualCoords', () {
      for (final deg in const [0, 89, 90, 91, 180, 181]) {
        for (final min in const [0, 1, 59, 60]) {
          for (final sec in const [0, 1, 59, 60]) {
            final text = formatManualCoords(
              latDeg: deg,
              latMin: min,
              latSec: sec,
              north: true,
              lonDeg: deg,
              lonMin: min,
              lonSec: sec,
              east: true,
            );
            final fields = _invalid(
              latDeg: deg,
              latMin: min,
              latSec: sec,
              lonDeg: deg,
              lonMin: min,
              lonSec: sec,
            );
            expect(fields.isEmpty, text != null, reason: '$deg $min $sec');
          }
        }
      }
    });
  });

  group('trang nhập tọa độ', () {
    testWidgets('đủ các phần theo thiết kế', (tester) async {
      await pumpToaDoApp(tester);
      await _openManual(tester);

      expect(find.text('Nhập tọa độ'), findsOneWidget);
      expect(find.text('Quay lại'), findsOneWidget);
      expect(find.text('Vĩ độ'), findsOneWidget);
      expect(find.text('Kinh độ'), findsOneWidget);
      expect(find.text('độ'), findsNWidgets(2));
      expect(find.text('phút'), findsNWidgets(2));
      expect(find.text('giây'), findsNWidgets(2));
    });

    testWidgets('ô nhập cao 76', (tester) async {
      await pumpToaDoApp(tester);
      await _openManual(tester);

      expect(
        tester.getSize(find.byType(CupertinoTextField).first).height,
        76,
      );
    });

    testWidgets('nút bán cầu đủ vùng chạm 44', (tester) async {
      await pumpToaDoApp(tester);
      await _openManual(tester);

      for (final label in ['N', 'S', 'E', 'W']) {
        final button = find.ancestor(
          of: find.text(label),
          matching: find.byType(CupertinoButton),
        );
        expect(tester.getSize(button).height, greaterThanOrEqualTo(44));
        expect(tester.getSize(button).width, greaterThanOrEqualTo(44));
      }
    });

    testWidgets('chọn bán cầu đổi nút đang chọn', (tester) async {
      await pumpToaDoApp(tester);
      await _openManual(tester);

      Color colorOf(String label) =>
          tester.widget<Text>(find.text(label)).style!.color!;

      expect(colorOf('N'), AppColors.screen);
      expect(colorOf('S'), AppColors.label);

      await tester.tap(find.text('S'));
      await tester.pump();

      expect(colorOf('N'), AppColors.label);
      expect(colorOf('S'), AppColors.screen);
    });

    testWidgets('nút quay lại về màn hình chính', (tester) async {
      await pumpToaDoApp(tester);
      await _openManual(tester);

      await tester.tap(find.text('Quay lại'));
      await tester.pumpAndSettle();

      expect(find.byType(ManualEntryScreen), findsNothing);
    });

    testWidgets('nhập đúng vẫn mở kết quả', (tester) async {
      await pumpToaDoApp(tester);
      await _openManual(tester);
      await _fill(tester, ['21', '1', '43', '105', '48', '12']);
      await tapButton(tester, 'Xem');

      expect(find.byType(ResultScreen), findsOneWidget);
    });
  });

  group('báo lỗi', () {
    testWidgets('chỉ ô sai đổi màu cảnh báo', (tester) async {
      await pumpToaDoApp(tester);
      await _openManual(tester);
      await _fill(tester, ['21', '61', '43', '105', '48', '12']);
      await tapButton(tester, 'Xem');

      expect(find.text(_invalidVi), findsOneWidget);
      expect(_isWarning(tester, 1), isTrue);
      for (final index in [0, 2, 3, 4, 5]) {
        expect(_isWarning(tester, index), isFalse, reason: 'ô $index');
      }
      expect(_decorationOf(tester, 1).color, AppColors.warningSurface);
    });

    testWidgets('nhãn ô sai cũng đổi màu, có chữ chứ không chỉ màu', (
      tester,
    ) async {
      await pumpToaDoApp(tester);
      await _openManual(tester);
      await _fill(tester, ['21', '61']);
      await tapButton(tester, 'Xem');

      final labels = tester
          .widgetList<Text>(find.text('phút'))
          .map((text) => text.style!.color)
          .toList();
      expect(labels, [AppColors.warning, AppColors.muted]);
    });

    testWidgets('sửa bất kỳ ô nào thì hết lỗi', (tester) async {
      await pumpToaDoApp(tester);
      await _openManual(tester);
      await _fill(tester, ['21', '61']);
      await tapButton(tester, 'Xem');

      await tester.enterText(find.byType(CupertinoTextField).at(4), '1');
      await tester.pump();

      expect(find.text(_invalidVi), findsNothing);
      expect(_isWarning(tester, 1), isFalse);
    });

    testWidgets('trình đọc màn hình biết ô nào sai', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpToaDoApp(tester);
      await _openManual(tester);
      await _fill(tester, ['21', '61']);
      await tapButton(tester, 'Xem');

      expect(find.bySemanticsLabel(RegExp('Vĩ độ, phút, sai')), findsWidgets);
      handle.dispose();
    });
  });

  test('chữ gợi ý đủ tương phản 4.5:1 trên nền ô nhập', () {
    expect(
      _contrast(AppColors.fieldHint, AppColors.field),
      greaterThanOrEqualTo(4.5),
    );
  });

  group('không tràn', () {
    for (final size in const [
      Size(390, 844),
      Size(360, 800),
      Size(320, 568),
    ]) {
      for (final language in AppLanguage.values) {
        for (final scale in const [1.0, 2.0]) {
          testWidgets('$size ${language.name} chữ x$scale', (tester) async {
            await pumpToaDoApp(
              tester,
              size: size,
              language: language,
              textScale: scale,
            );
            await tapButton(
              tester,
              language == AppLanguage.vi ? 'Nhập tay' : 'Enter manually',
            );
            await tester.enterText(find.byType(CupertinoTextField).at(1), '99');
            await tester.pump();

            final view = find.widgetWithText(
              CupertinoButton,
              language == AppLanguage.vi ? 'Xem' : 'View',
            );
            await tester.ensureVisible(view);
            await tester.pump();
            await tester.tap(view);
            await tester.pumpAndSettle();

            expect(tester.takeException(), isNull);
            expect(find.byType(ManualEntryScreen), findsOneWidget);
          });
        }
      }
    }

    testWidgets('bàn phím mở trên màn nhỏ vẫn cuộn được', (tester) async {
      await pumpToaDoApp(tester, size: const Size(320, 568));
      await _openManual(tester);
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final view = find.widgetWithText(CupertinoButton, 'Xem');
      await tester.ensureVisible(view);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
