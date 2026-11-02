// Kiểm thử hộp trắng cho lib/language_store.dart.
// Tài liệu: test-output/whitebox/ngon-ngu/language_store/
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toado/language_store.dart';
import 'package:toado/strings.dart';

void _a(AppLanguage l) {}
void _b(AppLanguage l) {}

LanguageScope _scope(AppLanguage l, ValueChanged<AppLanguage> cb, [Widget? child]) =>
    LanguageScope(language: l, onChanged: cb, child: child ?? const SizedBox());

void main() {
  group('LanguageStore (SharedPreferences)', () {
    test('6-1 chưa chọn lần nào ⇒ load trả null', () async {
      SharedPreferences.setMockInitialValues({});
      expect(await SharedPreferencesLanguageStore().load(), isNull);
    });

    test('6-2 đã lưu en ⇒ load trả en', () async {
      SharedPreferences.setMockInitialValues({'language': 'en'});
      expect(await SharedPreferencesLanguageStore().load(), AppLanguage.en);
    });

    test('6-3 đã lưu vi ⇒ load trả vi', () async {
      SharedPreferences.setMockInitialValues({'language': 'vi'});
      expect(await SharedPreferencesLanguageStore().load(), AppLanguage.vi);
    });

    test('6-4 (*) giá trị lạ đã lưu ⇒ coi như chưa chọn (null)', () async {
      SharedPreferences.setMockInitialValues({'language': 'fr'});
      expect(await SharedPreferencesLanguageStore().load(), isNull);
    });

    test('6-5 save rồi load ⇒ đọc lại đúng, lưu lại lần nữa thì ghi đè', () async {
      SharedPreferences.setMockInitialValues({});
      final store = SharedPreferencesLanguageStore();
      await store.save(AppLanguage.en);
      expect(await store.load(), AppLanguage.en);
      await store.save(AppLanguage.vi);
      expect(await store.load(), AppLanguage.vi);
      // Lưu bền: một đối tượng store mới vẫn đọc được lựa chọn.
      expect(await SharedPreferencesLanguageStore().load(), AppLanguage.vi);
    });
  });

  group('LanguageScope.of / strings', () {
    testWidgets('6-6 of(context) trả đúng scope tổ tiên gần nhất', (tester) async {
      LanguageScope? got;
      await tester.pumpWidget(_scope(
        AppLanguage.en,
        _a,
        Builder(builder: (c) {
          got = LanguageScope.of(c);
          return const SizedBox();
        }),
      ));
      expect(got, isNotNull);
      expect(got!.language, AppLanguage.en);
      expect(got!.onChanged, same(_a));
    });

    test('6-7 strings theo ngôn ngữ hiện tại (vi rồi en)', () {
      expect(_scope(AppLanguage.vi, _a).strings.language, AppLanguage.vi);
      expect(_scope(AppLanguage.en, _a).strings.language, AppLanguage.en);
      expect(_scope(AppLanguage.en, _a).strings, same(AppStrings.of(AppLanguage.en)));
    });
  });

  group('LanguageScope.updateShouldNotify', () {
    test('6-8 đổi ngôn ngữ ⇒ true (nút 1 Đ)', () {
      final n = _scope(AppLanguage.en, _a);
      final o = _scope(AppLanguage.vi, _a);
      expect(n.updateShouldNotify(o), isTrue);
    });

    test('6-9 (*) cùng ngôn ngữ, khác onChanged ⇒ true (nút 1 S, nút 2 Đ)', () {
      final n = _scope(AppLanguage.vi, _a);
      final o = _scope(AppLanguage.vi, _b);
      expect(n.updateShouldNotify(o), isTrue);
    });

    test('6-10 không đổi gì ⇒ false (nút 1 S, nút 2 S)', () {
      final n = _scope(AppLanguage.vi, _a);
      final o = _scope(AppLanguage.vi, _a);
      expect(n.updateShouldNotify(o), isFalse);
    });

    testWidgets('6-11 đổi ngôn ngữ ⇒ widget phụ thuộc dựng lại ngay với chuỗi mới; không đổi ⇒ không dựng lại',
        (tester) async {
      var builds = 0;
      AppLanguage? seen;
      final dependent = Builder(builder: (c) {
        builds++;
        seen = LanguageScope.of(c).language;
        return const SizedBox();
      });
      // Cùng một instance widget con để chỉ updateShouldNotify mới kích dựng lại.
      await tester.pumpWidget(_scope(AppLanguage.vi, _a, dependent));
      expect(builds, 1);
      await tester.pumpWidget(_scope(AppLanguage.vi, _a, dependent));
      expect(builds, 1);
      expect(seen, AppLanguage.vi);
      await tester.pumpWidget(_scope(AppLanguage.en, _a, dependent));
      expect(builds, 2);
      expect(seen, AppLanguage.en);
    });
  });
}
