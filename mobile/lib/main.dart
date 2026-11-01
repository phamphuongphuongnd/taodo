import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show DefaultMaterialLocalizations;
import 'package:flutter/services.dart';

import 'language_store.dart';
import 'location_screen.dart';
import 'location_service.dart';
import 'strings.dart';

void main() {
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

class _ToaDoAppState extends State<ToaDoApp> {
  /// `null` khi chưa đọc xong lựa chọn đã lưu.
  AppLanguage? _language;

  @override
  void initState() {
    super.initState();
    unawaited(_loadLanguage());
  }

  @override
  void dispose() {
    unawaited(widget.locationService.dispose());
    super.dispose();
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
    setState(() => _language = saved ?? defaultLanguage(device));
  }

  void _changeLanguage(AppLanguage language) {
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
      return const ColoredBox(color: Color(0xFF000000));
    }
    return LanguageScope(
      language: language,
      onChanged: _changeLanguage,
      child: CupertinoApp(
        title: 'Tọa Độ',
        debugShowCheckedModeBanner: false,
        color: const Color(0xFF000000),
        // Locale này chỉ dành cho nhãn có sẵn của Cupertino, vốn chỉ có tiếng
        // Anh. Chữ của app đi qua LanguageScope.
        locale: const Locale('en'),
        // Trang giấy phép là widget Material nên cần thêm bộ nhãn Material.
        localizationsDelegates: const [
          DefaultMaterialLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        theme: const CupertinoThemeData(
          brightness: Brightness.dark,
          primaryColor: CupertinoColors.white,
          scaffoldBackgroundColor: Color(0xFF000000),
          barBackgroundColor: Color(0xFF000000),
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
