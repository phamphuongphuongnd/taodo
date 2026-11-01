import 'package:flutter_test/flutter_test.dart';
import 'package:toado/coords.dart';

void main() {
  group('formatDmsCoords', () {
    test('đúng ví dụ chuẩn', () {
      expect(formatDmsCoords(21.02862, 105.80334), '21°01\'43"N 105°48\'12"E');
    });

    test('cắt bỏ phần lẻ của giây, không làm tròn lên', () {
      // 20.302431 là 18'08.75", 106.377830 là 22'40.19".
      expect(
        formatDmsCoords(20.302431, 106.377830),
        '20°18\'08"N 106°22\'40"E',
      );
    });

    test('số đúng tròn giây không bị hụt 1 giây do sai số tính toán', () {
      expect(formatDmsCoords(8.77, 0.1), '08°46\'12"N 00°06\'00"E');
      expect(
        formatDmsCoords(21 + 1 / 60 + 43 / 3600, 105 + 48 / 60 + 12 / 3600),
        '21°01\'43"N 105°48\'12"E',
      );
    });

    test('độ, phút và giây đều bù đủ 2 chữ số', () {
      expect(formatDmsCoords(1.034167, 5.085), '01°02\'03"N 05°05\'06"E');
    });

    test('vĩ độ 1 chữ số thêm 0 phía trước', () {
      expect(formatDmsCoords(8.77, 105.80334), '08°46\'12"N 105°48\'12"E');
    });

    test('đủ 4 bán cầu, âm dùng giá trị tuyệt đối', () {
      expect(formatDmsCoords(21.02862, 105.80334), '21°01\'43"N 105°48\'12"E');
      expect(formatDmsCoords(21.02862, -105.80334), '21°01\'43"N 105°48\'12"W');
      expect(formatDmsCoords(-21.02862, 105.80334), '21°01\'43"S 105°48\'12"E');
      expect(
        formatDmsCoords(-21.02862, -105.80334),
        '21°01\'43"S 105°48\'12"W',
      );
    });

    test('0,0 là N và E', () {
      expect(formatDmsCoords(0, 0), '00°00\'00"N 00°00\'00"E');
    });

    test('biên ±90 và ±180', () {
      expect(formatDmsCoords(90, 180), '90°00\'00"N 180°00\'00"E');
      expect(formatDmsCoords(-90, -180), '90°00\'00"S 180°00\'00"W');
    });

    test('gần tròn phút vẫn giữ nguyên phút, không nhớ lên', () {
      expect(formatDmsCoords(10.016665, 0), '10°00\'59"N 00°00\'00"E');
    });

    test('gần tròn độ vẫn giữ nguyên độ, không nhớ lên', () {
      expect(formatDmsCoords(20.99999, 10.999999), '20°59\'59"N 10°59\'59"E');
      expect(formatDmsCoords(-20.99999, -10.999999), '20°59\'59"S 10°59\'59"W');
    });

    test('dưới 1 giây thì ra 00', () {
      expect(formatDmsCoords(0.000139, 0.000138), '00°00\'00"N 00°00\'00"E');
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
        '01°00\'00"S 02°00\'00"W',
      );
    });

    test('toàn 0 là hợp lệ', () {
      expect(manual(), '00°00\'00"N 00°00\'00"E');
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
