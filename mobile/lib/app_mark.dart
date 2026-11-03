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
  static const lineWidth = 3.8;
  static const arcRadius = 25.0;
  static const arcWidth = 5.2;
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
      final point = _center.translate(
        radius * math.cos(angle),
        radius * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
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
