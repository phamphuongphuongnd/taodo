import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'coords.dart';
import 'language_store.dart';
import 'result_screen.dart';
import 'theme.dart';
import 'widgets.dart';

/// Nhập độ, phút, giây bằng tay rồi xem kết quả như tọa độ đo được.
class ManualEntryScreen extends StatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  final _controllers = {
    for (final field in ManualField.values) field: TextEditingController(),
  };
  bool _north = true;
  bool _east = true;
  Set<ManualField> _invalid = const {};
  bool _isEmptyError = false;

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Ô trống tính là 0.
  int _value(ManualField field) => int.tryParse(_controllers[field]!.text) ?? 0;

  void _clearError() {
    if (_invalid.isNotEmpty || _isEmptyError) {
      setState(() {
        _invalid = const {};
        _isEmptyError = false;
      });
    }
  }

  void _openResult() {
    // Một ô trống tính là 0, nhưng cả 6 ô trống nghĩa là chưa nhập gì.
    if (_controllers.values.every((controller) => controller.text.isEmpty)) {
      setState(() => _isEmptyError = true);
      return;
    }
    final invalid = invalidManualFields(
      latDeg: _value(ManualField.latDeg),
      latMin: _value(ManualField.latMin),
      latSec: _value(ManualField.latSec),
      lonDeg: _value(ManualField.lonDeg),
      lonMin: _value(ManualField.lonMin),
      lonSec: _value(ManualField.lonSec),
    );
    if (invalid.isNotEmpty) {
      setState(() => _invalid = invalid);
      return;
    }
    final coordsText = formatManualCoords(
      latDeg: _value(ManualField.latDeg),
      latMin: _value(ManualField.latMin),
      latSec: _value(ManualField.latSec),
      north: _north,
      lonDeg: _value(ManualField.lonDeg),
      lonMin: _value(ManualField.lonMin),
      lonSec: _value(ManualField.lonSec),
      east: _east,
    )!;
    unawaited(
      Navigator.of(context).push(
        CupertinoPageRoute<void>(
          builder: (_) => ResultScreen(coordsText: coordsText),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = LanguageScope.of(context).strings;
    final metrics = AppMetrics.of(context);

    return CupertinoPageScaffold(
      backgroundColor: AppColors.screen,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, viewport) => SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: viewport.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BackLink(label: strings.back),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        metrics.homeMargin,
                        8,
                        metrics.homeMargin,
                        24,
                      ),
                      child: Text(
                        strings.manualEntryTitle,
                        style: appText(
                          size: 32,
                          weight: 800,
                          letterSpacing: -0.64,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: metrics.pageMargin,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _CoordinateCard(
                            title: strings.latitude,
                            fields: const [
                              ManualField.latDeg,
                              ManualField.latMin,
                              ManualField.latSec,
                            ],
                            controllers: _controllers,
                            invalid: _invalid,
                            onChanged: _clearError,
                            positive: ('N', strings.north),
                            negative: ('S', strings.south),
                            isPositive: _north,
                            onHemisphereChanged: (value) => setState(() {
                              _north = value;
                              _invalid = const {};
                              _isEmptyError = false;
                            }),
                          ),
                          const SizedBox(height: 16),
                          _CoordinateCard(
                            title: strings.longitude,
                            fields: const [
                              ManualField.lonDeg,
                              ManualField.lonMin,
                              ManualField.lonSec,
                            ],
                            controllers: _controllers,
                            invalid: _invalid,
                            onChanged: _clearError,
                            positive: ('E', strings.east),
                            negative: ('W', strings.west),
                            isPositive: _east,
                            onHemisphereChanged: (value) => setState(() {
                              _east = value;
                              _invalid = const {};
                              _isEmptyError = false;
                            }),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        metrics.pageMargin,
                        16,
                        metrics.pageMargin,
                        28,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_invalid.isNotEmpty || _isEmptyError) ...[
                            _ErrorBox(
                              _isEmptyError
                                  ? strings.emptyCoords
                                  : strings.invalidCoords,
                            ),
                            const SizedBox(height: 14),
                          ],
                          PrimaryButton(
                            label: strings.view,
                            onPressed: _openResult,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.warningSurface,
          border: Border.all(color: AppColors.warningBoxBorder),
          borderRadius: const BorderRadius.all(Radius.circular(18)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 1),
              child: Icon(
                CupertinoIcons.exclamationmark_triangle,
                size: 20,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: appText(
                  size: 14,
                  weight: 500,
                  color: AppColors.warning,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoordinateCard extends StatelessWidget {
  const _CoordinateCard({
    required this.title,
    required this.fields,
    required this.controllers,
    required this.invalid,
    required this.onChanged,
    required this.positive,
    required this.negative,
    required this.isPositive,
    required this.onHemisphereChanged,
  });

  final String title;

  /// Ba ô theo thứ tự độ, phút, giây.
  final List<ManualField> fields;
  final Map<ManualField, TextEditingController> controllers;
  final Set<ManualField> invalid;
  final VoidCallback onChanged;
  final (String, String) positive;
  final (String, String) negative;
  final bool isPositive;
  final ValueChanged<bool> onHemisphereChanged;

  @override
  Widget build(BuildContext context) {
    final strings = LanguageScope.of(context).strings;
    final units = [
      ('°', strings.degrees, 3),
      ("'", strings.minutes, 2),
      ('"', strings.seconds, 2),
    ];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: const BorderRadius.all(Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title, style: appText(size: 17, weight: 700)),
              ),
              // Nút "Tiếp" trên bàn phím phải sang ô số kế tiếp, không dừng ở đây.
              ExcludeFocusTraversal(
                child: _HemisphereSwitch(
                  positive: positive,
                  negative: negative,
                  isPositive: isPositive,
                  onChanged: onHemisphereChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var index = 0; index < 3; index++) ...[
                if (index > 0) const SizedBox(width: 8),
                Expanded(
                  child: _NumberField(
                    controller: controllers[fields[index]]!,
                    unit: units[index].$1,
                    label: units[index].$2,
                    maxLength: units[index].$3,
                    spokenLabel: '$title, ${units[index].$2}',
                    invalidLabel: strings.invalidField,
                    hasError: invalid.contains(fields[index]),
                    onChanged: onChanged,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _HemisphereSwitch extends StatelessWidget {
  const _HemisphereSwitch({
    required this.positive,
    required this.negative,
    required this.isPositive,
    required this.onChanged,
  });

  final (String, String) positive;
  final (String, String) negative;
  final bool isPositive;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const ShapeDecoration(
        color: AppColors.field,
        shape: StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _HemisphereOption(
            option: positive,
            selected: isPositive,
            onPressed: () => onChanged(true),
          ),
          const SizedBox(width: 4),
          _HemisphereOption(
            option: negative,
            selected: !isPositive,
            onPressed: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}

class _HemisphereOption extends StatelessWidget {
  const _HemisphereOption({
    required this.option,
    required this.selected,
    required this.onPressed,
  });

  final (String, String) option;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: const Size(52, 44),
        pressedOpacity: 0.7,
        onPressed: onPressed,
        child: Container(
          width: 52,
          height: 44,
          alignment: Alignment.center,
          decoration: ShapeDecoration(
            color: selected ? AppColors.text : null,
            shape: const StadiumBorder(),
          ),
          child: Text(
            option.$1,
            semanticsLabel: option.$2,
            textScaler: TextScaler.noScaling,
            style: appText(
              size: 15,
              weight: selected ? 800 : 700,
              color: selected ? AppColors.screen : AppColors.label,
            ),
          ),
        ),
      ),
    );
  }
}

class _NumberField extends StatefulWidget {
  const _NumberField({
    required this.controller,
    required this.unit,
    required this.label,
    required this.maxLength,
    required this.spokenLabel,
    required this.invalidLabel,
    required this.hasError,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String unit;
  final String label;
  final int maxLength;
  final String spokenLabel;
  final String invalidLabel;
  final bool hasError;
  final VoidCallback onChanged;

  @override
  State<_NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<_NumberField> {
  static const _digitSize = 30.0;

  /// Lớn hơn nữa thì chiều cao chữ vượt ô cao 76.
  static const _maxDigitSize = 44.0;
  static const _padding = EdgeInsets.only(left: 6, right: 22);

  /// Chỗ cho con trỏ và viền ô.
  static const _caretRoom = 8.0;

  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() => setState(() {});

  /// Cỡ chữ theo cài đặt của máy nhưng luôn đủ chỗ cho 3 chữ số, vì ô nhập tràn
  /// thì tự cuộn và che mất số. Ba ô dùng chung một cỡ cho đều nhau.
  double _fittedDigitSize(BuildContext context, double fieldWidth) {
    final wanted = math.min(
      MediaQuery.textScalerOf(context).scale(_digitSize),
      _maxDigitSize,
    );
    final digits = TextPainter(
      text: TextSpan(
        text: '000',
        style: appText(size: _digitSize, weight: 700, tabular: true),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final widthAtDigitSize = digits.width;
    digits.dispose();
    final room = fieldWidth - _padding.horizontal - _caretRoom;
    return math.min(wanted, _digitSize * room / widthAtDigitSize);
  }

  Widget _buildField(double digitSize) {
    final hasError = widget.hasError;
    final borderColor = hasError
        ? AppColors.warningBorder
        : _focusNode.hasFocus
        ? AppColors.accent
        : const Color(0x00000000);

    return CupertinoTextField(
      controller: widget.controller,
      focusNode: _focusNode,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      textAlignVertical: TextAlignVertical.center,
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(widget.maxLength),
      ],
      onChanged: (_) => widget.onChanged(),
      placeholder: '0',
      placeholderStyle: appText(
        size: digitSize,
        weight: 700,
        color: AppColors.fieldHint,
        tabular: true,
      ),
      style: appText(
        size: digitSize,
        weight: 700,
        color: hasError ? AppColors.warning : AppColors.text,
        tabular: true,
      ),
      padding: _padding,
      decoration: BoxDecoration(
        color: hasError ? AppColors.warningSurface : AppColors.field,
        border: Border.all(color: borderColor, width: 1.5),
        borderRadius: const BorderRadius.all(Radius.circular(18)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.hasError;
    final accent = hasError ? AppColors.warning : AppColors.muted;

    return Column(
      children: [
        SizedBox(
          height: 76,
          child: LayoutBuilder(
            builder: (context, box) => Stack(
              children: [
                Positioned.fill(
                  child: Semantics(
                    label: hasError
                        ? '${widget.spokenLabel}, ${widget.invalidLabel}'
                        : widget.spokenLabel,
                    child: MediaQuery.withNoTextScaling(
                      child: _buildField(
                        _fittedDigitSize(context, box.maxWidth),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: ExcludeSemantics(
                    child: Text(
                      widget.unit,
                      textScaler: TextScaler.noScaling,
                      style: appText(size: 16, weight: 400, color: accent),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        ExcludeSemantics(
          child: Text(
            widget.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: appText(
              size: 12,
              weight: hasError ? 700 : 400,
              color: accent,
            ),
          ),
        ),
      ],
    );
  }
}
