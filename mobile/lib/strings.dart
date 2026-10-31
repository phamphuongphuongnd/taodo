import 'dart:ui' show Locale;

import 'thien_cung.dart';
import 'thien_cung_data.dart';

enum AppLanguage { vi, en }

/// Máy tiếng Việt ra tiếng Việt, ngôn ngữ khác ra tiếng Anh.
AppLanguage defaultLanguage(Locale deviceLocale) =>
    deviceLocale.languageCode == 'vi' ? AppLanguage.vi : AppLanguage.en;

/// Mọi chữ giao diện theo một ngôn ngữ.
class AppStrings {
  const AppStrings._({
    required this.language,
    required this.otherLanguageName,
    required this.view,
    required this.manualEntry,
    required this.manualEntryTitle,
    required this.latitude,
    required this.longitude,
    required this.invalidCoords,
    required this.waitingForGps,
    required this.permissionDenied,
    required this.locationOff,
    required this.openSettings,
    required this.back,
    required this.conclusionTitle,
    required this.noMatches,
    required this.noData,
    required this.noConclusion,
    required this.and,
  });

  factory AppStrings.of(AppLanguage language) => switch (language) {
    AppLanguage.vi => _vi,
    AppLanguage.en => _en,
  };

  static const AppStrings _vi = AppStrings._(
    language: AppLanguage.vi,
    otherLanguageName: 'English',
    view: 'Xem',
    manualEntry: 'Nhập tay',
    manualEntryTitle: 'Nhập tọa độ',
    latitude: 'Vĩ độ',
    longitude: 'Kinh độ',
    invalidCoords:
        'Tọa độ không hợp lệ. Phút và giây phải dưới 60, vĩ độ tối đa 90°, '
        'kinh độ tối đa 180°.',
    waitingForGps: 'Đang chờ tín hiệu GPS…',
    permissionDenied: 'Chưa cấp quyền vị trí',
    locationOff: 'Định vị đang tắt',
    openSettings: 'Mở Cài đặt',
    back: 'Quay lại',
    conclusionTitle: 'Kết luận',
    noMatches: 'Tọa độ này không có số nào trong bảng',
    noData: 'Chưa có dữ liệu',
    noConclusion: 'Chưa có dữ liệu để kết luận',
    and: 'và',
  );

  static const AppStrings _en = AppStrings._(
    language: AppLanguage.en,
    otherLanguageName: 'Tiếng Việt',
    view: 'View',
    manualEntry: 'Enter manually',
    manualEntryTitle: 'Enter coordinates',
    latitude: 'Latitude',
    longitude: 'Longitude',
    invalidCoords:
        'Invalid coordinates. Minutes and seconds must be under 60, latitude '
        'at most 90°, longitude at most 180°.',
    waitingForGps: 'Waiting for GPS signal…',
    permissionDenied: 'Location permission not granted',
    locationOff: 'Location services are off',
    openSettings: 'Open Settings',
    back: 'Back',
    conclusionTitle: 'Conclusion',
    noMatches: 'These coordinates have no numbers in the table',
    noData: 'No data yet',
    noConclusion: 'Not enough data for a conclusion',
    and: 'and',
  );

  final AppLanguage language;

  /// Tên ngôn ngữ còn lại, hiện trên nút chuyển ngôn ngữ.
  final String otherLanguageName;
  final String view;
  final String manualEntry;
  final String manualEntryTitle;
  final String latitude;
  final String longitude;
  final String invalidCoords;
  final String waitingForGps;
  final String permissionDenied;
  final String locationOff;
  final String openSettings;
  final String back;
  final String conclusionTitle;
  final String noMatches;
  final String noData;
  final String noConclusion;
  final String and;

  bool get _isVi => language == AppLanguage.vi;

  /// Ghép `a, b và c` hoặc `a, b and c`.
  String joinList(List<String> items) {
    if (items.length < 2) return items.join();
    final head = items.sublist(0, items.length - 1).join(', ');
    return '$head $and ${items.last}';
  }

  String palaceName(ThienCungGroup row) => _isVi ? row.palaceVi : row.palaceEn;

  String? groupName(ThienCungGroup row) => _isVi ? row.groupVi : row.groupEn;

  String meaning(ThienCungGroup row) {
    if (!row.hasMeaning) return noData;
    return _isVi ? row.meaningVi : row.meaningEn;
  }

  /// Tên một dòng trong bảng: `Cung (Nhóm)`, hoặc `Cung` nếu không có nhóm.
  String rowLabel(ThienCungGroup row) => _withGroups(palaceName(row), [row]);

  String _tallyLabel(PalaceTally tally) =>
      _withGroups(palaceName(tally.palace), tally.groups);

  String _withGroups(String palace, List<ThienCungGroup> rows) {
    final groups = rows.map(groupName).whereType<String>().toSet().toList();
    return groups.isEmpty ? palace : '$palace (${joinList(groups)})';
  }

  /// Câu chính của Kết luận. Các cung trong `top` có cùng số lần.
  String conclusionSentence(Conclusion conclusion) {
    final top = conclusion.top;
    final palaces = joinList(top.map(_tallyLabel).toList());
    final count = top.first.count;
    final each = top.length > 1;
    if (_isVi) {
      final times = each ? 'mỗi cung $count lần' : '$count lần';
      return 'Vị trí này nổi bật về $palaces, $times.';
    }
    final unit = count == 1 ? 'time' : 'times';
    final times = each ? '$count $unit each' : '$count $unit';
    return 'This location stands out for $palaces, $times.';
  }

  /// Câu lưu ý, nêu tên từng dòng trong `warnings`.
  String warningSentence(Conclusion conclusion) {
    final rows = joinList(conclusion.warnings.map(rowLabel).toList());
    return _isVi
        ? 'Lưu ý: vị trí này có $rows.'
        : 'Note: this location includes $rows.';
  }
}
