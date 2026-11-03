// Xuất icon app từ AppMarkPainter, không chạy cùng `flutter test`.
// Chạy trong mobile/: flutter test tool/app_icon_test.dart
// rồi dart run flutter_launcher_icons (sinh ic_launcher.png và icon iOS từ assets/icon/icon.png),
// rồi git checkout -- ios/Runner.xcodeproj/project.pbxproj: bản 0.14.4 ghi sai
// ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS thành AppIcon.
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toado/app_mark.dart';

import 'png_writer.dart';

/// Lớp trước của icon thích ứng: khung 108 dp ở từng mật độ.
const _foregroundSizes = {
  'mdpi': 108,
  'hdpi': 162,
  'xhdpi': 216,
  'xxhdpi': 324,
  'xxxhdpi': 432,
};

void main() {
  testWidgets('icon app', (tester) async {
    await tester.runAsync(() async {
      // Icon vuông (iOS, Android 7 trở xuống) không bị launcher cắt nên phóng hình to hơn.
      await _render('assets/icon/icon.png', 1024, withBackground: true, frame: 84);
      for (final entry in _foregroundSizes.entries) {
        await _render(
          'android/app/src/main/res/mipmap-${entry.key}/ic_launcher_foreground.png',
          entry.value,
          withBackground: false,
        );
      }
    });
  });
}

Future<void> _render(
  String path,
  int px, {
  required bool withBackground,
  double frame = 108,
}) async {
  final recorder = ui.PictureRecorder();
  AppMarkPainter(withBackground: withBackground, frame: frame)
      .paint(Canvas(recorder), Size.square(px.toDouble()));
  final image = await recorder.endRecording().toImage(px, px);
  final rgba = await image.toByteData(format: ui.ImageByteFormat.rawStraightRgba);
  writePng(path, px, px, rgba!.buffer.asUint8List(), alpha: !withBackground);
}
