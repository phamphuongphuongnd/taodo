// Kiểm thử hộp trắng (nhị phân) cho lib/coords.dart — Bước 6.
// Expected chép từ buoc-5-du-lieu-thu.md (nguồn: docs/superpowers/specs/2026-10-31-toado-design.md).
// (*) = yêu cầu không nêu rõ, cần xác nhận.
import 'package:flutter_test/flutter_test.dart';
import 'package:toado/coords.dart';

String? _manual({
  int latDeg = 21,
  int latMin = 1,
  int latSec = 43,
  bool north = true,
  int lonDeg = 105,
  int lonMin = 48,
  int lonSec = 12,
  bool east = true,
}) {
  return formatManualCoords(
    latDeg: latDeg,
    latMin: latMin,
    latSec: latSec,
    north: north,
    lonDeg: lonDeg,
    lonMin: lonMin,
    lonSec: lonSec,
    east: east,
  );
}

Set<ManualField> _invalid({
  int latDeg = 21,
  int latMin = 1,
  int latSec = 43,
  int lonDeg = 105,
  int lonMin = 48,
  int lonSec = 12,
}) {
  return invalidManualFields(
    latDeg: latDeg,
    latMin: latMin,
    latSec: latSec,
    lonDeg: lonDeg,
    lonMin: lonMin,
    lonSec: lonSec,
  );
}

void main() {
  group('formatDmsCoords + _formatDms (đơn vị A, F)', () {
    test('6-1 đường A1/F1: vĩ, kinh dương ⇒ N, E', () {
      expect(formatDmsCoords(21.02862, 105.80334), '21°01\'43"N 105°48\'12"E');
    });

    test('6-2 đường F2: vĩ, kinh âm ⇒ S, W, dùng giá trị tuyệt đối (*)', () {
      expect(
        formatDmsCoords(-21.02862, -105.80334),
        '21°01\'43"S 105°48\'12"W',
      );
    });

    test('6-3 biên F: 0 ⇒ N, E (*)', () {
      expect(formatDmsCoords(0, 0), '00°00\'00"N 00°00\'00"E');
    });

    test('6-4 giây cắt bỏ phần lẻ, không làm tròn lên', () {
      // 20.302431 là 18'08.75", 106.377830 là 22'40.19".
      expect(
        formatDmsCoords(20.302431, 106.377830),
        '20°18\'08"N 106°22\'40"E',
      );
    });

    test('6-5 số đúng tròn giây không bị hụt 1 giây', () {
      expect(formatDmsCoords(8.77, 0.1), '08°46\'12"N 00°06\'00"E');
    });
  });

  group('formatManualCoords (đơn vị B)', () {
    test('6-6 đường B1: hợp lệ, N, E', () {
      expect(_manual(), '21°01\'43"N 105°48\'12"E');
    });

    test('6-7 đường B2: vĩ độ sai ⇒ null', () {
      expect(_manual(latDeg: 91), isNull);
    });

    test('6-8 đường B3: vĩ hợp lệ, kinh độ sai ⇒ null', () {
      expect(_manual(lonDeg: 181), isNull);
    });

    test('6-9 đường B4: chọn S', () {
      expect(_manual(north: false), '21°01\'43"S 105°48\'12"E');
    });

    test('6-10 đường B5: chọn W', () {
      expect(_manual(east: false), '21°01\'43"N 105°48\'12"W');
    });
  });

  group('_manualTotalSeconds (đơn vị E) qua formatManualCoords', () {
    test('6-11 đường E2: độ âm ⇒ null (*)', () {
      expect(_manual(latDeg: -1), isNull);
    });

    test('6-12 đường E3: phút âm ⇒ null (*)', () {
      expect(_manual(latMin: -1), isNull);
    });

    test('6-13 đường E4: phút 60 ⇒ null', () {
      expect(_manual(latMin: 60), isNull);
    });

    test('6-14 đường E5: giây âm ⇒ null (*)', () {
      expect(_manual(latSec: -1), isNull);
    });

    test('6-15 đường E6: giây 60 ⇒ null', () {
      expect(_manual(latSec: 60), isNull);
    });

    test('6-16 đường E7: vượt 90° (90°00\'01") ⇒ null', () {
      expect(_manual(latDeg: 90, latMin: 0, latSec: 1), isNull);
    });

    test('6-17 biên E: 90°00\'00" và 180°00\'00" hợp lệ, phút/giây 59 hợp lệ', () {
      expect(
        _manual(latDeg: 90, latMin: 0, latSec: 0, lonDeg: 180, lonMin: 0, lonSec: 0),
        '90°00\'00"N 180°00\'00"E',
      );
      expect(
        _manual(latDeg: 0, latMin: 59, latSec: 59),
        '00°59\'59"N 105°48\'12"E',
      );
    });
  });

  group('_dmsText, _twoDigits (đơn vị G, H)', () {
    test('6-18 độ, phút, giây một chữ số được bù 0; độ 3 chữ số giữ nguyên', () {
      expect(
        _manual(latDeg: 1, latMin: 2, latSec: 3, lonDeg: 5, lonMin: 5, lonSec: 6),
        '01°02\'03"N 05°05\'06"E',
      );
      expect(
        _manual(lonDeg: 180, lonMin: 0, lonSec: 0),
        '21°01\'43"N 180°00\'00"E',
      );
    });
  });

  group('invalidManualFields (đơn vị C) và check (đơn vị D)', () {
    test('6-19 đường C1/D1: hợp lệ ⇒ rỗng', () {
      expect(_invalid(), isEmpty);
    });

    test('6-20 đường C1: cả vĩ và kinh sai ⇒ hợp hai tập', () {
      expect(_invalid(latMin: 60, lonSec: 61), {
        ManualField.latMin,
        ManualField.lonSec,
      });
    });

    test('6-21 đường D2: phút âm ⇒ ô phút (*)', () {
      expect(_invalid(latMin: -1), {ManualField.latMin});
    });

    test('6-22 đường D3: phút 60 ⇒ ô phút', () {
      expect(_invalid(latMin: 60), {ManualField.latMin});
    });

    test('6-23 đường D4: giây âm ⇒ ô giây (*)', () {
      expect(_invalid(lonSec: -1), {ManualField.lonSec});
    });

    test('6-24 đường D5: giây 60 ⇒ ô giây', () {
      expect(_invalid(latSec: 60), {ManualField.latSec});
    });

    test('6-25 đường D6: độ âm ⇒ ô độ (*)', () {
      expect(_invalid(latDeg: -1), {ManualField.latDeg});
    });

    test('6-26 đường D7: vĩ 91°, kinh 181° ⇒ ô độ', () {
      expect(_invalid(latDeg: 91), {ManualField.latDeg});
      expect(_invalid(lonDeg: 181), {ManualField.lonDeg});
    });

    test('6-27 đường D8: 90°00\'01" và 180°01\'00" ⇒ ô độ', () {
      expect(_invalid(latDeg: 90, latMin: 0, latSec: 1), {ManualField.latDeg});
      expect(_invalid(lonDeg: 180, lonMin: 1, lonSec: 0), {ManualField.lonDeg});
    });

    test('6-28 biên D: đúng 90° và 180°, phút/giây 59 ⇒ rỗng', () {
      expect(
        _invalid(latDeg: 90, latMin: 0, latSec: 0, lonDeg: 180, lonMin: 0, lonSec: 0),
        isEmpty,
      );
      expect(_invalid(latMin: 59, latSec: 59), isEmpty);
    });

    test('6-29 phút sai và độ vượt cùng lúc: đánh dấu cả hai ô (*)', () {
      expect(_invalid(latDeg: 91, latMin: 60), {
        ManualField.latDeg,
        ManualField.latMin,
      });
    });
  });
}
