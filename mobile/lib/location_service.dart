import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

sealed class LocationState {
  const LocationState();
}

/// Đã đủ điều kiện nhưng chưa nhận được tọa độ.
final class LocationWaiting extends LocationState {
  const LocationWaiting();
}

/// Chưa hỏi quyền trong phiên này: giải thích trước rồi mới xin quyền.
final class LocationPermissionNeeded extends LocationState {
  const LocationPermissionNeeded();
}

final class LocationPermissionDenied extends LocationState {
  const LocationPermissionDenied();
}

final class LocationServiceDisabled extends LocationState {
  const LocationServiceDisabled();
}

final class LocationAvailable extends LocationState {
  const LocationAvailable(this.latitude, this.longitude);

  final double latitude;
  final double longitude;
}

abstract class LocationService {
  Stream<LocationState> get states;

  /// Kiểm tra quyền và dịch vụ định vị rồi đo nếu đủ điều kiện. Gọi khi mở app
  /// và mỗi lần app quay lại, kể cả từ Cài đặt.
  Future<void> refresh();

  /// Ngừng đo khi app rời màn hình. [refresh] sẽ đo lại.
  Future<void> pause();

  /// Ngừng đo khi trang khác che màn hình chính nhưng giữ tọa độ đang có, để lúc
  /// quay về không phải chờ lại. [refresh] sẽ đo tiếp.
  Future<void> suspend();

  /// Bật hộp thoại xin quyền của hệ thống. Chỉ gọi khi người dùng đã đồng ý ở
  /// màn hình giải thích.
  Future<void> requestPermission();

  Future<void> openAppSettings();
  Future<void> openLocationSettings();
  Future<void> dispose();
}

/// Đo bằng GPS của máy qua `geolocator`, không gọi mạng.
class GeolocatorLocationService implements LocationService {
  GeolocatorLocationService({
    this.signalTimeout = const Duration(seconds: 60),
    this.retryDelay = const Duration(seconds: 5),
  });

  /// Lâu hơn mức này không có số mới thì coi như mất tín hiệu, để không hiện số
  /// cũ như thể vừa đo.
  final Duration signalTimeout;

  /// Luồng vị trí lỗi hoặc đóng mà sau chừng này chưa có số mới thì mở lại.
  final Duration retryDelay;

  final _controller = StreamController<LocationState>.broadcast();
  StreamSubscription<Position>? _position;
  StreamSubscription<ServiceStatus>? _serviceStatus;
  Timer? _signalTimer;
  Timer? _retryTimer;
  LocationState _state = const LocationWaiting();
  bool _permissionRequested = false;
  bool _disposed = false;

  // Hộp thoại xin quyền làm app đổi trạng thái vòng đời, nên [refresh] có thể
  // được gọi khi lần trước chưa xong. Xếp hàng để không chạy chồng lên nhau.
  Future<void> _queue = Future.value();

  @override
  Stream<LocationState> get states => _controller.stream;

  @override
  Future<void> refresh() => _enqueue(_refreshNow);

  @override
  Future<void> pause() => _stop(keepLast: false);

  @override
  Future<void> suspend() => _stop(keepLast: true);

  Future<void> _stop({required bool keepLast}) {
    _retryTimer?.cancel();
    return _enqueue(() async {
      await _stopPosition();
      await _serviceStatus?.cancel();
      _serviceStatus = null;
      // Khi quay lại app, người dùng có thể đã đi nơi khác nên phải chờ số mới.
      if (!keepLast && _state is LocationAvailable) {
        _emit(const LocationWaiting());
      }
    });
  }

  @override
  Future<void> requestPermission() => _enqueue(() async {
    // Bấm đúp nút Cho phép cũng chỉ hỏi một lần.
    if (!_permissionRequested) {
      _permissionRequested = true;
      await Geolocator.requestPermission();
    }
    if (!_disposed) await _refreshNow();
  });

  @override
  Future<void> openAppSettings() async {
    try {
      await Geolocator.openAppSettings();
    } catch (_) {
      // Không mở được thì người dùng vẫn ở lại màn hình hiện tại.
    }
  }

  @override
  Future<void> openLocationSettings() async {
    try {
      await Geolocator.openLocationSettings();
    } catch (_) {
      // Không mở được thì người dùng vẫn ở lại màn hình hiện tại.
    }
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    _signalTimer?.cancel();
    _retryTimer?.cancel();
    await _position?.cancel();
    await _serviceStatus?.cancel();
    await _controller.close();
  }

  Future<void> _enqueue(Future<void> Function() step) {
    return _queue = _queue.then((_) async {
      if (_disposed) return;
      try {
        await step();
      } catch (_) {
        if (!_disposed) _emit(const LocationWaiting());
      }
    });
  }

  Future<void> _refreshNow() async {
    // Theo dõi cả lúc bật tắt định vị từ thanh thông báo, khi app không rời
    // màn hình nên không có sự kiện quay lại.
    _serviceStatus ??= Geolocator.getServiceStatusStream().listen(
      (_) => unawaited(refresh()),
      onError: (Object _) {},
    );

    if (!await Geolocator.isLocationServiceEnabled()) {
      await _stopPosition();
      _emit(const LocationServiceDisabled());
      return;
    }

    final permission = await Geolocator.checkPermission();
    if (_disposed) return;

    // Chỉ hỏi một lần, nếu không người dùng từ chối xong app quay lại sẽ bị hỏi
    // tiếp ngay.
    if (permission == LocationPermission.denied && !_permissionRequested) {
      await _stopPosition();
      _emit(const LocationPermissionNeeded());
      return;
    }

    if (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      await _stopPosition();
      _emit(const LocationPermissionDenied());
      return;
    }

    if (_position != null) return;
    // Số giữ lại từ [suspend] vẫn hết hạn nếu không có số mới.
    if (_state is LocationAvailable) {
      _restartSignalTimer();
    } else {
      _emit(const LocationWaiting());
    }
    _position = Geolocator.getPositionStream(
      locationSettings: _locationSettings(),
    ).listen(_onPosition, onError: _onPositionError, onDone: _onPositionDone);
  }

  void _onPosition(Position position) {
    _retryTimer?.cancel();
    _emit(LocationAvailable(position.latitude, position.longitude));
    _restartSignalTimer();
  }

  void _restartSignalTimer() {
    _signalTimer?.cancel();
    _signalTimer = Timer(signalTimeout, () => _emit(const LocationWaiting()));
  }

  void _onPositionError(Object error) {
    final state = switch (error) {
      LocationServiceDisabledException() => const LocationServiceDisabled(),
      PermissionDeniedException() => const LocationPermissionDenied(),
      _ => const LocationWaiting(),
    };
    _emit(state);
    if (state is LocationWaiting) {
      _scheduleRetry();
    } else {
      unawaited(_enqueue(_stopPosition));
    }
  }

  void _onPositionDone() {
    _position = null;
    _signalTimer?.cancel();
    _emit(const LocationWaiting());
    _scheduleRetry();
  }

  /// Lỗi đến liên tục cũng không đẩy lùi lần mở lại đã hẹn.
  void _scheduleRetry() {
    if (_retryTimer?.isActive ?? false) return;
    _retryTimer = Timer(retryDelay, () {
      unawaited(
        _enqueue(() async {
          await _stopPosition();
          await _refreshNow();
        }),
      );
    });
  }

  Future<void> _stopPosition() async {
    _signalTimer?.cancel();
    await _position?.cancel();
    _position = null;
  }

  void _emit(LocationState state) {
    _state = state;
    if (!_disposed) _controller.add(state);
  }

  LocationSettings _locationSettings() {
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        forceLocationManager: true,
        intervalDuration: const Duration(seconds: 1),
      ),
      TargetPlatform.iOS => AppleSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        pauseLocationUpdatesAutomatically: false,
        allowBackgroundLocationUpdates: false,
      ),
      _ => const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
      ),
    };
  }
}
