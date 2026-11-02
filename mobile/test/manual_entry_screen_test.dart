import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toado/language_store.dart';
import 'package:toado/location_service.dart';
import 'package:toado/main.dart';
import 'package:toado/manual_entry_screen.dart';
import 'package:toado/result_screen.dart';
import 'package:toado/strings.dart';
import 'package:toado/widgets.dart';

Finder _coords(String text) => find.byWidgetPredicate(
  (widget) => widget is CoordsDisplay && widget.coordsText == text,
);

class _FakeLocationService implements LocationService {
  final _controller = StreamController<LocationState>.broadcast(sync: true);

  void emit(LocationState state) => _controller.add(state);

  @override
  Stream<LocationState> get states => _controller.stream;

  @override
  Future<void> refresh() async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> suspend() async {}

  @override
  Future<void> requestPermission() async {}

  @override
  Future<void> openAppSettings() async {}

  @override
  Future<void> openLocationSettings() async {}

  @override
  Future<void> dispose() async {}
}

class _FakeLanguageStore implements LanguageStore {
  _FakeLanguageStore(this.saved);

  AppLanguage? saved;

  @override
  Future<AppLanguage?> load() async => saved;

  @override
  Future<void> save(AppLanguage language) async => saved = language;
}

Future<_FakeLocationService> _pumpApp(
  WidgetTester tester, {
  AppLanguage language = AppLanguage.vi,
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

  final service = _FakeLocationService();
  await tester.pumpWidget(
    ToaDoApp(
      locationService: service,
      languageStore: _FakeLanguageStore(language),
    ),
  );
  await tester.pump();
  return service;
}

Future<void> _openManualEntry(WidgetTester tester, String label) async {
  await tester.tap(find.widgetWithText(CupertinoButton, label));
  await tester.pumpAndSettle();
}

/// Điền 6 ô theo thứ tự độ, phút, giây của vĩ độ rồi kinh độ.
Future<void> _fill(WidgetTester tester, List<String> values) async {
  final fields = find.byType(CupertinoTextField);
  for (var i = 0; i < values.length; i++) {
    await tester.enterText(fields.at(i), values[i]);
  }
  await tester.pump();
}

Future<void> _tapView(WidgetTester tester, String label) async {
  await tester.tap(find.widgetWithText(CupertinoButton, label));
  await tester.pumpAndSettle();
}

const _invalidVi =
    'Tọa độ không hợp lệ. Phút và giây phải dưới 60, vĩ độ tối đa 90°, '
    'kinh độ tối đa 180°.';

void main() {
  group('nút Nhập tay trên màn hình chính', () {
    testWidgets('bấm được khi đang chờ GPS', (tester) async {
      await _pumpApp(tester);
      await _openManualEntry(tester, 'Nhập tay');
      expect(find.byType(ManualEntryScreen), findsOneWidget);
    });

    testWidgets('bấm được khi chưa cấp quyền', (tester) async {
      final service = await _pumpApp(tester);
      service.emit(const LocationPermissionDenied());
      await tester.pump();
      await _openManualEntry(tester, 'Nhập tay');
      expect(find.byType(ManualEntryScreen), findsOneWidget);
    });

    testWidgets('bấm được khi định vị tắt', (tester) async {
      final service = await _pumpApp(tester);
      service.emit(const LocationServiceDisabled());
      await tester.pump();
      await _openManualEntry(tester, 'Nhập tay');
      expect(find.byType(ManualEntryScreen), findsOneWidget);
    });

    testWidgets('tiếng Anh', (tester) async {
      await _pumpApp(tester, language: AppLanguage.en);
      await _openManualEntry(tester, 'Enter manually');
      expect(find.byType(ManualEntryScreen), findsOneWidget);
      expect(find.text('Latitude'), findsOneWidget);
      expect(find.text('Longitude'), findsOneWidget);
    });
  });

  group('trang nhập tay', () {
    testWidgets('nhập đúng mở trang kết quả với tọa độ chuẩn', (tester) async {
      await _pumpApp(tester, size: const Size(390, 2000));
      await _openManualEntry(tester, 'Nhập tay');
      await _fill(tester, ['21', '1', '43', '105', '48', '12']);
      await _tapView(tester, 'Xem');

      expect(find.byType(ResultScreen), findsOneWidget);
      expect(_coords('21°01\'43"N 105°48\'12"E'), findsOneWidget);
      expect(find.text('31'), findsOneWidget);
    });

    testWidgets('ô trống tính là 0', (tester) async {
      await _pumpApp(tester);
      await _openManualEntry(tester, 'Nhập tay');
      await _tapView(tester, 'Xem');

      expect(_coords('00°00\'00"N 00°00\'00"E'), findsOneWidget);
    });

    testWidgets('chọn S và W', (tester) async {
      await _pumpApp(tester);
      await _openManualEntry(tester, 'Nhập tay');
      await _fill(tester, ['21', '1', '43', '105', '48', '12']);
      await tester.tap(find.text('S'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('W'));
      await tester.pumpAndSettle();
      await _tapView(tester, 'Xem');

      expect(_coords('21°01\'43"S 105°48\'12"W'), findsOneWidget);
    });

    testWidgets('phút từ 60 báo lỗi và không mở kết quả', (tester) async {
      await _pumpApp(tester);
      await _openManualEntry(tester, 'Nhập tay');
      await _fill(tester, ['21', '60']);
      await _tapView(tester, 'Xem');

      expect(find.text(_invalidVi), findsOneWidget);
      expect(find.byType(ResultScreen), findsNothing);
    });

    testWidgets('vượt 180° báo lỗi', (tester) async {
      await _pumpApp(tester);
      await _openManualEntry(tester, 'Nhập tay');
      await _fill(tester, ['0', '0', '0', '181']);
      await _tapView(tester, 'Xem');

      expect(find.text(_invalidVi), findsOneWidget);
    });

    testWidgets('sửa ô thì lỗi biến mất', (tester) async {
      await _pumpApp(tester);
      await _openManualEntry(tester, 'Nhập tay');
      await _fill(tester, ['91']);
      await _tapView(tester, 'Xem');
      expect(find.text(_invalidVi), findsOneWidget);

      await _fill(tester, ['90']);
      expect(find.text(_invalidVi), findsNothing);
    });

    testWidgets('ô chỉ nhận chữ số và giới hạn độ dài', (tester) async {
      await _pumpApp(tester);
      await _openManualEntry(tester, 'Nhập tay');
      await _fill(tester, ['a1b', '1234']);

      final fields = tester
          .widgetList<CupertinoTextField>(find.byType(CupertinoTextField))
          .toList();
      expect(fields[0].controller!.text, '1');
      expect(fields[1].controller!.text, '12');
    });

    testWidgets('quay lại từ kết quả vẫn giữ số đã nhập', (tester) async {
      await _pumpApp(tester);
      await _openManualEntry(tester, 'Nhập tay');
      await _fill(tester, ['21']);
      await _tapView(tester, 'Xem');
      await tester.tap(find.descendant(
      of: find.byType(BackLink),
      matching: find.byType(CupertinoButton),
    ));
      await tester.pumpAndSettle();

      expect(find.byType(ManualEntryScreen), findsOneWidget);
      expect(find.widgetWithText(CupertinoTextField, '21'), findsOneWidget);
    });

    for (final size in const [Size(390, 844), Size(320, 568)]) {
      testWidgets('không tràn ở $size', (tester) async {
        await _pumpApp(tester, size: size);
        await _openManualEntry(tester, 'Nhập tay');
        await _fill(tester, ['90', '59', '59', '180', '59', '59']);
        await tester.tap(find.text('S'));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('không tràn khi bàn phím mở', (tester) async {
      await _pumpApp(tester, size: const Size(320, 568));
      await _openManualEntry(tester, 'Nhập tay');
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
