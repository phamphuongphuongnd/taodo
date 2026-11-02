import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toado/language_store.dart';
import 'package:toado/strings.dart';
import 'package:toado/thien_cung.dart';
import 'package:toado/thien_cung_data.dart';

const _exampleCoords = '21°01\'43"N 105°48\'12"E';
const _fourPalacesCoords = '27°68\'00"N 00°00\'00"E';

Conclusion _conclusionOf(String coordsText) =>
    buildConclusion(matchPairs(splitPairs(coordsText)));

void main() {
  final vi = AppStrings.of(AppLanguage.vi);
  final en = AppStrings.of(AppLanguage.en);

  group('defaultLanguage', () {
    test('máy tiếng Việt ra tiếng Việt', () {
      expect(defaultLanguage(const Locale('vi')), AppLanguage.vi);
      expect(defaultLanguage(const Locale('vi', 'VN')), AppLanguage.vi);
    });

    test('ngôn ngữ khác ra tiếng Anh', () {
      expect(defaultLanguage(const Locale('en')), AppLanguage.en);
      expect(defaultLanguage(const Locale('ja')), AppLanguage.en);
    });
  });

  group('joinList', () {
    test('ghép tự nhiên theo ngôn ngữ', () {
      expect(vi.joinList(['a']), 'a');
      expect(vi.joinList(['a', 'b']), 'a và b');
      expect(vi.joinList(['a', 'b', 'c']), 'a, b và c');
      expect(en.joinList(['a', 'b', 'c']), 'a, b and c');
    });
  });

  group('câu Kết luận', () {
    test('ví dụ chuẩn tính các cung có dữ liệu, bằng nhau thì nêu hết', () {
      expect(
        vi.conclusionSentence(_conclusionOf(_exampleCoords)),
        'Vị trí này có 3 cung, mỗi cung một lần: Thiên Tài (Đại tài) thiên về '
        'tiền tài và cơ hội làm giàu; Tích Lũy Tài Sản về tích góp của '
        'cải bền lâu; Chăm Chỉ về sự cần cù và kiên trì.',
      );
    });

    test('nhiều cung bằng nhau', () {
      final conclusion = _conclusionOf('38 19 31');
      final talent = lookupPair('31').single;
      final career = lookupPair('19').single;
      final romance = lookupPair('38').single;
      expect(
        vi.conclusionSentence(conclusion),
        'Vị trí này có 3 cung, mỗi cung một lần: Thiên Tài (Đại tài) thiên về '
        'tiền tài và cơ hội làm giàu; Quan Lộc (Đại quan) về công danh '
        'và đường sự nghiệp; Đào Hoa (May mắn) về nhân duyên và tình cảm.',
      );
      expect(
        en.conclusionSentence(conclusion),
        'This location has 3 themes, once each: '
        '${talent.palaceEn} (${talent.groupEn}) pointing to wealth and '
        'opportunities to prosper; ${career.palaceEn} (${career.groupEn}) '
        'to status and career path; ${romance.palaceEn} (${romance.groupEn}) '
        'to relationships and affection.',
      );
    });

    test('một cung nhiều lần', () {
      // Ba cặp khác nhau cùng thuộc Chăm Chỉ; cặp trùng chỉ tính một lần.
      final conclusion = _conclusionOf('12 21 96');
      final diligence = lookupPair('12').single;
      expect(
        vi.conclusionSentence(conclusion),
        'Vị trí này nổi bật về Chăm Chỉ, 3 lần, thiên về sự cần cù và kiên '
        'trì.',
      );
      expect(
        en.conclusionSentence(conclusion),
        'This location stands out for ${diligence.palaceEn}, 3 times, pointing to '
        'steady effort and perseverance.',
      );
    });

    test('cặp số trùng vẫn đếm đủ số lần', () {
      final conclusion = _conclusionOf('12 12 12');
      expect(
        vi.conclusionSentence(conclusion),
        'Vị trí này nổi bật về Chăm Chỉ, 3 lần, thiên về sự cần cù và kiên trì.',
      );
    });

    test('dòng chưa có dữ liệu hiện chữ báo thiếu', () {
      const emptyRow = ThienCungGroup(
        palaceOrder: 7,
        palaceVi: 'Cung Trống',
        palaceEn: 'Empty',
        numbers: ['12'],
        meaningVi: '',
        meaningEn: '',
      );
      expect(vi.meaning(emptyRow), 'Chưa có dữ liệu');
      expect(en.meaning(emptyRow), 'No data yet');
      final diligence = lookupPair('12').single;
      expect(vi.meaning(diligence), diligence.meaningVi);
      expect(en.meaning(diligence), diligence.meaningEn);
    });

    test('một cung gặp nhiều nhóm thì nêu đủ nhóm theo thứ tự bảng', () {
      final conclusion = _conclusionOf(_fourPalacesCoords);
      expect(
        vi.conclusionSentence(conclusion),
        'Vị trí này có 4 cung. Nổi bật nhất là Bảo Vệ, 4 lần, thiên về '
        'giữ gìn thành quả và sự bình ổn. Bên cạnh đó, Thiên Tài (Trung tài và '
        'Tiểu tài), 2 lần, thiên về tiền tài và cơ hội làm giàu; Thông Minh '
        '(IQ cao) về trí tuệ và khả năng học hỏi; Thần Linh Trời Định '
        '(Số trời) về phúc phận do trời định.',
      );
    });

    test('bản tiếng Anh: nổi bật nhất cộng cung khác', () {
      final conclusion = _conclusionOf(_fourPalacesCoords);
      expect(
        en.conclusionSentence(conclusion),
        'This location has 4 themes. The strongest is Protection, '
        '4 times, pointing to safeguarding achievements and stability. Alongside '
        'this, Fortune (Moderate Fortune and Minor Fortune), 2 times, pointing to '
        'wealth and opportunities to prosper; Intelligence (High IQ) to '
        'intellect and the ability to learn; Divine Destiny (Heavenly Fate) '
        'to blessings ordained by heaven.',
      );
    });

    test('có Tai Họa: cung Tai Họa được nêu như mọi cung khác', () {
      final conclusion = _conclusionOf('12 21 96 16');
      expect(
        vi.conclusionSentence(conclusion),
        'Vị trí này có 3 cung. Nổi bật nhất là Chăm Chỉ, 3 lần, thiên về '
        'sự cần cù và kiên trì. Bên cạnh đó, Đào Hoa (Tai họa) thiên về sóng '
        'gió tình cảm cần giữ gìn; Tai Họa về vận hạn cần cẩn trọng.',
      );
      expect(
        en.conclusionSentence(conclusion),
        'This location has 3 themes. The strongest is Diligence, '
        '3 times, pointing to steady effort and perseverance. Alongside this, Romance '
        '(Misfortune) pointing to relationship troubles that need care; Misfortune to '
        'setbacks that call for caution.',
      );
      // Chỉ có hai cung Tai Họa bằng nhau thì không còn cung khác.
      expect(
        vi.conclusionSentence(_conclusionOf('16')),
        'Vị trí này có 2 cung, mỗi cung một lần: Đào Hoa (Tai họa) thiên về '
        'sóng gió tình cảm cần giữ gìn; Tai Họa về vận hạn cần cẩn trọng.',
      );
    });

    test('câu lưu ý nêu tên từng dòng', () {
      final conclusion = _conclusionOf('16');
      final [romance, misfortune] = lookupPair('16');
      expect(
        vi.warningSentence(conclusion),
        'Lưu ý: vị trí này có Đào Hoa (Tai họa) và Tai Họa.',
      );
      expect(
        en.warningSentence(conclusion),
        'Note: this location includes ${romance.palaceEn} (${romance.groupEn}) '
        'and ${misfortune.palaceEn}.',
      );
    });
  });

  group('SharedPreferencesLanguageStore', () {
    test('chưa chọn thì trả null', () async {
      SharedPreferences.setMockInitialValues({});
      expect(await SharedPreferencesLanguageStore().load(), isNull);
    });

    test('đọc lại đúng lựa chọn đã lưu', () async {
      SharedPreferences.setMockInitialValues({});
      final store = SharedPreferencesLanguageStore();
      await store.save(AppLanguage.en);
      expect(await store.load(), AppLanguage.en);
      await store.save(AppLanguage.vi);
      expect(await store.load(), AppLanguage.vi);
    });

    test('giá trị lạ coi như chưa chọn', () async {
      SharedPreferences.setMockInitialValues({'language': 'fr'});
      expect(await SharedPreferencesLanguageStore().load(), isNull);
    });
  });
}
