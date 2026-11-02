import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toado/language_store.dart';
import 'package:toado/strings.dart';
import 'package:toado/thien_cung.dart';
import 'package:toado/thien_cung_data.dart';

const _exampleCoords = '21°01\'43"N 105°48\'12"E';

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
        'Vị trí này nổi bật về Thiên Tài (Đại tài), Tích Lũy Tài Sản và '
        'Chăm Chỉ, mỗi cung 1 lần.',
      );
    });

    test('nhiều cung bằng nhau', () {
      final conclusion = _conclusionOf('38 19 31');
      final talent = lookupPair('31').single;
      final career = lookupPair('19').single;
      final romance = lookupPair('38').single;
      expect(
        vi.conclusionSentence(conclusion),
        'Vị trí này nổi bật về Thiên Tài (Đại tài), Quan Lộc (Đại quan) và '
        'Đào Hoa (May mắn), mỗi cung 1 lần.',
      );
      expect(
        en.conclusionSentence(conclusion),
        'This location stands out for ${talent.palaceEn} (${talent.groupEn}), '
        '${career.palaceEn} (${career.groupEn}) and '
        '${romance.palaceEn} (${romance.groupEn}), 1 time each.',
      );
    });

    test('một cung nhiều lần', () {
      final conclusion = _conclusionOf('13 31 13');
      final talent = lookupPair('13').single;
      expect(
        vi.conclusionSentence(conclusion),
        'Vị trí này nổi bật về Thiên Tài (Đại tài), 3 lần.',
      );
      expect(
        en.conclusionSentence(conclusion),
        'This location stands out for ${talent.palaceEn} (${talent.groupEn}), '
        '3 times.',
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
      final conclusion = _conclusionOf('27 68');
      expect(
        vi.conclusionSentence(conclusion),
        'Vị trí này nổi bật về Thiên Tài (Trung tài và Tiểu tài), 2 lần.',
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
