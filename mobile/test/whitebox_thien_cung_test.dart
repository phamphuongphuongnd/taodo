// Kiểm thử hộp trắng (nhị phân) cho lib/thien_cung.dart — Bước 6.
// Thiết kế: test-output/whitebox/tinh-toan-thien-cung/thien_cung/buoc-5-du-lieu-thu.md
// Expected lấy từ yêu cầu (docs/superpowers/specs/2026-10-31-toado-design.md), không lấy từ hành vi code.
import 'package:flutter_test/flutter_test.dart';
import 'package:toado/thien_cung.dart';
import 'package:toado/thien_cung_data.dart';

String label(ThienCungGroup g) =>
    g.groupVi == null ? g.palaceVi : '${g.palaceVi} / ${g.groupVi}';

List<String> palaces(Conclusion c) =>
    c.top.map((t) => t.palace.palaceVi).toList();

Conclusion conclude(List<String> pairs) => buildConclusion(matchPairs(pairs));

void main() {
  group('U1 splitPairs', () {
    // Đường cơ sở: U1-D1 Đ rồi S, U1-D2 luôn S (số chữ số chẵn).
    test('6-1 số chữ số chẵn ⇒ tách cặp từ phải sang trái, không thêm 0', () {
      expect(splitPairs('12°34\'56"N'), ['56', '34', '12']);
    });

    // Lật U1-D1: S ngay lần kiểm đầu.
    test('6-2 không có chữ số ⇒ danh sách rỗng', () {
      expect(splitPairs(''), isEmpty);
      expect(splitPairs('NE'), isEmpty);
    });

    // Lật U1-D2: Đ (end == 1) ⇒ cặp cuối lẻ thêm 0 phía trước.
    test('6-3 số chữ số lẻ ⇒ cặp cuối thêm 0 phía trước', () {
      expect(splitPairs('1°23\'45"N'), ['45', '23', '01']);
      expect(
        splitPairs('21°01\'43"N 105°48\'12"E'),
        ['12', '48', '05', '31', '14', '10', '02'],
      );
    });
  });

  group('U2 lookupPair', () {
    test('6-4 số thuộc nhiều cung ⇒ đủ các dòng theo thứ tự bảng; số lạ ⇒ rỗng', () {
      expect(
        lookupPair('27').map(label).toList(),
        [
          'Thiên Tài / Tiểu tài',
          'Thông Minh / IQ cao',
          'Thần Linh Trời Định / Số trời',
        ],
      );
      expect(lookupPair('48'), isEmpty);
    });
  });

  group('U3 matchPairs', () {
    test('6-5 giữ thứ tự pairs, mỗi dòng khớp một PairMatch, bỏ cặp lạ', () {
      final matches = matchPairs(['48', '27', '14']);
      expect(matches.map((m) => m.pair).toList(), ['27', '27', '27', '14']);
      expect(
        matches.map((m) => label(m.group)).toList(),
        [
          'Thiên Tài / Tiểu tài',
          'Thông Minh / IQ cao',
          'Thần Linh Trời Định / Số trời',
          'Tích Lũy Tài Sản',
        ],
      );
      expect(matchPairs([]), isEmpty);
    });
  });

  group('U4 buildConclusion', () {
    // Đường cơ sở: D1 S, D2 Đ, D3 S (đếm bằng nhau), D4 Đ.
    test('6-6 hai cung bằng nhau ⇒ nêu tất cả theo thứ tự bảng', () {
      final r = conclude(['13', '19']);
      expect(palaces(r), ['Thiên Tài', 'Quan Lộc']);
      expect(r.top.map((t) => t.count).toList(), [1, 1]);
      expect(r.warnings, isEmpty);
      expect(r.isEmpty, isFalse);
    });

    // Lật D1: Đ ⇒ chỉ có dòng chưa có dữ liệu thì không có kết luận.
    test('6-7 chỉ dòng chưa có dữ liệu ⇒ không có kết luận', () {
      const emptyRow = ThienCungGroup(
        palaceOrder: 7,
        palaceVi: 'Cung Trống',
        palaceEn: 'Empty',
        numbers: ['12', '14'],
        meaningVi: '',
        meaningEn: '',
      );
      final r = buildConclusion(matchPairs(['12', '14'], table: const [emptyRow]));
      expect(r.top, isEmpty);
      expect(r.warnings, isEmpty);
      expect(r.isEmpty, isTrue);
    });

    // Lật D2: S (cung đã gặp) cùng D3 S, D4 Đ.
    test('6-8 mỗi cung gặp 2 lần ⇒ đếm cộng dồn, bằng nhau nêu cả hai', () {
      final r = conclude(['13', '13', '19', '19']);
      expect(palaces(r), ['Thiên Tài', 'Quan Lộc']);
      expect(r.top.map((t) => t.count).toList(), [2, 2]);
    });

    // Lật D3: Đ (a > b) ⇒ cung nhiều nhất đứng trước; cung ít hơn bị loại (D4 S).
    test('6-9 cung nhiều nhất gặp trước ⇒ chỉ nêu cung đó', () {
      final r = conclude(['13', '13', '19']);
      expect(palaces(r), ['Thiên Tài']);
      expect(r.top.single.count, 2);
    });

    // Lật D4: S với D3 S (cung ít hơn gặp trước).
    test('6-10 cung ít hơn gặp trước ⇒ vẫn chỉ nêu cung nhiều nhất', () {
      final r = conclude(['19', '13', '13']);
      expect(palaces(r), ['Thiên Tài']);
      expect(r.top.single.count, 2);
    });
  });

  group('U5/U6 getter', () {
    test('6-11 PalaceTally.palace ⇒ dòng đầu của groups', () {
      final tally = PalaceTally(
        groups: [thienCungTable[0], thienCungTable[1]],
        count: 1,
      );
      expect(identical(tally.palace, thienCungTable[0]), isTrue);
    });

    test('6-12 Conclusion.isEmpty ⇒ đúng khi top rỗng, sai khi có top', () {
      expect(const Conclusion(top: [], warnings: []).isEmpty, isTrue);
      expect(conclude(['13']).isEmpty, isFalse);
    });
  });
}
