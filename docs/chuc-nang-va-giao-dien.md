# Tọa Độ — Chức năng và giao diện hiện có

Tài liệu mô tả đúng những gì app đang có, tính đến lần cập nhật ngày 2026-11-02. Nội dung lấy từ code trong `mobile/lib/`; các câu Kết luận ở mục 7 lấy từ logic thật của app. Thiết kế gốc nằm ở `design-mobile/`.

## 1. Tóm tắt app

- **Tên hiển thị:** Tọa Độ (`com.phuong.toado`, phiên bản 1.0.0).
- **Nền tảng:** app native viết bằng Flutter, dùng bộ widget Cupertino trên cả Android và iOS. Mới build và thử trên
  Android; iOS chưa build.
- **Việc app làm:** lấy tọa độ hiện tại từ GPS hoặc do người dùng nhập tay, tách thành các cặp số, tra trong Bảng số
  Thiên Cung rồi đưa ra ý nghĩa và kết luận cho vị trí đó.
- **Đặc điểm:** chạy offline, không có server, không có tài khoản, bản release không có quyền Internet.
- **Quy mô giao diện:** 4 màn hình và trang giấy phép mã nguồn mở, 2 ngôn ngữ (Việt, Anh), chỉ có giao diện tối.

```text
Màn hình chính ──[Xem]───────────────────────────────► Kết quả
       │                                                  ▲
       ├──[Nhập tay]──► Nhập tọa độ ──[Xem, nếu hợp lệ]───┘
       │
       └──[nút i]─────► Thông tin ──[Giấy phép]──► Trang giấy phép

Các trang con quay lại bằng nút "Quay lại" hoặc cử chỉ quay lại của máy.
```

## 2. Danh sách chức năng

### Đo vị trí

| Chức năng | Cách hoạt động |
| --- | --- |
| Đo GPS liên tục | Tọa độ cập nhật khoảng 1 giây một lần (Android) khi màn hình chính đang hiện, không gọi mạng |
| Hiện tọa độ dạng độ-phút-giây | Dạng `21°01'43"N 105°48'12"E`, tách hai dòng vĩ độ và kinh độ; độ, phút, giây đủ ít nhất 2 chữ số; giây cắt bỏ phần lẻ, không làm tròn |
| Xin quyền vị trí | Màn hình giải thích và nút "Cho phép" hiện trước, rồi mới bật hộp thoại của hệ thống; mỗi lần mở app hỏi tối đa một lần |
| Báo trạng thái chưa có tọa độ | 4 trường hợp: đang chờ GPS (kèm gợi ý ra nơi thoáng, bật Wi-Fi), cần xin quyền, đã từ chối quyền, định vị đang tắt |
| Dòng giới thiệu | Màn hình chính luôn có một dòng giải thích ngắn app làm gì (`appIntro`), ở mọi trạng thái |
| Mở Cài đặt | Có nút khi đã từ chối quyền (mở cài đặt app) hoặc định vị tắt (mở cài đặt vị trí) |
| Tự đo lại | Khi quay lại app, kể cả từ Cài đặt; khi từ trang con về màn hình chính; khi bật/tắt định vị từ thanh thông báo |
| Mất tín hiệu | 60 giây không có số mới thì về trạng thái chờ, không giữ số cũ như thể vừa đo; luồng vị trí lỗi thì tự mở lại sau 5 giây |
| Tiết kiệm pin | Ngừng đo khi app xuống nền và khi Nhập tọa độ, Kết quả hoặc Thông tin che màn hình chính; không đo nền. Trang con che thì giữ tọa độ đang có (`suspend()`), về là đo tiếp không phải chờ; số giữ lại vẫn hết hạn sau 60 giây nếu không có số mới. Ra nền rồi quay lại app thì xóa số và chờ số mới |

### Nhập tay

| Chức năng | Cách hoạt động |
| --- | --- |
| Nhập độ, phút, giây | 6 ô số: 3 ô cho vĩ độ, 3 ô cho kinh độ; luôn vào được, kể cả khi chưa có GPS hoặc không cấp quyền |
| Chọn bán cầu | Công tắc N/S cho vĩ độ, E/W cho kinh độ; mặc định N và E |
| Giới hạn khi gõ | Chỉ nhận chữ số; ô độ tối đa 3 chữ số, ô phút và giây tối đa 2 chữ số |
| Ô trống | Tính là 0; để trống cả 6 ô vẫn xem được |
| Kiểm tra hợp lệ | Khi bấm "Xem": phút và giây dưới 60, vĩ độ tối đa 90°, kinh độ tối đa 180° (đúng 90° hoặc 180° thì phút và giây phải bằng 0) |
| Báo lỗi | Ô sai chuyển màu cam và hộp lỗi hiện trên nút "Xem"; tự ẩn khi sửa bất kỳ ô nào hoặc đổi bán cầu |

### Kết quả

| Chức năng | Cách hoạt động |
| --- | --- |
| Giữ cố định tọa độ | Lấy tọa độ tại lúc bấm "Xem", không cập nhật theo GPS nữa |
| Tách cặp số | Lấy mọi chữ số, tách từ phải sang trái, cặp cuối lẻ thì thêm `0` phía trước |
| Tra bảng | Mỗi cặp tra trong bảng; một cặp có thể khớp nhiều dòng; cặp không có trong bảng bị ẩn |
| Hiện danh sách | Mỗi dòng gồm cặp số, tên cung (kèm nhóm nếu có) và ý nghĩa, theo thứ tự cặp gặp đầu tiên |
| Cặp lặp lại | Chỉ hiện một dòng, ghi `×N` cạnh tên cung; số lần vẫn được cộng đủ vào Kết luận |
| Kết luận | Đoạn văn nêu **tất cả** cung gặp trong tọa độ, mỗi cung kèm một ý diễn giải ngắn; cung nhiều lần nhất nêu trước |
| Lưu ý xấu | Gặp Cung Tai Họa hoặc nhóm Tai họa của Đào Hoa thì thêm hộp lưu ý màu cam, kể cả khi không phải cung nhiều nhất |
| Dòng nhắc | Ngay dưới thẻ Kết luận có một dòng chữ mờ (`resultNotice`): GPS dao động vài giây nên kết quả có thể khác giữa các lần đo, nội dung chỉ mang tính tham khảo. Không hiện khi tọa độ không khớp số nào |
| Dòng chưa có dữ liệu | Bảng hiện đủ ý nghĩa nên không xảy ra. Code vẫn giữ phương án dự phòng: dòng thiếu ý nghĩa hiện "Chưa có dữ liệu" với ô nét đứt và không tính vào Kết luận |

### Thông tin

| Chức năng | Cách hoạt động |
| --- | --- |
| Phiên bản | Hiện dưới tiêu đề trang |
| Bảng số Thiên Cung | Thẻ đầu tiên, giải thích cặp số trong bảng và cách app tách, tra rồi tổng hợp thành Kết luận |
| Quyền riêng tư | Tóm tắt ngay trong app, kèm đường link chính sách đầy đủ |
| Lưu ý khi dùng | Tọa độ có sai số, không dùng để dẫn đường; Bảng số chỉ mang tính tham khảo |
| Liên hệ và báo lỗi | Kèm đường link trang báo lỗi |
| Giấy phép mã nguồn mở | Mở trang giấy phép của Flutter |

App không có quyền Internet nên các đường link là chữ thường. Toàn trang chọn được chữ để sao chép.

### Ngôn ngữ

| Chức năng | Cách hoạt động |
| --- | --- |
| Lần mở đầu | Máy tiếng Việt ra tiếng Việt, ngôn ngữ khác ra tiếng Anh |
| Đổi ngôn ngữ | Nút ở góc màn hình chính, đổi là áp dụng ngay |
| Lưu lựa chọn | Lưu trên máy, mở lại app vẫn giữ |
| Nhãn hệ thống | Menu chọn chữ (Sao chép, Dán) và trang giấy phép đi theo ngôn ngữ app |

Số tọa độ và các chữ N/S/E/W không đổi theo ngôn ngữ.

### Trợ năng

| Chức năng | Cách hoạt động |
| --- | --- |
| Trình đọc màn hình | Tọa độ đọc thành lời ("Vĩ độ 21 độ 1 phút 43 giây Bắc…"), không đọc lại mỗi giây; `×4` đọc thành "4 lần"; hộp lỗi tự được đọc |
| Giảm chuyển động | Máy bật giảm chuyển động thì các hoạt ảnh lặp đứng yên |
| Chữ phóng to | Chữ theo cỡ của máy và tự co trong nút; số trong ô nhập luôn đủ chỗ cho 3 chữ số nên không lên đủ 200% |
| Vùng chạm | Nút nhỏ nhất cao 44 |

### App chủ động không có

Chia sẻ, đổi định dạng tọa độ, độ chính xác (±mét), bản đồ, lịch sử, tài khoản, đo nền, quảng cáo.

## 3. Giao diện chung

### Phong cách

Nền gần đen, chữ trắng, nút chính trắng chữ đen. Màu xanh bạc hà là màu nhấn (GPS đang đo, bán cầu, cặp số, Kết luận);
màu cam chỉ dùng cho cảnh báo và lỗi. Nội dung đặt trong thẻ bo góc lớn, nút bo tròn hẳn.

### Màu đang dùng

Nguồn: `mobile/lib/theme.dart`.

| Mã màu | Vai trò | Nơi dùng |
| --- | --- | --- |
| `#050608` | Nền chính | Mọi màn hình, màn hình mở app, chữ trên nút trắng |
| `#F5F6F8` | Chữ chính | Tọa độ, tiêu đề, tên cung, nền nút chính |
| `#B4B9C4` | Chữ nội dung | Ý nghĩa, đoạn giải thích |
| `#9BA0AB` | Nhãn | Nhãn nhỏ, tên nhóm |
| `#7D8390` | Chữ phụ | Đơn vị, chữ mờ, nút bị khóa |
| `#6EE7B7` | Màu nhấn | Chữ N/S/E/W, cặp số, tiêu đề Kết luận, viền ô đang chọn |
| `#FFB340` | Cảnh báo | Tên cung xấu, câu lưu ý, chữ lỗi |
| `#FF9F0A` | Viền cảnh báo | Ô cặp số xấu, ô nhập sai |
| `#2A1C06` | Nền cảnh báo | Hộp lưu ý, hộp lỗi, ô sai |
| `#0E1015` | Nền thẻ | Thẻ tọa độ, thẻ nhập, thẻ Thông tin |
| `#0D1713` | Nền thẻ Kết luận | Thẻ Kết luận, viền `#1E3A30` |
| `#12201A` | Nền ô cặp số | Ô cặp số thường |
| `#181B22` | Nền ô nhập | Ô số, công tắc bán cầu |
| `#14171D` | Nền nút khóa | Nút "Xem" khi chưa có tọa độ |

### Chữ

Dùng font Manrope đóng gói trong app (font biến thiên, đủ dấu tiếng Việt). Số trong tọa độ, cặp số và ô nhập dùng chữ số
đều độ rộng để chữ không giật khi tọa độ cập nhật. Máy rộng dưới 390 dùng bộ số nhỏ hơn, ghi sau dấu `/`.

| Cỡ | Đậm | Dùng cho |
| --- | --- | --- |
| 52 / 46 | 700 | Tọa độ ở Màn hình chính (tự co cho vừa dòng) |
| 36 / 34 | 700 | Tọa độ ở Kết quả (tự co cho vừa dòng) |
| 32 | 800 | Tiêu đề trang Nhập tọa độ và Thông tin |
| 30 | 700 | Số trong ô nhập (tự co) |
| 24 / 22 | 800 | Cặp số |
| 18 / 17 | 500 | Câu Kết luận |
| 18 | 800 | Chữ nút chính |
| 18 | 800 | Tên app ở Màn hình chính |
| 17 | 700 | Tên cung, tiêu đề thẻ |
| 16 | 600–700 | Nút phụ, nút hành động, nút "Quay lại" |
| 15 | 400 | Ý nghĩa, nội dung Thông tin |
| 14 | 400–600 | Gợi ý khi chờ GPS, hộp lỗi, nút đổi ngôn ngữ |
| 13 | 400–700 | "GPS ĐANG ĐO", số dòng, dòng phụ, dòng giới thiệu, dòng nhắc dưới Kết luận |
| 12 | 700 | Nhãn nhỏ giãn chữ như "VĨ ĐỘ" |

### Thành phần

Nguồn: `mobile/lib/widgets.dart`.

| Thành phần | Mô tả hiện tại |
| --- | --- |
| Nút chính | Nền trắng, chữ đen và mũi tên, bo tròn hẳn, cao 60 / 56. Khi khóa: nền `#14171D`, chữ `#7D8390` |
| Nút phụ | Viền mảnh, không nền, có biểu tượng, cao 52 (Nhập tay, Giấy phép) |
| Nút hành động | Nền `#12151B`, viền, có biểu tượng, cao 52 (Cho phép, Mở Cài đặt) |
| Nút đổi ngôn ngữ | Viên nhỏ có biểu tượng quả cầu, hiện tên ngôn ngữ **còn lại**, cao 44 |
| Nút tròn | Biểu tượng `i` mở Thông tin, đường kính 44 |
| Nút quay lại | Mũi tên và chữ "Quay lại", đầu trang con |
| Thẻ | Bo góc 24, có viền mảnh |
| Ô nhập số | Cao 76, bo góc 18, số căn giữa, chữ mờ `0`, đơn vị ở góc trên phải, tên đơn vị bên dưới ô. Đang chọn: viền xanh. Sai: nền và viền cam |
| Công tắc bán cầu | Hai nút 52×44 trong viên bo tròn; lựa chọn đang bật nền trắng chữ đen |
| Ô cặp số | Vuông 56 / 52, bo góc 16. Thường: nền xanh đậm, số xanh. Cảnh báo: nền và viền cam, số cam |
| Dòng kết quả | Ngăn bằng đường kẻ mảnh, không có thẻ; dòng cảnh báo có thêm nhãn "CẢNH BÁO" và biểu tượng tam giác |

### Hoạt ảnh

| Hoạt ảnh | Nơi hiện |
| --- | --- |
| Các vòng tròn đồng tâm làm nền, thêm vòng sóng xanh lan ra khi đang chờ GPS | Màn hình chính |
| Chấm xanh nhấp nháy cạnh "GPS ĐANG ĐO" | Màn hình chính khi có tọa độ |
| Ba chấm nhấp nháy | Màn hình chính khi đang chờ GPS |

Chuyển trang kiểu iOS trượt ngang.

### Icon và màn hình mở app

- **Icon app:** la bàn trên nền tối (`mobile/assets/icon/icon.png`); Android dùng icon thích ứng nên không còn khung trắng.
- **Màn hình mở app:** nền `#050608` trùng màu app trên cả Android và iOS nên không bị chớp sáng.

## 4. Từng màn hình

Ví dụ dưới đây dùng tiếng Việt. Khung bố cục chỉ thể hiện vị trí, không đúng tỉ lệ.

### 4.1. Màn hình chính — `location_screen.dart`

Là màn hình đầu tiên khi mở app. Thanh trên cùng có la bàn, tên app, nút Thông tin và nút đổi ngôn ngữ.

```text
┌──────────────────────────────┐
│ ◎ Tọa Độ        (i) (◍ English)│  thanh trên cùng
│                              │
│ • GPS ĐANG ĐO                │
│                              │
│ VĨ ĐỘ                        │
│ 21°01'43"N                   │  tọa độ cỡ lớn, chữ N xanh
│ ──────────────────────────── │
│ KINH ĐỘ                      │
│ 105°48'12"E                  │
│                              │
│ Cập nhật liên tục · Chạy offline
│                              │
│   Bấm Xem để biết ý nghĩa    │  dòng giới thiệu, căn giữa, luôn hiện
│   vị trí này theo các cặp…   │
│                              │
│ ┌──────────────────────────┐ │
│ │          Xem  →          │ │  nút chính
│ └──────────────────────────┘ │
│ ┌──────────────────────────┐ │
│ │       ✎ Nhập tay         │ │  nút phụ
│ └──────────────────────────┘ │
└──────────────────────────────┘
```

Lề hai bên 24 / 20. Vùng giữa chiếm hết phần còn lại và cuộn được nếu chữ quá dài.

| Trạng thái | Vùng giữa | Nút "Xem" | Nút "Nhập tay" |
| --- | --- | --- | --- |
| Đã có tọa độ | "GPS ĐANG ĐO", tọa độ cập nhật liên tục | Bấm được | Bấm được |
| Đang chờ GPS | Biểu tượng định vị, "Đang chờ tín hiệu GPS…", ba chấm, gợi ý `waitingHint`, tọa độ gạch ngang mờ, vòng sóng xanh ở nền | Khóa | Bấm được |
| Cần xin quyền | Đoạn giải thích dùng vị trí, nút "Cho phép" | Khóa | Bấm được |
| Đã từ chối quyền | "Chưa cấp quyền vị trí", nút "Mở Cài đặt" | Khóa | Bấm được |
| Định vị đang tắt | "Định vị đang tắt", nút "Mở Cài đặt" | Khóa | Bấm được |
| Mọi trạng thái trên | Cuối vùng giữa luôn có dòng giới thiệu `appIntro` | Theo trạng thái | Bấm được |

Từ trang con quay về thì tọa độ đang có được giữ lại (`suspend()`) nên không phải chờ, GPS đo tiếp ngay; số giữ lại vẫn hết
hạn sau 60 giây nếu không có số mới. Ra nền rồi quay lại app thì tọa độ cũ bị xóa và màn hình chờ số mới, vì người dùng có
thể đã đi nơi khác. Thời gian chờ tùy tín hiệu: vài giây ngoài trời, lâu hơn khi ở trong nhà hoặc khi tắt Wi-Fi.

### 4.2. Nhập tọa độ — `manual_entry_screen.dart`

```text
┌──────────────────────────────┐
│ ‹ Quay lại                   │
│ Nhập tọa độ                  │  tiêu đề lớn
│ ┌──────────────────────────┐ │
│ │ Vĩ độ           [N | S]  │ │  thẻ vĩ độ
│ │ ┌──────┐┌──────┐┌──────┐ │ │
│ │ │ 0   °││ 0   '││ 0   "│ │ │
│ │ └──────┘└──────┘└──────┘ │ │
│ │   độ      phút    giây   │ │
│ └──────────────────────────┘ │
│ ┌──────────────────────────┐ │
│ │ Kinh độ         [E | W]  │ │  thẻ kinh độ
│ │ ┌──────┐┌──────┐┌──────┐ │ │
│ │ │ 0   °││ 0   '││ 0   "│ │ │
│ │ └──────┘└──────┘└──────┘ │ │
│ │   độ      phút    giây   │ │
│ └──────────────────────────┘ │
│ ⚠ Tọa độ không hợp lệ. Phút… │  hộp lỗi cam, chỉ hiện khi sai
│ ┌──────────────────────────┐ │
│ │          Xem  →          │ │
│ └──────────────────────────┘ │
└──────────────────────────────┘
```

Lề hai bên 20 / 16. Ba ô bằng nhau, cách nhau 8. Toàn trang cuộn được và kéo là ẩn bàn phím. Bàn phím số tự bật khi chạm ô.

| Trạng thái | Hiển thị |
| --- | --- |
| Mới vào | Các ô trống với chữ mờ `0`, chọn sẵn N và E |
| Đang nhập | Ô đang chọn có viền xanh, số trắng |
| Sai giá trị | Ô sai nền cam, viền cam, số cam, tên đơn vị đậm; hộp lỗi trên nút "Xem"; ở lại trang này |
| Hợp lệ | Chuyển sang Kết quả |

### 4.3. Kết quả — `result_screen.dart`

Đầu trang có nút "‹ Quay lại", không có tiêu đề. Toàn trang là một danh sách cuộn, lề hai bên 20 / 16. Kết luận nằm trên
danh sách chi tiết.

```text
┌──────────────────────────────┐
│ ‹ Quay lại                   │
│ ┌──────────────────────────┐ │
│ │ VĨ ĐỘ                    │ │  thẻ tọa độ
│ │ 21°01'43"N               │ │
│ │ ──────────────────────── │ │
│ │ KINH ĐỘ                  │ │
│ │ 105°48'12"E              │ │
│ └──────────────────────────┘ │
│ ┌──────────────────────────┐ │
│ │ ✦ KẾT LUẬN               │ │  thẻ nền xanh đậm
│ │ Vị trí này có 3 cung     │ │
│ │ cùng nổi bật: …          │ │
│ │ ⚠ Lưu ý: vị trí này có … │ │  hộp cam, chỉ hiện khi có cung xấu
│ └──────────────────────────┘ │
│ Tọa độ GPS dao động vài giây │  dòng nhắc, chữ mờ
│ nên kết quả có thể khác…     │
│ CHI TIẾT THEO CẶP SỐ  3 dòng │
│ ──────────────────────────── │
│ [12]  Chăm Chỉ               │  ô cặp số bên trái
│       Cần cù, bền bỉ và…     │  tên cung + ý nghĩa bên phải
│ ──────────────────────────── │
│ [31]  Thiên Tài (Đại tài)    │
│       Vận tài lộc ở đỉnh…    │
│ ──────────────────────────── │
│ [55]  Bảo Vệ  ×4             │  cặp lặp lại gộp một dòng
│       Năng lượng che chở…    │
└──────────────────────────────┘
```

| Trạng thái | Hiển thị |
| --- | --- |
| Có dòng khớp | Thẻ tọa độ, thẻ Kết luận, dòng nhắc `resultNotice`, danh sách chi tiết kèm số dòng |
| Có cung xấu | Dòng đó có nhãn "CẢNH BÁO", tên và ô cặp số màu cam; thẻ Kết luận có thêm hộp "Lưu ý: …" |
| Không khớp số nào | Chỉ có tọa độ căn giữa, biểu tượng tìm kiếm và câu "Tọa độ này không có số nào trong bảng"; không có Kết luận |
| Dòng thiếu ý nghĩa (dự phòng) | Ô nét đứt, chữ xám nghiêng "Chưa có dữ liệu"; nếu chỉ có các dòng này thì Kết luận ghi "Chưa có dữ liệu để kết luận" |

Các dòng trong danh sách không bấm được.

### 4.4. Thông tin — `about_screen.dart`

Đầu trang có nút "‹ Quay lại", tiêu đề lớn "Thông tin", dòng phiên bản, rồi 4 thẻ (Bảng số Thiên Cung, Quyền riêng tư, Lưu ý
khi dùng, Liên hệ và báo lỗi) và nút phụ "Giấy phép mã nguồn mở". Toàn bộ nội dung nằm trong app nên đọc được khi không có mạng.

## 5. Toàn bộ chữ trên giao diện

Nguồn: `mobile/lib/strings.dart`. Độ dài hai ngôn ngữ chênh nhau khá nhiều, ví dụ "Nhập tay" và "Enter manually", nên
giao diện cần chịu được cả hai.

| Vị trí | Tiếng Việt | Tiếng Anh |
| --- | --- | --- |
| Nút đổi ngôn ngữ | English | Tiếng Việt |
| Nút chính | Xem | View |
| Nút phụ | Nhập tay | Enter manually |
| Trạng thái đo | GPS ĐANG ĐO | GPS ACTIVE |
| Dòng phụ | Cập nhật liên tục · Chạy offline | Live updates · Works offline |
| Nhãn tọa độ | VĨ ĐỘ, KINH ĐỘ | LATITUDE, LONGITUDE |
| Tiêu đề trang nhập | Nhập tọa độ | Enter coordinates |
| Nhãn thẻ nhập | Vĩ độ, Kinh độ | Latitude, Longitude |
| Tên đơn vị | độ, phút, giây | degrees, minutes, seconds |
| Lỗi nhập | Tọa độ không hợp lệ. Phút và giây phải dưới 60, vĩ độ tối đa 90°, kinh độ tối đa 180°. | Invalid coordinates. Minutes and seconds must be under 60, latitude at most 90°, longitude at most 180°. |
| Chờ GPS | Đang chờ tín hiệu GPS… | Waiting for GPS signal… |
| Gợi ý chờ GPS (`waitingHint`) | Hãy ra nơi thoáng, tránh mái che. Bật Wi-Fi có thể giúp nhanh hơn. | Move to an open area away from roofs. Turning on Wi-Fi may speed this up. |
| Dòng giới thiệu (`appIntro`) | Bấm Xem để biết ý nghĩa vị trí này theo các cặp số trong tọa độ và Bảng số Thiên Cung. | Tap View to see what this location means, based on the number pairs in its coordinates and the Thien Cung table. |
| Giải thích quyền | Tọa Độ dùng vị trí chính xác của điện thoại để hiện kinh độ và vĩ độ. Vị trí chỉ được dùng khi app đang mở, chỉ xử lý trên điện thoại và không gửi đi đâu. Nếu không muốn cho phép, bạn vẫn dùng được Nhập tay. | Toa Do uses your phone's precise location to show your longitude and latitude. It is used only while the app is open, processed only on your phone and never sent anywhere. If you prefer not to allow it, you can still enter coordinates manually. |
| Nút xin quyền | Cho phép | Allow |
| Đã từ chối quyền | Chưa cấp quyền vị trí | Location permission not granted |
| Định vị tắt | Định vị đang tắt | Location services are off |
| Nút cài đặt | Mở Cài đặt | Open Settings |
| Nút lùi | Quay lại | Back |
| Tiêu đề Kết luận | KẾT LUẬN | CONCLUSION |
| Dòng nhắc ở Kết quả (`resultNotice`) | Tọa độ GPS dao động vài giây nên kết quả có thể khác giữa các lần đo. Nội dung chỉ mang tính tham khảo. | GPS coordinates drift by a few seconds, so results can differ between readings. This content is for reference only. |
| Tiêu đề danh sách | CHI TIẾT THEO CẶP SỐ | DETAILS BY NUMBER PAIR |
| Số dòng | {n} dòng | 1 row, {n} rows |
| Nhãn dòng xấu | CẢNH BÁO | WARNING |
| Không khớp | Tọa độ này không có số nào trong bảng | These coordinates have no numbers in the table |
| Dòng thiếu ý nghĩa | Chưa có dữ liệu | No data yet |
| Kết luận trống | Chưa có dữ liệu để kết luận | Not enough data for a conclusion |
| Câu lưu ý | Lưu ý: vị trí này có {danh sách}. | Note: this location includes {danh sách}. |
| Trang Thông tin | Thông tin, Phiên bản, Quyền riêng tư, Lưu ý khi dùng, Liên hệ và báo lỗi, Giấy phép mã nguồn mở | About, Version, Privacy, Before you use it, Contact and bug reports, Open source licenses |
| Tiêu đề thẻ Bảng số (`tableTitle`) | Bảng số Thiên Cung | The Thien Cung table |
| Nội dung thẻ Bảng số (`tableBody`) | Mỗi cặp hai chữ số trong bảng ứng với một cung và một ý nghĩa. App tách các chữ số của tọa độ thành từng cặp, tính từ phải sang trái, rồi tra trong bảng và tổng hợp thành phần Kết luận. | Each two-digit pair in the table belongs to a theme with its own meaning. The app splits the digits of your coordinates into pairs, starting from the right, looks each one up and sums them up in the Conclusion. |

Nội dung các thẻ còn lại ở trang Thông tin nằm trong `privacyBody`, `noticeBody`, `contactBody` của `strings.dart`.

### Câu Kết luận

Trong đó {mô tả} là `{cung} thiên về {ý}` (tiếng Anh `{cung} pointing to {ý}`), nhiều cung thì nối bằng dấu chấm phẩy; phần
sau "Bên cạnh đó" / "Alongside this" ghi thêm số lần: `{cung}, {n} lần, thiên về {ý}`. Số lần chỉ ghi khi lớn hơn 1.

| Trường hợp | Tiếng Việt | Tiếng Anh |
| --- | --- | --- |
| Một cung | Vị trí này nổi bật về {cung}, {n} lần, thiên về {ý}. | This location stands out for {cung}, {n} times, pointing to {ý}. |
| Nhiều cung bằng nhau, không còn cung khác | Vị trí này có {t} cung cùng nổi bật, mỗi cung {n} lần: {mô tả}. | This location has {t} equally strong themes, {n} times each: {mô tả}. |
| Một cung nổi bật, có cung khác | Vị trí này có {t} cung. Nổi bật nhất là {cung}, {n} lần, thiên về {ý}. Bên cạnh đó, {mô tả}. | This location has {t} themes. The strongest is {cung}, {n} times, pointing to {ý}. Alongside this, {mô tả}. |
| Nhiều cung nổi bật, có cung khác | Vị trí này có {t} cung. Nổi bật nhất là {a} và {b}, mỗi cung {n} lần: {mô tả}. Bên cạnh đó, {mô tả}. | This location has {t} themes. The strongest are {a} and {b}, {n} times each: {mô tả}. Alongside this, {mô tả}. |

Mỗi cung có một ý diễn giải ngắn, do Claude soạn và **chờ chủ app duyệt**; riêng nhóm Tai họa của Đào Hoa là dòng cảnh báo
nên không dùng ý chung của cung:

| Cung | Ý tiếng Việt | Ý tiếng Anh |
| --- | --- | --- |
| Thiên Tài | tiền tài và cơ hội làm giàu | wealth and opportunities to prosper |
| Quan Lộc | công danh và đường sự nghiệp | status and career path |
| Thông Minh | trí tuệ và khả năng học hỏi | intellect and the ability to learn |
| Thần Linh Trời Định | phúc phận do trời định | blessings ordained by heaven |
| Tích Lũy Tài Sản | tích góp của cải bền lâu | lasting accumulation of assets |
| Linh Ứng | tâm linh và việc thờ cúng | spirituality and worship |
| Đào Hoa | nhân duyên và tình cảm | relationships and affection |
| Đào Hoa, chỉ gặp nhóm Tai họa | sóng gió tình cảm cần giữ gìn | relationship troubles that need care |
| Đào Hoa, gặp cả hai nhóm | nhân duyên và tình cảm, nhưng có sóng gió tình cảm cần giữ gìn | relationships and affection, but also relationship troubles that need care |
| Chăm Chỉ | sự cần cù và kiên trì | steady effort and perseverance |
| Bảo Vệ | giữ gìn thành quả và sự bình ổn | safeguarding achievements and stability |
| Đạo Đức | đạo lý và phúc đức | principle and merit |
| Tai Họa | vận hạn cần cẩn trọng | setbacks that call for caution |

Thông báo xin quyền trên iOS: "Tọa Độ dùng vị trí để hiện kinh độ, vĩ độ. / Toa Do uses your location to show your coordinates."

## 6. Dữ liệu Bảng số Thiên Cung

Nguồn: `mobile/lib/thien_cung_data.dart`. Bảng có 11 cung, 20 dòng và 56 cặp số khác nhau. Cả 20 dòng đều đã có ý nghĩa
tiếng Việt và tiếng Anh; bản tiếng Anh nằm cùng file.

Nội dung theo ý chủ app đưa, đã được Claude biên tập cho dễ nghe, chờ chủ app đọc lại. Bạn vẫn sửa chữ được bất cứ lúc nào.

| Cung | Nhóm | Tên tiếng Anh | Cặp số | Ý nghĩa |
| --- | --- | --- | --- | --- |
| Thiên Tài | Đại tài | Fortune · Great Fortune | 13, 31 | Vận tài lộc ở đỉnh cao: tiền bạc hanh thông, cơ hội lớn dễ đến và dễ nắm bắt. |
| Thiên Tài | Trung tài | Fortune · Moderate Fortune | 68, 86 | Tài lộc dồi dào ở mức khá, rất thuận cho buôn bán, giao thương và kinh doanh vừa và nhỏ. |
| Thiên Tài | Tiểu tài | Fortune · Minor Fortune | 27, 72, 49, 94 | Lộc nhỏ mà đều, thu nhập ổn định, đủ để cuộc sống luôn an tâm. |
| Quan Lộc | Đại quan | Career · High Office | 19, 91 | Khí chất của người đứng đầu, có tài lãnh đạo và đủ uy để dẫn dắt nhiều người. |
| Quan Lộc | Thượng quan | Career · Senior Office | 26, 62 | Vị trí trọng yếu trong bộ máy, có uy tín cao và tiếng nói được nhiều người nể trọng. |
| Quan Lộc | Trung quan | Career · Middle Office | 78, 87 | Đường công danh vững vàng, thăng tiến từng bước lên cấp quản lý, ổn định và bền lâu. |
| Quan Lộc | Quan nhỏ | Career · Minor Office | 46, 64 | Công việc ổn định nơi công sở, làm tròn bổn phận, được tin cậy và ít sóng gió. |
| Quan Lộc | Hạ quan | Career · Lower Office | 43, 34 | Công danh bình lặng, gắn với công việc thực thi; muốn tiến xa cần thêm nỗ lực và thời gian. |
| Thông Minh | IQ cao | Intelligence · High IQ | 27, 72 | Trí tuệ sáng, ngộ tính cao, tư duy nhạy bén, học một biết mười. |
| Thông Minh | IQ trung bình khá | Intelligence · Above-average IQ | 49, 94 | Đầu óc logic, học hành vững vàng, xử lý công việc thực tế gọn gàng và hiệu quả. |
| Thần Linh Trời Định | Đất của trời | Divine Destiny · Land of Heaven | 17, 71 | Vùng đất trời ban. Người có căn nguyên được phúc đức dày, nhà đất thuận lợi, có chỗ dựa vững chắc. Người chưa đủ căn nguyên khó giữ bền và dễ gặp trắc trở. |
| Thần Linh Trời Định | Số trời | Divine Destiny · Heavenly Fate | 72, 27 | Vận mệnh do trời sắp đặt. Người có căn nguyên gặp cơ duyên bất ngờ, thuận theo tự nhiên và nắm đúng thời cơ. Người chưa đủ căn nguyên khó gánh được và dễ gặp trắc trở. |
| Tích Lũy Tài Sản | — | Wealth Accumulation | 74, 47, 14, 41 | Tiền của đến chậm mà chắc, nhờ chi tiêu khéo và tích góp bền bỉ nên tài sản lớn dần theo năm tháng. |
| Linh Ứng | — | Spiritual Response | 18, 81, 24, 42, 63, 36 | Vùng đất linh thiêng, hợp với việc thờ cúng; càng giữ lòng thành và chăm lo hương khói thì càng phát đạt. |
| Đào Hoa | May mắn | Romance · Fortunate | 38, 83 | Nhân duyên đẹp, được nhiều người quý mến, gia đình êm ấm, hòa thuận; đặc biệt tốt cho phụ nữ. |
| Đào Hoa ⚠️ | Tai họa | Romance · Misfortune | 16, 61 | Tình cảm dễ vướng thị phi, gia đạo kém êm ấm, hôn nhân cần được giữ gìn và vun đắp nhiều hơn. |
| Chăm Chỉ | — | Diligence | 12, 21, 69, 96 | Cần cù, bền bỉ và có trách nhiệm; thành quả đến từ công sức đều đặn hơn là từ may mắn. |
| Bảo Vệ | — | Protection | 00, 11, 22, 33, 44, 55, 66, 77, 88, 99 | Năng lượng che chở, giúp giữ vững thành quả đã tạo dựng và bình ổn trước sóng gió, chứ không tự sinh ra tiền tài. |
| Đạo Đức | — | Virtue | 28, 82, 39, 93 | Sống trọng đạo lý và chữ tín, được người đời kính nể, phúc đức tích dày, hậu vận bình an. |
| Tai Họa ⚠️ | — | Misfortune | 23, 32, 34, 43, 89, 98, 16, 61 | Vận hạn cần đề phòng: nên giữ gìn sức khỏe, cẩn thận đi lại, giữ chắc tài sản và tránh tranh chấp, thị phi. |

⚠️ là dòng cảnh báo, hiện màu cam. Hai dòng Thần Linh Trời Định không đánh dấu cảnh báo, vì app không biết người xem có căn
nguyên hay không; điều kiện chỉ nằm trong câu ý nghĩa.

### Giới hạn độ dài cần tính khi sửa giao diện

- **Tọa độ:** 21 hoặc 22 ký tự, tùy kinh độ có 2 hay 3 chữ số; hiện thành hai dòng.
- **Số cặp:** 6 hoặc 7 cặp cho mỗi tọa độ.
- **Số dòng kết quả:** mỗi cặp ra 0 đến 3 dòng. Cặp 27, 72 ra 3 dòng; cặp 49, 94, 34, 43, 16, 61 ra 2 dòng.
- **Ý nghĩa:** tiếng Việt từ 62 đến 201 ký tự, tiếng Anh từ 66 đến 209 ký tự.
- **Tên dài nhất:** "Thần Linh Trời Định (Đất của trời)" và "Divine Destiny (Land of Heaven)".
- **Câu kết luận:** có thể nêu 6 cung trở lên, thành một đoạn dài nhiều dòng.

## 7. Dữ liệu mẫu

Các mẫu dưới tính theo đúng logic trong `thien_cung.dart` và `strings.dart`.

**Mẫu bình thường:** `21°01'43"N 105°48'12"E`

- Cặp số: 12, 48, 05, 31, 14, 10, 02.
- Dòng hiện ra: 12 Chăm Chỉ, 31 Thiên Tài (Đại tài), 14 Tích Lũy Tài Sản.
- Kết luận: "Vị trí này có 3 cung cùng nổi bật: Thiên Tài (Đại tài) thiên về tiền tài và cơ hội làm giàu; Tích Lũy Tài
  Sản thiên về tích góp của cải bền lâu; Chăm Chỉ thiên về sự cần cù và kiên trì."

**Mẫu dài, có cảnh báo:** `20°59'16"N 105°50'27"E`

- Cặp số: 27, 50, 05, 61, 91, 05, 02.
- Dòng hiện ra: 27 Thiên Tài (Tiểu tài), 27 Thông Minh (IQ cao), 27 Thần Linh Trời Định (Số trời), 61 Đào Hoa (Tai họa,
  màu cam), 61 Tai Họa (màu cam), 91 Quan Lộc (Đại quan).
- Kết luận: "Vị trí này có 6 cung cùng nổi bật: Thiên Tài (Tiểu tài) thiên về tiền tài và cơ hội làm giàu; Quan Lộc
  (Đại quan) thiên về công danh và đường sự nghiệp; Thông Minh (IQ cao) thiên về trí tuệ và khả năng học hỏi; Thần Linh
  Trời Định (Số trời) thiên về phúc phận do trời định; Đào Hoa (Tai họa) thiên về sóng gió tình cảm cần giữ gìn; Tai Họa
  thiên về vận hạn cần cẩn trọng."
- Lưu ý: "Lưu ý: vị trí này có Đào Hoa (Tai họa) và Tai Họa."

**Mẫu một cung lặp lại:** `55°55'55"N 105°55'55"E`

- Cặp số: 55, 55, 05, 51, 55, 55, 05.
- Dòng hiện ra: một dòng 55 Bảo Vệ, ghi `×4`.
- Kết luận: "Vị trí này nổi bật về Bảo Vệ, 4 lần, thiên về giữ gìn thành quả và sự bình ổn."

**Mẫu không khớp:** `10°20'30"N 40°50'10"E`

- Cặp số: 10, 50, 40, 30, 20, 10.
- Không có dòng nào, chỉ hiện tọa độ và câu "Tọa độ này không có số nào trong bảng".

## 8. Lưu ý khi sửa giao diện

### Cần giữ

- Đủ 5 trạng thái của Màn hình chính và các trạng thái của Kết quả ở mục 4.
- Tọa độ giữ nguyên đúng định dạng, không dịch, không đổi cách viết.
- Chữ số đều độ rộng cho tọa độ, nếu không chữ sẽ giật mỗi giây.
- Cảnh báo phải tách biệt rõ với nội dung thường bằng cả chữ và biểu tượng, không chỉ bằng màu.
- Mọi chữ đi qua `strings.dart` và luôn có đủ hai ngôn ngữ.
- Font mới phải có đủ dấu tiếng Việt và ký hiệu `°`.
- Hoạt ảnh lặp đặt trong `RepaintBoundary` và dừng khi máy bật giảm chuyển động.
- Không thêm quyền Internet.

### Điểm còn mở

- **Nội dung chờ duyệt:** 11 ý diễn giải trong Kết luận và ý riêng cho nhóm Tai họa của Đào Hoa do Claude soạn; nội dung 20
  dòng ý nghĩa chờ chủ app đọc lại.
- **Chờ quyết định:** cách ghi số ít ở tiếng Anh; đổi N/S có xóa báo lỗi không; ô vừa chọn vừa sai thì viền nào thắng
  (code hiện cho viền lỗi thắng và đổi bán cầu thì xóa lỗi).
- **Trình đọc màn hình:** chưa kiểm bằng TalkBack trên máy thật, và có thể đọc theo ngôn ngữ của máy thay vì ngôn ngữ app.
- **Chữ phóng to:** chưa kiểm trên máy thật; số trong ô nhập không lên đủ 200%.
- **Mất tín hiệu GPS 60 giây:** đã có test tự động, chưa kiểm trên máy thật.
- **Xoay ngang:** app không khóa hướng màn hình nhưng cũng chưa thiết kế cho màn hình ngang.
- **iOS:** chưa build; `Info.plist` chưa khai báo ngôn ngữ tiếng Việt.

### Khi sửa code

Nên thay giao diện trong các file màn hình và `widgets.dart`, giữ nguyên `coords.dart`, `thien_cung.dart`,
`location_service.dart`. Màu và cỡ chữ nằm ở `theme.dart`. Test trong `mobile/test/` tìm chữ hiển thị và kiểu widget, nên
đổi chữ hoặc đổi widget thì phải sửa test theo. Chạy `flutter test -j 1` (toàn bộ test); chạy song song dễ gặp lỗi
"Connection closed".

Build AAB release cần `android/key.properties`, thiếu thì dừng và báo lỗi. APK dùng thử vẫn build được bằng khóa debug.

APK dùng thử chỉ build cho arm64 bằng `flutter build apk --release --target-platform android-arm64` (17,9 MB so với 50 MB
bản 3 kiến trúc), máy 32-bit không cài được; AAB trên Play tự chia theo máy.
