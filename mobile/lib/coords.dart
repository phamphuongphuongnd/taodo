/// Định dạng tọa độ kiểu `21°01'43"N 105°48'12"E`.
String formatDmsCoords(double lat, double lon) {
  return '${_formatDms(lat, 'N', 'S')} ${_formatDms(lon, 'E', 'W')}';
}

/// Chuỗi tọa độ từ các ô nhập tay, `null` nếu giá trị không hợp lệ.
String? formatManualCoords({
  required int latDeg,
  required int latMin,
  required int latSec,
  required bool north,
  required int lonDeg,
  required int lonMin,
  required int lonSec,
  required bool east,
}) {
  final invalid = invalidManualFields(
    latDeg: latDeg,
    latMin: latMin,
    latSec: latSec,
    lonDeg: lonDeg,
    lonMin: lonMin,
    lonSec: lonSec,
  );
  if (invalid.isNotEmpty) return null;
  return '${_dmsText(_totalSeconds(latDeg, latMin, latSec), north ? 'N' : 'S')} '
      '${_dmsText(_totalSeconds(lonDeg, lonMin, lonSec), east ? 'E' : 'W')}';
}

enum ManualField { latDeg, latMin, latSec, lonDeg, lonMin, lonSec }

/// Các ô nhập tay bị sai, rỗng khi [formatManualCoords] nhận được.
Set<ManualField> invalidManualFields({
  required int latDeg,
  required int latMin,
  required int latSec,
  required int lonDeg,
  required int lonMin,
  required int lonSec,
}) {
  Iterable<ManualField> check(
    int degrees,
    int minutes,
    int seconds,
    int maxDegrees,
    ManualField degreeField,
    ManualField minuteField,
    ManualField secondField,
  ) sync* {
    final badMinutes = minutes < 0 || minutes > 59;
    final badSeconds = seconds < 0 || seconds > 59;
    if (badMinutes) yield minuteField;
    if (badSeconds) yield secondField;
    final total = _totalSeconds(degrees, minutes, seconds);
    if (degrees < 0 ||
        degrees > maxDegrees ||
        (!badMinutes && !badSeconds && total > maxDegrees * 3600)) {
      yield degreeField;
    }
  }

  return {
    ...check(
      latDeg,
      latMin,
      latSec,
      90,
      ManualField.latDeg,
      ManualField.latMin,
      ManualField.latSec,
    ),
    ...check(
      lonDeg,
      lonMin,
      lonSec,
      180,
      ManualField.lonDeg,
      ManualField.lonMin,
      ManualField.lonSec,
    ),
  };
}

int _totalSeconds(int degrees, int minutes, int seconds) =>
    degrees * 3600 + minutes * 60 + seconds;

/// Cắt bỏ phần lẻ của giây. Cộng thêm một lượng rất nhỏ để số đúng tròn giây
/// không bị hụt 1 giây do sai số của phép tính số thực.
String _formatDms(double value, String positive, String negative) {
  final totalSeconds = (value.abs() * 3600 + 1e-6).floor();
  return _dmsText(totalSeconds, value >= 0 ? positive : negative);
}

String _dmsText(int totalSeconds, String hemisphere) {
  final degrees = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;
  final text =
      '${_twoDigits(degrees)}°${_twoDigits(minutes)}\'${_twoDigits(seconds)}"';
  return '$text$hemisphere';
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');
