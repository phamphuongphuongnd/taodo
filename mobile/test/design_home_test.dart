import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toado/language_store.dart';
import 'package:toado/location_service.dart';
import 'package:toado/main.dart';
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

const _hanoi = LocationAvailable(21.02862, 105.80334);

Future<_FakeLocationService> _pumpApp(
  WidgetTester tester, {
  AppLanguage language = AppLanguage.vi,
  Size size = const Size(390, 844),
  bool reduceMotion = true,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      FakeAccessibilityFeatures(disableAnimations: reduceMotion);
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

void main() {
  group('màn hình chính', () {
    testWidgets('có tọa độ: đủ các phần theo thiết kế', (tester) async {
      final service = await _pumpApp(tester);
      service.emit(_hanoi);
      await tester.pump();

      expect(find.text('Tọa Độ'), findsOneWidget);
      expect(find.text('GPS ĐANG ĐO'), findsOneWidget);
      expect(find.text('VĨ ĐỘ'), findsOneWidget);
      expect(find.text('KINH ĐỘ'), findsOneWidget);
      expect(find.text('Cập nhật liên tục · Chạy offline'), findsOneWidget);
    });

    testWidgets('tiếng Anh', (tester) async {
      final service = await _pumpApp(tester, language: AppLanguage.en);
      service.emit(_hanoi);
      await tester.pump();

      expect(find.text('GPS ACTIVE'), findsOneWidget);
      expect(find.text('LATITUDE'), findsOneWidget);
      expect(find.text('Live updates · Works offline'), findsOneWidget);
    });

    testWidgets('chưa có tọa độ thì không ghi GPS đang đo', (tester) async {
      await _pumpApp(tester);

      expect(find.text('GPS ĐANG ĐO'), findsNothing);
      expect(find.text('Đang chờ tín hiệu GPS…'), findsOneWidget);
    });

    testWidgets('số tọa độ dùng chữ số đều chiều rộng', (tester) async {
      final service = await _pumpApp(tester);
      service.emit(_hanoi);
      await tester.pump();

      for (final digits in ['21', '01', '43', '105', '48', '12']) {
        final text = tester.widget<Text>(
          find.descendant(
            of: find.byType(CoordsDisplay),
            matching: find.text(digits),
          ),
        );
        expect(
          text.style!.fontFeatures,
          contains(const FontFeature.tabularFigures()),
          reason: digits,
        );
      }
    });

    testWidgets('ký hiệu đơn vị nâng cao hơn đường chân chữ số', (tester) async {
      final service = await _pumpApp(tester);
      service.emit(_hanoi);
      await tester.pump();

      final unit = find.descendant(
        of: find.byType(CoordsDisplay),
        matching: find.text('°'),
      );
      final digits = find.descendant(
        of: find.byType(CoordsDisplay),
        matching: find.text('21'),
      );
      expect(unit, findsNWidgets(2));
      expect(
        tester.getCenter(unit.first).dy,
        lessThan(tester.getCenter(digits).dy),
      );
    });

    testWidgets('nút ngôn ngữ ôm sát chữ, không giãn hết chỗ', (tester) async {
      await _pumpApp(tester);

      final pill = find.byType(LanguagePill);
      expect(tester.getSize(pill).width, lessThan(160));
      expect(tester.getTopRight(pill).dx, 390 - 16);
    });

    testWidgets('nút hành động giữa màn ôm sát chữ', (tester) async {
      final service = await _pumpApp(tester);
      service.emit(const LocationPermissionDenied());
      await tester.pump();

      final button = find.byType(ActionButton);
      expect(tester.getSize(button).width, lessThan(260));
    });

    for (final size in const [
      Size(390, 844),
      Size(360, 800),
      Size(320, 568),
    ]) {
      testWidgets('$size: không tràn ở mọi trạng thái', (tester) async {
        final service = await _pumpApp(tester, size: size);
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
    }

    testWidgets('nút chính cao đúng theo từng cỡ máy', (tester) async {
      await _pumpApp(tester);
      final button = find.widgetWithText(CupertinoButton, 'Xem');
      expect(tester.getSize(button).height, 60);

      await tester.pumpWidget(const SizedBox());
      await _pumpApp(tester, size: const Size(360, 800));
      expect(tester.getSize(button).height, 56);
    });

    testWidgets('nút Thông tin đủ vùng chạm và có nhãn', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpApp(tester);

      final about = find.byKey(const ValueKey('about-button'));
      expect(tester.getSize(about).width, greaterThanOrEqualTo(44));
      expect(tester.getSize(about).height, greaterThanOrEqualTo(44));
      expect(find.bySemanticsLabel(RegExp('Thông tin')), findsWidgets);
      expect(find.bySemanticsLabel(RegExp('Đổi ngôn ngữ')), findsWidgets);
      handle.dispose();
    });
  });

  group('ngôn ngữ máy đến muộn', () {
    Future<void> pumpWith(
      WidgetTester tester,
      _FakeLanguageStore store,
    ) async {
      tester.platformDispatcher.localesTestValue = const [Locale('en')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await tester.pumpWidget(
        ToaDoApp(
          locationService: _FakeLocationService(),
          languageStore: store,
        ),
      );
      await tester.pump();
    }

    Future<void> deviceReportsVietnamese(WidgetTester tester) async {
      tester.platformDispatcher.localesTestValue = const [Locale('vi', 'VN')];
      await tester.pump();
    }

    testWidgets('chưa chọn thì theo ngôn ngữ thật của máy', (tester) async {
      await pumpWith(tester, _FakeLanguageStore(null));
      expect(find.text('View'), findsOneWidget);

      await deviceReportsVietnamese(tester);

      expect(find.text('Xem'), findsOneWidget);
    });

    testWidgets('đã lưu lựa chọn thì giữ nguyên', (tester) async {
      await pumpWith(tester, _FakeLanguageStore(AppLanguage.en));

      await deviceReportsVietnamese(tester);

      expect(find.text('View'), findsOneWidget);
    });

    testWidgets('vừa bấm chọn thì không bị đổi lại', (tester) async {
      final store = _FakeLanguageStore(null);
      await pumpWith(tester, store);
      await tester.tap(find.byType(LanguagePill));
      await tester.pump();
      expect(find.text('Xem'), findsOneWidget);
      await tester.tap(find.byType(LanguagePill));
      await tester.pump();
      expect(find.text('View'), findsOneWidget);

      await deviceReportsVietnamese(tester);

      expect(find.text('View'), findsOneWidget);
    });
  });

  group('giảm chuyển động', () {
    testWidgets('bật giảm chuyển động thì không có hoạt ảnh', (tester) async {
      final service = await _pumpApp(tester);

      expect(tester.hasRunningAnimations, isFalse);
      service.emit(_hanoi);
      await tester.pump();
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('bình thường thì chờ GPS có hoạt ảnh', (tester) async {
      await _pumpApp(tester, reduceMotion: false);

      expect(tester.hasRunningAnimations, isTrue);
      await tester.pumpWidget(const SizedBox());
    });
  });

  test('màu cảnh báo và màu nhấn tách biệt', () {
    expect(AppColors.accent, isNot(AppColors.warning));
  });
}
