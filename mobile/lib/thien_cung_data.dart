// Ý nghĩa tiếng Việt (meaningVi) theo nội dung chủ app đưa, đã biên tập cho dễ
// nghe; meaningEn dịch từ đó.
// Dòng chưa có dữ liệu để meaningVi và meaningEn rỗng.

/// Một dòng trong Bảng số Thiên Cung: một cung, hoặc một nhóm trong cung.
class ThienCungGroup {
  const ThienCungGroup({
    required this.palaceOrder,
    required this.palaceVi,
    required this.palaceEn,
    this.groupVi,
    this.groupEn,
    required this.numbers,
    required this.meaningVi,
    required this.meaningEn,
    this.isWarning = false,
  });

  /// Thứ tự cung trong bảng, từ 0 (Thiên Tài) đến 10 (Tai Họa).
  final int palaceOrder;
  final String palaceVi;
  final String palaceEn;
  final String? groupVi;
  final String? groupEn;

  /// Các cặp số đủ 2 chữ số, ví dụ `'00'`.
  final List<String> numbers;
  final String meaningVi;
  final String meaningEn;

  /// True với Cung Tai Họa và nhóm Tai họa của Đào Hoa.
  final bool isWarning;

  /// False với dòng chưa có dữ liệu.
  bool get hasMeaning => meaningVi.isNotEmpty;
}

const List<ThienCungGroup> thienCungTable = [
  ThienCungGroup(
    palaceOrder: 0,
    palaceVi: 'Thiên Tài',
    palaceEn: 'Fortune',
    groupVi: 'Đại tài',
    groupEn: 'Great Fortune',
    numbers: ['13', '31'],
    meaningVi: 'Vận tài lộc ở đỉnh cao: tiền bạc hanh thông, cơ hội lớn dễ đến và dễ nắm bắt.',
    meaningEn: 'Wealth at its peak: money flows freely, and great opportunities arrive and are easy to seize.',
  ),
  ThienCungGroup(
    palaceOrder: 0,
    palaceVi: 'Thiên Tài',
    palaceEn: 'Fortune',
    groupVi: 'Trung tài',
    groupEn: 'Moderate Fortune',
    numbers: ['68', '86'],
    meaningVi: 'Tài lộc dồi dào ở mức khá, rất thuận cho buôn bán, giao thương và kinh doanh vừa và nhỏ.',
    meaningEn: 'Healthy, generous fortune, especially favorable for trade and small to medium businesses.',
  ),
  ThienCungGroup(
    palaceOrder: 0,
    palaceVi: 'Thiên Tài',
    palaceEn: 'Fortune',
    groupVi: 'Tiểu tài',
    groupEn: 'Minor Fortune',
    numbers: ['27', '72', '49', '94'],
    meaningVi: 'Lộc nhỏ mà đều, thu nhập ổn định, đủ để cuộc sống luôn an tâm.',
    meaningEn:
        'Small but steady blessings: a stable income that keeps life secure.',
  ),
  ThienCungGroup(
    palaceOrder: 1,
    palaceVi: 'Quan Lộc',
    palaceEn: 'Career',
    groupVi: 'Đại quan',
    groupEn: 'High Office',
    numbers: ['19', '91'],
    meaningVi: 'Khí chất của người đứng đầu, có tài lãnh đạo và đủ uy để dẫn dắt nhiều người.',
    meaningEn: 'The presence of a true leader, with the talent and authority to guide many people.',
  ),
  ThienCungGroup(
    palaceOrder: 1,
    palaceVi: 'Quan Lộc',
    palaceEn: 'Career',
    groupVi: 'Thượng quan',
    groupEn: 'Senior Office',
    numbers: ['26', '62'],
    meaningVi: 'Vị trí trọng yếu trong bộ máy, có uy tín cao và tiếng nói được nhiều người nể trọng.',
    meaningEn: 'A key position at a high level, with strong standing and a voice others respect.',
  ),
  ThienCungGroup(
    palaceOrder: 1,
    palaceVi: 'Quan Lộc',
    palaceEn: 'Career',
    groupVi: 'Trung quan',
    groupEn: 'Middle Office',
    numbers: ['78', '87'],
    meaningVi: 'Đường công danh vững vàng, thăng tiến từng bước lên cấp quản lý, ổn định và bền lâu.',
    meaningEn: 'A solid career path, rising step by step into management, stable and lasting.',
  ),
  ThienCungGroup(
    palaceOrder: 1,
    palaceVi: 'Quan Lộc',
    palaceEn: 'Career',
    groupVi: 'Quan nhỏ',
    groupEn: 'Minor Office',
    numbers: ['46', '64'],
    meaningVi: 'Công việc ổn định nơi công sở, làm tròn bổn phận, được tin cậy và ít sóng gió.',
    meaningEn: 'Steady office work, duties done well, trusted by others and free of major storms.',
  ),
  ThienCungGroup(
    palaceOrder: 1,
    palaceVi: 'Quan Lộc',
    palaceEn: 'Career',
    groupVi: 'Hạ quan',
    groupEn: 'Lower Office',
    numbers: ['43', '34'],
    meaningVi: 'Công danh bình lặng, gắn với công việc thực thi; muốn tiến xa cần thêm nỗ lực và thời gian.',
    meaningEn: 'A quiet career rooted in hands-on work; going further takes extra effort and time.',
  ),
  ThienCungGroup(
    palaceOrder: 2,
    palaceVi: 'Thông Minh',
    palaceEn: 'Intelligence',
    groupVi: 'IQ cao',
    groupEn: 'High IQ',
    numbers: ['27', '72'],
    meaningVi:
        'Trí tuệ sáng, ngộ tính cao, tư duy nhạy bén, học một biết mười.',
    meaningEn: 'A bright mind with deep insight and quick thinking, learning one thing and grasping ten.',
  ),
  ThienCungGroup(
    palaceOrder: 2,
    palaceVi: 'Thông Minh',
    palaceEn: 'Intelligence',
    groupVi: 'IQ trung bình khá',
    groupEn: 'Above-average IQ',
    numbers: ['49', '94'],
    meaningVi: 'Đầu óc logic, học hành vững vàng, xử lý công việc thực tế gọn gàng và hiệu quả.',
    meaningEn:
        'A logical mind, steady in study and efficient with practical work.',
  ),
  ThienCungGroup(
    palaceOrder: 3,
    palaceVi: 'Thần Linh Trời Định',
    palaceEn: 'Divine Destiny',
    groupVi: 'Đất của trời',
    groupEn: 'Land of Heaven',
    numbers: ['17', '71'],
    meaningVi: 'Vùng đất trời ban. Người có căn nguyên được phúc đức dày, nhà đất thuận lợi, có chỗ dựa vững chắc. Người chưa đủ căn nguyên khó giữ bền và dễ gặp trắc trở.',
    meaningEn: 'Land granted by heaven. Those with a karmic root enjoy deep merit, good fortune with property and solid support. Those without it struggle to hold on and meet hardship.',
  ),
  ThienCungGroup(
    palaceOrder: 3,
    palaceVi: 'Thần Linh Trời Định',
    palaceEn: 'Divine Destiny',
    groupVi: 'Số trời',
    groupEn: 'Heavenly Fate',
    numbers: ['72', '27'],
    meaningVi: 'Vận mệnh do trời sắp đặt. Người có căn nguyên gặp cơ duyên bất ngờ, thuận theo tự nhiên và nắm đúng thời cơ. Người chưa đủ căn nguyên khó gánh được và dễ gặp trắc trở.',
    meaningEn: 'A fate arranged by heaven. Those with a karmic root meet unexpected chances, follow the natural course and seize the moment. Those without it find it too heavy and meet hardship.',
  ),
  ThienCungGroup(
    palaceOrder: 4,
    palaceVi: 'Tích Lũy Tài Sản',
    palaceEn: 'Wealth Accumulation',
    numbers: ['74', '47', '14', '41'],
    meaningVi: 'Tiền của đến chậm mà chắc, nhờ chi tiêu khéo và tích góp bền bỉ nên tài sản lớn dần theo năm tháng.',
    meaningEn: 'Money comes slowly but surely: careful spending and patient saving let your assets grow over the years.',
  ),
  ThienCungGroup(
    palaceOrder: 5,
    palaceVi: 'Linh Ứng',
    palaceEn: 'Spiritual Response',
    numbers: ['18', '81', '24', '42', '63', '36'],
    meaningVi: 'Vùng đất linh thiêng, hợp với việc thờ cúng; càng giữ lòng thành và chăm lo hương khói thì càng phát đạt.',
    meaningEn: 'Sacred ground suited to worship: the more sincerely you tend your offerings, the more you prosper.',
  ),
  ThienCungGroup(
    palaceOrder: 6,
    palaceVi: 'Đào Hoa',
    palaceEn: 'Romance',
    groupVi: 'May mắn',
    groupEn: 'Fortunate',
    numbers: ['38', '83'],
    meaningVi: 'Nhân duyên đẹp, được nhiều người quý mến, gia đình êm ấm, hòa thuận; đặc biệt tốt cho phụ nữ.',
    meaningEn: 'Lovely relationships, the affection of many and a warm, harmonious family; especially good for women.',
  ),
  ThienCungGroup(
    palaceOrder: 6,
    palaceVi: 'Đào Hoa',
    palaceEn: 'Romance',
    groupVi: 'Tai họa',
    groupEn: 'Misfortune',
    numbers: ['16', '61'],
    meaningVi: 'Tình cảm dễ vướng thị phi, gia đạo kém êm ấm, hôn nhân cần được giữ gìn và vun đắp nhiều hơn.',
    meaningEn: 'Love attracts gossip and home life can turn restless, so a marriage needs extra care and attention.',
    isWarning: true,
  ),
  ThienCungGroup(
    palaceOrder: 7,
    palaceVi: 'Chăm Chỉ',
    palaceEn: 'Diligence',
    numbers: ['12', '21', '69', '96'],
    meaningVi: 'Cần cù, bền bỉ và có trách nhiệm; thành quả đến từ công sức đều đặn hơn là từ may mắn.',
    meaningEn: 'Hardworking, persistent and responsible; results come from steady effort more than from luck.',
  ),
  ThienCungGroup(
    palaceOrder: 8,
    palaceVi: 'Bảo Vệ',
    palaceEn: 'Protection',
    numbers: ['00', '11', '22', '33', '44', '55', '66', '77', '88', '99'],
    meaningVi: 'Năng lượng che chở, giúp giữ vững thành quả đã tạo dựng và bình ổn trước sóng gió, chứ không tự sinh ra tiền tài.',
    meaningEn: 'A sheltering energy that keeps what you have built safe and steady through storms, though it does not create wealth by itself.',
  ),
  ThienCungGroup(
    palaceOrder: 9,
    palaceVi: 'Đạo Đức',
    palaceEn: 'Virtue',
    numbers: ['28', '82', '39', '93'],
    meaningVi: 'Sống trọng đạo lý và chữ tín, được người đời kính nể, phúc đức tích dày, hậu vận bình an.',
    meaningEn: 'A life of principle and good faith, respected by others, rich in merit, with peaceful later years.',
  ),
  ThienCungGroup(
    palaceOrder: 10,
    palaceVi: 'Tai Họa',
    palaceEn: 'Misfortune',
    numbers: ['23', '32', '34', '43', '89', '98', '16', '61'],
    meaningVi: 'Vận hạn cần đề phòng: nên giữ gìn sức khỏe, cẩn thận đi lại, giữ chắc tài sản và tránh tranh chấp, thị phi.',
    meaningEn: 'A period that calls for care: look after your health, travel safely, protect your assets and avoid disputes and gossip.',
    isWarning: true,
  ),
];
