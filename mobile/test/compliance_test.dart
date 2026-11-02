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
import 'package:toado/theme.dart';
import 'package:toado/widgets.dart';

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

Future<void> _tapButton(WidgetTester tester, String label) async {
  await tester.tap(find.widgetWithText(CupertinoButton, label));
  await tester.pumpAndSettle();
}

Future<void> _openAbout(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('about-button')));
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

  group('nút có nhãn đọc riêng không đọc lặp chữ hiển thị', () {
    testWidgets('LanguagePill: nhãn đọc gồm đúng một câu, vẫn là nút bấm được', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      var taps = 0;
      await tester.pumpWidget(
        CupertinoApp(
          home: Center(
            child: LanguagePill(
              label: 'English',
              spokenLabel: 'Đổi ngôn ngữ sang English',
              onPressed: () => taps++,
            ),
          ),
        ),
      );

      final pill = find.byType(LanguagePill);
      final node = tester.getSemantics(pill);
      expect(node.getSemanticsData().label, 'Đổi ngôn ngữ sang English');
      expect(node, isSemantics(isButton: true, hasTapAction: true));

      await tester.tap(pill);
      expect(taps, 1);
      handle.dispose();
    });

    testWidgets('CircleIconButton: nhãn đọc gồm đúng một câu, vẫn là nút', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        CupertinoApp(
          home: Center(
            child: CircleIconButton(
              icon: CupertinoIcons.info,
              spokenLabel: 'Thông tin',
              onPressed: () {},
            ),
          ),
        ),
      );

      final node = tester.getSemantics(find.byType(CircleIconButton));
      expect(node.getSemanticsData().label, 'Thông tin');
      expect(node, isSemantics(isButton: true, hasTapAction: true));
      handle.dispose();
    });

    for (final (language, spoken) in const [
      (AppLanguage.vi, 'Đổi ngôn ngữ sang English'),
      (AppLanguage.en, 'Change language to Vietnamese'),
    ]) {
      testWidgets('${language.name}: nút ngôn ngữ trong app thật', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await _pumpApp(tester, language: language);

        final node = tester.getSemantics(find.byType(LanguagePill));
        expect(node.getSemanticsData().label, spoken);
        expect(node, isSemantics(isButton: true, hasTapAction: true));
        handle.dispose();
      });
    }
  });

  group('chữ phóng to 200%', () {
    for (final size in const [
      Size(390, 844),
      Size(360, 800),
      Size(320, 568),
    ]) {
      for (final language in AppLanguage.values) {
        final manual = language == AppLanguage.vi
            ? 'Nhập tay'
            : 'Enter manually';
        final view = language == AppLanguage.vi ? 'Xem' : 'View';

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
          await _openAbout(tester);

          expect(find.byType(AboutScreen), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
      }
    }
  });

  group('độ tương phản chữ', () {
    double contrast(Color foreground, Color background) {
      final a = foreground.computeLuminance();
      final b = background.computeLuminance();
      final light = a > b ? a : b;
      final dark = a > b ? b : a;
      return (light + 0.05) / (dark + 0.05);
    }

    const pairs = {
      'chữ chính trên nền': (AppColors.text, AppColors.screen),
      'nhãn trên nền': (AppColors.label, AppColors.screen),
      'chữ phụ trên nền': (AppColors.muted, AppColors.screen),
      'chữ phụ trên thẻ': (AppColors.muted, AppColors.card),
      'ý nghĩa trên thẻ': (AppColors.meaning, AppColors.card),
      'nhấn trên nền': (AppColors.accent, AppColors.screen),
      'nhấn trên thẻ Kết luận': (AppColors.accent, AppColors.conclusionSurface),
      'nhấn trên ô cặp số': (AppColors.accent, AppColors.pairSurface),
      'gợi ý trên ô nhập': (AppColors.fieldHint, AppColors.field),
      'cảnh báo trên nền': (AppColors.warning, AppColors.screen),
      'cảnh báo trên nền cảnh báo': (AppColors.warning, AppColors.warningSurface),
      'chữ nút chính': (AppColors.screen, AppColors.text),
      'nút Xem bị khóa': (AppColors.muted, AppColors.disabledSurface),
      'nút ngôn ngữ': (AppColors.pillText, AppColors.pillSurface),
    };

    for (final MapEntry(key: name, value: pair) in pairs.entries) {
      test('$name đạt 4.5:1', () {
        expect(contrast(pair.$1, pair.$2), greaterThanOrEqualTo(4.5));
      });
    }
  });

  group('trang Thông tin', () {
    testWidgets('có đủ quyền riêng tư, lưu ý, liên hệ', (tester) async {
      await _pumpApp(tester);
      await _openAbout(tester);

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
      await _openAbout(tester);

      expect(find.text('Privacy'), findsOneWidget);
      expect(find.textContaining('never sent anywhere'), findsOneWidget);
    });

    testWidgets('mở được danh sách giấy phép', (tester) async {
      await _pumpApp(tester);
      await _openAbout(tester);
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
