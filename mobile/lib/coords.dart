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
  final latTotal = _manualTotalSeconds(latDeg, latMin, latSec, 90);
  final lonTotal = _manualTotalSeconds(lonDeg, lonMin, lonSec, 180);
  if (latTotal == null || lonTotal == null) {
    return null;
  }
  return '${_dmsText(latTotal, north ? 'N' : 'S')} '
      '${_dmsText(lonTotal, east ? 'E' : 'W')}';
}

int? _manualTotalSeconds(
  int degrees,
  int minutes,
  int seconds,
  int maxDegrees,
) {
  if (degrees < 0 || minutes < 0 || minutes > 59) return null;
  if (seconds < 0 || seconds > 59) return null;
  final total = degrees * 3600 + minutes * 60 + seconds;
  return total <= maxDegrees * 3600 ? total : null;
}

/// Làm tròn tổng số giây trước rồi mới chia, để giây và phút tự nhớ lên.
String _formatDms(double value, String positive, String negative) {
  final totalSeconds = (value.abs() * 3600).round();
  return _dmsText(totalSeconds, value >= 0 ? positive : negative);
}

String _dmsText(int totalSeconds, String hemisphere) {
  final degrees = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;
  return '$degrees°${_twoDigits(minutes)}\'${_twoDigits(seconds)}"$hemisphere';
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');
