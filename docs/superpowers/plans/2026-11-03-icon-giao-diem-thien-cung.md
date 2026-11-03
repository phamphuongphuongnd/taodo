# Icon "Giao điểm Thiên Cung" Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Thay icon la bàn bằng dấu hiệu "Giao điểm Thiên Cung" ở icon app (Android, iOS, trang Play) và ở thanh trên màn hình chính.

**Architecture:** Hình vẽ một lần trong `AppMarkPainter` (`mobile/lib/app_mark.dart`). Widget `AppMark` dùng painter đó trong app; tool `mobile/tool/app_icon_test.dart` dùng painter đó xuất PNG. Bộ ghi PNG tách thành `mobile/tool/png_writer.dart` dùng chung với `store_assets_test.dart`.

**Tech Stack:** Flutter (CustomPainter, dart:ui), `flutter_launcher_icons` đã có. Không thêm thư viện.

Spec: `docs/superpowers/specs/2026-11-03-icon-giao-diem-thien-cung-design.md`. Mọi lệnh chạy trong `mobile/`. Chỉ commit khi người dùng đồng ý.

---

### Task 1: AppMarkPainter và AppMark

**Files:**
- Create: `mobile/lib/app_mark.dart`
- Test: `mobile/test/app_mark_test.dart`

- [ ] **Step 1: Viết test hỏng**

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toado/app_mark.dart';

import 'test_support.dart';

void main() {
  test('mọi nét nằm trong vùng an toàn bán kính 33 của khung 108', () {
    expect(AppMarkPainter.lineHalf + AppMarkPainter.lineWidth / 2,
        lessThanOrEqualTo(AppMarkPainter.safeRadius));
    expect(AppMarkPainter.arcRadius + AppMarkPainter.arcWidth / 2,
        lessThanOrEqualTo(AppMarkPainter.safeRadius));
    expect(AppMarkPainter.starOuter + AppMarkPainter.starGap,
        lessThanOrEqualTo(AppMarkPainter.safeRadius));
  });

  test('chỉ vẽ lại khi đổi nền', () {
    const plain = AppMarkPainter();
    expect(plain.shouldRepaint(const AppMarkPainter()), isFalse);
    expect(plain.shouldRepaint(const AppMarkPainter(withBackground: true)), isTrue);
  });

  testWidgets('thanh trên màn hình chính dùng AppMark thay la bàn', (tester) async {
    await pumpToaDoApp(tester);
    expect(find.byType(AppMark), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.compass), findsNothing);
  });
}
```

- [ ] **Step 2: Chạy, xác nhận hỏng** — `flutter test test/app_mark_test.dart` → lỗi biên dịch, chưa có `app_mark.dart`.

- [ ] **Step 3: Viết `mobile/lib/app_mark.dart`**

```dart
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'theme.dart';

/// Dấu hiệu "Giao điểm Thiên Cung": vĩ tuyến, kinh tuyến, hai cung tròn và ngôi sao ở
/// giao điểm. Số đo tính trên khung 108 của icon thích ứng Android, tâm (54, 54);
/// mọi nét nằm trong vòng tròn [safeRadius] để launcher cắt hình nào cũng không mất nét.
class AppMarkPainter extends CustomPainter {
  const AppMarkPainter({this.withBackground = false, this.frame = 108});

  /// Phủ nền màu màn hình app; false thì nền trong suốt.
  final bool withBackground;

  /// Cạnh khung (đơn vị gốc) được co giãn cho vừa kích thước vẽ. 108 là cả khung icon;
  /// nhỏ hơn thì phóng to phần giữa, dùng khi hình đứng một mình trong giao diện.
  final double frame;

  static const safeRadius = 33.0;
  static const lineHalf = 31.0;
  static const lineWidth = 3.0;
  static const arcRadius = 25.0;
  static const arcWidth = 4.5;
  static const starOuter = 15.0;
  static const starInner = 4.0;

  /// Khe trong suốt quanh ngôi sao, tách sao khỏi hai đường kẻ.
  static const starGap = 2.5;

  static const _center = Offset(54, 54);

  @override
  void paint(Canvas canvas, Size size) {
    if (withBackground) {
      canvas.drawRect(Offset.zero & size, Paint()..color = AppColors.screen);
    }
    // Vẽ trong lớp riêng để khe quanh sao chỉ xóa nét của hình, không xóa nền phía dưới.
    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(size.shortestSide / frame);
    canvas.translate(-_center.dx, -_center.dy);

    final line = Paint()
      ..color = AppColors.text
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawLine(_center.translate(-lineHalf, 0), _center.translate(lineHalf, 0), line)
      ..drawLine(_center.translate(0, -lineHalf), _center.translate(0, lineHalf), line);

    final arc = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = arcWidth
      ..strokeCap = StrokeCap.round;
    final circle = Rect.fromCircle(center: _center, radius: arcRadius);
    canvas
      ..drawArc(circle, math.pi, math.pi / 2, false, arc)
      ..drawArc(circle, 0, math.pi / 2, false, arc);

    final star = _star();
    canvas
      ..drawPath(
        star,
        Paint()
          ..blendMode = BlendMode.clear
          ..style = PaintingStyle.stroke
          ..strokeWidth = starGap * 2
          ..strokeJoin = StrokeJoin.round,
      )
      ..drawPath(star, Paint()..color = AppColors.accent)
      ..restore();
  }

  static Path _star() {
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final radius = i.isEven ? starOuter : starInner;
      final angle = -math.pi / 2 + i * math.pi / 4;
      final point = _center.translate(radius * math.cos(angle), radius * math.sin(angle));
      i == 0 ? path.moveTo(point.dx, point.dy) : path.lineTo(point.dx, point.dy);
    }
    return path..close();
  }

  @override
  bool shouldRepaint(AppMarkPainter oldDelegate) =>
      oldDelegate.withBackground != withBackground || oldDelegate.frame != frame;
}

/// Dấu hiệu app trong giao diện, chỉ để trang trí nên không có nhãn đọc màn hình.
class AppMark extends StatelessWidget {
  const AppMark({super.key, this.size = 24});

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    // Khung 70: vòng an toàn 66 cộng chút lề để hình lấp đầy ô như icon cũ.
    child: const CustomPaint(painter: AppMarkPainter(frame: 70)),
  );
}
```

- [ ] **Step 4: Thay la bàn ở `mobile/lib/location_screen.dart:204`**

```dart
          const AppMark(),
```
và thêm `import 'app_mark.dart';`.

- [ ] **Step 5: Chạy** `flutter test test/app_mark_test.dart` → PASS; `flutter test` → toàn bộ PASS.

### Task 2: Tách bộ ghi PNG

**Files:**
- Create: `mobile/tool/png_writer.dart` (chuyển nguyên `_writePng`, `_chunk`, `_crcTable`, `_crc32` từ `store_assets_test.dart`, đổi `_writePng` thành `writePng`)
- Modify: `mobile/tool/store_assets_test.dart` (xóa các hàm trên, `import 'png_writer.dart';`, gọi `writePng`)

- [ ] **Step 1:** Chuyển code, chạy `flutter analyze` → sạch.

### Task 3: Tool xuất icon

**Files:**
- Create: `mobile/tool/app_icon_test.dart`

- [ ] **Step 1: Viết tool**

```dart
// Xuất icon app từ AppMarkPainter, không chạy cùng `flutter test`.
// Chạy trong mobile/: flutter test tool/app_icon_test.dart
// rồi dart run flutter_launcher_icons (sinh ic_launcher.png và icon iOS từ assets/icon/icon.png).
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
      await _render('assets/icon/icon.png', 1024, withBackground: true);
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

Future<void> _render(String path, int px, {required bool withBackground}) async {
  final recorder = ui.PictureRecorder();
  AppMarkPainter(withBackground: withBackground)
      .paint(Canvas(recorder), Size.square(px.toDouble()));
  final image = await recorder.endRecording().toImage(px, px);
  final rgba = await image.toByteData(format: ui.ImageByteFormat.rawStraightRgba);
  writePng(path, px, px, rgba!.buffer.asUint8List(), alpha: !withBackground);
}
```

- [ ] **Step 2:** Chạy `flutter test tool/app_icon_test.dart` rồi `dart run flutter_launcher_icons`. Xem `git status`: chỉ đổi `icon.png`, `ic_launcher.png`, `ic_launcher_foreground.png` và `ios/Runner/Assets.xcassets/AppIcon.appiconset/*`; `mipmap-anydpi-v26/ic_launcher.xml` không đổi.
- [ ] **Step 3:** Xem ảnh 1024 và `mipmap-mdpi/ic_launcher.png` (48 px). Nét quá mảnh thì chỉnh hằng số (±30%), chạy lại Task 1 Step 5 và Step 1–2 của task này.

### Task 4: Ảnh trang Play và tài liệu

- [ ] **Step 1:** `flutter test tool/store_assets_test.dart` → 5 test PASS; xem lại icon 512, ảnh bìa, ảnh màn hình chính.
- [ ] **Step 2:** Sửa `docs/chuc-nang-va-giao-dien.md`: mục "Icon app" và câu "Thanh trên cùng có la bàn" thành dấu hiệu Giao điểm Thiên Cung.

### Task 5: Kiểm tra

- [ ] `flutter analyze` sạch; `flutter test` toàn bộ PASS.
- [ ] `flutter build appbundle --release`; `aapt2` kiểm icon trong bản build bằng APK release (`flutter build apk --release`, `aapt2 dump badging` dòng `application-icon`).
- [ ] Hỏi người dùng có muốn cài thử lên máy thật và có muốn commit.
