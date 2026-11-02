// Kiểm thử hộp trắng (nhị phân) cho lib/strings.dart.
// Bộ dữ liệu: test-output/whitebox/ngon-ngu/strings/buoc-5-du-lieu-thu.md
// Expected chép từ Bước 5. Chuỗi đánh dấu (*) là câu chữ yêu cầu chưa nêu, cần xác nhận.
import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:toado/strings.dart';
import 'package:toado/thien_cung.dart';
import 'package:toado/thien_cung_data.dart';

const _talentGreat = ThienCungGroup(
  palaceOrder: 0,
  palaceVi: 'Thiên Tài',
  palaceEn: 'Talent',
  groupVi: 'Đại tài',
  groupEn: 'Great',
  numbers: ['13'],
  meaningVi: 'nghĩa vi',
  meaningEn: 'meaning en',
);

const _talentMid = ThienCungGroup(
  palaceOrder: 0,
  palaceVi: 'Thiên Tài',
  palaceEn: 'Talent',
  groupVi: 'Trung tài',
  groupEn: 'Mid',
  numbers: ['68'],
  meaningVi: 'nghĩa vi',
  meaningEn: 'meaning en',
);

const _talentMinor = ThienCungGroup(
  palaceOrder: 0,
  palaceVi: 'Thiên Tài',
  palaceEn: 'Talent',
  groupVi: 'Tiểu tài',
  groupEn: 'Minor',
  numbers: ['27'],
  meaningVi: 'nghĩa vi',
  meaningEn: 'meaning en',
);

const _career = ThienCungGroup(
  palaceOrder: 1,
  palaceVi: 'Quan Lộc',
  palaceEn: 'Career',
  groupVi: 'Đại quan',
  groupEn: 'High Office',
  numbers: ['19'],
  meaningVi: 'nghĩa vi',
  meaningEn: 'meaning en',
);

const _noGroup = ThienCungGroup(
  palaceOrder: 10,
  palaceVi: 'Tai Họa',
  palaceEn: 'Misfortune',
  numbers: ['23'],
  meaningVi: 'nghĩa vi',
  meaningEn: 'meaning en',
  isWarning: true,
);

const _emptyRow = ThienCungGroup(
  palaceOrder: 2,
  palaceVi: 'Cần Cù',
  palaceEn: 'Diligence',
  numbers: ['12'],
  meaningVi: '',
  meaningEn: '',
);

const _romanceWarn = ThienCungGroup(
  palaceOrder: 5,
  palaceVi: 'Đào Hoa',
  palaceEn: 'Romance',
  groupVi: 'Tai họa',
  groupEn: 'Misfortune',
  numbers: ['16'],
  meaningVi: 'nghĩa vi',
  meaningEn: 'meaning en',
  isWarning: true,
);

Conclusion _conclusion(
  List<PalaceTally> top, [
  List<ThienCungGroup> warnings = const [],
  List<PalaceTally>? all,
]) => Conclusion(top: top, warnings: warnings, all: all ?? top);

void main() {
  final vi = AppStrings.of(AppLanguage.vi);
  final en = AppStrings.of(AppLanguage.en);

  group('U1 defaultLanguage', () {
    test('6-1 máy tiếng Việt ⇒ vi (n1 Đ)', () {
      expect(defaultLanguage(const Locale('vi', 'VN')), AppLanguage.vi);
    });
    test('6-2 máy ngôn ngữ khác ⇒ en (n1 S)', () {
      expect(defaultLanguage(const Locale('ja')), AppLanguage.en);
    });
  });

  group('U2 AppStrings.of', () {
    test('6-3 vi ⇒ bộ chữ tiếng Việt (n1 Đ)', () {
      final s = AppStrings.of(AppLanguage.vi);
      expect(s.language, AppLanguage.vi);
      expect(s.otherLanguageName, 'English');
    });
    test('6-4 en ⇒ bộ chữ tiếng Anh (n1 S)', () {
      final s = AppStrings.of(AppLanguage.en);
      expect(s.language, AppLanguage.en);
      expect(s.otherLanguageName, 'Tiếng Việt');
    });
  });

  group('U3 spokenCoords', () {
    test('6-5 chuỗi không đúng dạng ⇒ giữ nguyên (n1 Đ)', () {
      expect(vi.spokenCoords('abc'), 'abc');
      expect(vi.spokenCoords('20°18\'08"N'), '20°18\'08"N');
    });
    test('6-6 đúng 2 cụm ⇒ đọc thành lời, tiếng Anh (n1 S) (*)', () {
      expect(
        en.spokenCoords('20°18\'08"N 105°48\'12"E'),
        'Latitude 20 degrees 18 minutes 8 seconds North, '
        'longitude 105 degrees 48 minutes 12 seconds East',
      );
    });
  });

  group('U4 _spokenPart (qua spokenCoords)', () {
    test('6-7 N ⇒ Bắc (n1 Đ)', () {
      // Nguồn: docs/compliance/bao-cao-tiep-can.md ("Vĩ độ 20 độ 18 phút 8 giây Bắc").
      expect(
        vi.spokenCoords('20°18\'08"N 105°48\'12"E'),
        startsWith('Vĩ độ 20 độ 18 phút 8 giây Bắc'),
      );
    });
    test('6-8 S ⇒ Nam (n1 S, n2 Đ)', () {
      expect(
        vi.spokenCoords('10°00\'05"S 20°30\'00"E'),
        startsWith('Vĩ độ 10 độ 0 phút 5 giây Nam'),
      );
    });
    test('6-9 E ⇒ Đông (n1 S, n2 S, n3 Đ)', () {
      expect(
        vi.spokenCoords('20°18\'08"N 105°48\'12"E'),
        endsWith('105 độ 48 phút 12 giây Đông'),
      );
    });
    test('6-10 W ⇒ Tây (n1 S, n2 S, n3 S)', () {
      expect(
        vi.spokenCoords('33°52\'04"S 151°12\'30"W'),
        endsWith('151 độ 12 phút 30 giây Tây'),
      );
    });
  });

  group('U5 rowCount', () {
    test('6-11 vi ⇒ "N dòng" (n1 Đ) (*)', () {
      expect(vi.rowCount(5), '5 dòng');
    });
    test('6-12 en, 1 ⇒ "1 row" (n1 S, n2 Đ) (*)', () {
      expect(en.rowCount(1), '1 row');
    });
    test('6-13 en, 3 ⇒ "3 rows" (n1 S, n2 S) (*)', () {
      expect(en.rowCount(3), '3 rows');
    });
  });

  group('U6 joinList', () {
    test('6-14 dưới 2 phần tử ⇒ nối trực tiếp (n1 Đ)', () {
      expect(vi.joinList(['a']), 'a');
      expect(vi.joinList([]), '');
    });
    test('6-15 từ 2 phần tử ⇒ "a, b và c" (n1 S) (*)', () {
      expect(vi.joinList(['a', 'b', 'c']), 'a, b và c');
      expect(en.joinList(['a', 'b', 'c']), 'a, b and c');
    });
  });

  group('U7 palaceName', () {
    test('6-16 vi ⇒ palaceVi (n1 Đ)', () {
      expect(vi.palaceName(_talentGreat), 'Thiên Tài');
    });
    test('6-17 en ⇒ palaceEn (n1 S)', () {
      expect(en.palaceName(_talentGreat), 'Talent');
    });
  });

  group('U8 groupName', () {
    test('6-18 vi ⇒ groupVi, không nhóm ⇒ null (n1 Đ)', () {
      expect(vi.groupName(_talentGreat), 'Đại tài');
      expect(vi.groupName(_noGroup), isNull);
    });
    test('6-19 en ⇒ groupEn, không nhóm ⇒ null (n1 S)', () {
      expect(en.groupName(_talentGreat), 'Great');
      expect(en.groupName(_noGroup), isNull);
    });
  });

  group('U9 meaning', () {
    test('6-20 dòng chưa có dữ liệu ⇒ chữ báo thiếu (n1 Đ)', () {
      // Nguồn: spec "Kết luận" mục 5 (tiếng Việt); bản Anh "No data yet" (*).
      expect(vi.meaning(_emptyRow), 'Chưa có dữ liệu');
      expect(en.meaning(_emptyRow), 'No data yet');
    });
    test('6-21 có dữ liệu, vi ⇒ meaningVi (n1 S, n2 Đ)', () {
      expect(vi.meaning(_talentGreat), 'nghĩa vi');
    });
    test('6-22 có dữ liệu, en ⇒ meaningEn (n1 S, n2 S)', () {
      expect(en.meaning(_talentGreat), 'meaning en');
    });
  });

  group('U10 rowLabel', () {
    test('6-23 "Cung (Nhóm)" theo ngôn ngữ (đường duy nhất) (*)', () {
      expect(vi.rowLabel(_romanceWarn), 'Đào Hoa (Tai họa)');
      expect(en.rowLabel(_romanceWarn), 'Romance (Misfortune)');
    });
  });

  group('U11 _tallyLabel (qua conclusionSentence)', () {
    test('6-24 nhãn cung lấy từ tally.palace + tally.groups (đường duy nhất) (*)', () {
      final c = _conclusion([
        const PalaceTally(groups: [_career], count: 1),
      ]);
      expect(vi.conclusionSentence(c), contains('Quan Lộc (Đại quan)'));
    });
  });

  group('U12 _withGroups (qua rowLabel / conclusionSentence)', () {
    test('6-25 không có nhóm ⇒ chỉ tên cung (n1 Đ)', () {
      expect(vi.rowLabel(_noGroup), 'Tai Họa');
      expect(en.rowLabel(_noGroup), 'Misfortune');
    });
    test('6-26 nhiều nhóm ⇒ nêu đủ, không lặp, theo thứ tự bảng (n1 S) (*)', () {
      final c = _conclusion([
        const PalaceTally(
          groups: [_talentMid, _talentMinor, _talentMid],
          count: 2,
        ),
      ]);
      expect(
        vi.conclusionSentence(c),
        'Vị trí này nổi bật về Thiên Tài (Trung tài và Tiểu tài), 2 lần, '
        'thiên về tiền tài và cơ hội làm giàu.',
      );
    });
  });

  group('U13 conclusionSentence', () {
    // Nguồn: spec "Kết luận" mục 2 (nêu cung nhiều nhất, bằng nhau nêu tất cả
    // theo thứ tự). Câu chữ cụ thể (*) cần xác nhận.
    test('6-27 vi, một cung 3 lần (n1 Đ, n2 S)', () {
      final c = _conclusion([const PalaceTally(groups: [_talentGreat], count: 3)]);
      expect(
        vi.conclusionSentence(c),
        'Vị trí này nổi bật về Thiên Tài (Đại tài), 3 lần, '
        'thiên về tiền tài và cơ hội làm giàu.',
      );
    });
    test('6-28 vi, nhiều cung bằng nhau (n1 Đ, n2 Đ)', () {
      final c = _conclusion([
        const PalaceTally(groups: [_talentGreat], count: 1),
        const PalaceTally(groups: [_career], count: 1),
      ]);
      expect(
        vi.conclusionSentence(c),
        'Vị trí này có 2 cung cùng nổi bật: Thiên Tài (Đại tài) thiên về '
        'tiền tài và cơ hội làm giàu; Quan Lộc (Đại quan) thiên về công danh '
        'và đường sự nghiệp.',
      );
    });
    test('6-29 en, một cung 3 lần (n1 S, n3 S, n4 S)', () {
      final c = _conclusion([const PalaceTally(groups: [_talentGreat], count: 3)]);
      expect(
        en.conclusionSentence(c),
        'This location stands out for Talent (Great), 3 times, pointing to wealth '
        'and opportunities to prosper.',
      );
    });
    test('6-30 en, một cung 1 lần (n1 S, n3 Đ, n4 S)', () {
      final c = _conclusion([const PalaceTally(groups: [_talentGreat], count: 1)]);
      expect(
        en.conclusionSentence(c),
        // Một cặp đã gộp thành một lần nên không ghi số lần.
        'This location stands out for Talent (Great), pointing to wealth and '
        'opportunities to prosper.',
      );
    });
    test('6-31 en, nhiều cung bằng nhau 2 lần (n1 S, n3 S, n4 Đ)', () {
      final c = _conclusion([
        const PalaceTally(groups: [_talentGreat], count: 2),
        const PalaceTally(groups: [_career], count: 2),
      ]);
      expect(
        en.conclusionSentence(c),
        'This location has 2 equally strong themes, 2 times each: '
        'Talent (Great) pointing to wealth and opportunities to prosper; Career '
        '(High Office) pointing to status and career path.',
      );
    });
    test('6-31a vi, cung nổi bật duy nhất + cung khác 1 lần', () {
      final c = _conclusion(
        [const PalaceTally(groups: [_talentGreat], count: 2)],
        const [],
        [
          const PalaceTally(groups: [_talentGreat], count: 2),
          const PalaceTally(groups: [_career], count: 1),
          const PalaceTally(groups: [_noGroup], count: 1),
        ],
      );
      expect(
        vi.conclusionSentence(c),
        'Vị trí này có 3 cung. Nổi bật nhất là Thiên Tài (Đại tài), 2 lần, '
        'thiên về tiền tài và cơ hội làm giàu. Bên cạnh đó, Quan Lộc (Đại quan) '
        'thiên về công danh và đường sự nghiệp; Tai Họa thiên về vận hạn cần '
        'cẩn trọng.',
      );
    });
    test('6-31b en, cung nổi bật duy nhất + cung khác 1 lần', () {
      final c = _conclusion(
        [const PalaceTally(groups: [_talentGreat], count: 2)],
        const [],
        [
          const PalaceTally(groups: [_talentGreat], count: 2),
          const PalaceTally(groups: [_career], count: 1),
          const PalaceTally(groups: [_noGroup], count: 1),
        ],
      );
      expect(
        en.conclusionSentence(c),
        'This location has 3 themes. The strongest is Talent '
        '(Great), 2 times, pointing to wealth and opportunities to prosper. '
        'Alongside this, Career (High Office) pointing to status and career path; '
        'Misfortune pointing to setbacks that call for caution.',
      );
    });
    test('6-31c vi, cung khác gặp nhiều lần ghi số lần', () {
      final c = _conclusion(
        [const PalaceTally(groups: [_talentGreat], count: 3)],
        const [],
        [
          const PalaceTally(groups: [_talentGreat], count: 3),
          const PalaceTally(groups: [_career], count: 2),
        ],
      );
      expect(
        vi.conclusionSentence(c),
        'Vị trí này có 2 cung. Nổi bật nhất là Thiên Tài (Đại tài), 3 lần, '
        'thiên về tiền tài và cơ hội làm giàu. Bên cạnh đó, Quan Lộc (Đại '
        'quan), 2 lần, thiên về công danh và đường sự nghiệp.',
      );
    });
    test('6-31d vi, nhiều cung nổi bật bằng nhau + cung khác', () {
      final c = _conclusion(
        [
          const PalaceTally(groups: [_talentGreat], count: 2),
          const PalaceTally(groups: [_career], count: 2),
        ],
        const [],
        [
          const PalaceTally(groups: [_talentGreat], count: 2),
          const PalaceTally(groups: [_career], count: 2),
          const PalaceTally(groups: [_noGroup], count: 1),
        ],
      );
      expect(
        vi.conclusionSentence(c),
        'Vị trí này có 3 cung. Nổi bật nhất là Thiên Tài (Đại tài) và Quan '
        'Lộc (Đại quan), mỗi cung 2 lần: Thiên Tài (Đại tài) thiên về tiền tài '
        'và cơ hội làm giàu; Quan Lộc (Đại quan) thiên về công danh và đường '
        'sự nghiệp. Bên cạnh đó, Tai Họa thiên về vận hạn cần cẩn trọng.',
      );
    });
    test('6-31e en, nhiều cung nổi bật bằng nhau + cung khác', () {
      final c = _conclusion(
        [
          const PalaceTally(groups: [_talentGreat], count: 3),
          const PalaceTally(groups: [_career], count: 3),
        ],
        const [],
        [
          const PalaceTally(groups: [_talentGreat], count: 3),
          const PalaceTally(groups: [_career], count: 3),
          const PalaceTally(groups: [_noGroup], count: 2),
        ],
      );
      expect(
        en.conclusionSentence(c),
        'This location has 3 themes. The strongest are Talent '
        '(Great) and Career (High Office), 3 times each: Talent (Great) pointing to wealth and '
        'opportunities to prosper; Career (High Office) pointing to status and '
        'career path. Alongside this, Misfortune, 2 times, pointing to setbacks '
        'that call for caution.',
      );
    });
  });

  group('U14 warningSentence', () {
    // Nguồn: spec "Kết luận" mục 3 (thêm câu lưu ý). Câu chữ (*) cần xác nhận.
    test('6-32 vi nêu tên từng dòng (n1 Đ)', () {
      final c = _conclusion([], [_romanceWarn, _noGroup]);
      expect(
        vi.warningSentence(c),
        'Lưu ý: vị trí này có Đào Hoa (Tai họa) và Tai Họa.',
      );
    });
    test('6-33 en nêu tên từng dòng (n1 S)', () {
      final c = _conclusion([], [_romanceWarn, _noGroup]);
      expect(
        en.warningSentence(c),
        'Note: this location includes Romance (Misfortune) and Misfortune.',
      );
    });
  });
}
