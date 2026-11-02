// Kiểm thử hộp trắng (nhị phân) cho lib/location_service.dart — Bước 6.
// Mã bộ 6-1 … 6-50 khớp test-output/whitebox/dinh-vi-gps/location_service/buoc-5-du-lieu-thu.md.
// Mock _Fake chép từ location_screen_test.dart (_FakeGeolocator), thêm cổng chờ để chen dispose vào giữa chừng.
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:toado/location_service.dart';

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

class _Fake extends GeolocatorPlatform {
  bool serviceEnabled = true;
  LocationPermission permission = LocationPermission.whileInUse;
  LocationPermission requestResult = LocationPermission.whileInUse;
  Completer<void>? requestGate;
  Completer<void>? checkGate;
  Completer<void>? cancelGate;
  bool failing = false;
  bool openAppThrows = false;
  bool openLocationThrows = false;

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
  Future<LocationPermission> checkPermission() async {
    await checkGate?.future;
    return permission;
  }

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
      onCancel: () {
        positionListeners--;
        final gate = cancelGate;
        if (gate != null) return gate.future;
        return null;
      },
    );
    positions = controller;
    return controller.stream;
  }

  @override
  Future<bool> openAppSettings() async {
    openAppCount++;
    if (openAppThrows) throw StateError('open app');
    return true;
  }

  @override
  Future<bool> openLocationSettings() async {
    openLocationCount++;
    if (openLocationThrows) throw StateError('open location');
    return true;
  }
}

Future<void> _settle() => Future<void>.delayed(Duration.zero);
Future<void> _wait(int ms) => Future<void>.delayed(Duration(milliseconds: ms));

void main() {
  late _Fake platform;
  late List<GeolocatorLocationService> created;

  GeolocatorLocationService make({int signalMs = 60000, int retryMs = 5000}) {
    final service = GeolocatorLocationService(
      signalTimeout: Duration(milliseconds: signalMs),
      retryDelay: Duration(milliseconds: retryMs),
    );
    created.add(service);
    return service;
  }

  List<LocationState> listen(GeolocatorLocationService service) {
    final states = <LocationState>[];
    service.states.listen(states.add);
    return states;
  }

  setUp(() {
    platform = _Fake();
    GeolocatorPlatform.instance = platform;
    created = [];
  });

  tearDown(() async {
    debugDefaultTargetPlatformOverride = null;
    for (final gate in [
      platform.requestGate,
      platform.checkGate,
      platform.cancelGate,
    ]) {
      if (gate != null && !gate.isCompleted) gate.complete();
    }
    for (final service in created) {
      await service.dispose();
    }
  });

  group('pause()', () {
    test('6-1 pause: chưa có hẹn mở lại ⇒ xong, không mở luồng', () async {
      final service = make(retryMs: 20);
      final states = listen(service);

      await service.pause();
      await _wait(60);

      expect(platform.positionStreamsCreated, 0);
      expect(states, isEmpty);
    });

    test('6-2 pause: có hẹn mở lại ⇒ hủy hẹn, không tự mở lại', () async {
      final service = make(retryMs: 20);
      await service.refresh();
      platform.positions!.addError(const PositionUpdateException('x'));

      await service.pause();
      await _wait(60);

      expect(platform.positionStreamsCreated, 1);
      expect(platform.positionListeners, 0);
    });

    test('6-3 pause (closure): đã đo, state Waiting ⇒ không phát thêm', () async {
      final service = make();
      final states = listen(service);
      await service.refresh();
      await _settle();
      final before = states.length;

      await service.pause();
      await _settle();

      expect(platform.positionListeners, 0);
      expect(platform.serviceStatus.hasListener, isFalse);
      expect(states.length, before);
      expect(states.last, isA<LocationWaiting>());
    });

    test('6-4 pause (closure): chưa refresh ⇒ không có gì để hủy', () async {
      final service = make();
      final states = listen(service);

      await service.pause();
      await _settle();

      expect(platform.serviceListeners, 0);
      expect(platform.positionStreamsCreated, 0);
      expect(states, isEmpty);
    });

    test('6-5 pause (closure): đang có số ⇒ phát Waiting', () async {
      final service = make();
      final states = listen(service);
      await service.refresh();
      platform.positions!.add(_position(1, 2));
      await _settle();
      expect(states.last, isA<LocationAvailable>());

      await service.pause();
      await _settle();

      expect(platform.positionListeners, 0);
      expect(states.last, isA<LocationWaiting>());
      expect(states.whereType<LocationAvailable>(), hasLength(1));
    });
  });

  group('requestPermission()', () {
    test('6-6 lần đầu ⇒ hỏi quyền rồi đo lại', () async {
      platform.permission = LocationPermission.denied;
      final service = make();
      final states = listen(service);

      await service.requestPermission();
      await _settle();

      expect(platform.requestCount, 1);
      expect(platform.positionListeners, 1);
      expect(states.last, isA<LocationWaiting>());
    });

    test('6-7 lần hai ⇒ không hỏi lại, vẫn đo lại', () async {
      platform.permission = LocationPermission.denied;
      platform.requestResult = LocationPermission.denied;
      final service = make();
      final states = listen(service);

      await service.requestPermission();
      await service.requestPermission();
      await _settle();

      expect(platform.requestCount, 1);
      expect(states.last, isA<LocationPermissionDenied>());
    });

    test('6-8 dispose khi hộp thoại chưa xong ⇒ không đo lại', () async {
      platform.permission = LocationPermission.denied;
      final gate = platform.requestGate = Completer<void>();
      final service = make();

      final first = service.requestPermission();
      await _settle();
      expect(platform.requestCount, 1);
      final disposing = service.dispose();
      gate.complete();
      await first;
      await disposing;

      expect(platform.requestCount, 1);
      expect(platform.serviceListeners, 0);
      expect(platform.positionStreamsCreated, 0);
    });
  });

  group('openAppSettings() / openLocationSettings()', () {
    test('6-9 mở Cài đặt app được ⇒ gọi nền tảng một lần', () async {
      final service = make();

      await service.openAppSettings();

      expect(platform.openAppCount, 1);
    });

    test('6-10 mở Cài đặt app ném lỗi ⇒ nuốt lỗi, không văng', () async {
      platform.openAppThrows = true;
      final service = make();

      await expectLater(service.openAppSettings(), completes);

      expect(platform.openAppCount, 1);
    });

    test('6-11 mở Cài đặt vị trí được ⇒ gọi nền tảng một lần', () async {
      final service = make();

      await service.openLocationSettings();

      expect(platform.openLocationCount, 1);
    });

    test('6-12 mở Cài đặt vị trí ném lỗi ⇒ nuốt lỗi, không văng', () async {
      platform.openLocationThrows = true;
      final service = make();

      await expectLater(service.openLocationSettings(), completes);

      expect(platform.openLocationCount, 1);
    });
  });

  group('dispose()', () {
    Future<bool> disposeAndCheckClosed(
      GeolocatorLocationService service,
    ) async {
      var done = false;
      service.states.listen((_) {}, onDone: () => done = true);
      await service.dispose();
      await _settle();
      return done;
    }

    test('6-13 dispose: mọi thứ còn null ⇒ đóng luồng, không văng', () async {
      final service = make();

      expect(await disposeAndCheckClosed(service), isTrue);
      expect(platform.serviceListeners, 0);
    });

    test('6-14 dispose: chỉ _signalTimer khác null', () async {
      final service = make();
      await service.refresh();
      platform.positions!.add(_position(1, 2));
      await _settle();
      await service.pause();

      expect(await disposeAndCheckClosed(service), isTrue);
      expect(platform.positionListeners, 0);
      expect(platform.serviceStatus.hasListener, isFalse);
    });

    test('6-15 dispose: chỉ _retryTimer khác null', () async {
      final service = make(retryMs: 50);
      await service.refresh();
      platform.positions!.addError(const PositionUpdateException('x'));
      await service.pause();

      expect(await disposeAndCheckClosed(service), isTrue);
      await _wait(100);
      expect(platform.positionStreamsCreated, 1);
    });

    test('6-16 dispose: chỉ _serviceStatus khác null', () async {
      platform.serviceEnabled = false;
      final service = make();
      await service.refresh();
      expect(platform.serviceStatus.hasListener, isTrue);

      expect(await disposeAndCheckClosed(service), isTrue);
      expect(platform.serviceStatus.hasListener, isFalse);
    });

    test('6-17 dispose: _serviceStatus và _position khác null', () async {
      final service = make();
      await service.refresh();
      expect(platform.positionListeners, 1);

      expect(await disposeAndCheckClosed(service), isTrue);
      expect(platform.positionListeners, 0);
      expect(platform.serviceStatus.hasListener, isFalse);
    });
  });

  group('_enqueue', () {
    test('6-18 đã dispose ⇒ bước không chạy', () async {
      final service = make();
      await service.dispose();

      await service.refresh();

      expect(platform.serviceListeners, 0);
      expect(platform.positionStreamsCreated, 0);
    });

    test('6-19 bước chạy xong không lỗi ⇒ không phát Waiting thêm', () async {
      final service = make();
      final states = listen(service);

      await service.refresh();
      await _settle();

      expect(platform.positionStreamsCreated, 1);
      expect(states, hasLength(1));
      expect(states.single, isA<LocationWaiting>());
    });

    test('6-20 bước ném lỗi, chưa dispose ⇒ phát Waiting', () async {
      platform.failing = true;
      final service = make();
      final states = listen(service);

      await service.refresh();
      await _settle();

      expect(states, hasLength(1));
      expect(states.single, isA<LocationWaiting>());
    });

    test('6-21 bước ném lỗi sau khi đã dispose ⇒ không phát gì', () async {
      platform.permission = LocationPermission.denied;
      final gate = platform.requestGate = Completer<void>();
      final service = make();
      final states = listen(service);

      final request = service.requestPermission();
      await _settle();
      final disposing = service.dispose();
      final before = states.length;
      gate.completeError(StateError('x'));
      await request;
      await disposing;

      expect(states.length, before);
    });
  });

  group('_refreshNow', () {
    test('6-22 lần đầu, có quyền ⇒ nghe trạng thái dịch vụ và mở luồng', () async {
      final service = make();
      final states = listen(service);

      await service.refresh();
      await _settle();

      expect(platform.serviceListeners, 1);
      expect(platform.positionStreamsCreated, 1);
      expect(states.last, isA<LocationWaiting>());
    });

    test('6-23 đã nghe trạng thái dịch vụ ⇒ không nghe thêm', () async {
      platform.serviceEnabled = false;
      final service = make();
      final states = listen(service);
      await service.refresh();
      await _settle();
      expect(states.last, isA<LocationServiceDisabled>());
      expect(platform.serviceListeners, 1);

      platform.serviceEnabled = true;
      await service.refresh();
      await _settle();

      expect(platform.serviceListeners, 1);
      expect(platform.positionStreamsCreated, 1);
      expect(states.last, isA<LocationWaiting>());
    });

    test('6-24 định vị tắt ⇒ ServiceDisabled, không xin quyền, không đo', () async {
      platform.serviceEnabled = false;
      platform.permission = LocationPermission.denied;
      final service = make();
      final states = listen(service);

      await service.refresh();
      await _settle();

      expect(states.last, isA<LocationServiceDisabled>());
      expect(platform.requestCount, 0);
      expect(platform.positionListeners, 0);
    });

    test('6-25 dispose khi đang kiểm tra quyền ⇒ dừng, không mở luồng', () async {
      final gate = platform.checkGate = Completer<void>();
      final service = make();

      final refreshing = service.refresh();
      await _settle();
      expect(platform.serviceListeners, 1);
      final disposing = service.dispose();
      gate.complete();
      await refreshing;
      await disposing;

      expect(platform.positionStreamsCreated, 0);
      expect(platform.requestCount, 0);
    });

    test('6-26 denied, chưa từng hỏi ⇒ PermissionNeeded, không hỏi, không đo', () async {
      platform.permission = LocationPermission.denied;
      final service = make();
      final states = listen(service);

      await service.refresh();
      await _settle();

      expect(states.last, isA<LocationPermissionNeeded>());
      expect(platform.requestCount, 0);
      expect(platform.positionListeners, 0);
    });

    test('6-27 denied, đã hỏi rồi ⇒ PermissionDenied, không hỏi lại', () async {
      platform.permission = LocationPermission.denied;
      platform.requestResult = LocationPermission.denied;
      final service = make();
      final states = listen(service);

      await service.requestPermission();
      await service.refresh();
      await _settle();

      expect(states.last, isA<LocationPermissionDenied>());
      expect(platform.requestCount, 1);
      expect(platform.positionListeners, 0);
    });

    test('6-28 quyền always ⇒ được đo', () async {
      platform.permission = LocationPermission.always;
      final service = make();
      final states = listen(service);

      await service.refresh();
      await _settle();

      expect(platform.positionStreamsCreated, 1);
      expect(platform.positionListeners, 1);
      expect(states.last, isA<LocationWaiting>());
    });

    test('6-29 deniedForever ⇒ PermissionDenied, không hỏi, không đo', () async {
      platform.permission = LocationPermission.deniedForever;
      final service = make();
      final states = listen(service);

      await service.refresh();
      await _settle();

      expect(states.last, isA<LocationPermissionDenied>());
      expect(platform.requestCount, 0);
      expect(platform.positionListeners, 0);
    });

    test('6-30 đang đo mà refresh lại ⇒ không mở thêm luồng', () async {
      final service = make();

      await service.refresh();
      await service.refresh();

      expect(platform.positionStreamsCreated, 1);
      expect(platform.positionListeners, 1);
    });
  });

  group('_onPosition / _restartSignalTimer', () {
    test('6-31 có vị trí, chưa có hẹn mở lại ⇒ phát Available đúng số', () async {
      final service = make();
      final states = listen(service);
      await service.refresh();

      platform.positions!.add(_position(21.0286, 105.8033));
      await _settle();

      final last = states.last as LocationAvailable;
      expect(last.latitude, 21.0286);
      expect(last.longitude, 105.8033);
    });

    test('6-32 có vị trí khi đang chờ mở lại ⇒ hủy hẹn, không mở lại', () async {
      final service = make(retryMs: 40);
      final states = listen(service);
      await service.refresh();

      platform.positions!.addError(const PositionUpdateException('x'));
      platform.positions!.add(_position(3, 4));
      await _wait(100);

      expect(platform.positionStreamsCreated, 1);
      expect(states.last, isA<LocationAvailable>());
    });

    test('6-33 số đầu tiên ⇒ hẹn giờ mất tín hiệu, hết hạn thì về Waiting', () async {
      final service = make(signalMs: 40);
      final states = listen(service);
      await service.refresh();

      platform.positions!.add(_position(1, 2));
      await _settle();
      expect(states.last, isA<LocationAvailable>());
      await _wait(100);

      expect(states.last, isA<LocationWaiting>());
    });

    test('6-34 số thứ hai ⇒ hẹn giờ cũ bị hủy, tính lại từ số mới', () async {
      final service = make(signalMs: 100);
      final states = listen(service);
      await service.refresh();

      platform.positions!.add(_position(1, 2));
      await _wait(60);
      platform.positions!.add(_position(3, 4));
      await _wait(70);
      expect(states.last, isA<LocationAvailable>());
      await _wait(120);

      expect(states.last, isA<LocationWaiting>());
      expect(states.whereType<LocationAvailable>(), hasLength(2));
      expect(states.whereType<LocationWaiting>(), hasLength(2));
    });
  });

  group('_onPositionError', () {
    test('6-35 lỗi định vị tắt ⇒ ServiceDisabled, dừng đo, không mở lại', () async {
      final service = make(retryMs: 20);
      final states = listen(service);
      await service.refresh();

      platform.positions!.addError(const LocationServiceDisabledException());
      await _wait(60);

      expect(states.last, isA<LocationServiceDisabled>());
      expect(platform.positionListeners, 0);
      expect(platform.positionStreamsCreated, 1);
    });

    test('6-36 lỗi mất quyền ⇒ PermissionDenied, dừng đo, không mở lại', () async {
      final service = make(retryMs: 20);
      final states = listen(service);
      await service.refresh();

      platform.positions!.addError(const PermissionDeniedException('x'));
      await _wait(60);

      expect(states.last, isA<LocationPermissionDenied>());
      expect(platform.positionListeners, 0);
      expect(platform.positionStreamsCreated, 1);
    });

    test('6-37 lỗi khác ⇒ Waiting, hẹn mở lại luồng', () async {
      final service = make(retryMs: 20);
      final states = listen(service);
      await service.refresh();

      platform.positions!.addError(const PositionUpdateException('x'));
      await _settle();
      expect(states.last, isA<LocationWaiting>());
      await _wait(60);

      expect(platform.positionStreamsCreated, 2);
      expect(platform.positionListeners, 1);
    });
  });

  group('_onPositionDone', () {
    test('6-38 luồng đóng, chưa từng có số ⇒ Waiting rồi mở lại', () async {
      final service = make(retryMs: 20);
      final states = listen(service);
      await service.refresh();

      await platform.positions!.close();
      await _settle();
      expect(states.last, isA<LocationWaiting>());
      await _wait(60);

      expect(platform.positionStreamsCreated, 2);
      expect(platform.positionListeners, 1);
    });

    test('6-39 luồng đóng sau khi có số ⇒ hủy hẹn mất tín hiệu', () async {
      final service = make(signalMs: 40);
      final states = listen(service);
      await service.refresh();
      platform.positions!.add(_position(1, 2));
      await _settle();

      await platform.positions!.close();
      await _settle();
      final waitingAfterClose = states.whereType<LocationWaiting>().length;
      await _wait(100);

      expect(states.last, isA<LocationWaiting>());
      expect(states.whereType<LocationWaiting>(), hasLength(waitingAfterClose));
    });
  });

  group('_scheduleRetry', () {
    test('6-40 chưa có hẹn ⇒ tạo hẹn, hết hạn thì mở lại luồng', () async {
      final service = make(retryMs: 20);
      await service.refresh();

      platform.positions!.addError(const PositionUpdateException('x'));
      await _wait(60);

      expect(platform.positionStreamsCreated, 2);
      expect(platform.positionListeners, 1);
    });

    test('6-41 hẹn cũ đã chạy xong ⇒ lỗi mới hẹn lại được', () async {
      final service = make(retryMs: 20);
      await service.refresh();
      platform.positions!.addError(const PositionUpdateException('x'));
      await _wait(60);
      expect(platform.positionStreamsCreated, 2);

      platform.positions!.addError(const PositionUpdateException('y'));
      await _wait(60);

      expect(platform.positionStreamsCreated, 3);
      expect(platform.positionListeners, 1);
    });

    test('6-42 hẹn đang chạy ⇒ lỗi dồn dập không đẩy lùi giờ mở lại', () async {
      final service = make(retryMs: 50);
      await service.refresh();
      final dead = platform.positions!;

      for (var i = 0; i < 3; i++) {
        dead.addError(const PositionUpdateException('x'));
        await _wait(25);
      }

      expect(platform.positionStreamsCreated, 2);
    });
  });

  group('_stopPosition', () {
    test('6-43 chưa có hẹn giờ, chưa có luồng ⇒ dừng êm', () async {
      platform.serviceEnabled = false;
      final service = make();
      final states = listen(service);

      await service.refresh();
      await _settle();

      expect(states.last, isA<LocationServiceDisabled>());
      expect(platform.positionListeners, 0);
    });

    test('6-44 có luồng, chưa có hẹn giờ ⇒ hủy luồng', () async {
      final service = make();
      await service.refresh();
      expect(platform.positionListeners, 1);

      await service.pause();

      expect(platform.positionListeners, 0);
    });

    test('6-45 có hẹn giờ cũ, không còn luồng ⇒ dừng êm, không hiện Waiting thêm', () async {
      final service = make(signalMs: 40);
      final states = listen(service);
      await service.refresh();
      platform.positions!.add(_position(1, 2));
      await _settle();
      await service.pause();

      platform.serviceEnabled = false;
      await service.refresh();
      await _settle();
      final waiting = states.whereType<LocationWaiting>().length;
      await _wait(100);

      expect(states.last, isA<LocationServiceDisabled>());
      expect(states.whereType<LocationWaiting>(), hasLength(waiting));
    });
  });

  group('_emit', () {
    test('6-46 chưa dispose ⇒ trạng thái tới người nghe', () async {
      final service = make();
      final states = listen(service);
      await service.refresh();

      platform.positions!.add(_position(1, 2));
      await _settle();

      expect(states.last, isA<LocationAvailable>());
    });

    test('6-47 đã dispose ⇒ không phát trạng thái nữa', () async {
      final service = make();
      final states = listen(service);
      await service.refresh();
      final gate = platform.cancelGate = Completer<void>();
      platform.serviceEnabled = false;

      final refreshing = service.refresh();
      await _settle();
      final disposing = service.dispose();
      gate.complete();
      await refreshing;
      await disposing;

      expect(states.whereType<LocationServiceDisabled>(), isEmpty);
    });
  });

  group('_locationSettings', () {
    test('6-48 Android ⇒ LocationManager, độ chính xác cao, 1 giây', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final service = make();

      await service.refresh();

      final settings = platform.settings;
      expect(settings, isA<AndroidSettings>());
      final android = settings! as AndroidSettings;
      expect(android.forceLocationManager, isTrue);
      expect(android.accuracy, LocationAccuracy.high);
      expect(android.distanceFilter, 0);
      expect(android.intervalDuration, const Duration(seconds: 1));
    });

    test('6-49 iOS ⇒ không đo nền, không tự tạm dừng', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final service = make();

      await service.refresh();

      final settings = platform.settings;
      expect(settings, isA<AppleSettings>());
      final apple = settings! as AppleSettings;
      expect(apple.allowBackgroundLocationUpdates, isFalse);
      expect(apple.pauseLocationUpdatesAutomatically, isFalse);
      expect(apple.accuracy, LocationAccuracy.high);
      expect(apple.distanceFilter, 0);
    });

    test('6-50 nền tảng khác ⇒ LocationSettings chung, độ chính xác cao', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      final service = make();

      await service.refresh();

      final settings = platform.settings;
      expect(settings, isNotNull);
      expect(settings.runtimeType, LocationSettings);
      expect(settings!.accuracy, LocationAccuracy.high);
      expect(settings.distanceFilter, 0);
    });
  });
}
