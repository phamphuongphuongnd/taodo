import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toado/language_store.dart';
import 'package:toado/location_service.dart';
import 'package:toado/main.dart';
import 'package:toado/strings.dart';

class FakeLocationService implements LocationService {
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

class FakeLanguageStore implements LanguageStore {
  FakeLanguageStore(this.saved);

  AppLanguage? saved;

  @override
  Future<AppLanguage?> load() async => saved;

  @override
  Future<void> save(AppLanguage language) async => saved = language;
}

/// Dựng app ở cỡ màn hình cho trước. Mặc định tắt hoạt ảnh để `pumpAndSettle`
/// dừng được.
Future<FakeLocationService> pumpToaDoApp(
  WidgetTester tester, {
  AppLanguage language = AppLanguage.vi,
  Size size = const Size(390, 844),
  double textScale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

  final service = FakeLocationService();
  await tester.pumpWidget(
    ToaDoApp(
      locationService: service,
      languageStore: FakeLanguageStore(language),
    ),
  );
  await tester.pump();
  return service;
}

Future<void> tapButton(WidgetTester tester, String label) async {
  await tester.tap(find.widgetWithText(CupertinoButton, label));
  await tester.pumpAndSettle();
}
