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

  test('chỉ vẽ lại khi đổi nền hoặc khung', () {
    const plain = AppMarkPainter();
    expect(plain.shouldRepaint(const AppMarkPainter()), isFalse);
    expect(plain.shouldRepaint(const AppMarkPainter(withBackground: true)), isTrue);
    expect(plain.shouldRepaint(const AppMarkPainter(frame: 70)), isTrue);
  });

  testWidgets('thanh trên màn hình chính dùng AppMark thay la bàn', (tester) async {
    await pumpToaDoApp(tester);
    expect(find.byType(AppMark), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.compass), findsNothing);
  });
}
