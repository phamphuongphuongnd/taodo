import 'package:flutter_test/flutter_test.dart';
import 'package:toado/coords.dart';

void main() {
  group('formatDmsCoords', () {
    test('đúng ví dụ chuẩn', () {
      expect(
        formatDmsCoords(21.028611, 105.803333),
        '21°01\'43"N 105°48\'12"E',
      );
    });

    test('phút và giây bù số 0, độ không bù', () {
      expect(formatDmsCoords(1.034167, 5.085), '1°02\'03"N 5°05\'06"E');
    });

    test('đủ 4 bán cầu, âm dùng giá trị tuyệt đối', () {
      expect(
        formatDmsCoords(21.028611, 105.803333),
        '21°01\'43"N 105°48\'12"E',
      );
      expect(
        formatDmsCoords(21.028611, -105.803333),
        '21°01\'43"N 105°48\'12"W',
      );
      expect(
        formatDmsCoords(-21.028611, 105.803333),
        '21°01\'43"S 105°48\'12"E',
      );
      expect(
        formatDmsCoords(-21.028611, -105.803333),
        '21°01\'43"S 105°48\'12"W',
      );
    });

    test('0,0 là N và E', () {
      expect(formatDmsCoords(0, 0), '0°00\'00"N 0°00\'00"E');
    });

    test('biên ±90 và ±180', () {
      expect(formatDmsCoords(90, 180), '90°00\'00"N 180°00\'00"E');
      expect(formatDmsCoords(-90, -180), '90°00\'00"S 180°00\'00"W');
    });

    test('giây làm tròn lên 60 nhớ sang phút', () {
      expect(formatDmsCoords(10.016665, 0), '10°01\'00"N 0°00\'00"E');
    });

    test('phút lên 60 nhớ sang độ', () {
      expect(formatDmsCoords(20.99999, 10.999999), '21°00\'00"N 11°00\'00"E');
      expect(formatDmsCoords(-20.99999, -10.999999), '21°00\'00"S 11°00\'00"W');
    });

    test('giây làm tròn thành số nguyên', () {
      expect(formatDmsCoords(0.000139, 0.000138), '0°00\'01"N 0°00\'00"E');
    });
  });

  group('formatManualCoords', () {
    String? manual({
      int latDeg = 0,
      int latMin = 0,
      int latSec = 0,
      bool north = true,
      int lonDeg = 0,
      int lonMin = 0,
      int lonSec = 0,
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

    test('đúng ví dụ chuẩn', () {
      expect(
        manual(
          latDeg: 21,
          latMin: 1,
          latSec: 43,
          lonDeg: 105,
          lonMin: 48,
          lonSec: 12,
        ),
        '21°01\'43"N 105°48\'12"E',
      );
    });

    test('chọn S và W', () {
      expect(
        manual(latDeg: 1, north: false, lonDeg: 2, east: false),
        '1°00\'00"S 2°00\'00"W',
      );
    });

    test('toàn 0 là hợp lệ', () {
      expect(manual(), '0°00\'00"N 0°00\'00"E');
    });

    test('biên 90° và 180° hợp lệ', () {
      expect(manual(latDeg: 90, lonDeg: 180), '90°00\'00"N 180°00\'00"E');
    });

    test('vượt 90° hoặc 180° là không hợp lệ', () {
      expect(manual(latDeg: 91), isNull);
      expect(manual(latDeg: 90, latSec: 1), isNull);
      expect(manual(lonDeg: 181), isNull);
      expect(manual(lonDeg: 180, lonMin: 1), isNull);
    });

    test('phút hoặc giây từ 60 trở lên là không hợp lệ', () {
      expect(manual(latMin: 60), isNull);
      expect(manual(latSec: 60), isNull);
      expect(manual(lonMin: 60), isNull);
      expect(manual(lonSec: 60), isNull);
    });

    test('số âm là không hợp lệ', () {
      expect(manual(latDeg: -1), isNull);
      expect(manual(lonSec: -1), isNull);
    });
  });
}
