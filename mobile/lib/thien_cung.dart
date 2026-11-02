import 'thien_cung_data.dart';

/// Một cặp số khớp với một dòng trong bảng.
class PairMatch {
  const PairMatch(this.pair, this.group);

  final String pair;
  final ThienCungGroup group;
}

/// Số lần một cung xuất hiện trong kết quả.
class PalaceTally {
  const PalaceTally({required this.groups, required this.count});

  /// Các dòng khác nhau đã gặp của cung này, theo thứ tự trong bảng.
  final List<ThienCungGroup> groups;
  final int count;

  ThienCungGroup get palace => groups.first;
}

class Conclusion {
  const Conclusion({required this.top, required this.warnings});

  /// Các cung xuất hiện nhiều nhất, theo thứ tự trong bảng.
  final List<PalaceTally> top;

  /// Các dòng `isWarning` đã gặp, không trùng, theo thứ tự trong bảng.
  final List<ThienCungGroup> warnings;

  bool get isEmpty => top.isEmpty;
}

/// Lấy chữ số trong [coordsText], tách cặp từ phải sang trái, cặp cuối lẻ thì
/// thêm `0` phía trước.
List<String> splitPairs(String coordsText) {
  final digits = coordsText.replaceAll(RegExp(r'\D'), '');
  return [
    for (var end = digits.length; end > 0; end -= 2)
      digits.substring(end < 2 ? 0 : end - 2, end).padLeft(2, '0'),
  ];
}

/// Mọi dòng trong bảng có chứa [pair], theo thứ tự trong bảng.
List<ThienCungGroup> lookupPair(
  String pair, {
  List<ThienCungGroup> table = thienCungTable,
}) {
  return table.where((row) => row.numbers.contains(pair)).toList();
}

/// Các kết quả khớp theo thứ tự của [pairs]; cặp không có trong bảng bị bỏ.
/// [table] chỉ để test dựng bảng có dòng chưa có dữ liệu.
List<PairMatch> matchPairs(
  List<String> pairs, {
  List<ThienCungGroup> table = thienCungTable,
}) {
  return [
    for (final pair in pairs)
      for (final row in lookupPair(pair, table: table)) PairMatch(pair, row),
  ];
}

/// Kết luận chỉ tính các dòng đã có ý nghĩa.
Conclusion buildConclusion(List<PairMatch> allMatches) {
  final matches = allMatches.where((match) => match.group.hasMeaning).toList();
  if (matches.isEmpty) {
    return const Conclusion(top: [], warnings: []);
  }

  final counts = <int, int>{};
  for (final match in matches) {
    final order = match.group.palaceOrder;
    counts[order] = (counts[order] ?? 0) + 1;
  }
  final highest = counts.values.reduce((a, b) => a > b ? a : b);

  final metRows = {for (final match in matches) match.group};
  final metInTableOrder = thienCungTable.where(metRows.contains).toList();
  final topOrders = {
    for (final row in metInTableOrder)
      if (counts[row.palaceOrder] == highest) row.palaceOrder,
  };

  return Conclusion(
    top: [
      for (final order in topOrders)
        PalaceTally(
          groups: metInTableOrder
              .where((row) => row.palaceOrder == order)
              .toList(),
          count: highest,
        ),
    ],
    warnings: metInTableOrder.where((row) => row.isWarning).toList(),
  );
}
