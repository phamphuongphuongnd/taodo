// Ý nghĩa tiếng Việt (meaningVi) do người dùng cung cấp; meaningEn dịch từ đó.
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
    meaningVi: 'Năng lượng đỉnh cao về tiền tài, biểu thị sự hanh thông lớn, dễ nắm bắt đại cơ hội.',
    meaningEn: 'Peak energy for money, signifying great smoothness and an ease in seizing major opportunities.',
  ),
  ThienCungGroup(
    palaceOrder: 0,
    palaceVi: 'Thiên Tài',
    palaceEn: 'Fortune',
    groupVi: 'Trung tài',
    groupEn: 'Moderate Fortune',
    numbers: ['68', '86'],
    meaningVi: 'Năng lượng phát lộc ở mức khá, rất thuận lợi cho việc giao thương, kinh doanh nhỏ và vừa.',
    meaningEn: 'A good level of prosperity energy, very favorable for trade and small to medium businesses.',
  ),
  ThienCungGroup(
    palaceOrder: 0,
    palaceVi: 'Thiên Tài',
    palaceEn: 'Fortune',
    groupVi: 'Tiểu tài',
    groupEn: 'Minor Fortune',
    numbers: ['27', '72', '49', '94'],
    meaningVi:
        'Các nguồn lộc nhỏ, lộc vặt, hoặc nguồn thu nhập đều đặn, bình ổn.',
    meaningEn: 'Small sources of luck, minor windfalls, or a regular and stable income.',
  ),
  ThienCungGroup(
    palaceOrder: 1,
    palaceVi: 'Quan Lộc',
    palaceEn: 'Career',
    groupVi: 'Đại quan',
    groupEn: 'High Office',
    numbers: ['19', '91'],
    meaningVi: 'Năng lượng của người đứng đầu, mang tố chất lãnh đạo tối cao, quản lý vạn người.',
    meaningEn: 'The energy of a head figure, with supreme leadership qualities, managing many people.',
  ),
  ThienCungGroup(
    palaceOrder: 1,
    palaceVi: 'Quan Lộc',
    palaceEn: 'Career',
    groupVi: 'Thượng quan',
    groupEn: 'Senior Office',
    numbers: ['26', '62'],
    meaningVi: 'Vị trí cốt cán trong bộ máy, quan chức cấp cao có uy tín và sức ảnh hưởng sâu rộng.',
    meaningEn: 'A core position in the organization: a senior official with prestige and wide influence.',
  ),
  ThienCungGroup(
    palaceOrder: 1,
    palaceVi: 'Quan Lộc',
    palaceEn: 'Career',
    groupVi: 'Trung quan',
    groupEn: 'Middle Office',
    numbers: ['78', '87'],
    meaningVi: 'Cấp quản lý tầm trung, sự nghiệp thăng tiến theo lộ trình ổn định, bền vững.',
    meaningEn: 'Mid-level management, with a career advancing along a stable and lasting path.',
  ),
  ThienCungGroup(
    palaceOrder: 1,
    palaceVi: 'Quan Lộc',
    palaceEn: 'Career',
    groupVi: 'Quan nhỏ',
    groupEn: 'Minor Office',
    numbers: ['46', '64'],
    meaningVi: 'Công chức mẫn cán, cấp quản lý cơ sở hoặc nhân viên hành chính, ít sóng gió.',
    meaningEn: 'A diligent civil servant, frontline manager or administrative employee, with few upheavals.',
  ),
  ThienCungGroup(
    palaceOrder: 1,
    palaceVi: 'Quan Lộc',
    palaceEn: 'Career',
    groupVi: 'Hạ quan',
    groupEn: 'Lower Office',
    numbers: ['43', '34'],
    meaningVi: 'Vị trí thực thi ở cấp thấp nhất trong hệ thống, công danh bình thường, ít có sự bứt phá.',
    meaningEn: 'An executing role at the lowest level of the system, with an ordinary career and few breakthroughs.',
  ),
  ThienCungGroup(
    palaceOrder: 2,
    palaceVi: 'Thông Minh',
    palaceEn: 'Intelligence',
    groupVi: 'IQ cao',
    groupEn: 'High IQ',
    numbers: ['27', '72'],
    meaningVi: 'Sóng não có ngộ tính rất cao, tư duy nhạy bén vượt trội, học một biết mười.',
    meaningEn: 'Brainwaves with very high insight, outstandingly sharp thinking, grasping much from little.',
  ),
  ThienCungGroup(
    palaceOrder: 2,
    palaceVi: 'Thông Minh',
    palaceEn: 'Intelligence',
    groupVi: 'IQ trung bình khá',
    groupEn: 'Above-average IQ',
    numbers: ['49', '94'],
    meaningVi: 'Tư duy logic ở mức khá giỏi, đủ năng lực học tập vững vàng và xử lý tốt công việc thực tế.',
    meaningEn: 'Fairly strong logical thinking, able to study steadily and handle practical work well.',
  ),
  ThienCungGroup(
    palaceOrder: 3,
    palaceVi: 'Thần Linh Trời Định',
    palaceEn: 'Divine Destiny',
    groupVi: 'Đất của trời',
    groupEn: 'Land of Heaven',
    numbers: ['17', '71'],
    meaningVi: 'Vùng đất do trời ban: người có căn nguyên thì nền tảng phúc đức dày, thuận lợi về nhà đất, nơi ở và có chỗ dựa vững chắc; người không có căn nguyên thì không giữ nổi, dễ gặp tai họa, như dân thường ngồi lên ngai vua.',
    meaningEn: 'Land granted by heaven: for those with a karmic root, a deep foundation of merit, favoring property and home with solid support; for those without one, it cannot be held and invites calamity, like a commoner sitting on the king\'s throne.',
  ),
  ThienCungGroup(
    palaceOrder: 3,
    palaceVi: 'Thần Linh Trời Định',
    palaceEn: 'Divine Destiny',
    groupVi: 'Số trời',
    groupEn: 'Heavenly Fate',
    numbers: ['72', '27'],
    meaningVi: 'Vận mệnh do trời sắp đặt: người có căn nguyên thì cơ duyên đến bất ngờ, biết thuận theo tự nhiên và nắm đúng thời cơ; người không có căn nguyên thì không gánh nổi, dễ gặp tai họa, như dân thường ngồi lên ngai vua.',
    meaningEn: 'A fate arranged by heaven: for those with a karmic root, unexpected opportunities that suit following the natural course and seizing the right moment; for those without one, it is too heavy to bear and invites calamity, like a commoner sitting on the king\'s throne.',
  ),
  ThienCungGroup(
    palaceOrder: 4,
    palaceVi: 'Tích Lũy Tài Sản',
    palaceEn: 'Wealth Accumulation',
    numbers: ['74', '47', '14', '41'],
    meaningVi: 'Tiền của đến chậm mà chắc, biết tiết kiệm và tích góp từng chút, tài sản tăng đều theo năm tháng nhờ sự bền bỉ.',
    meaningEn: 'Money comes slowly but surely: thrifty and saving bit by bit, with assets growing steadily over the years through perseverance.',
  ),
  ThienCungGroup(
    palaceOrder: 5,
    palaceVi: 'Linh Ứng',
    palaceEn: 'Spiritual Response',
    numbers: ['18', '81', '24', '42', '63', '36'],
    meaningVi: 'Vùng đất dành cho việc thờ cúng, muốn phát đạt thì phải thờ cúng nhiều.',
    meaningEn:
        'Land meant for worship: to prosper, one must worship abundantly.',
  ),
  ThienCungGroup(
    palaceOrder: 6,
    palaceVi: 'Đào Hoa',
    palaceEn: 'Romance',
    groupVi: 'May mắn',
    groupEn: 'Fortunate',
    numbers: ['38', '83'],
    meaningVi: 'Nhân duyên tốt đẹp, được mọi người yêu mến, tình cảm gia đình thuận lợi, hòa hợp (đặc biệt bổ trợ rất tốt cho phụ nữ).',
    meaningEn: 'Good relationships, loved by everyone, with smooth and harmonious family bonds (especially supportive for women).',
  ),
  ThienCungGroup(
    palaceOrder: 6,
    palaceVi: 'Đào Hoa',
    palaceEn: 'Romance',
    groupVi: 'Tai họa',
    groupEn: 'Misfortune',
    numbers: ['16', '61'],
    meaningVi: 'Dễ dẫn đến rắc rối thị phi, tai tiếng liên quan đến tình cảm, nội bộ gia đình lục đục hoặc hôn nhân rạn nứt.',
    meaningEn: 'Easily leads to gossip and scandal around love, family discord or a fractured marriage.',
    isWarning: true,
  ),
  ThienCungGroup(
    palaceOrder: 7,
    palaceVi: 'Chăm Chỉ',
    palaceEn: 'Diligence',
    numbers: ['12', '21', '69', '96'],
    meaningVi: 'Chịu khó, kiên trì và có trách nhiệm, thành quả đến từ sự cần cù và làm việc đều đặn hơn là từ may mắn.',
    meaningEn: 'Hardworking, persistent and responsible, with results coming from diligence and steady effort rather than luck.',
  ),
  ThienCungGroup(
    palaceOrder: 8,
    palaceVi: 'Bảo Vệ',
    palaceEn: 'Protection',
    numbers: ['00', '11', '22', '33', '44', '55', '66', '77', '88', '99'],
    meaningVi: 'Mang năng lượng bảo vệ và giữ vững những thành quả mà bản thân đã làm ra, giúp cuộc sống bình ổn trước sóng gió biến động chứ không tự sinh ra tiền tài ảo.',
    meaningEn: 'Carries energy that protects and preserves what you have achieved, keeping life stable through upheaval rather than creating illusory wealth.',
  ),
  ThienCungGroup(
    palaceOrder: 9,
    palaceVi: 'Đạo Đức',
    palaceEn: 'Virtue',
    numbers: ['28', '82', '39', '93'],
    meaningVi: 'Sống trọng đạo lý và chữ tín, được người khác kính trọng, tích được phúc đức và hậu vận bình an.',
    meaningEn: 'Living by principle and trustworthiness, respected by others, accumulating merit and enjoying a peaceful later life.',
  ),
  ThienCungGroup(
    palaceOrder: 10,
    palaceVi: 'Tai Họa',
    palaceEn: 'Misfortune',
    numbers: ['23', '32', '34', '43', '89', '98', '16', '61'],
    meaningVi: 'Dễ kích hoạt các vận hạn tiêu cực như suy giảm sức khỏe, tai nạn tai ương, tổn hao sản nghiệp, tranh chấp pháp lý hoặc thị phi bủa vây.',
    meaningEn: 'Easily triggers negative fortunes such as declining health, accidents and calamities, loss of property, legal disputes or surrounding gossip.',
    isWarning: true,
  ),
];
