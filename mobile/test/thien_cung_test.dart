import 'package:flutter_test/flutter_test.dart';
import 'package:toado/thien_cung.dart';
import 'package:toado/thien_cung_data.dart';

/// Nhãn dễ đọc của một dòng: `Cung` hoặc `Cung / Nhóm`.
String label(ThienCungGroup g) =>
    g.groupVi == null ? g.palaceVi : '${g.palaceVi} / ${g.groupVi}';

List<String> labels(Iterable<ThienCungGroup> groups) =>
    groups.map(label).toList();

/// Một dòng của bảng gốc: `(palaceOrder, cung, nhóm, các số, isWarning)`.
typedef Row = (int, String, String?, List<String>, bool);

const List<Row> expectedTable = [
  (0, 'Thiên Tài', 'Đại tài', ['13', '31'], false),
  (0, 'Thiên Tài', 'Trung tài', ['68', '86'], false),
  (0, 'Thiên Tài', 'Tiểu tài', ['27', '72', '49', '94'], false),
  (1, 'Quan Lộc', 'Đại quan', ['19', '91'], false),
  (1, 'Quan Lộc', 'Thượng quan', ['26', '62'], false),
  (1, 'Quan Lộc', 'Trung quan', ['78', '87'], false),
  (1, 'Quan Lộc', 'Quan nhỏ', ['46', '64'], false),
  (1, 'Quan Lộc', 'Hạ quan', ['43', '34'], false),
  (2, 'Thông Minh', 'IQ cao', ['27', '72'], false),
  (2, 'Thông Minh', 'IQ trung bình khá', ['49', '94'], false),
  (3, 'Thần Linh Trời Định', 'Đất của trời', ['17', '71'], false),
  (3, 'Thần Linh Trời Định', 'Số trời', ['72', '27'], false),
  (4, 'Tích Lũy Tài Sản', null, ['74', '47', '14', '41'], false),
  (5, 'Linh Ứng', null, ['18', '81', '24', '42', '63', '36'], false),
  (6, 'Đào Hoa', 'May mắn', ['38', '83'], false),
  (6, 'Đào Hoa', 'Tai họa', ['16', '61'], true),
  (7, 'Chăm Chỉ', null, ['12', '21', '69', '96'], false),
  (
    8,
    'Bảo Vệ',
    null,
    ['00', '11', '22', '33', '44', '55', '66', '77', '88', '99'],
    false,
  ),
  (9, 'Đạo Đức', null, ['28', '82', '39', '93'], false),
  (10, 'Tai Họa', null, ['23', '32', '34', '43', '89', '98', '16', '61'], true),
];

void main() {
  group('splitPairs', () {
    test('đúng ví dụ chuẩn, số chữ số lẻ thì thêm 0 phía trước', () {
      expect(splitPairs('21°01\'43"N 105°48\'12"E'), [
        '12',
        '48',
        '05',
        '31',
        '14',
        '10',
        '02',
      ]);
    });

    test('vĩ độ 1 chữ số đã bù 0 vẫn tách đủ', () {
      expect(splitPairs('08°46\'12"N 105°48\'12"E'), [
        '12',
        '48',
        '05',
        '21',
        '61',
        '84',
        '00',
      ]);
    });

    test('số chữ số chẵn thì không thêm 0', () {
      expect(splitPairs('12°34\'56"N'), ['56', '34', '12']);
    });

    test('số chữ số lẻ', () {
      expect(splitPairs('1°23\'45"N'), ['45', '23', '01']);
    });

    test('một chữ số và không có chữ số', () {
      expect(splitPairs('7'), ['07']);
      expect(splitPairs('NE'), isEmpty);
      expect(splitPairs(''), isEmpty);
    });
  });

  group('thienCungTable', () {
    test('đủ 20 dòng', () {
      expect(thienCungTable, hasLength(20));
    });

    test('mọi dòng bảng thật đều đã có ý nghĩa, 6 nhóm đã điền đúng số và cung', () {
      expect(thienCungTable.where((row) => !row.hasMeaning), isEmpty);
      const filled = <String, (int, List<String>)>{
        'Thần Linh Trời Định / Đất của trời': (3, ['17', '71']),
        'Thần Linh Trời Định / Số trời': (3, ['72', '27']),
        'Tích Lũy Tài Sản': (4, ['74', '47', '14', '41']),
        'Linh Ứng': (5, ['18', '81', '24', '42', '63', '36']),
        'Chăm Chỉ': (7, ['12', '21', '69', '96']),
        'Đạo Đức': (9, ['28', '82', '39', '93']),
      };
      for (final entry in filled.entries) {
        final row = thienCungTable.singleWhere((r) => label(r) == entry.key);
        expect(row.palaceOrder, entry.value.$1, reason: entry.key);
        expect(row.numbers, entry.value.$2, reason: entry.key);
        expect(row.hasMeaning, isTrue, reason: entry.key);
      }
    });

    test('dòng có dữ liệu thì có đủ bản tiếng Anh', () {
      for (final row in thienCungTable) {
        expect(row.meaningEn.isNotEmpty, row.hasMeaning, reason: label(row));
      }
    });

    test('từng dòng đúng cung, nhóm, số, cảnh báo và đúng thứ tự', () {
      expect(thienCungTable, hasLength(expectedTable.length));
      for (var i = 0; i < expectedTable.length; i++) {
        final (order, palace, groupName, numbers, warning) = expectedTable[i];
        final row = thienCungTable[i];
        expect(row.palaceOrder, order, reason: 'dòng $i');
        expect(row.palaceVi, palace, reason: 'dòng $i');
        expect(row.groupVi, groupName, reason: 'dòng $i');
        expect(row.numbers, numbers, reason: 'dòng $i');
        expect(row.isWarning, warning, reason: 'dòng $i');
      }
    });

    test('tên tiếng Anh đều có, cung không nhóm thì nhóm null', () {
      for (final row in thienCungTable) {
        final name = label(row);
        expect(row.palaceEn, isNotEmpty, reason: name);
        expect(row.groupEn == null, row.groupVi == null, reason: name);
      }
    });

    test('tên cung không kèm chữ "Cung"', () {
      for (final row in thienCungTable) {
        expect(row.palaceVi.startsWith('Cung'), isFalse, reason: row.palaceVi);
      }
    });

    test('mọi số đều đủ 2 chữ số', () {
      for (final row in thienCungTable) {
        for (final number in row.numbers) {
          expect(number, matches(RegExp(r'^\d{2}$')), reason: label(row));
        }
      }
    });

    test('Thiên Tài → Fortune', () {
      expect(thienCungTable.first.palaceEn, 'Fortune');
    });

    test('Thiên Tài / Đại tài dùng đúng ý nghĩa người dùng đưa', () {
      expect(
        thienCungTable.first.meaningVi,
        'Năng lượng đỉnh cao về tiền tài, biểu thị sự hanh thông lớn, dễ nắm '
        'bắt đại cơ hội.',
      );
    });
  });

  group('lookupPair', () {
    test('12 → Chăm Chỉ', () {
      expect(labels(lookupPair('12')), ['Chăm Chỉ']);
    });

    test('31 → Thiên Tài / Đại tài', () {
      expect(labels(lookupPair('31')), ['Thiên Tài / Đại tài']);
    });

    test('27 ra đủ 3 dòng theo thứ tự bảng', () {
      expect(labels(lookupPair('27')), [
        'Thiên Tài / Tiểu tài',
        'Thông Minh / IQ cao',
        'Thần Linh Trời Định / Số trời',
      ]);
    });

    test('22 chỉ còn Bảo Vệ', () {
      expect(labels(lookupPair('22')), ['Bảo Vệ']);
    });

    test('34 ra Hạ quan và Tai Họa', () {
      expect(labels(lookupPair('34')), ['Quan Lộc / Hạ quan', 'Tai Họa']);
    });

    test('16 ra Đào Hoa / Tai họa và Tai Họa', () {
      expect(labels(lookupPair('16')), ['Đào Hoa / Tai họa', 'Tai Họa']);
    });

    test('00 giữ số 0 đầu', () {
      expect(labels(lookupPair('00')), ['Bảo Vệ']);
    });

    test('48, 05, 10, 02 không có trong bảng', () {
      for (final pair in ['48', '05', '10', '02']) {
        expect(lookupPair(pair), isEmpty, reason: pair);
      }
    });
  });

  group('matchPairs', () {
    test('giữ thứ tự pairs, mỗi dòng khớp sinh một PairMatch, bỏ cặp lạ', () {
      final matches = matchPairs(['48', '27', '05', '14']);
      expect(matches.map((m) => m.pair).toList(), ['27', '27', '27', '14']);
      expect(labels(matches.map((m) => m.group)), [
        'Thiên Tài / Tiểu tài',
        'Thông Minh / IQ cao',
        'Thần Linh Trời Định / Số trời',
        'Tích Lũy Tài Sản',
      ]);
    });

    test('thứ tự theo pairs chứ không theo bảng', () {
      final matches = matchPairs(['14', '31']);
      expect(matches.map((m) => m.pair).toList(), ['14', '31']);
    });

    test('danh sách rỗng', () {
      expect(matchPairs([]), isEmpty);
    });
  });

  group('buildConclusion', () {
    Conclusion conclude(List<String> pairs) =>
        buildConclusion(matchPairs(pairs));

    test('ví dụ chuẩn: tính cả Chăm Chỉ và Tích Lũy, mỗi cung 1 lần', () {
      final result = conclude(['12', '48', '05', '31', '14', '10', '02']);
      expect(result.top.map((t) => t.palace.palaceVi).toList(), [
        'Thiên Tài',
        'Tích Lũy Tài Sản',
        'Chăm Chỉ',
      ]);
      expect(result.top.map((t) => t.count).toList(), [1, 1, 1]);
      expect(labels(result.top.first.groups), ['Thiên Tài / Đại tài']);
      expect(result.warnings, isEmpty);
      expect(result.isEmpty, isFalse);
    });

    test('chỉ có dòng chưa có dữ liệu thì không có kết luận', () {
      const emptyRow = ThienCungGroup(
        palaceOrder: 3,
        palaceVi: 'Cung Trống',
        palaceEn: 'Empty',
        numbers: ['12', '14', '28'],
        meaningVi: '',
        meaningEn: '',
      );
      expect(emptyRow.hasMeaning, isFalse);
      final result = buildConclusion(
        matchPairs(['12', '14', '28'], table: const [emptyRow]),
      );
      expect(result.isEmpty, isTrue);
      expect(result.warnings, isEmpty);
    });

    test('dòng chưa có dữ liệu bị bỏ, dòng có dữ liệu vẫn được đếm', () {
      const emptyRow = ThienCungGroup(
        palaceOrder: 3,
        palaceVi: 'Cung Trống',
        palaceEn: 'Empty',
        numbers: ['12'],
        meaningVi: '',
        meaningEn: '',
      );
      final matches = [
        ...matchPairs(['12'], table: const [emptyRow]),
        ...matchPairs(['31']),
      ];
      final result = buildConclusion(matches);
      expect(result.top.map((t) => t.palace.palaceVi).toList(), ['Thiên Tài']);
      expect(result.top.single.count, 1);
    });

    test('nhiều cung bằng nhau theo thứ tự bảng', () {
      final result = conclude(['38', '31']);
      expect(result.top.map((t) => t.palace.palaceVi).toList(), [
        'Thiên Tài',
        'Đào Hoa',
      ]);
      expect(result.top.map((t) => t.count).toList(), [1, 1]);
    });

    test('một cung nhiều nhất', () {
      final result = conclude(['12', '13', '31']);
      expect(result.top, hasLength(1));
      expect(result.top.single.palace.palaceVi, 'Thiên Tài');
      expect(result.top.single.count, 2);
    });

    test(
      'groups là các dòng khác nhau, theo thứ tự bảng, không theo pairs',
      () {
        final result = conclude(['68', '31', '13']);
        final tally = result.top.single;
        expect(tally.count, 3);
        expect(labels(tally.groups), [
          'Thiên Tài / Đại tài',
          'Thiên Tài / Trung tài',
        ]);
      },
    );

    test('cặp lặp lại vẫn đếm từng PairMatch', () {
      final tally = conclude(['38', '38']).top.single;
      expect(tally.count, 2);
      expect(labels(tally.groups), ['Đào Hoa / May mắn']);
    });

    test('cảnh báo vẫn báo dù cung đó không nằm trong top', () {
      final result = conclude(['13', '31', '89']);
      expect(result.top.single.palace.palaceVi, 'Thiên Tài');
      expect(labels(result.warnings), ['Tai Họa']);
    });

    test('cảnh báo không trùng và theo thứ tự bảng', () {
      final result = conclude(['89', '98', '16', '61']);
      expect(labels(result.warnings), ['Đào Hoa / Tai họa', 'Tai Họa']);
      expect(result.top.single.palace.palaceVi, 'Tai Họa');
      expect(result.top.single.count, 4);
    });

    test('dòng không phải cảnh báo của cung Đào Hoa thì không báo', () {
      expect(conclude(['38']).warnings, isEmpty);
    });

    test('một số thuộc nhiều cung thì mỗi cung đều được đếm', () {
      final result = conclude(['27']);
      expect(result.top.map((t) => t.palace.palaceVi).toList(), [
        'Thiên Tài',
        'Thông Minh',
        'Thần Linh Trời Định',
      ]);
      expect(result.top.map((t) => t.count).toList(), [1, 1, 1]);
    });

    test('một số thuộc cung thường và cung cảnh báo', () {
      final result = conclude(['34']);
      expect(result.top.map((t) => t.palace.palaceVi).toList(), [
        'Quan Lộc',
        'Tai Họa',
      ]);
      expect(labels(result.warnings), ['Tai Họa']);
    });

    test('không có match thì rỗng', () {
      final result = buildConclusion([]);
      expect(result.top, isEmpty);
      expect(result.warnings, isEmpty);
      expect(result.isEmpty, isTrue);
    });

    test('toàn cặp không có trong bảng thì rỗng', () {
      expect(conclude(['48', '05', '10', '02']).isEmpty, isTrue);
    });
  });
}
