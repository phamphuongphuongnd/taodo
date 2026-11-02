import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart'
    show LicenseEntryWithLineBreaks, LicenseRegistry;
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'language_store.dart';
import 'location_screen.dart';
import 'location_service.dart';
import 'strings.dart';
import 'theme.dart';

void main() {
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks(const [
      'Manrope',
    ], await rootBundle.loadString('assets/fonts/OFL.txt'));
  });
  runApp(
    ToaDoApp(
      locationService: GeolocatorLocationService(),
      languageStore: SharedPreferencesLanguageStore(),
    ),
  );
}

class ToaDoApp extends StatefulWidget {
  const ToaDoApp({
    super.key,
    required this.locationService,
    required this.languageStore,
    this.deviceLocale,
  });

  final LocationService locationService;
  final LanguageStore languageStore;

  /// Mặc định lấy ngôn ngữ của điện thoại.
  final Locale? deviceLocale;

  @override
  State<ToaDoApp> createState() => _ToaDoAppState();
}

class _ToaDoAppState extends State<ToaDoApp> with WidgetsBindingObserver {
  /// `null` khi chưa đọc xong lựa chọn đã lưu.
  AppLanguage? _language;

  /// Người dùng chưa chọn ngôn ngữ thì đi theo ngôn ngữ máy.
  bool _followsDevice = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_loadLanguage());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(widget.locationService.dispose());
    super.dispose();
  }

  // Lúc app khởi động, nền tảng có thể chưa báo ngôn ngữ thật của máy.
  @override
  void didChangeLocales(List<Locale>? locales) {
    if (!_followsDevice || widget.deviceLocale != null) return;
    if (locales == null || locales.isEmpty) return;
    setState(() => _language = defaultLanguage(locales.first));
  }

  Future<void> _loadLanguage() async {
    AppLanguage? saved;
    try {
      saved = await widget.languageStore.load();
    } catch (_) {
      // Không đọc được thì coi như chưa chọn, app vẫn chạy theo ngôn ngữ máy.
    }
    if (!mounted) return;
    final device = widget.deviceLocale ?? PlatformDispatcher.instance.locale;
    _followsDevice = saved == null;
    setState(() => _language = saved ?? defaultLanguage(device));
  }

  void _changeLanguage(AppLanguage language) {
    _followsDevice = false;
    setState(() => _language = language);
    unawaited(_saveLanguage(language));
  }

  Future<void> _saveLanguage(AppLanguage language) async {
    try {
      await widget.languageStore.save(language);
    } catch (_) {
      // Không lưu được thì lựa chọn vẫn có hiệu lực tới khi đóng app.
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = _language;
    if (language == null) {
      return const ColoredBox(color: AppColors.screen);
    }
    return LanguageScope(
      language: language,
      onChanged: _changeLanguage,
      child: CupertinoApp(
        title: 'Tọa Độ',
        debugShowCheckedModeBanner: false,
        color: AppColors.screen,
        // Locale này cho nhãn hệ thống (menu chọn chữ, trang giấy phép), đi theo
        // ngôn ngữ app. Tên enum trùng mã ngôn ngữ. Chữ của app đi qua
        // LanguageScope.
        locale: Locale(language.name),
        supportedLocales: [
          for (final supported in AppLanguage.values) Locale(supported.name),
        ],
        // Gồm cả bộ nhãn Material vì trang giấy phép và SelectionArea cần nó.
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        theme: CupertinoThemeData(
          brightness: Brightness.dark,
          primaryColor: AppColors.text,
          scaffoldBackgroundColor: AppColors.screen,
          barBackgroundColor: AppColors.screen,
          textTheme: CupertinoTextThemeData(
            textStyle: appText(size: 16, weight: 400),
          ),
        ),
        builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: child!,
        ),
        home: LocationScreen(locationService: widget.locationService),
      ),
    );
  }
}
