import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'strings.dart';

/// Lưu ngôn ngữ người dùng đã chọn.
abstract class LanguageStore {
  /// Lựa chọn đã lưu, hoặc `null` nếu người dùng chưa chọn lần nào.
  Future<AppLanguage?> load();

  Future<void> save(AppLanguage language);
}

class SharedPreferencesLanguageStore implements LanguageStore {
  static const _key = 'language';

  @override
  Future<AppLanguage?> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AppLanguage.values.asNameMap()[prefs.getString(_key)];
  }

  @override
  Future<void> save(AppLanguage language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, language.name);
  }
}

/// Đưa ngôn ngữ hiện tại xuống cả hai màn hình, đổi là áp dụng ngay.
class LanguageScope extends InheritedWidget {
  const LanguageScope({
    super.key,
    required this.language,
    required this.onChanged,
    required super.child,
  });

  final AppLanguage language;
  final ValueChanged<AppLanguage> onChanged;

  static LanguageScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<LanguageScope>()!;

  AppStrings get strings => AppStrings.of(language);

  @override
  bool updateShouldNotify(LanguageScope oldWidget) =>
      language != oldWidget.language || onChanged != oldWidget.onChanged;
}
