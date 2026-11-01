# Tọa Độ — Thiết kế giao diện mobile

Bản thiết kế lại giao diện cho app Tọa Độ, dựng từ `docs/chuc-nang-va-giao-dien.md`. Chỉ thay phần giao diện; logic (`coords.dart`, `thien_cung.dart`, `location_service.dart`) giữ nguyên.

## 1. Các file trong thư mục này

| File | Nội dung |
| --- | --- |
| `canvas.json` | Vị trí, kích thước và tên từng màn trên canvas thiết kế |
| `*.dc.html` | Mỗi file là một màn hình (xem mục 4) |

Lưu ý khi mở các file:

- Mỗi file `.dc.html` gọi `./support.js`. File này do trình Design của Claude cấp lúc chạy và **không nằm trong thư mục này**. Mở riêng bằng trình duyệt sẽ không dựng được trang. Hãy dùng các file này để **đọc số đo, màu, chữ**, không phải để chạy.
- Phần giao diện nằm trong thẻ `<x-dc>`, toàn bộ là style inline, đọc thẳng được số đo từng thành phần.
- Bản đẹp để xem là canvas đã publish trong Claude (mục Artifacts, tên "Tọa Độ – Giao diện mobile").

## 2. Design tokens

### Màu

| Vai trò | Mã màu | Dùng ở |
| --- | --- | --- |
| Nền màn hình | `#050608` | Mọi màn |
| Nền thẻ | `#0E1015` | Thẻ tọa độ, thẻ nhập |
| Viền thẻ, đường kẻ | `#1E2128` | Thẻ, đường kẻ giữa các dòng |
| Nền ô nhập, nền công tắc bán cầu | `#181B22` | Ô số, công tắc N/S E/W |
| Vòng tròn trang trí | `#161920` | Hình vòng đồng tâm phía sau Màn hình chính |
| Viền nút phụ, nút ngôn ngữ | `#23262E` | Nhập tay, English |
| Nút "Mở Cài đặt" | nền `#12151B`, viền `#3A3F4A` | Trạng thái chưa cấp quyền, định vị tắt |
| Nút "Xem" bị khóa | nền `#14171D`, chữ `#7D8390` | Khi chưa có tọa độ |
| Chữ chính | `#F5F6F8` | Tọa độ, tên cung, nút |
| Chữ nhãn | `#9BA0AB` | VĨ ĐỘ, KINH ĐỘ, tiêu đề nhóm |
| Chữ phụ mờ | `#7D8390` | Đơn vị `° ' "`, nhãn độ/phút/giây, "Chưa có dữ liệu" |
| Chữ ý nghĩa | `#B4B9C4` | Mô tả ý nghĩa của cung |
| Chữ gợi ý trong ô | `#4B505B` | Chữ mờ `0` |
| **Nhấn xanh ngọc** | `#6EE7B7` | GPS đang đo, chữ N/E, cặp số có dữ liệu, mục Kết luận, ô đang chọn |
| Nền thẻ Kết luận / ô cặp số có dữ liệu | `#0D1713` / `#12201A`, viền `#1E3A30` | Phần Kết luận, ô cặp số |
| Ô cặp số chưa có dữ liệu | viền nét đứt `1.5px #2A2E37`, chữ `#7D8390` | Dòng "Chưa có dữ liệu" |
| **Cảnh báo cam** | chữ `#FFB340`, viền `#FF9F0A` | Cung xấu, lỗi nhập |
| Nền cảnh báo | `#2A1C06`, viền hộp `#6B4A12` | Hộp lưu ý, hộp lỗi, ô cặp số cảnh báo, ô nhập sai |

Quy tắc dùng màu: cam **chỉ** dùng cho cảnh báo và lỗi. Cảnh báo luôn có thêm nhãn chữ "CẢNH BÁO" và biểu tượng tam giác, không chỉ khác màu. Gộp hai màu chữ phụ cũ (`#8E8E93`, `#AEAEB2`) thành `#9BA0AB` và `#7D8390`.

### Chữ

Font: **Manrope** (400–800). Số dùng `font-variant-numeric: tabular-nums` để tọa độ không giật khi cập nhật mỗi giây.

| Dùng cho | Cỡ (iPhone 390) | Cỡ (Android 360) | Đậm |
| --- | --- | --- | --- |
| Tọa độ, Màn hình chính | 52 | 46 | 700 |
| Tọa độ, Kết quả | 36 | 34 | 700 |
| Tiêu đề trang "Nhập tọa độ" | 32 | 32 | 800 |
| Số trong ô nhập | 30 | 30 | 700 |
| Cặp số | 24 | 22 | 800 |
| Câu Kết luận | 20 | 19 | 700 |
| Nút "Xem" | 18 | 18 | 800 |
| Tên cung | 17 | 17 | 700 |
| Nút phụ, nút lùi | 16 | 16 | 600 |
| Ý nghĩa | 15 | 15 | 400 |
| Nút ngôn ngữ, dòng lỗi, "Chưa có dữ liệu" (nghiêng) | 14 | 14 | 600 / 500 / 400 |
| Nhãn VĨ ĐỘ, KINH ĐỘ, KẾT LUẬN | 11–12 | 11–12 | 700, giãn chữ 0,18em |

Đơn vị `° ' "` trong tọa độ: cỡ 0,55em, nâng lên 0,5em, màu `#7D8390`. Chữ N/S/E/W: cỡ 0,6em, màu `#6EE7B7`.

> **Chưa kiểm tra:** font Manrope có đủ dấu tiếng Việt (ộ, ũ, ứ...) và ký hiệu `°` hay không. Khi làm trong code, hãy thử hiển thị đủ các chữ này trước khi chốt font. Nếu thiếu thì đổi font khác có hỗ trợ tiếng Việt.

### Bo góc và khoảng cách

| Thành phần | Giá trị |
| --- | --- |
| Thẻ lớn | bo 24, đệm 18–22 |
| Nút chính, nút phụ, công tắc, nút ngôn ngữ | bo tròn hẳn (pill) |
| Ô nhập số | bo 18, cao 76 |
| Ô cặp số | 56×56 (iPhone) / 52×52 (Android), bo 16 |
| Hộp lưu ý, hộp lỗi | bo 16 / 18, đệm 14×16 |
| Lề hai bên, Màn hình chính | 24 (iPhone) / 20 (Android) |
| Lề hai bên, Nhập và Kết quả | 20 (iPhone) / 16 (Android) |
| Chiều cao nút chính | 60 (iPhone) / 56 (Android) |
| Nút phụ, nút Cài đặt | cao 52 |
| Vùng chạm tối thiểu | 44 |

## 3. Khác biệt iPhone và Android

Thiết kế dùng **một giao diện chung**, không bắt chước riêng iOS hay Android. Hai kích thước tham chiếu: iPhone **390×844**, Android **360×800**. Chỉ có hai màn (Chính, Kết quả) được vẽ thêm bản 360×800; các màn còn lại chỉ vẽ cỡ 390×844.

| Chủ đề | iPhone | Android |
| --- | --- | --- |
| Kích thước tham chiếu | 390×844 | 360×800 |
| Tọa độ ở Màn hình chính | cỡ 52 | cỡ 46 (hoặc co tự động cho vừa một dòng) |
| Lề | 24 / 20 | 20 / 16 |
| Vùng an toàn phía trên | tai thỏ / Dynamic Island | thanh trạng thái |
| Vùng an toàn phía dưới | thanh home (khoảng 34) | thanh điều hướng cử chỉ hoặc 3 nút |
| Quay lại | vuốt từ mép trái hoặc nút "‹ Quay lại" | nút/cử chỉ Back của hệ thống, nút "‹ Quay lại" vẫn giữ trong app |
| Màn hình mở app | mặc định nền trắng, cần đổi sang `#050608` | cần đổi sang `#050608`, kể cả chế độ sáng |
| Bàn phím số | `numberPad` không có phím xong: giữ cách kéo trang để ẩn bàn phím | có phím xong, vẫn giữ cách kéo để ẩn cho đồng nhất |
| Quyền vị trí | thông báo trong `Info.plist` (chữ ở mục 5 của file mô tả) | khai báo quyền trong `AndroidManifest.xml` |

Nút cách đáy khoảng 28–32 trong thiết kế **chưa tính vùng an toàn**. Trong code phải cộng thêm `SafeArea` / `MediaQuery.padding.bottom`.

App hiện dùng widget Cupertino cho cả hai nền tảng. Thiết kế mới dùng nhiều thành phần tự vẽ (nút pill, công tắc bán cầu, thẻ), nên không cần Cupertino cho phần nội dung nữa.

## 4. Danh sách màn hình theo nhóm luồng

Luồng: **Chính** → `Xem` → **Kết quả**; **Chính** → `Nhập tay` → **Nhập tọa độ** → `Xem` (nếu hợp lệ) → **Kết quả**.

### Nhóm A — Đo vị trí

| Mã | File | Màn |
| --- | --- | --- |
| 1 | `Main.dc.html` | Chính, đã có tọa độ (GPS đang đo, nút Xem bấm được) |
| 1b | `Home-GPS.dc.html` | Chính, chờ GPS (vòng sóng và 3 chấm nhấp nháy, tọa độ để trống, Xem bị khóa) |
| 1c | `Home-Quyen.dc.html` | Chính, chưa cấp quyền (nút Mở Cài đặt, Xem bị khóa) |
| 1d | `Home-Tat.dc.html` | Chính, định vị đang tắt (nút Mở Cài đặt, Xem bị khóa) |
| — | `Main-Android.dc.html` | Chính, đã có tọa độ, cỡ Android 360×800 |

### Nhóm B — Nhập tay

| Mã | File | Màn |
| --- | --- | --- |
| 2 | `Nhap-Trong.dc.html` | Nhập tọa độ, mới vào (ô trống, chọn sẵn N và E) |
| 2b | `Nhap-Loi.dc.html` | Nhập tọa độ, báo lỗi (ô phút sai viền cam, hộp lỗi trên nút Xem) |

### Nhóm C — Kết quả

| Mã | File | Màn |
| --- | --- | --- |
| 3 | `Ket-qua.dc.html` | Kết quả bình thường (mẫu `21°01'43"N 105°48'12"E`) |
| 3b | `Ket-qua-canh-bao.dc.html` | Có cung xấu, danh sách dài, cuộn trong khung (mẫu `20°59'16"N 105°50'27"E`) |
| 3c | `Ket-qua-khong-khop.dc.html` | Không khớp số nào (mẫu `20°50'50"N 105°50'50"E`) |
| — | `Ket-qua-Android.dc.html` | Kết quả bình thường, cỡ Android 360×800 |

### Chưa vẽ

- Trạng thái Kết quả "chỉ khớp dòng chưa có dữ liệu" (Kết luận ghi "Chưa có dữ liệu để kết luận").
- Màn hình mở app (splash) và logo.
- Bản tiếng Anh của mọi màn.
- Bản Android 360×800 của các màn còn lại.
- Xoay ngang.

## 5. Tab bar theo vai trò

**App không có tab bar và không có vai trò.** Theo file mô tả, app chỉ có 3 màn nối với nhau bằng nút, chạy offline, không server, không tài khoản. Thiết kế giữ đúng như vậy: không có thanh tab và không phân quyền theo vai trò. Mục này để trống có chủ đích, không bịa thêm.

## 6. Hướng dẫn cho người code

1. **Đổi giao diện trong ba file màn hình** (`location_screen.dart`, `manual_entry_screen.dart`, `result_screen.dart`); giữ nguyên `coords.dart`, `thien_cung.dart`, `location_service.dart`.
2. **Chữ đi qua `strings.dart`**, luôn đủ hai ngôn ngữ. Các câu mới thêm trong thiết kế: "CẢNH BÁO", "GPS ĐANG ĐO", "Cập nhật liên tục · Chạy offline", "CHI TIẾT THEO CẶP SỐ", "{n} dòng", và nhãn "độ / phút / giây" dưới ô nhập. **Chưa có bản tiếng Anh**, cần dịch và thêm vào `strings.dart`.
3. **Tọa độ** giữ đúng định dạng `21°01'43"N 105°48'12"E`. Trong thiết kế, vĩ độ và kinh độ tách thành hai dòng, mỗi dòng dùng `FittedBox(fit: BoxFit.scaleDown)` để không bị tràn trên máy hẹp. Dùng `FontFeature.tabularFigures()`.
4. **Font:** app chạy offline, nên đưa file font vào `assets` và khai báo trong `pubspec.yaml`, không tải từ mạng. Kiểm tra dấu tiếng Việt trước (xem ghi chú ở mục 2).
5. **Thứ tự Kết quả:** tọa độ, rồi thẻ Kết luận, rồi danh sách chi tiết (khác bản cũ là danh sách trước, Kết luận sau). Hộp "Lưu ý" nằm trong thẻ Kết luận khi có cung xấu.
6. **Dòng "Chưa có dữ liệu"** hiện mờ, ô số viền nét đứt, tên cung xám; không tính vào Kết luận (logic cũ giữ nguyên).
7. **Dòng cảnh báo** (Cung Tai Họa, Đào Hoa nhóm Tai họa) có nhãn "CẢNH BÁO", biểu tượng tam giác, ô số nền cam.
8. **Ô nhập số:** chỉ nhận chữ số, độ tối đa 3 chữ số, phút và giây tối đa 2; ô trống tính là 0. Khi sai, **chỉ ô sai** viền cam (bản cũ không chỉ ra ô nào), kèm hộp lỗi phía trên nút Xem. Hộp lỗi tự ẩn khi sửa bất kỳ ô nào.
9. **Trạng thái chờ GPS** có hoạt ảnh (vòng sóng, 3 chấm). Nên tắt hoặc giảm hoạt ảnh khi máy bật "giảm chuyển động".
10. **Test trong `mobile/test/`** đang tìm chữ hiển thị và các widget như `CupertinoTextField`, `CupertinoButton`, `CupertinoNavigationBarBackButton`, `ListView`. Đổi các widget này thì phải sửa test theo.
11. **Khả năng tiếp cận:** chưa đo độ tương phản bằng công cụ. Chữ gợi ý `0` trong ô nhập (`#4B505B`) và các dấu `–` chờ GPS (`#23262E`) rất mờ, có thể không đạt 4,5:1; nên kiểm tra lại. Hai nút của công tắc bán cầu (N/S, E/W) trong thiết kế cao 40, nhỏ hơn mức 44 nên cần tăng khi code. Thêm nhãn đọc màn hình cho nút chỉ có biểu tượng (nút ngôn ngữ).
