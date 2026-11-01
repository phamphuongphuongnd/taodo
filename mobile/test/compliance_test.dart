import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show LicensePage;
import 'package:flutter_test/flutter_test.dart';
import 'package:toado/about_screen.dart';
import 'package:toado/language_store.dart';
import 'package:toado/location_service.dart';
import 'package:toado/main.dart';
import 'package:toado/result_screen.dart';
import 'package:toado/strings.dart';

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

const _hanoi = LocationAvailable(21.02862, 105.80334);
const _hanoiVi =
    'Vĩ độ 21 độ 1 phút 43 giây Bắc, kinh độ 105 độ 48 phút 12 giây Đông';

Future<_FakeLocationService> _pumpApp(
  WidgetTester tester, {
  AppLanguage language = AppLanguage.vi,
  Size size = const Size(390, 844),
  double textScale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

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

Future<void> _tapButton(WidgetTester tester, String label) async {
  await tester.tap(find.widgetWithText(CupertinoButton, label));
  await tester.pumpAndSettle();
}

void main() {
  group('đọc tọa độ cho trình đọc màn hình', () {
    final vi = AppStrings.of(AppLanguage.vi);
    final en = AppStrings.of(AppLanguage.en);

    test('tiếng Việt', () {
      expect(
        vi.spokenCoords('20°18\'08"N 106°22\'40"E'),
        'Vĩ độ 20 độ 18 phút 8 giây Bắc, kinh độ 106 độ 22 phút 40 giây Đông',
      );
    });

    test('tiếng Anh, bán cầu Nam và Tây', () {
      expect(
        en.spokenCoords('08°46\'12"S 005°00\'01"W'),
        'Latitude 8 degrees 46 minutes 12 seconds South, '
        'longitude 5 degrees 0 minutes 1 seconds West',
      );
    });

    test('chuỗi lạ thì giữ nguyên', () {
      expect(vi.spokenCoords('abc'), 'abc');
    });
  });

  group('nhãn cho trình đọc màn hình', () {
    testWidgets('màn hình chính đọc tọa độ thành lời', (tester) async {
      final handle = tester.ensureSemantics();
      final service = await _pumpApp(tester);
      service.emit(_hanoi);
      await tester.pump();

      expect(find.bySemanticsLabel(_hanoiVi), findsOneWidget);
      handle.dispose();
    });

    testWidgets('trang kết quả đọc tọa độ thành lời', (tester) async {
      final handle = tester.ensureSemantics();
      final service = await _pumpApp(tester);
      service.emit(_hanoi);
      await tester.pump();
      await _tapButton(tester, 'Xem');

      expect(find.byType(ResultScreen), findsOneWidget);
      expect(find.bySemanticsLabel(_hanoiVi), findsOneWidget);
      handle.dispose();
    });

    testWidgets('6 ô nhập và nút bán cầu đều có nhãn', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpApp(tester);
      await _tapButton(tester, 'Nhập tay');

      for (final label in [
        'Vĩ độ, độ',
        'Vĩ độ, phút',
        'Vĩ độ, giây',
        'Kinh độ, độ',
        'Kinh độ, phút',
        'Kinh độ, giây',
        'Bắc',
        'Nam',
        'Đông',
        'Tây',
      ]) {
        expect(
          find.bySemanticsLabel(RegExp('^$label')),
          findsWidgets,
          reason: label,
        );
      }
      handle.dispose();
    });

    testWidgets('lỗi nhập được đọc lên ngay', (tester) async {
      await _pumpApp(tester);
      await _tapButton(tester, 'Nhập tay');
      await tester.enterText(find.byType(CupertinoTextField).at(1), '75');
      await tester.pump();
      await _tapButton(tester, 'Xem');

      final error = find.textContaining('Tọa độ không hợp lệ');
      final region = tester
          .widgetList<Semantics>(
            find.ancestor(of: error, matching: find.byType(Semantics)),
          )
          .any((semantics) => semantics.properties.liveRegion == true);
      expect(region, isTrue);
    });
  });

  group('chữ phóng to 200%', () {
    for (final size in const [Size(390, 844), Size(320, 568)]) {
      for (final language in AppLanguage.values) {
        final manual = language == AppLanguage.vi
            ? 'Nhập tay'
            : 'Enter manually';
        final view = language == AppLanguage.vi ? 'Xem' : 'View';
        final about = language == AppLanguage.vi ? 'Thông tin' : 'About';

        testWidgets('$size ${language.name}: các trạng thái', (tester) async {
          final service = await _pumpApp(
            tester,
            language: language,
            size: size,
            textScale: 2,
          );
          for (final state in const <LocationState>[
            LocationWaiting(),
            LocationPermissionNeeded(),
            LocationPermissionDenied(),
            LocationServiceDisabled(),
            _hanoi,
          ]) {
            service.emit(state);
            await tester.pump();
            expect(tester.takeException(), isNull);
          }
        });

        testWidgets('$size ${language.name}: nhập tay', (tester) async {
          await _pumpApp(
            tester,
            language: language,
            size: size,
            textScale: 2,
          );
          await _tapButton(tester, manual);

          expect(tester.takeException(), isNull);
        });

        testWidgets('$size ${language.name}: kết quả', (tester) async {
          final service = await _pumpApp(
            tester,
            language: language,
            size: size,
            textScale: 2,
          );
          service.emit(_hanoi);
          await tester.pump();
          await _tapButton(tester, view);

          expect(tester.takeException(), isNull);
        });

        testWidgets('$size ${language.name}: thông tin', (tester) async {
          await _pumpApp(
            tester,
            language: language,
            size: size,
            textScale: 2,
          );
          await _tapButton(tester, about);

          expect(find.byType(AboutScreen), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
      }
    }
  });

  group('trang Thông tin', () {
    testWidgets('có đủ quyền riêng tư, lưu ý, liên hệ', (tester) async {
      await _pumpApp(tester);
      await _tapButton(tester, 'Thông tin');

      expect(find.text('Quyền riêng tư'), findsOneWidget);
      expect(find.textContaining('không gửi đi đâu'), findsOneWidget);
      expect(find.textContaining(privacyPolicyUrl), findsOneWidget);
      await tester.scrollUntilVisible(
        find.textContaining('chỉ mang tính tham khảo'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.textContaining('dẫn đường'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.textContaining(issuesUrl),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.textContaining(issuesUrl), findsOneWidget);
    });

    testWidgets('tiếng Anh', (tester) async {
      await _pumpApp(tester, language: AppLanguage.en);
      await _tapButton(tester, 'About');

      expect(find.text('Privacy'), findsOneWidget);
      expect(find.textContaining('never sent anywhere'), findsOneWidget);
    });

    testWidgets('mở được danh sách giấy phép', (tester) async {
      await _pumpApp(tester);
      await _tapButton(tester, 'Thông tin');
      final licenses = find.widgetWithText(
        CupertinoButton,
        'Giấy phép mã nguồn mở',
      );
      await tester.scrollUntilVisible(
        licenses,
        200,
        scrollable: find.byType(Scrollable).last,
      );

      await tester.tap(licenses);
      await tester.pumpAndSettle();

      expect(find.byType(LicensePage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    test('phiên bản hiển thị khớp pubspec.yaml', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      final version = RegExp(
        r'^version: (\S+)\+\d+',
        multiLine: true,
      ).firstMatch(pubspec)!.group(1);

      expect(appVersion, version);
    });
  });
}
