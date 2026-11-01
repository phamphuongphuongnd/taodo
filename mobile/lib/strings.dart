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
    required this.permissionDisclosure,
    required this.allowLocation,
    required this.permissionDenied,
    required this.locationOff,
    required this.openSettings,
    required this.back,
    required this.conclusionTitle,
    required this.noMatches,
    required this.noData,
    required this.noConclusion,
    required this.and,
    required this.about,
    required this.version,
    required this.privacyTitle,
    required this.privacyBody,
    required this.noticeTitle,
    required this.noticeBody,
    required this.contactTitle,
    required this.contactBody,
    required this.licenses,
    required this.spokenLatitude,
    required this.spokenLongitude,
    required this.degrees,
    required this.minutes,
    required this.seconds,
    required this.north,
    required this.south,
    required this.east,
    required this.west,
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
    permissionDisclosure:
        'Tọa Độ dùng vị trí chính xác của điện thoại để hiện kinh độ và vĩ độ. '
        'Vị trí chỉ được dùng khi app đang mở, chỉ xử lý trên điện thoại và '
        'không gửi đi đâu. Nếu không muốn cho phép, bạn vẫn dùng được Nhập tay.',
    allowLocation: 'Cho phép',
    permissionDenied: 'Chưa cấp quyền vị trí',
    locationOff: 'Định vị đang tắt',
    openSettings: 'Mở Cài đặt',
    back: 'Quay lại',
    conclusionTitle: 'Kết luận',
    noMatches: 'Tọa độ này không có số nào trong bảng',
    noData: 'Chưa có dữ liệu',
    noConclusion: 'Chưa có dữ liệu để kết luận',
    and: 'và',
    about: 'Thông tin',
    version: 'Phiên bản',
    privacyTitle: 'Quyền riêng tư',
    privacyBody:
        'Vị trí chỉ được dùng khi app đang mở để hiện tọa độ, chỉ xử lý trên '
        'điện thoại và không gửi đi đâu. App không có tài khoản, quảng cáo hay '
        'công cụ theo dõi, và không có quyền truy cập Internet. Dữ liệu duy '
        'nhất được lưu là ngôn ngữ bạn chọn, nằm trên điện thoại và mất đi khi '
        'gỡ app. Toàn văn chính sách:',
    noticeTitle: 'Lưu ý khi dùng',
    noticeBody:
        'Tọa độ có sai số, nhất là trong nhà hoặc khi tín hiệu yếu. Không dùng '
        'app để dẫn đường hay trong tình huống khẩn cấp.\n\n'
        'Nội dung Bảng số Thiên Cung chỉ mang tính tham khảo, không phải lời '
        'khuyên về tài chính, sức khỏe, pháp lý hay quyết định cá nhân.',
    contactTitle: 'Liên hệ và báo lỗi',
    contactBody:
        'Báo lỗi hoặc góp ý tại trang dưới đây. Lỗi bảo mật xin chỉ ghi vắn tắt '
        'và không đăng chi tiết công khai.',
    licenses: 'Giấy phép mã nguồn mở',
    spokenLatitude: 'Vĩ độ',
    spokenLongitude: 'kinh độ',
    degrees: 'độ',
    minutes: 'phút',
    seconds: 'giây',
    north: 'Bắc',
    south: 'Nam',
    east: 'Đông',
    west: 'Tây',
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
    permissionDisclosure:
        'Toa Do uses your phone\'s precise location to show your longitude and '
        'latitude. It is used only while the app is open, processed only on '
        'your phone and never sent anywhere. If you prefer not to allow it, '
        'you can still enter coordinates manually.',
    allowLocation: 'Allow',
    permissionDenied: 'Location permission not granted',
    locationOff: 'Location services are off',
    openSettings: 'Open Settings',
    back: 'Back',
    conclusionTitle: 'Conclusion',
    noMatches: 'These coordinates have no numbers in the table',
    noData: 'No data yet',
    noConclusion: 'Not enough data for a conclusion',
    and: 'and',
    about: 'About',
    version: 'Version',
    privacyTitle: 'Privacy',
    privacyBody:
        'Your location is used only while the app is open to show coordinates. '
        'It is processed only on your phone and never sent anywhere. The app '
        'has no accounts, ads or trackers, and no internet access. The only '
        'data stored is your chosen language, kept on your phone and removed '
        'when you uninstall the app. Full policy:',
    noticeTitle: 'Before you use it',
    noticeBody:
        'Coordinates are approximate, especially indoors or with a weak signal. '
        'Do not use this app for navigation or in an emergency.\n\n'
        'The Thien Cung number table is for reference only. It is not advice '
        'about money, health, legal matters or personal decisions.',
    contactTitle: 'Contact and bug reports',
    contactBody:
        'Report bugs or send feedback on the page below. For security issues, '
        'please keep the report brief and do not post details publicly.',
    licenses: 'Open source licenses',
    spokenLatitude: 'Latitude',
    spokenLongitude: 'longitude',
    degrees: 'degrees',
    minutes: 'minutes',
    seconds: 'seconds',
    north: 'North',
    south: 'South',
    east: 'East',
    west: 'West',
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
  final String permissionDisclosure;
  final String allowLocation;
  final String permissionDenied;
  final String locationOff;
  final String openSettings;
  final String back;
  final String conclusionTitle;
  final String noMatches;
  final String noData;
  final String noConclusion;
  final String and;
  final String about;
  final String version;
  final String privacyTitle;
  final String privacyBody;
  final String noticeTitle;
  final String noticeBody;
  final String contactTitle;
  final String contactBody;
  final String licenses;
  final String spokenLatitude;
  final String spokenLongitude;
  final String degrees;
  final String minutes;
  final String seconds;
  final String north;
  final String south;
  final String east;
  final String west;

  bool get _isVi => language == AppLanguage.vi;

  /// Câu đọc tọa độ cho trình đọc màn hình. Chuỗi không đúng dạng thì giữ nguyên.
  String spokenCoords(String coordsText) {
    final parts = RegExp(
      r'''(\d+)°(\d+)'(\d+)"([NSEW])''',
    ).allMatches(coordsText).toList();
    if (parts.length != 2) return coordsText;
    return '$spokenLatitude ${_spokenPart(parts[0])}, '
        '$spokenLongitude ${_spokenPart(parts[1])}';
  }

  String _spokenPart(RegExpMatch part) {
    final hemisphere = switch (part[4]) {
      'N' => north,
      'S' => south,
      'E' => east,
      _ => west,
    };
    return '${int.parse(part[1]!)} $degrees ${int.parse(part[2]!)} $minutes '
        '${int.parse(part[3]!)} $seconds $hemisphere';
  }

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
