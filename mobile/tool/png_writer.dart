// Ghi PNG không cần thư viện ngoài, dùng chung cho các tool xuất ảnh.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// PNG tối giản: RGB 8 bit (không kênh trong suốt) hoặc RGBA 8 bit.
void writePng(String path, int width, int height, Uint8List rgba,
    {required bool alpha}) {
  final channels = alpha ? 4 : 3;
  final stride = width * channels + 1;
  final raw = Uint8List(stride * height);
  for (var y = 0; y < height; y++) {
    var o = y * stride + 1;
    for (var x = 0; x < width; x++) {
      final i = (y * width + x) * 4;
      for (var c = 0; c < channels; c++) {
        raw[o++] = rgba[i + c];
      }
    }
  }
  final header = ByteData(13)
    ..setUint32(0, width)
    ..setUint32(4, height)
    ..setUint8(8, 8)
    ..setUint8(9, alpha ? 6 : 2);
  final out = BytesBuilder()
    ..add(const [137, 80, 78, 71, 13, 10, 26, 10])
    ..add(_chunk('IHDR', header.buffer.asUint8List()))
    ..add(_chunk('IDAT', Uint8List.fromList(zlib.encode(raw))))
    ..add(_chunk('IEND', Uint8List(0)));
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(out.toBytes());
}

Uint8List _chunk(String type, Uint8List data) {
  final typeBytes = ascii.encode(type);
  final out = ByteData(12 + data.length)..setUint32(0, data.length);
  final bytes = out.buffer.asUint8List()
    ..setRange(4, 8, typeBytes)
    ..setRange(8, 8 + data.length, data);
  out.setUint32(8 + data.length, _crc32(bytes.sublist(4, 8 + data.length)));
  return bytes;
}

final _crcTable = List<int>.generate(256, (n) {
  var c = n;
  for (var k = 0; k < 8; k++) {
    c = (c & 1) != 0 ? 0xEDB88320 ^ (c >>> 1) : c >>> 1;
  }
  return c;
});

int _crc32(Uint8List bytes) {
  var c = 0xFFFFFFFF;
  for (final b in bytes) {
    c = _crcTable[(c ^ b) & 0xFF] ^ (c >>> 8);
  }
  return c ^ 0xFFFFFFFF;
}
