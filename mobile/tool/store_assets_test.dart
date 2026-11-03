// Xuất ảnh cho trang Google Play từ giao diện thật của app, không chạy cùng `flutter test`.
// Chạy trong mobile/: flutter test tool/store_assets_test.dart
// Kết quả ghi vào docs/store/, PNG không có kênh trong suốt (trừ icon), đúng yêu cầu của Play.
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toado/location_service.dart';
import 'package:toado/main.dart';
import 'package:toado/strings.dart';
import 'package:toado/theme.dart';

import '../test/test_support.dart';
import 'png_writer.dart';

const _outDir = '../docs/store';

/// Tọa độ mẫu của bản thiết kế (21°01'43"N 105°48'12"E), không phải vị trí của ai.
const _sample = LocationAvailable(21.02862, 105.80335);

/// 1080×1920, tỷ lệ 16:9, nằm trong giới hạn 2:1 của Play.
const _phoneLogical = Size(432, 768);
const _phoneRatio = 2.5;

void main() {
  setUpAll(_loadFonts);

  for (final language in AppLanguage.values) {
    testWidgets('ảnh chụp màn hình ${language.name}', (tester) async {
      final key = GlobalKey();
      tester.view.physicalSize = _phoneLogical * _phoneRatio;
      tester.view.devicePixelRatio = _phoneRatio;
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

      final service = FakeLocationService();
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: ToaDoApp(
            locationService: service,
            languageStore: FakeLanguageStore(language),
          ),
        ),
      );
      await tester.pump();
      final strings = AppStrings.of(language);
      final dir = '$_outDir/${language.name}';

      service.emit(_sample);
      await tester.pumpAndSettle();
      await _capture(tester, key, '$dir/1-man-hinh-chinh.png');

      await tapButton(tester, strings.view);
      await _capture(tester, key, '$dir/2-ket-qua.png');

      await tester.drag(find.byType(Scrollable).last, const Offset(0, -2000));
      await tester.pumpAndSettle();
      await _capture(tester, key, '$dir/3-ket-luan.png');

      await tapButton(tester, strings.back);
      await tapButton(tester, strings.manualEntry);
      final fields = find.byType(CupertinoTextField);
      const values = ['21', '01', '43', '105', '48', '12'];
      for (var i = 0; i < values.length; i++) {
        await tester.enterText(fields.at(i), values[i]);
      }
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await _capture(tester, key, '$dir/4-nhap-tay.png');
    });

    testWidgets('ảnh bìa ${language.name}', (tester) async {
      final key = GlobalKey();
      tester.view.physicalSize = const Size(1024, 500);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final icon = await tester.runAsync(() => _decodeIcon(220));
      await tester.pumpWidget(
        RepaintBoundary(key: key, child: _FeatureGraphic(language, icon!)),
      );
      await _capture(tester, key, '$_outDir/${language.name}/anh-bia-1024x500.png');
    });
  }

  testWidgets('icon 512', (tester) async {
    await tester.runAsync(() async {
      final image = await _decodeIcon(512);
      final rgba = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      writePng('$_outDir/icon-512.png', 512, 512, rgba!.buffer.asUint8List(),
          alpha: true);
    });
  });
}

class _FeatureGraphic extends StatelessWidget {
  const _FeatureGraphic(this.language, this.icon);

  final AppLanguage language;
  final ui.Image icon;

  @override
  Widget build(BuildContext context) {
    final vi = language == AppLanguage.vi;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ColoredBox(
        color: AppColors.screen,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 72),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(48),
                child: RawImage(image: icon, width: 220, height: 220),
              ),
              const SizedBox(width: 56),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vi ? 'Tọa Độ' : 'Toa Do',
                        style: appText(size: 72, weight: 700)),
                    const SizedBox(height: 12),
                    Text('21°01\'43"N 105°48\'12"E',
                        style: appText(
                            size: 34,
                            weight: 600,
                            color: AppColors.accent,
                            tabular: true)),
                    const SizedBox(height: 20),
                    Text(
                      vi
                          ? 'Tọa độ nơi bạn đứng và Bảng số Thiên Cung.\nChạy offline, không quảng cáo.'
                          : 'Your coordinates and the Thien Cung table.\nWorks offline, no ads.',
                      style: appText(
                          size: 26, weight: 500, color: AppColors.meaning, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _loadFonts() async {
  final manifest =
      json.decode(await rootBundle.loadString('FontManifest.json')) as List;
  for (final family in manifest.cast<Map<String, dynamic>>()) {
    final loader = FontLoader(family['family'] as String);
    for (final font in (family['fonts'] as List).cast<Map<String, dynamic>>()) {
      loader.addFont(rootBundle.load(font['asset'] as String));
    }
    await loader.load();
  }
}

Future<ui.Image> _decodeIcon(int size) async {
  final bytes = await File('assets/icon/icon.png').readAsBytes();
  final codec =
      await ui.instantiateImageCodec(bytes, targetWidth: size, targetHeight: size);
  return (await codec.getNextFrame()).image;
}

Future<void> _capture(WidgetTester tester, GlobalKey key, String path) async {
  final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final ratio = tester.view.devicePixelRatio;
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: ratio);
    final rgba = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    writePng(path, image.width, image.height, rgba!.buffer.asUint8List(),
        alpha: false);
  });
}
