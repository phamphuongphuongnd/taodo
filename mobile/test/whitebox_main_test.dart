// Kiểm thử hộp trắng nhị phân cho mobile/lib/main.dart (ToaDoApp, _ToaDoAppState).
// Mã bộ 6-x chép từ test-output/whitebox/ung-dung-ngon-ngu/main/buoc-5-du-lieu-thu.md.
import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show LicenseRegistry;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toado/language_store.dart';
import 'package:toado/location_screen.dart';
import 'package:toado/location_service.dart';
import 'package:toado/main.dart' as app;
import 'package:toado/strings.dart';
import 'package:toado/theme.dart';

class _Service implements LocationService {
  int disposeCount = 0;
  final _controller = StreamController<LocationState>.broadcast(sync: true);

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
  Future<void> dispose() async => disposeCount++;
}

class _Store implements LanguageStore {
  _Store({
    this.saved,
    this.throwOnLoad = false,
    this.throwOnSave = false,
    this.gate,
  });

  AppLanguage? saved;
  bool throwOnLoad;
  bool throwOnSave;

  /// Khi có, `load()` chờ tới lúc test cho phép.
  Completer<void>? gate;
  int loadCount = 0;
  final saves = <AppLanguage>[];

  @override
  Future<AppLanguage?> load() async {
    loadCount++;
    if (gate != null) await gate!.future;
    if (throwOnLoad) throw StateError('load');
    return saved;
  }

  @override
  Future<void> save(AppLanguage language) async {
    saves.add(language);
    if (throwOnSave) throw StateError('save');
    saved = language;
  }
}

Finder _view(String label) => find.widgetWithText(CupertinoButton, label);
Finder get _vi => _view('Xem');
Finder get _en => _view('View');

Future<_Service> _pump(
  WidgetTester tester,
  LanguageStore store, {
  Locale? deviceLocale,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);

  final service = _Service();
  await tester.pumpWidget(
    app.ToaDoApp(
      locationService: service,
      languageStore: store,
      deviceLocale: deviceLocale,
    ),
  );
  await tester.pump();
  return service;
}

Future<void> _deviceReports(WidgetTester tester, Locale locale) async {
  tester.platformDispatcher.localesTestValue = [locale];
  await tester.pump();
}

/// Gọi thẳng vào observer của app, dùng cho đầu vào mà hệ điều hành không gửi.
WidgetsBindingObserver _observer(WidgetTester tester) =>
    tester.state(find.byType(app.ToaDoApp)) as WidgetsBindingObserver;

void main() {
  // Luật yêu cầu: máy tiếng Việt ra tiếng Việt, ngôn ngữ khác ra tiếng Anh.
  final realDeviceIsVi =
      PlatformDispatcher.instance.locale.languageCode == 'vi';
  final Finder realDeviceView = realDeviceIsVi ? _vi : _en;

  group('main()', () {
    testWidgets('6-1 main() dựng ToaDoApp bằng runApp', (tester) async {
      SharedPreferences.setMockInitialValues({});
      app.main();
      await tester.pump();
      await tester.pump();

      expect(find.byType(app.ToaDoApp), findsOneWidget);
      expect(find.byType(LocationScreen), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('6-2 callback giấy phép trả giấy phép Manrope', (tester) async {
      SharedPreferences.setMockInitialValues({});
      app.main();
      await tester.pump();

      final entries = await LicenseRegistry.licenses.toList();
      final manrope = entries.where((e) => e.packages.contains('Manrope'));

      expect(manrope, isNotEmpty);
      expect(
        manrope.first.paragraphs.map((p) => p.text).join('\n'),
        contains('SIL Open Font License'),
      );

      await tester.pumpWidget(const SizedBox());
    });
  });

  group('initState / dispose', () {
    testWidgets('6-3 initState đăng ký observer và bắt đầu đọc ngôn ngữ', (
      tester,
    ) async {
      final store = _Store(saved: AppLanguage.en);
      await _pump(tester, store);

      expect(store.loadCount, 1);
      expect(_en, findsOneWidget);
    });

    testWidgets('6-4 dispose gỡ observer và dọn dịch vụ vị trí', (
      tester,
    ) async {
      final store = _Store(saved: AppLanguage.vi);
      final service = await _pump(tester, store);
      expect(service.disposeCount, 0);

      await tester.pumpWidget(const SizedBox());
      // Sau khi gỡ, đổi ngôn ngữ máy không được gọi vào state đã chết.
      await _deviceReports(tester, const Locale('en'));

      expect(service.disposeCount, 1);
      expect(tester.takeException(), isNull);
    });
  });

  group('didChangeLocales', () {
    testWidgets('6-5 chưa chọn, theo máy: máy báo tiếng Việt thì ra tiếng Việt', (
      tester,
    ) async {
      await _pump(tester, _Store());
      await _deviceReports(tester, const Locale('en'));
      expect(_en, findsOneWidget);

      await _deviceReports(tester, const Locale('vi', 'VN'));

      expect(_vi, findsOneWidget);
    });

    testWidgets('6-6 đã lưu lựa chọn thì ngôn ngữ máy đến muộn không đổi', (
      tester,
    ) async {
      await _pump(tester, _Store(saved: AppLanguage.en));

      await _deviceReports(tester, const Locale('vi', 'VN'));

      expect(_en, findsOneWidget);
      expect(_vi, findsNothing);
    });

    testWidgets('6-7 deviceLocale được tiêm thì không theo ngôn ngữ máy thật', (
      tester,
    ) async {
      await _pump(tester, _Store(), deviceLocale: const Locale('en'));
      expect(_en, findsOneWidget);

      await _deviceReports(tester, const Locale('vi', 'VN'));

      expect(_en, findsOneWidget);
      expect(_vi, findsNothing);
    });

    testWidgets('6-8 danh sách ngôn ngữ null thì giữ nguyên, không lỗi', (
      tester,
    ) async {
      await _pump(tester, _Store());
      await _deviceReports(tester, const Locale('en'));

      _observer(tester).didChangeLocales(null);
      await tester.pump();

      expect(_en, findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('6-9 danh sách ngôn ngữ rỗng thì giữ nguyên, không lỗi', (
      tester,
    ) async {
      await _pump(tester, _Store());
      await _deviceReports(tester, const Locale('en'));

      _observer(tester).didChangeLocales(const []);
      await tester.pump();

      expect(_en, findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('_loadLanguage', () {
    testWidgets('6-10 chưa lưu, không tiêm: theo ngôn ngữ máy thật, không ghi', (
      tester,
    ) async {
      final store = _Store();
      await _pump(tester, store);

      expect(realDeviceView, findsOneWidget);
      expect(store.saves, isEmpty);
    });

    testWidgets('6-11 store đọc lỗi thì coi như chưa chọn, vẫn theo máy', (
      tester,
    ) async {
      final store = _Store(throwOnLoad: true);
      await _pump(tester, store);

      expect(realDeviceView, findsOneWidget);
      expect(tester.takeException(), isNull);

      // Còn theo máy: ngôn ngữ máy đến muộn vẫn có hiệu lực.
      await _deviceReports(tester, const Locale('vi', 'VN'));
      expect(_vi, findsOneWidget);
    });

    testWidgets('6-12 widget gỡ trước khi đọc xong thì không setState', (
      tester,
    ) async {
      final gate = Completer<void>();
      final store = _Store(saved: AppLanguage.vi, gate: gate);
      await _pump(tester, store);
      expect(find.byType(CupertinoApp), findsNothing);

      await tester.pumpWidget(const SizedBox());
      gate.complete();
      await tester.pump();
      await tester.pump();

      expect(find.byType(CupertinoApp), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('6-13 deviceLocale tiêm tiếng Việt, chưa lưu: ra tiếng Việt', (
      tester,
    ) async {
      final store = _Store();
      await _pump(tester, store, deviceLocale: const Locale('vi'));

      expect(_vi, findsOneWidget);
      expect(store.saves, isEmpty);
    });

    testWidgets('6-14 đã lưu tiếng Anh, máy tiếng Việt: lựa chọn đã lưu thắng', (
      tester,
    ) async {
      final store = _Store(saved: AppLanguage.en);
      await _pump(tester, store, deviceLocale: const Locale('vi'));

      expect(_en, findsOneWidget);
      expect(store.saved, AppLanguage.en);
    });
  });

  group('_changeLanguage / _saveLanguage', () {
    testWidgets('6-15 đổi ngôn ngữ áp dụng ngay, ghi vào store, thôi theo máy', (
      tester,
    ) async {
      final store = _Store();
      await _pump(tester, store, deviceLocale: const Locale('vi'));
      expect(_vi, findsOneWidget);

      await tester.tap(find.text('English'));
      await tester.pump();

      expect(_en, findsOneWidget);
      expect(store.saves, [AppLanguage.en]);

      // Đã chọn tay: ngôn ngữ máy đến muộn không được đổi lại.
      await _deviceReports(tester, const Locale('vi', 'VN'));
      expect(_en, findsOneWidget);
    });

    testWidgets('6-16 ghi thành công thì store giữ lựa chọn', (tester) async {
      final store = _Store(saved: AppLanguage.vi);
      await _pump(tester, store);

      await tester.tap(find.text('English'));
      await tester.pump();

      expect(store.saved, AppLanguage.en);
      expect(tester.takeException(), isNull);
    });

    testWidgets('6-17 ghi lỗi thì lựa chọn vẫn có hiệu lực, không lỗi', (
      tester,
    ) async {
      final store = _Store(saved: AppLanguage.vi, throwOnSave: true);
      await _pump(tester, store);

      await tester.tap(find.text('English'));
      await tester.pump();

      expect(store.saves, [AppLanguage.en]);
      expect(_en, findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('build', () {
    testWidgets('6-18 chưa đọc xong thì chỉ hiện nền màn hình', (tester) async {
      final gate = Completer<void>();
      await _pump(tester, _Store(saved: AppLanguage.vi, gate: gate));

      expect(find.byType(CupertinoApp), findsNothing);
      expect(find.byType(LanguageScope), findsNothing);
      final box = tester.widget<ColoredBox>(find.byType(ColoredBox));
      expect(box.color, AppColors.screen);

      gate.complete();
      await tester.pump();
      await tester.pump();
      expect(find.byType(CupertinoApp), findsOneWidget);
    });

    testWidgets(
      '6-19 đọc xong thì dựng LanguageScope + CupertinoApp + màn hình chính',
      (tester) async {
        await _pump(tester, _Store(saved: AppLanguage.en));

        final scope = tester.widget<LanguageScope>(find.byType(LanguageScope));
        expect(scope.language, AppLanguage.en);
        final cupertino = tester.widget<CupertinoApp>(
          find.byType(CupertinoApp),
        );
        expect(cupertino.title, 'Tọa Độ');
        expect(find.byType(LocationScreen), findsOneWidget);
      },
    );
  });
}
