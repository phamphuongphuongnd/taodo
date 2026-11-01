import 'package:flutter/widgets.dart';

/// Màu theo design-mobile/screens/README.md. Cam chỉ dùng cho cảnh báo và lỗi.
abstract final class AppColors {
  static const screen = Color(0xFF050608);
  static const card = Color(0xFF0E1015);
  static const cardBorder = Color(0xFF1E2128);
  static const field = Color(0xFF181B22);

  /// Sáng hơn `#4B505B` trong thiết kế để đủ tương phản 4.5:1 trên nền ô nhập.
  static const fieldHint = Color(0xFF7D8390);
  static const ring = Color(0xFF161920);
  static const outline = Color(0xFF23262E);
  static const pillSurface = Color(0xFF0C0E12);
  static const pillText = Color(0xFFC9CED8);
  static const actionSurface = Color(0xFF12151B);
  static const actionBorder = Color(0xFF3A3F4A);
  static const disabledSurface = Color(0xFF14171D);
  static const text = Color(0xFFF5F6F8);
  static const label = Color(0xFF9BA0AB);
  static const muted = Color(0xFF7D8390);
  static const meaning = Color(0xFFB4B9C4);
  static const accent = Color(0xFF6EE7B7);
  static const accentSurface = Color(0xFF0F1A16);
  static const accentBorder = Color(0xFF1E3A30);
  static const conclusionSurface = Color(0xFF0D1713);
  static const pairSurface = Color(0xFF12201A);
  static const dashedBorder = Color(0xFF2A2E37);
  static const warning = Color(0xFFFFB340);
  static const warningBorder = Color(0xFFFF9F0A);
  static const warningSurface = Color(0xFF2A1C06);
  static const warningBoxBorder = Color(0xFF6B4A12);
}

/// Font Manrope là font biến thiên nên độ đậm phải đặt qua trục `wght`.
TextStyle appText({
  required double size,
  required int weight,
  Color color = AppColors.text,
  double? letterSpacing,
  double? height,
  bool tabular = false,
  FontStyle? fontStyle,
}) {
  return TextStyle(
    fontFamily: 'Manrope',
    fontSize: size,
    fontWeight: FontWeight.values[(weight ~/ 100) - 1],
    fontVariations: [FontVariation('wght', weight.toDouble())],
    fontFeatures: tabular ? const [FontFeature.tabularFigures()] : null,
    fontStyle: fontStyle,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
  );
}

/// Số đo thay đổi theo máy: màn hẹp hơn 390 dùng bộ số Android 360×800.
class AppMetrics {
  const AppMetrics._({
    required this.homeMargin,
    required this.pageMargin,
    required this.homeCoordsSize,
    required this.resultCoordsSize,
    required this.pairSize,
    required this.pairBox,
    required this.conclusionSize,
    required this.primaryHeight,
  });

  factory AppMetrics.of(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 390 ? _compact : _regular;

  static const _regular = AppMetrics._(
    homeMargin: 24,
    pageMargin: 20,
    homeCoordsSize: 52,
    resultCoordsSize: 36,
    pairSize: 24,
    pairBox: 56,
    conclusionSize: 20,
    primaryHeight: 60,
  );

  static const _compact = AppMetrics._(
    homeMargin: 20,
    pageMargin: 16,
    homeCoordsSize: 46,
    resultCoordsSize: 34,
    pairSize: 22,
    pairBox: 52,
    conclusionSize: 19,
    primaryHeight: 56,
  );

  final double homeMargin;
  final double pageMargin;
  final double homeCoordsSize;
  final double resultCoordsSize;
  final double pairSize;
  final double pairBox;
  final double conclusionSize;
  final double primaryHeight;
}
