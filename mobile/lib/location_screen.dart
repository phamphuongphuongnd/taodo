import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

import 'about_screen.dart';
import 'coords.dart';
import 'language_store.dart';
import 'location_service.dart';
import 'manual_entry_screen.dart';
import 'result_screen.dart';
import 'strings.dart';
import 'theme.dart';
import 'widgets.dart';

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

  void _openAbout() {
    unawaited(
      Navigator.of(context)
          .push(CupertinoPageRoute<void>(builder: (_) => const AboutScreen())),
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
    final metrics = AppMetrics.of(context);
    final state = _state;
    final coordsText = switch (state) {
      LocationAvailable(:final latitude, :final longitude) => formatDmsCoords(
        latitude,
        longitude,
      ),
      _ => null,
    };

    return CupertinoPageScaffold(
      backgroundColor: AppColors.screen,
      child: Stack(
        children: [
          Positioned.fill(child: _Rings(pulsing: state is LocationWaiting)),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TopBar(scope: scope, onAbout: _openAbout),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: metrics.homeMargin,
                      ),
                      child: coordsText != null
                          ? _Measuring(coordsText, strings: strings)
                          : _Status(
                              state: state,
                              strings: strings,
                              service: widget.locationService,
                            ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    metrics.homeMargin,
                    8,
                    metrics.homeMargin,
                    28,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PrimaryButton(
                        label: strings.view,
                        onPressed: coordsText == null
                            ? null
                            : () => _openResult(coordsText),
                      ),
                      const SizedBox(height: 10),
                      SecondaryButton(
                        label: strings.manualEntry,
                        icon: CupertinoIcons.pencil,
                        onPressed: _openManualEntry,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.scope, required this.onAbout});

  final LanguageScope scope;
  final VoidCallback onAbout;

  @override
  Widget build(BuildContext context) {
    final strings = scope.strings;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppMetrics.of(context).homeMargin,
        14,
        16,
        0,
      ),
      child: Row(
        children: [
          const Icon(CupertinoIcons.compass, size: 24, color: AppColors.text),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Tọa Độ',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: appText(size: 18, weight: 800, letterSpacing: -0.18),
            ),
          ),
          CircleIconButton(
            key: const ValueKey('about-button'),
            icon: CupertinoIcons.info,
            spokenLabel: strings.about,
            onPressed: onAbout,
          ),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.42,
            ),
            child: LanguagePill(
              label: strings.otherLanguageName,
              spokenLabel: strings.changeLanguage,
              onPressed: () => scope.onChanged(switch (strings.language) {
                AppLanguage.vi => AppLanguage.en,
                AppLanguage.en => AppLanguage.vi,
              }),
            ),
          ),
        ],
      ),
    );
  }
}

/// Vòng tròn trang trí; khi chờ GPS có thêm vòng sóng xanh.
class _Rings extends StatelessWidget {
  const _Rings({required this.pulsing});

  final bool pulsing;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: pulsing
          ? LoopingBuilder(
              period: const Duration(milliseconds: 2800),
              restValue: 0,
              builder: (context, value) =>
                  CustomPaint(painter: _RingsPainter(wave: value)),
            )
          : CustomPaint(painter: _RingsPainter()),
    );
  }
}

class _RingsPainter extends CustomPainter {
  const _RingsPainter({this.wave});

  final double? wave;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.485);
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..color = AppColors.ring;
    for (final radius in const [80.0, 150.0, 220.0, 290.0]) {
      canvas.drawCircle(center, radius, ring);
    }
    final progress = wave;
    if (progress == null || progress == 0) return;
    for (final phase in [progress, (progress + 0.5) % 1]) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = AppColors.accent.withValues(
          alpha: math.max(0, 0.7 * (1 - phase)),
        );
      canvas.drawCircle(center, 150 * (0.55 + 0.95 * phase), paint);
    }
  }

  @override
  bool shouldRepaint(_RingsPainter oldDelegate) => oldDelegate.wave != wave;
}

class _Measuring extends StatelessWidget {
  const _Measuring(this.coordsText, {required this.strings});

  final String coordsText;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const ExcludeSemantics(child: _PingDot()),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                strings.gpsMeasuring,
                style: appText(
                  size: 13,
                  weight: 700,
                  color: AppColors.accent,
                  letterSpacing: 0.78,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        CoordsDisplay(
          coordsText: coordsText,
          fontSize: AppMetrics.of(context).homeCoordsSize,
        ),
        const SizedBox(height: 30),
        Text(
          strings.liveOffline,
          style: appText(size: 13, weight: 400, color: AppColors.muted),
        ),
      ],
    );
  }
}

class _PingDot extends StatelessWidget {
  const _PingDot();

  @override
  Widget build(BuildContext context) {
    const dot = DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.accent,
        shape: BoxShape.circle,
      ),
    );
    return SizedBox.square(
      dimension: 8,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned.fill(child: dot),
          Positioned.fill(
            child: LoopingBuilder(
              period: const Duration(milliseconds: 1800),
              builder: (context, value) => Opacity(
                opacity: 0.6 * (1 - value),
                child: Transform.scale(scale: 1 + 2 * value, child: dot),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Status extends StatelessWidget {
  const _Status({
    required this.state,
    required this.strings,
    required this.service,
  });

  final LocationState state;
  final AppStrings strings;
  final LocationService service;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      LocationPermissionNeeded() => _Blocked(
        icon: CupertinoIcons.location,
        message: strings.permissionDisclosure,
        isLongMessage: true,
        action: strings.allowLocation,
        actionIcon: CupertinoIcons.checkmark,
        onAction: service.requestPermission,
      ),
      LocationPermissionDenied() => _Blocked(
        icon: CupertinoIcons.location_slash,
        message: strings.permissionDenied,
        action: strings.openSettings,
        actionIcon: CupertinoIcons.gear_alt,
        onAction: service.openAppSettings,
      ),
      LocationServiceDisabled() => _Blocked(
        icon: CupertinoIcons.scope,
        message: strings.locationOff,
        action: strings.openSettings,
        actionIcon: CupertinoIcons.gear_alt,
        onAction: service.openLocationSettings,
      ),
      _ => _Waiting(strings: strings),
    };
  }
}

class _Blocked extends StatelessWidget {
  const _Blocked({
    required this.icon,
    required this.message,
    required this.action,
    required this.actionIcon,
    required this.onAction,
    this.isLongMessage = false,
  });

  final IconData icon;
  final String message;
  final String action;
  final IconData actionIcon;
  final VoidCallback onAction;
  final bool isLongMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: AppColors.card,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.outline),
          ),
          child: Icon(icon, size: 38, color: AppColors.pillText),
        ),
        const SizedBox(height: 26),
        Text(
          message,
          textAlign: TextAlign.center,
          style: isLongMessage
              ? appText(
                  size: 16,
                  weight: 500,
                  color: AppColors.meaning,
                  height: 1.45,
                )
              : appText(size: 22, weight: 700, letterSpacing: -0.22),
        ),
        const SizedBox(height: 26),
        ActionButton(label: action, icon: actionIcon, onPressed: onAction),
      ],
    );
  }
}

class _Waiting extends StatelessWidget {
  const _Waiting({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final dashes = appText(
      size: 38,
      weight: 700,
      color: AppColors.outline,
      letterSpacing: -0.76,
      height: 1,
      tabular: true,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.accentSurface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.accentBorder),
          ),
          child: const Icon(
            CupertinoIcons.location,
            size: 30,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(height: 22),
        Text(
          strings.waitingForGps,
          textAlign: TextAlign.center,
          style: appText(size: 20, weight: 700, letterSpacing: -0.2),
        ),
        const SizedBox(height: 10),
        const ExcludeSemantics(child: _BlinkingDots()),
        const SizedBox(height: 32),
        ExcludeSemantics(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              children: [
                Text('––°––\'––"N', maxLines: 1, style: dashes),
                const SizedBox(height: 10),
                Text('–––°––\'––"E', maxLines: 1, style: dashes),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BlinkingDots extends StatelessWidget {
  const _BlinkingDots();

  @override
  Widget build(BuildContext context) {
    return LoopingBuilder(
      period: const Duration(milliseconds: 1400),
      restValue: 0.4,
      builder: (context, value) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < 3; index++)
            Padding(
              padding: EdgeInsets.only(left: index == 0 ? 0 : 7),
              child: Opacity(
                opacity: _blink(value - index * 0.14),
                child: const SizedBox.square(
                  dimension: 7,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Sáng dần tới 40% chu kỳ rồi tắt dần tới 80%.
  double _blink(double value) {
    final t = value % 1;
    if (t >= 0.8) return 0.25;
    final distance = (t - 0.4).abs() / 0.4;
    return 1 - 0.75 * distance;
  }
}
