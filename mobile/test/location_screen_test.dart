import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:toado/language_store.dart';
import 'package:toado/location_service.dart';
import 'package:toado/main.dart';
import 'package:toado/result_screen.dart';
import 'package:toado/strings.dart';
import 'package:toado/thien_cung.dart';

/// Hà Nội: `21°01'43"N 105°48'12"E`.
const _hanoi = LocationAvailable(21.02862, 105.80334);
const _hanoiText = '21°01\'43"N 105°48\'12"E';

/// Nơi khác, tách ra 10, 50, 40, 30, 20, 10: không số nào có trong bảng.
const _empty = LocationAvailable(10.34167, 40.83612);
const _emptyText = '10°20\'30"N 40°50\'10"E';

/// Chuỗi dài nhất có thể.
const _longest = LocationAvailable(-79.99973, -179.99973);
const _longestText = '79°59\'59"S 179°59\'59"W';

class _FakeLocationService implements LocationService {
  final _controller = StreamController<LocationState>.broadcast(sync: true);
  int refreshCount = 0;
  int pauseCount = 0;
  int openAppSettingsCount = 0;
  int openLocationSettingsCount = 0;
  int disposeCount = 0;

  void emit(LocationState state) => _controller.add(state);

  @override
  Stream<LocationState> get states => _controller.stream;

  @override
  Future<void> refresh() async => refreshCount++;

  @override
  Future<void> pause() async => pauseCount++;

  @override
  Future<void> openAppSettings() async => openAppSettingsCount++;

  @override
  Future<void> openLocationSettings() async => openLocationSettingsCount++;

  @override
  Future<void> dispose() async => disposeCount++;
}

class _FakeLanguageStore implements LanguageStore {
  _FakeLanguageStore([this.saved]);

  AppLanguage? saved;
  bool failing = false;

  @override
  Future<AppLanguage?> load() async {
    if (failing) throw StateError('load');
    return saved;
  }

  @override
  Future<void> save(AppLanguage language) async {
    if (failing) throw StateError('save');
    saved = language;
  }
}

Future<_FakeLocationService> _pumpApp(
  WidgetTester tester, {
  LanguageStore? store,
  Locale deviceLocale = const Locale('vi'),
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final service = _FakeLocationService();
  await tester.pumpWidget(
    ToaDoApp(
      locationService: service,
      languageStore: store ?? _FakeLanguageStore(),
      deviceLocale: deviceLocale,
    ),
  );
  await tester.pump();
  return service;
}

Future<void> _emit(
  WidgetTester tester,
  _FakeLocationService service,
  LocationState state,
) async {
  service.emit(state);
  await tester.pump();
}

Finder _button(String label) => find.widgetWithText(CupertinoButton, label);

VoidCallback? _onPressed(WidgetTester tester, String label) =>
    tester.widget<CupertinoButton>(_button(label)).onPressed;

Future<void> _goBack(WidgetTester tester) async {
  await tester.tap(find.byType(CupertinoNavigationBarBackButton));
  await tester.pumpAndSettle();
}

Position _position(double latitude, double longitude) => Position(
  latitude: latitude,
  longitude: longitude,
  timestamp: DateTime(2026),
  accuracy: 0,
  altitude: 0,
  altitudeAccuracy: 0,
  heading: 0,
  headingAccuracy: 0,
  speed: 0,
  speedAccuracy: 0,
);

class _FakeGeolocator extends GeolocatorPlatform {
  bool serviceEnabled = true;
  LocationPermission permission = LocationPermission.whileInUse;
  LocationPermission requestResult = LocationPermission.whileInUse;
  Completer<void>? requestGate;
  bool failing = false;

  int requestCount = 0;
  int openAppCount = 0;
  int openLocationCount = 0;
  int positionListeners = 0;
  int positionStreamsCreated = 0;
  int serviceListeners = 0;
  LocationSettings? settings;
  StreamController<Position>? positions;
  final serviceStatus = StreamController<ServiceStatus>.broadcast(sync: true);

  @override
  Future<bool> isLocationServiceEnabled() async {
    if (failing) throw StateError('platform');
    return serviceEnabled;
  }

  @override
  Future<LocationPermission> checkPermission() async => permission;

  @override
  Future<LocationPermission> requestPermission() async {
    requestCount++;
    await requestGate?.future;
    return permission = requestResult;
  }

  @override
  Stream<ServiceStatus> getServiceStatusStream() {
    serviceListeners++;
    return serviceStatus.stream;
  }

  @override
  Stream<Position> getPositionStream({LocationSettings? locationSettings}) {
    positionStreamsCreated++;
    settings = locationSettings;
    final controller = StreamController<Position>(
      sync: true,
      onListen: () => positionListeners++,
      onCancel: () => positionListeners--,
    );
    positions = controller;
    return controller.stream;
  }

  @override
  Future<bool> openAppSettings() async {
    openAppCount++;
    return true;
  }

  @override
  Future<bool> openLocationSettings() async {
    openLocationCount++;
    return true;
  }
}

Future<void> _settleEvents() => Future<void>.delayed(Duration.zero);

void main() {
  group('trạng thái', () {
    const sizes = [Size(390, 844), Size(320, 568)];
    const texts = {
      AppLanguage.vi: (
        locale: Locale('vi'),
        view: 'Xem',
        waiting: 'Đang chờ tín hiệu GPS…',
        denied: 'Chưa cấp quyền vị trí',
        off: 'Định vị đang tắt',
        settings: 'Mở Cài đặt',
      ),
      AppLanguage.en: (
        locale: Locale('en'),
        view: 'View',
        waiting: 'Waiting for GPS signal…',
        denied: 'Location permission not granted',
        off: 'Location services are off',
        settings: 'Open Settings',
      ),
    };

    for (final size in sizes) {
      for (final MapEntry(key: language, value: t) in texts.entries) {
        final label = '$size ${language.name}';

        testWidgets('$label: chờ GPS', (tester) async {
          await _pumpApp(tester, deviceLocale: t.locale, size: size);

          expect(find.text(t.waiting), findsOneWidget);
          expect(find.text(t.settings), findsNothing);
          expect(_onPressed(tester, t.view), isNull);
          expect(tester.takeException(), isNull);
        });

        testWidgets('$label: chưa cấp quyền', (tester) async {
          final service = await _pumpApp(
            tester,
            deviceLocale: t.locale,
            size: size,
          );
          await _emit(tester, service, const LocationPermissionDenied());

          expect(find.text(t.denied), findsOneWidget);
          expect(_onPressed(tester, t.view), isNull);
          await tester.tap(find.text(t.settings));
          expect(service.openAppSettingsCount, 1);
          expect(service.openLocationSettingsCount, 0);
          expect(tester.takeException(), isNull);
        });

        testWidgets('$label: định vị tắt', (tester) async {
          final service = await _pumpApp(
            tester,
            deviceLocale: t.locale,
            size: size,
          );
          await _emit(tester, service, const LocationServiceDisabled());

          expect(find.text(t.off), findsOneWidget);
          expect(_onPressed(tester, t.view), isNull);
          await tester.tap(find.text(t.settings));
          expect(service.openLocationSettingsCount, 1);
          expect(service.openAppSettingsCount, 0);
          expect(tester.takeException(), isNull);
        });

        testWidgets('$label: có tọa độ', (tester) async {
          final service = await _pumpApp(
            tester,
            deviceLocale: t.locale,
            size: size,
          );
          await _emit(tester, service, _hanoi);

          expect(find.text(_hanoiText), findsOneWidget);
          expect(find.text(t.waiting), findsNothing);
          expect(_onPressed(tester, t.view), isNotNull);
          expect(tester.takeException(), isNull);
        });

        testWidgets('$label: chuỗi dài nhất vẫn nằm gọn một dòng', (
          tester,
        ) async {
          final service = await _pumpApp(
            tester,
            deviceLocale: t.locale,
            size: size,
          );
          await _emit(tester, service, _longest);

          final text = find.text(_longestText);
          expect(tester.getBottomLeft(text).dx, greaterThanOrEqualTo(0));
          expect(tester.getBottomRight(text).dx, lessThanOrEqualTo(size.width));
          expect(tester.getSize(text).height, lessThan(70));
          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('tọa độ cập nhật liên tục', (tester) async {
      final service = await _pumpApp(tester);

      await _emit(tester, service, _hanoi);
      await _emit(tester, service, _empty);

      expect(find.text(_hanoiText), findsNothing);
      expect(find.text(_emptyText), findsOneWidget);
    });

    testWidgets('mất tọa độ thì khóa lại nút Xem', (tester) async {
      final service = await _pumpApp(tester);

      await _emit(tester, service, _hanoi);
      await _emit(tester, service, const LocationWaiting());

      expect(find.text(_hanoiText), findsNothing);
      expect(_onPressed(tester, 'Xem'), isNull);
    });

    testWidgets('không có nút ngoài phạm vi', (tester) async {
      final service = await _pumpApp(tester);
      await _emit(tester, service, _hanoi);

      expect(find.byType(CupertinoButton), findsNWidgets(3));
    });
  });

  group('trang kết quả', () {
    testWidgets('bấm Xem mở trang kết quả với tọa độ lúc bấm', (tester) async {
      final service = await _pumpApp(tester);
      await _emit(tester, service, _hanoi);

      await tester.tap(_button('Xem'));
      await tester.pumpAndSettle();

      expect(find.byType(ResultScreen), findsOneWidget);
      expect(find.text(_hanoiText), findsOneWidget);
      expect(find.text('Quay lại'), findsOneWidget);
      expect(find.text('Chăm Chỉ'), findsOneWidget);
    });

    testWidgets('GPS đổi thì trang kết quả giữ nguyên, bấm lại ra mới', (
      tester,
    ) async {
      final service = await _pumpApp(tester);
      await _emit(tester, service, _hanoi);
      await tester.tap(_button('Xem'));
      await tester.pumpAndSettle();

      await _emit(tester, service, _empty);
      await tester.pumpAndSettle();

      expect(find.text(_hanoiText), findsOneWidget);
      expect(find.text('Chăm Chỉ'), findsOneWidget);
      expect(find.text(_emptyText), findsNothing);

      await _goBack(tester);
      expect(find.text(_emptyText), findsOneWidget);

      await tester.tap(_button('Xem'));
      await tester.pumpAndSettle();

      expect(find.text(_emptyText), findsOneWidget);
      expect(
        find.text('Tọa độ này không có số nào trong bảng'),
        findsOneWidget,
      );
      expect(find.text('Kết luận'), findsNothing);
    });

    testWidgets('đổi ngôn ngữ áp dụng ngay cho cả hai màn hình', (
      tester,
    ) async {
      final service = await _pumpApp(tester);
      await _emit(tester, service, _hanoi);
      await tester.tap(_button('Xem'));
      await tester.pumpAndSettle();
      expect(find.text('Chăm Chỉ'), findsOneWidget);

      final context = tester.element(find.byType(ResultScreen));
      LanguageScope.of(context).onChanged(AppLanguage.en);
      await tester.pump();

      expect(find.text(lookupPair('14').single.palaceEn), findsOneWidget);
      expect(find.text('Chăm Chỉ'), findsNothing);
      expect(find.text(_hanoiText), findsOneWidget);

      await _goBack(tester);
      expect(_button('View'), findsOneWidget);
      expect(find.text(_hanoiText), findsOneWidget);
    });
  });

  group('ngôn ngữ', () {
    testWidgets('lần đầu theo ngôn ngữ máy và chưa ghi gì', (tester) async {
      final store = _FakeLanguageStore();
      await _pumpApp(tester, store: store, deviceLocale: const Locale('ja'));

      expect(_button('View'), findsOneWidget);
      expect(store.saved, isNull);
    });

    testWidgets('lựa chọn đã lưu thắng ngôn ngữ máy', (tester) async {
      await _pumpApp(tester, store: _FakeLanguageStore(AppLanguage.en));

      expect(_button('View'), findsOneWidget);
    });

    testWidgets('bấm nút đổi ngôn ngữ và ghi vào store', (tester) async {
      final store = _FakeLanguageStore();
      await _pumpApp(tester, store: store);
      expect(_button('Xem'), findsOneWidget);

      await tester.tap(find.text('English'));
      await tester.pump();

      expect(_button('View'), findsOneWidget);
      expect(find.text('Waiting for GPS signal…'), findsOneWidget);
      expect(store.saved, AppLanguage.en);

      await tester.tap(find.text('Tiếng Việt'));
      await tester.pump();

      expect(_button('Xem'), findsOneWidget);
      expect(store.saved, AppLanguage.vi);
    });

    testWidgets('store lỗi thì app vẫn chạy', (tester) async {
      final store = _FakeLanguageStore()..failing = true;
      await _pumpApp(tester, store: store);
      expect(_button('Xem'), findsOneWidget);

      await tester.tap(find.text('English'));
      await tester.pump();

      expect(_button('View'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('vòng đời', () {
    testWidgets('mở app thì bắt đầu đo', (tester) async {
      final service = await _pumpApp(tester);

      expect(service.refreshCount, 1);
    });

    testWidgets('rời app thì ngừng đo, quay lại thì kiểm tra lại', (
      tester,
    ) async {
      final service = await _pumpApp(tester);
      final binding = tester.binding;

      binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      expect(service.pauseCount, 0);
      binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      expect(service.pauseCount, greaterThan(0));
      expect(service.refreshCount, 1);

      binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      expect(service.refreshCount, 2);
    });

    testWidgets('gỡ app thì dispose service', (tester) async {
      final service = await _pumpApp(tester);

      await tester.pumpWidget(const SizedBox());

      expect(service.disposeCount, 1);
    });
  });

  group('GeolocatorLocationService', () {
    late _FakeGeolocator platform;
    late GeolocatorLocationService service;
    late List<LocationState> states;

    setUp(() {
      platform = _FakeGeolocator();
      GeolocatorPlatform.instance = platform;
      service = GeolocatorLocationService();
      states = [];
      service.states.listen(states.add);
    });

    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
    });

    test('Android ép dùng LocationManager với độ chính xác cao', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      await service.refresh();
      debugDefaultTargetPlatformOverride = null;

      final settings = platform.settings;
      expect(settings, isA<AndroidSettings>());
      expect((settings! as AndroidSettings).forceLocationManager, isTrue);
      expect(settings.accuracy, LocationAccuracy.high);
    });

    test('iOS không đo nền', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      await service.refresh();
      debugDefaultTargetPlatformOverride = null;

      final settings = platform.settings;
      expect(settings, isA<AppleSettings>());
      expect(
        (settings! as AppleSettings).allowBackgroundLocationUpdates,
        isFalse,
      );
      expect(settings.accuracy, LocationAccuracy.high);
    });

    test('có quyền thì đổi vị trí thành tọa độ', () async {
      await service.refresh();
      platform.positions!.add(_position(21.0286, 105.8033));
      await _settleEvents();

      expect(states.first, isA<LocationWaiting>());
      final last = states.last as LocationAvailable;
      expect(last.latitude, 21.0286);
      expect(last.longitude, 105.8033);
    });

    test('định vị tắt thì không xin quyền và không đo', () async {
      platform.serviceEnabled = false;
      platform.permission = LocationPermission.denied;

      await service.refresh();
      await _settleEvents();

      expect(states.last, isA<LocationServiceDisabled>());
      expect(platform.requestCount, 0);
      expect(platform.positionListeners, 0);
    });

    test('bị từ chối thì báo trạng thái và chỉ hỏi một lần', () async {
      platform.permission = LocationPermission.denied;
      platform.requestResult = LocationPermission.denied;

      await service.refresh();
      await service.refresh();
      await _settleEvents();

      expect(states.last, isA<LocationPermissionDenied>());
      expect(platform.requestCount, 1);
      expect(platform.positionListeners, 0);
    });

    test('từ chối vĩnh viễn thì không hỏi', () async {
      platform.permission = LocationPermission.deniedForever;

      await service.refresh();
      await _settleEvents();

      expect(states.last, isA<LocationPermissionDenied>());
      expect(platform.requestCount, 0);
    });

    test(
      'app quay lại khi hộp thoại quyền chưa xong thì không chồng',
      () async {
        platform.permission = LocationPermission.denied;
        final gate = platform.requestGate = Completer<void>();

        final first = service.refresh();
        final second = service.refresh();
        await _settleEvents();
        expect(platform.requestCount, 1);

        gate.complete();
        await Future.wait([first, second]);

        expect(platform.requestCount, 1);
        expect(platform.positionStreamsCreated, 1);
      },
    );

    test('cấp quyền trong Cài đặt rồi quay lại thì bắt đầu đo', () async {
      platform.permission = LocationPermission.denied;
      platform.requestResult = LocationPermission.denied;
      await service.refresh();

      platform.permission = LocationPermission.whileInUse;
      await service.refresh();
      await _settleEvents();

      expect(states.last, isA<LocationWaiting>());
      expect(platform.positionListeners, 1);
    });

    test('bật định vị từ thanh thông báo thì tự đo lại', () async {
      platform.serviceEnabled = false;
      await service.refresh();

      platform.serviceEnabled = true;
      platform.serviceStatus.add(ServiceStatus.enabled);
      await _settleEvents();
      await _settleEvents();

      expect(states.last, isA<LocationWaiting>());
      expect(platform.positionListeners, 1);
    });

    test('tắt định vị khi đang đo thì đổi thành trạng thái', () async {
      await service.refresh();

      platform.positions!.addError(const LocationServiceDisabledException());
      await _settleEvents();

      expect(states.last, isA<LocationServiceDisabled>());
      expect(platform.positionListeners, 0);
    });

    test('mất quyền khi đang đo thì đổi thành trạng thái', () async {
      await service.refresh();

      platform.positions!.addError(const PermissionDeniedException('x'));
      await _settleEvents();

      expect(states.last, isA<LocationPermissionDenied>());
      expect(platform.positionListeners, 0);
    });

    test('lỗi khác của stream thì về chờ và đo tiếp', () async {
      await service.refresh();
      platform.positions!.add(_position(1, 2));

      platform.positions!.addError(const PositionUpdateException('x'));
      await _settleEvents();
      expect(states.last, isA<LocationWaiting>());

      platform.positions!.add(_position(3, 4));
      await _settleEvents();
      expect(states.last, isA<LocationAvailable>());
    });

    test('nền tảng lỗi thì không sập', () async {
      platform.failing = true;

      await service.refresh();
      await _settleEvents();

      expect(states.last, isA<LocationWaiting>());
    });

    test('pause ngừng đo, refresh đo lại', () async {
      await service.refresh();
      expect(platform.positionListeners, 1);

      await service.pause();
      expect(platform.positionListeners, 0);

      await service.refresh();
      expect(platform.positionListeners, 1);
    });

    test('refresh khi đang đo không mở thêm stream', () async {
      await service.refresh();
      await service.refresh();

      expect(platform.positionStreamsCreated, 1);
    });

    test('dispose huỷ subscription', () async {
      await service.refresh();

      await service.dispose();

      expect(platform.positionListeners, 0);
    });

    test('mở đúng trang Cài đặt', () async {
      await service.openAppSettings();
      await service.openLocationSettings();

      expect(platform.openAppCount, 1);
      expect(platform.openLocationCount, 1);
    });
  });
}
