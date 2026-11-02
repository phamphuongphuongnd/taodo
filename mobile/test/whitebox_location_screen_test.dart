// Kiểm thử hộp trắng (nhị phân) cho lib/location_screen.dart.
// Thiết kế: test-output/whitebox/man-hinh-vi-tri/location_screen/buoc-5-du-lieu-thu.md
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toado/about_screen.dart';
import 'package:toado/location_service.dart';
import 'package:toado/main.dart';
import 'package:toado/manual_entry_screen.dart';
import 'package:toado/result_screen.dart';
import 'package:toado/strings.dart';
import 'package:toado/widgets.dart' show CoordsDisplay;

import 'test_support.dart' show FakeLanguageStore, tapButton;

const _hanoi = LocationAvailable(21.02862, 105.80334);
const _hanoiText = '21°01\'43"N 105°48\'12"E';

class _CountingService implements LocationService {
  final controller = StreamController<LocationState>.broadcast(sync: true);
  int refreshCount = 0;
  int pauseCount = 0;
  int suspendCount = 0;
  int requestPermissionCount = 0;
  int openAppSettingsCount = 0;
  int openLocationSettingsCount = 0;

  void emit(LocationState state) => controller.add(state);

  @override
  Stream<LocationState> get states => controller.stream;

  @override
  Future<void> refresh() async => refreshCount++;

  @override
  Future<void> pause() async => pauseCount++;

  @override
  Future<void> suspend() async => suspendCount++;

  @override
  Future<void> requestPermission() async => requestPermissionCount++;

  @override
  Future<void> openAppSettings() async => openAppSettingsCount++;

  @override
  Future<void> openLocationSettings() async => openLocationSettingsCount++;

  @override
  Future<void> dispose() async {}
}

/// Luồng bỏ qua `cancel`: gọi được listener sau khi màn hình đã gỡ.
class _LeakyService extends _CountingService {
  void Function(LocationState)? leakedListener;

  @override
  Stream<LocationState> get states => _LeakyStream(this);
}

class _LeakyStream extends Stream<LocationState> {
  _LeakyStream(this.owner);

  final _LeakyService owner;

  @override
  StreamSubscription<LocationState> listen(
    void Function(LocationState event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    owner.leakedListener = onData;
    return const Stream<LocationState>.empty().listen(null);
  }
}

class _CountingCanvas implements Canvas {
  final List<double> radii = [];

  @override
  void drawCircle(Offset c, double radius, Paint paint) => radii.add(radius);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Future<T> _pump<T extends _CountingService>(
  WidgetTester tester,
  T service, {
  AppLanguage language = AppLanguage.vi,
  bool reduceMotion = true,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      FakeAccessibilityFeatures(disableAnimations: reduceMotion);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  await tester.pumpWidget(
    ToaDoApp(
      locationService: service,
      languageStore: FakeLanguageStore(language),
    ),
  );
  await tester.pump();
  return service;
}

Future<void> _emit(
  WidgetTester tester,
  _CountingService service,
  LocationState state,
) async {
  service.emit(state);
  await tester.pump();
}

Finder _ringsPainter() => find.byWidgetPredicate(
  (w) => w is CustomPaint && w.painter.runtimeType.toString() == '_RingsPainter',
);

CustomPainter _painter(WidgetTester tester) =>
    tester.widget<CustomPaint>(_ringsPainter()).painter!;

double? _wave(WidgetTester tester) {
  final paint = tester.widget<CustomPaint>(_ringsPainter());
  return (paint.painter as dynamic).wave as double?;
}

VoidCallback? _onPressed(WidgetTester tester, String label) => tester
    .widget<CupertinoButton>(find.widgetWithText(CupertinoButton, label))
    .onPressed;

double? _fontSize(WidgetTester tester, String text) =>
    tester.widget<Text>(find.text(text)).style?.fontSize;

List<Opacity> _dots(WidgetTester tester) {
  final dots = find.descendant(
    of: find.byType(ExcludeSemantics),
    matching: find.byType(Opacity),
  );
  return tester.widgetList<Opacity>(dots).toList();
}

double _leftOf(WidgetTester tester, Opacity dot) {
  final padding = tester.widget<Padding>(
    find
        .ancestor(of: find.byWidget(dot), matching: find.byType(Padding))
        .first,
  );
  return (padding.padding as EdgeInsets).left;
}

void main() {
  group('whitebox location_screen', () {
    // --- Đơn vị 1: listener `if (mounted)` (n1)
    testWidgets('6-1 n1=Đ: đang hiện màn hình ⇒ nhận tọa độ mới và vẽ lại', (
      tester,
    ) async {
      final service = await _pump(tester, _CountingService());
      await _emit(tester, service, _hanoi);

      expect(find.text('GPS ĐANG ĐO'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('6-2 n1=S: listener chạy sau khi gỡ màn hình ⇒ không setState', (
      tester,
    ) async {
      final service = await _pump(tester, _LeakyService());
      expect(service.leakedListener, isNotNull);

      await tester.pumpWidget(const SizedBox());
      service.leakedListener!(_hanoi);
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    // --- Đơn vị 2: dispose
    testWidgets('6-3 dispose: hủy lắng nghe và bỏ theo dõi vòng đời', (
      tester,
    ) async {
      final service = await _pump(tester, _CountingService());
      expect(service.controller.hasListener, isTrue);

      await tester.pumpWidget(const SizedBox());

      expect(service.controller.hasListener, isFalse);
      final pauses = service.pauseCount;
      final refreshes = service.refreshCount;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      expect(service.pauseCount, pauses);
      expect(service.refreshCount, refreshes);
    });

    // --- Đơn vị 3: vòng đời (n2, n3)
    testWidgets('6-4 n2=Đ: quay lại app (resumed) ⇒ refresh, không pause', (
      tester,
    ) async {
      final service = await _pump(tester, _CountingService());
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      final refreshBefore = service.refreshCount;
      final pauseBefore = service.pauseCount;

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);

      expect(service.refreshCount, refreshBefore + 1);
      expect(service.pauseCount, pauseBefore);
    });

    testWidgets('6-5 n2=S,n3=Đ: hidden / paused ⇒ pause, không refresh', (
      tester,
    ) async {
      final service = await _pump(tester, _CountingService());
      final refreshBefore = service.refreshCount;
      final binding = tester.binding;

      binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      expect(service.pauseCount, 1, reason: 'hidden');
      binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      expect(service.pauseCount, 2, reason: 'paused');
      expect(service.refreshCount, refreshBefore);
    });

    testWidgets('6-6 n2=S,n3=S: inactive / detached ⇒ không làm gì', (
      tester,
    ) async {
      final service = await _pump(tester, _CountingService());
      final refreshBefore = service.refreshCount;
      final binding = tester.binding;

      binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      expect(service.pauseCount, 0, reason: 'inactive');
      expect(service.refreshCount, refreshBefore, reason: 'inactive');

      binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      final pauseBefore = service.pauseCount;
      binding.handleAppLifecycleStateChanged(AppLifecycleState.detached);
      expect(service.pauseCount, pauseBefore, reason: 'detached');
      expect(service.refreshCount, refreshBefore, reason: 'detached');
    });

    // --- Đơn vị 7: build (n4..n7), 10 (n9), 13, 14, 17
    testWidgets('6-7 build Available: hiện tọa độ, Xem bấm được, vòng tĩnh', (
      tester,
    ) async {
      final service = await _pump(tester, _CountingService());
      await _emit(tester, service, _hanoi);

      expect(find.text('GPS ĐANG ĐO'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is CoordsDisplay && w.coordsText == _hanoiText,
        ),
        findsOneWidget,
      );
      expect(find.text('Đang chờ tín hiệu GPS…'), findsNothing);
      expect(_onPressed(tester, 'Xem'), isNotNull);
      expect(_wave(tester), isNull);
    });

    testWidgets('6-8 build Waiting: chờ GPS, Xem khóa, vòng sóng chạy', (
      tester,
    ) async {
      await _pump(tester, _CountingService());

      expect(find.text('Đang chờ tín hiệu GPS…'), findsOneWidget);
      expect(find.text('GPS ĐANG ĐO'), findsNothing);
      expect(_onPressed(tester, 'Xem'), isNull);
      expect(_wave(tester), isNotNull);
    });

    testWidgets('6-9 build trạng thái chặn: giải thích quyền, Xem khóa, vòng tĩnh', (
      tester,
    ) async {
      final service = await _pump(tester, _CountingService());
      await _emit(tester, service, const LocationPermissionNeeded());

      expect(find.text('Cho phép'), findsOneWidget);
      expect(find.text('GPS ĐANG ĐO'), findsNothing);
      expect(find.text('Đang chờ tín hiệu GPS…'), findsNothing);
      expect(_onPressed(tester, 'Xem'), isNull);
      expect(_wave(tester), isNull);
    });

    // --- Đơn vị 4, 5, 6: điều hướng
    testWidgets('6-10 bấm Xem mở ResultScreen với tọa độ lúc bấm', (
      tester,
    ) async {
      final service = await _pump(tester, _CountingService());
      await _emit(tester, service, _hanoi);

      await tapButton(tester, 'Xem');

      expect(find.byType(ResultScreen), findsOneWidget);
      expect(tester.widget<ResultScreen>(find.byType(ResultScreen)).coordsText,
          _hanoiText);
    });

    testWidgets('6-11 bấm nút Thông tin mở AboutScreen', (tester) async {
      await _pump(tester, _CountingService());

      await tester.tap(find.byKey(const ValueKey('about-button')));
      await tester.pumpAndSettle();

      expect(find.byType(AboutScreen), findsOneWidget);
    });

    testWidgets('6-12 bấm Nhập tay mở ManualEntryScreen', (tester) async {
      await _pump(tester, _CountingService());

      await tapButton(tester, 'Nhập tay');

      expect(find.byType(ManualEntryScreen), findsOneWidget);
    });

    // --- Đơn vị 9: đổi ngôn ngữ (n8)
    testWidgets('6-13 n8=Đ: đang tiếng Việt, bấm English ⇒ chuyển sang Anh', (
      tester,
    ) async {
      await _pump(tester, _CountingService());
      expect(find.text('Xem'), findsOneWidget);

      await tapButton(tester, 'English');

      expect(find.text('View'), findsOneWidget);
      expect(find.text('Xem'), findsNothing);
    });

    testWidgets('6-14 n8=S: đang tiếng Anh, bấm Tiếng Việt ⇒ chuyển sang Việt', (
      tester,
    ) async {
      await _pump(tester, _CountingService(), language: AppLanguage.en);
      expect(find.text('View'), findsOneWidget);

      await tapButton(tester, 'Tiếng Việt');

      expect(find.text('Xem'), findsOneWidget);
      expect(find.text('View'), findsNothing);
    });

    // --- Đơn vị 11: paint (n10, n11), 12: shouldRepaint
    // _RingsPainter là lớp private: lấy bản thật từ cây widget rồi gọi paint.
    testWidgets('6-15 n10=Đ: wave null ⇒ chỉ 4 vòng cố định', (tester) async {
      final service = await _pump(tester, _CountingService());
      await _emit(tester, service, const LocationPermissionDenied());
      expect(_wave(tester), isNull);

      final canvas = _CountingCanvas();
      _painter(tester).paint(canvas, const Size(390, 844));

      expect(canvas.radii, [80.0, 150.0, 220.0, 290.0]);
    });

    testWidgets('6-16 n10=S,n11=Đ: wave 0 ⇒ chỉ 4 vòng cố định (không sóng)', (
      tester,
    ) async {
      await _pump(tester, _CountingService());
      expect(_wave(tester), 0);

      final canvas = _CountingCanvas();
      _painter(tester).paint(canvas, const Size(390, 844));

      expect(canvas.radii, [80.0, 150.0, 220.0, 290.0]);
    });

    testWidgets('6-17 n10=S,n11=S: wave > 0 ⇒ 4 vòng cố định + 2 vòng sóng', (
      tester,
    ) async {
      await _pump(tester, _CountingService(), reduceMotion: false);
      await tester.pump(const Duration(milliseconds: 700));
      expect(_wave(tester), greaterThan(0));

      final canvas = _CountingCanvas();
      _painter(tester).paint(canvas, const Size(390, 844));

      expect(canvas.radii.length, 6);
      expect(canvas.radii.sublist(0, 4), [80.0, 150.0, 220.0, 290.0]);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('6-18 shouldRepaint: wave đổi thì vẽ lại, giữ nguyên thì không', (
      tester,
    ) async {
      final service = await _pump(tester, _CountingService());
      final waiting = _painter(tester); // wave 0
      await _emit(tester, service, const LocationPermissionDenied());
      final blocked = _painter(tester); // wave null

      expect(waiting.shouldRepaint(waiting), isFalse, reason: 'cùng wave');
      expect(blocked.shouldRepaint(waiting), isTrue, reason: 'null ≠ 0');
    });

    testWidgets('6-19 sóng chạy thật: wave > 0 khi hoạt ảnh bật', (
      tester,
    ) async {
      await _pump(tester, _CountingService(), reduceMotion: false);
      await tester.pump(const Duration(milliseconds: 700));

      final wave = _wave(tester);
      expect(wave, isNotNull);
      expect(wave, greaterThan(0));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });

    // --- Đơn vị 15, 16: _Status (n13..n15), _Blocked (n12)
    testWidgets('6-20 n13=Đ: cần quyền ⇒ Cho phép gọi requestPermission', (
      tester,
    ) async {
      final service = await _pump(tester, _CountingService());
      await _emit(tester, service, const LocationPermissionNeeded());

      await tester.tap(find.text('Cho phép'));

      expect(service.requestPermissionCount, 1);
      expect(service.openAppSettingsCount, 0);
      expect(service.openLocationSettingsCount, 0);
    });

    testWidgets('6-21 n14=Đ: bị từ chối ⇒ Mở Cài đặt gọi openAppSettings', (
      tester,
    ) async {
      final service = await _pump(tester, _CountingService());
      await _emit(tester, service, const LocationPermissionDenied());

      expect(find.text('Chưa cấp quyền vị trí'), findsOneWidget);
      await tester.tap(find.text('Mở Cài đặt'));

      expect(service.openAppSettingsCount, 1);
      expect(service.openLocationSettingsCount, 0);
      expect(service.requestPermissionCount, 0);
    });

    testWidgets('6-22 n15=Đ: định vị tắt ⇒ Mở Cài đặt gọi openLocationSettings', (
      tester,
    ) async {
      final service = await _pump(tester, _CountingService());
      await _emit(tester, service, const LocationServiceDisabled());

      expect(find.text('Định vị đang tắt'), findsOneWidget);
      await tester.tap(find.text('Mở Cài đặt'));

      expect(service.openLocationSettingsCount, 1);
      expect(service.openAppSettingsCount, 0);
      expect(service.requestPermissionCount, 0);
    });

    testWidgets('6-23 n15=S: Waiting ⇒ không có nút Cài đặt / Cho phép', (
      tester,
    ) async {
      await _pump(tester, _CountingService());

      expect(find.text('Đang chờ tín hiệu GPS…'), findsOneWidget);
      expect(find.text('Mở Cài đặt'), findsNothing);
      expect(find.text('Cho phép'), findsNothing);
    });

    testWidgets('6-24 n12: lời giải thích dài cỡ 16, thông báo ngắn cỡ 22', (
      tester,
    ) async {
      final service = await _pump(tester, _CountingService());

      await _emit(tester, service, const LocationPermissionDenied());
      expect(_fontSize(tester, 'Chưa cấp quyền vị trí'), 22, reason: 'S');
      await _emit(tester, service, const LocationServiceDisabled());
      expect(_fontSize(tester, 'Định vị đang tắt'), 22, reason: 'S');

      await _emit(tester, service, const LocationPermissionNeeded());
      final longMessage = tester
          .widgetList<Text>(find.textContaining('Tọa Độ dùng vị trí chính xác'))
          .single;
      expect(longMessage.style?.fontSize, 16, reason: 'Đ (*)');
    });

    // --- Đơn vị 18, 19: _BlinkingDots (n16, n17), _blink (n18)
    testWidgets('6-25 n16/n17: 3 chấm, chấm đầu lề 0, các chấm sau lề 7', (
      tester,
    ) async {
      await _pump(tester, _CountingService());

      final dots = _dots(tester);
      expect(dots.length, 3);
      expect(_leftOf(tester, dots[0]), 0);
      expect(_leftOf(tester, dots[1]), 7);
      expect(_leftOf(tester, dots[2]), 7);
    });

    testWidgets('6-26 n18=S: đứng yên ở 40% chu kỳ ⇒ sáng dần theo chấm', (
      tester,
    ) async {
      await _pump(tester, _CountingService());

      final opacities = _dots(tester).map((d) => d.opacity).toList();
      expect(opacities[0], closeTo(1.0, 0.001));
      expect(opacities[1], closeTo(0.7375, 0.001));
      expect(opacities[2], closeTo(0.475, 0.001));
    });

    testWidgets('6-27 n18=Đ: chu kỳ ≥ 80% ⇒ chấm tắt ở độ mờ 0.25', (
      tester,
    ) async {
      await _pump(tester, _CountingService(), reduceMotion: false);
      await tester.pump(const Duration(milliseconds: 1260));

      final opacities = _dots(tester).map((d) => d.opacity).toList();
      expect(opacities[0], closeTo(0.25, 0.01));
      await tester.pumpWidget(const SizedBox());
    });
  });
}
