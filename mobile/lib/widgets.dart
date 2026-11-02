import 'package:flutter/cupertino.dart';

import 'language_store.dart';
import 'theme.dart';

/// Nút chính bo tròn hẳn, tắt thì đổi sang nền xám.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = CupertinoIcons.arrow_right,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final color = enabled ? AppColors.screen : AppColors.muted;
    return _Pill(
      height: AppMetrics.of(context).primaryHeight,
      background: enabled ? AppColors.text : AppColors.disabledSurface,
      onPressed: onPressed,
      child: _Label(
        text: label,
        style: appText(size: 18, weight: 800, color: color),
        trailing: Icon(icon, size: 20, color: color),
      ),
    );
  }
}

/// Nút phụ viền mảnh, ví dụ "Nhập tay".
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return _Pill(
      height: 52,
      border: AppColors.outline,
      onPressed: onPressed,
      child: _Label(
        text: label,
        style: appText(size: 16, weight: 600),
        leading: Icon(icon, size: 18, color: AppColors.text),
      ),
    );
  }
}

/// Nút hành động giữa màn hình, ví dụ "Mở Cài đặt".
class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return _Pill(
      height: 52,
      background: AppColors.actionSurface,
      border: AppColors.actionBorder,
      horizontalPadding: 28,
      onPressed: onPressed,
      child: _Label(
        text: label,
        style: appText(size: 16, weight: 700),
        leading: Icon(icon, size: 18, color: AppColors.text),
      ),
    );
  }
}

/// Thẻ bo góc lớn.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.color,
    required this.border,
    required this.child,
  });

  final Color color;
  final Color border;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 22),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: border),
        borderRadius: const BorderRadius.all(Radius.circular(24)),
      ),
      child: child,
    );
  }
}

/// Nút lùi "‹ Quay lại" ở đầu trang.
class BackLink extends StatelessWidget {
  const BackLink({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: const Size.square(44),
          onPressed: () => Navigator.of(context).maybePop(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                CupertinoIcons.chevron_left,
                size: 22,
                color: AppColors.text,
              ),
              const SizedBox(width: 2),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: appText(size: 16, weight: 600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Nút ngôn ngữ trên thanh trên cùng.
class LanguagePill extends StatelessWidget {
  const LanguagePill({
    super.key,
    required this.label,
    required this.spokenLabel,
    required this.onPressed,
  });

  final String label;
  final String spokenLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: spokenLabel,
      child: _Pill(
        height: 44,
        background: AppColors.pillSurface,
        border: AppColors.outline,
        horizontalPadding: 16,
        onPressed: onPressed,
        // [spokenLabel] đã nêu tên ngôn ngữ; để chữ con vào cây semantics thì
        // nó gộp vào cùng nút và TalkBack đọc lặp. Chỉ bọc phần chữ để nút vẫn
        // giữ vai trò button và thao tác chạm.
        child: ExcludeSemantics(
          child: _Label(
            text: label,
            style: appText(size: 14, weight: 600, color: AppColors.pillText),
            leading: const Icon(
              CupertinoIcons.globe,
              size: 16,
              color: AppColors.pillText,
            ),
          ),
        ),
      ),
    );
  }
}

/// Nút tròn chỉ có biểu tượng, vùng chạm 44.
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.spokenLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String spokenLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: spokenLabel,
      child: SizedBox.square(
        dimension: 44,
        child: _Pill(
          height: 44,
          background: AppColors.pillSurface,
          border: AppColors.outline,
          onPressed: onPressed,
          child: Icon(icon, size: 20, color: AppColors.pillText),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.height,
    required this.onPressed,
    required this.child,
    this.background,
    this.border,
    this.horizontalPadding = 0,
  });

  final double height;
  final VoidCallback? onPressed;
  final Widget child;
  final Color? background;
  final Color? border;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.square(height),
      onPressed: onPressed,
      child: Container(
        height: height,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        decoration: ShapeDecoration(
          color: background,
          shape: StadiumBorder(
            side: border == null ? BorderSide.none : BorderSide(color: border!),
          ),
        ),
        // Có đệm ngang nghĩa là nút ôm sát chữ, không thì giãn hết bề ngang.
        child: Center(
          widthFactor: horizontalPadding > 0 ? 1 : null,
          child: child,
        ),
      ),
    );
  }
}

/// Chữ và biểu tượng trong nút; tự co khi chữ hệ thống phóng to.
class _Label extends StatelessWidget {
  const _Label({
    required this.text,
    required this.style,
    this.leading,
    this.trailing,
  });

  final String text;
  final TextStyle style;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 10)],
          Text(text, maxLines: 1, style: style),
          if (trailing != null) ...[const SizedBox(width: 10), trailing!],
        ],
      ),
    );
  }
}

/// Tọa độ tách hai dòng vĩ độ, kinh độ. Trình đọc màn hình đọc thành lời; không
/// dùng live region vì số cập nhật mỗi giây sẽ bị đọc liên tục.
class CoordsDisplay extends StatelessWidget {
  const CoordsDisplay({
    super.key,
    required this.coordsText,
    required this.fontSize,
    this.labelSize = 12,
    this.labelGap = 8,
    this.dividerGap = 30,
    this.centered = false,
  });

  final String coordsText;
  final double fontSize;
  final double labelSize;
  final double labelGap;
  final double dividerGap;

  /// Căn giữa, chỉ có hai dòng số, không nhãn và không đường kẻ.
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final strings = LanguageScope.of(context).strings;
    final parts = coordsText.split(' ');
    return Semantics(
      label: strings.spokenCoords(coordsText),
      excludeSemantics: true,
      child: centered
          ? Column(
              children: [
                _CoordsLine(
                  parts.first,
                  fontSize: fontSize,
                  alignment: Alignment.center,
                ),
                const SizedBox(height: 6),
                _CoordsLine(
                  parts.last,
                  fontSize: fontSize,
                  alignment: Alignment.center,
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionLabel(strings.latitudeLabel, size: labelSize),
                SizedBox(height: labelGap),
                _CoordsLine(parts.first, fontSize: fontSize),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: dividerGap),
                  child: const SizedBox(
                    height: 1,
                    child: ColoredBox(color: AppColors.cardBorder),
                  ),
                ),
                SectionLabel(strings.longitudeLabel, size: labelSize),
                SizedBox(height: labelGap),
                _CoordsLine(parts.last, fontSize: fontSize),
              ],
            ),
    );
  }
}

class _CoordsLine extends StatelessWidget {
  const _CoordsLine(
    this.text, {
    required this.fontSize,
    this.alignment = Alignment.centerLeft,
  });

  final String text;
  final double fontSize;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final digits = appText(
      size: fontSize,
      weight: 700,
      letterSpacing: -0.03 * fontSize,
      height: 1.05,
      tabular: true,
    );
    final unit = appText(
      size: fontSize * 0.55,
      weight: 500,
      color: AppColors.muted,
      height: 1,
    );
    final hemisphere = appText(
      size: fontSize * 0.6,
      weight: 700,
      color: AppColors.accent,
      height: 1,
    );
    final tokens = RegExp(r'''\d+|[°'"]|[NSEW]''').allMatches(text);
    return Align(
      alignment: alignment,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            for (final token in tokens)
              switch (token[0]!) {
                'N' || 'S' || 'E' || 'W' => Padding(
                  padding: EdgeInsets.only(left: fontSize * 0.1),
                  child: Text(token[0]!, style: hemisphere),
                ),
                '°' || "'" || '"' => Padding(
                  padding: EdgeInsets.symmetric(horizontal: fontSize * 0.03),
                  child: Transform.translate(
                    offset: Offset(0, -fontSize * 0.275),
                    child: Text(token[0]!, style: unit),
                  ),
                ),
                final number => Text(number, style: digits),
              },
          ],
        ),
      ),
    );
  }
}

/// Nhãn nhỏ giãn chữ, ví dụ "VĨ ĐỘ".
class SectionLabel extends StatelessWidget {
  const SectionLabel(
    this.text, {
    super.key,
    this.size = 12,
    this.color = AppColors.label,
  });

  final String text;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: appText(
        size: size,
        weight: 700,
        color: color,
        letterSpacing: 0.18 * size,
      ),
    );
  }
}

/// Hoạt ảnh lặp. Khi máy bật giảm chuyển động thì đứng yên ở [restValue].
class LoopingBuilder extends StatefulWidget {
  const LoopingBuilder({
    super.key,
    required this.period,
    required this.builder,
    this.restValue = 1,
  });

  final Duration period;
  final double restValue;
  final Widget Function(BuildContext context, double value) builder;

  @override
  State<LoopingBuilder> createState() => _LoopingBuilderState();
}

class _LoopingBuilderState extends State<LoopingBuilder>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: widget.period,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return widget.builder(context, widget.restValue);
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => widget.builder(context, _controller.value),
    );
  }
}
