import 'dart:async';

import 'package:flutter/cupertino.dart';

import 'coords.dart';
import 'language_store.dart';
import 'location_service.dart';
import 'manual_entry_screen.dart';
import 'result_screen.dart';
import 'strings.dart';

const _secondaryText = Color(0xFF8E8E93);
const _disabledBackground = Color(0xFF2C2C2E);

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key, required this.locationService});

  final LocationService locationService;

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen>
    with WidgetsBindingObserver {
  LocationState _state = const LocationWaiting();
  late final StreamSubscription<LocationState> _subscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _subscription = widget.locationService.states.listen((state) {
      if (mounted) setState(() => _state = state);
    });
    unawaited(widget.locationService.refresh());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_subscription.cancel());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        unawaited(widget.locationService.refresh());
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        unawaited(widget.locationService.pause());
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }

  void _openResult(String coordsText) {
    unawaited(
      Navigator.of(context).push(
        CupertinoPageRoute<void>(
          builder: (_) => ResultScreen(coordsText: coordsText),
        ),
      ),
    );
  }

  void _openManualEntry() {
    unawaited(
      Navigator.of(context).push(
        CupertinoPageRoute<void>(builder: (_) => const ManualEntryScreen()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scope = LanguageScope.of(context);
    final strings = scope.strings;
    final state = _state;
    final coordsText = switch (state) {
      LocationAvailable(:final latitude, :final longitude) => formatDmsCoords(
        latitude,
        longitude,
      ),
      _ => null,
    };

    return CupertinoPageScaffold(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: _LanguageButton(scope: scope),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: coordsText != null
                      ? _CoordsText(coordsText)
                      : _StatusMessage(
                          state: state,
                          strings: strings,
                          service: widget.locationService,
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              child: CupertinoButton(
                color: CupertinoColors.white,
                foregroundColor: const Color(0xFF000000),
                disabledColor: _disabledBackground,
                onPressed: coordsText == null
                    ? null
                    : () => _openResult(coordsText),
                child: Text(
                  strings.view,
                  style: TextStyle(
                    color: coordsText == null
                        ? _secondaryText
                        : const Color(0xFF000000),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: CupertinoButton(
                onPressed: _openManualEntry,
                child: Text(
                  strings.manualEntry,
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 17,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  const _LanguageButton({required this.scope});

  final LanguageScope scope;

  @override
  Widget build(BuildContext context) {
    final strings = scope.strings;
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      minimumSize: const Size.square(44),
      onPressed: () => scope.onChanged(switch (strings.language) {
        AppLanguage.vi => AppLanguage.en,
        AppLanguage.en => AppLanguage.vi,
      }),
      child: Text(
        strings.otherLanguageName,
        style: const TextStyle(color: _secondaryText, fontSize: 14),
      ),
    );
  }
}

class _CoordsText extends StatelessWidget {
  const _CoordsText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        text,
        maxLines: 1,
        softWrap: false,
        style: const TextStyle(
          color: CupertinoColors.white,
          fontSize: 44,
          fontWeight: FontWeight.w600,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({
    required this.state,
    required this.strings,
    required this.service,
  });

  final LocationState state;
  final AppStrings strings;
  final LocationService service;

  @override
  Widget build(BuildContext context) {
    final (message, openSettings) = switch (state) {
      LocationPermissionDenied() => (
        strings.permissionDenied,
        service.openAppSettings,
      ),
      LocationServiceDisabled() => (
        strings.locationOff,
        service.openLocationSettings,
      ),
      _ => (strings.waitingForGps, null),
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: _secondaryText, fontSize: 17),
        ),
        if (openSettings != null)
          CupertinoButton(
            onPressed: openSettings,
            child: Text(
              strings.openSettings,
              style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 17,
              ),
            ),
          ),
      ],
    );
  }
}
