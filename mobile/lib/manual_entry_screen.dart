import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'coords.dart';
import 'language_store.dart';
import 'result_screen.dart';

const _secondaryText = Color(0xFFAEAEB2);
const _warningText = Color(0xFFFF9F0A);
const _fieldBackground = Color(0xFF1C1C1E);

/// Nhập độ, phút, giây bằng tay rồi xem kết quả như tọa độ đo được.
class ManualEntryScreen extends StatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  final _latDeg = TextEditingController();
  final _latMin = TextEditingController();
  final _latSec = TextEditingController();
  final _lonDeg = TextEditingController();
  final _lonMin = TextEditingController();
  final _lonSec = TextEditingController();
  bool _north = true;
  bool _east = true;
  bool _invalid = false;

  @override
  void dispose() {
    _latDeg.dispose();
    _latMin.dispose();
    _latSec.dispose();
    _lonDeg.dispose();
    _lonMin.dispose();
    _lonSec.dispose();
    super.dispose();
  }

  /// Ô trống tính là 0.
  int _value(TextEditingController field) => int.tryParse(field.text) ?? 0;

  void _clearError() {
    if (_invalid) setState(() => _invalid = false);
  }

  void _openResult() {
    final coordsText = formatManualCoords(
      latDeg: _value(_latDeg),
      latMin: _value(_latMin),
      latSec: _value(_latSec),
      north: _north,
      lonDeg: _value(_lonDeg),
      lonMin: _value(_lonMin),
      lonSec: _value(_lonSec),
      east: _east,
    );
    if (coordsText == null) {
      setState(() => _invalid = true);
      return;
    }
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

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoNavigationBarBackButton(
          color: CupertinoColors.white,
          previousPageTitle: strings.back,
        ),
        middle: Text(
          strings.manualEntryTitle,
          style: const TextStyle(color: CupertinoColors.white),
        ),
        border: null,
        transitionBetweenRoutes: false,
      ),
      child: SafeArea(
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            _CoordinateFields(
              label: strings.latitude,
              degrees: _latDeg,
              minutes: _latMin,
              seconds: _latSec,
              onChanged: _clearError,
              positiveLabel: 'N',
              negativeLabel: 'S',
              isPositive: _north,
              onHemisphereChanged: (value) => setState(() {
                _north = value;
                _invalid = false;
              }),
            ),
            const SizedBox(height: 28),
            _CoordinateFields(
              label: strings.longitude,
              degrees: _lonDeg,
              minutes: _lonMin,
              seconds: _lonSec,
              onChanged: _clearError,
              positiveLabel: 'E',
              negativeLabel: 'W',
              isPositive: _east,
              onHemisphereChanged: (value) => setState(() {
                _east = value;
                _invalid = false;
              }),
            ),
            if (_invalid) ...[
              const SizedBox(height: 20),
              Text(
                strings.invalidCoords,
                style: const TextStyle(
                  color: _warningText,
                  fontSize: 15,
                  height: 1.35,
                ),
              ),
            ],
            const SizedBox(height: 28),
            CupertinoButton(
              color: CupertinoColors.white,
              foregroundColor: const Color(0xFF000000),
              onPressed: _openResult,
              child: Text(
                strings.view,
                style: const TextStyle(
                  color: Color(0xFF000000),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoordinateFields extends StatelessWidget {
  const _CoordinateFields({
    required this.label,
    required this.degrees,
    required this.minutes,
    required this.seconds,
    required this.onChanged,
    required this.positiveLabel,
    required this.negativeLabel,
    required this.isPositive,
    required this.onHemisphereChanged,
  });

  final String label;
  final TextEditingController degrees;
  final TextEditingController minutes;
  final TextEditingController seconds;
  final VoidCallback onChanged;
  final String positiveLabel;
  final String negativeLabel;
  final bool isPositive;
  final ValueChanged<bool> onHemisphereChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: _secondaryText, fontSize: 15),
              ),
            ),
            CupertinoSlidingSegmentedControl<bool>(
              groupValue: isPositive,
              onValueChanged: (value) {
                if (value != null) onHemisphereChanged(value);
              },
              children: {
                true: Text(positiveLabel),
                false: Text(negativeLabel),
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _NumberField(
                controller: degrees,
                maxLength: 3,
                unit: '°',
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _NumberField(
                controller: minutes,
                maxLength: 2,
                unit: "'",
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _NumberField(
                controller: seconds,
                maxLength: 2,
                unit: '"',
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.maxLength,
    required this.unit,
    required this.onChanged,
  });

  final TextEditingController controller;
  final int maxLength;
  final String unit;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(maxLength),
      ],
      onChanged: (_) => onChanged(),
      placeholder: '0',
      placeholderStyle: const TextStyle(color: _secondaryText, fontSize: 22),
      style: const TextStyle(
        color: CupertinoColors.white,
        fontSize: 22,
        fontFeatures: [FontFeature.tabularFigures()],
      ),
      suffix: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Text(
          unit,
          style: const TextStyle(color: _secondaryText, fontSize: 20),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: const BoxDecoration(
        color: _fieldBackground,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
    );
  }
}
