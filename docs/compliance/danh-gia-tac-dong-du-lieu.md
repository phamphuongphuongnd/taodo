# Hồ sơ đánh giá tác động xử lý dữ liệu cá nhân — app Tọa Độ (BẢN NHÁP)

Bản nháp ngày 03/11/2026 cho phiên bản 1.0.0, để luật sư rà soát. **Không phải tư vấn pháp lý và chưa phải hồ sơ nộp.**

- Căn cứ: Điều 21 Luật Bảo vệ dữ liệu cá nhân 91/2025/QH15 (hiệu lực 01/01/2026); Nghị định 356/2025/NĐ-CP; thủ tục
  theo Quyết định 778/QĐ-BCA-A05 ngày 09/02/2026. Nguồn: Lớp 3 của `tieu-chuan-ban-app-toan-cau.md`.
- Bản nháp viết theo nội dung, chưa theo mẫu biểu chính thức. Luật sư cần chuyển sang đúng mẫu ban hành kèm Nghị định
  356/2025/NĐ-CP và thủ tục tại Quyết định 778.
- Ô `[...]` là thông tin chỉ chủ app điền được. Không ghi số giấy tờ tùy thân vào file này vì file nằm trên GitHub công khai.

## Phần A — Câu hỏi cần luật sư trả lời trước

Câu trả lời quyết định có phải nộp hồ sơ hay không.

| # | Câu hỏi | Dữ kiện liên quan |
|---|---|---|
| 1 | Nhà phát triển có phải bên kiểm soát hoặc bên xử lý dữ liệu khi dữ liệu chỉ xử lý trên điện thoại người dùng và không bao giờ gửi về nhà phát triển? | App không có quyền Internet; nhà phát triển không nhận, không lưu, không truy cập được dữ liệu nào (Phần B, mục 3 và 6) |
| 2 | Vị trí lấy từ dịch vụ định vị của điện thoại có phải dữ liệu cá nhân nhạy cảm theo Luật 91/2025/QH15 và Nghị định 356/2025/NĐ-CP không? | Nếu có, miễn trừ ở câu 3 không áp dụng vì Điều 38 loại trừ trường hợp xử lý trực tiếp dữ liệu nhạy cảm |
| 3 | Chủ app là cá nhân (tài khoản nhà phát triển cá nhân trên Google Play, `[có / không]` đăng ký hộ kinh doanh hoặc doanh nghiệp) có thuộc diện miễn hoặc được lựa chọn theo Điều 38(2), (3) đối với Điều 21, 22, 33(2) không? | Điều 38(2), (3): doanh nghiệp nhỏ, khởi nghiệp được chọn trong 5 năm từ 01/01/2026; hộ kinh doanh, doanh nghiệp siêu nhỏ được miễn; tài liệu tiêu chuẩn không nêu trường hợp cá nhân |
| 4 | Nếu phải nộp: mốc 60 ngày "kể từ ngày đầu xử lý" tính từ ngày nào — ngày bắt đầu chạy thử kín (khoảng 12 người thử) hay ngày phát hành công khai? | Chạy thử kín dự kiến bắt đầu `[ngày]`; phát hành công khai sớm nhất 14 ngày sau đó |
| 5 | Nếu phải nộp: nộp qua kênh nào (trực tuyến hay trực tiếp tại Cục A05) và theo mẫu nào? | Quyết định 778/QĐ-BCA-A05 công bố thủ tục |
| 6 | Có phải chỉ định bộ phận hoặc nhân sự bảo vệ dữ liệu theo Điều 33(2) không? Nếu có, chủ app tự đảm nhận được không? | Một người phát triển và vận hành |
| 7 | Có cần đăng ký hay thông báo nào khác (Luật An ninh mạng 116/2025/QH15, Luật Dữ liệu 60/2024/QH15) cho một app không có máy chủ, không có tài khoản, không có nội dung do người dùng tạo không? | Phần B, mục 2 |

## Phần B — Nội dung hồ sơ

### 1. Bên lập hồ sơ

| Mục | Thông tin |
|---|---|
| Họ tên chủ app | `[bạn điền]` |
| Tư cách | Cá nhân phát triển ứng dụng `[hoặc tên hộ kinh doanh / doanh nghiệp nếu có]` |
| Tên hiển thị trên Google Play | Phiotron |
| Địa chỉ liên hệ | `[bạn điền]` |
| Email liên hệ | `[bạn điền, trùng email trên Play Console]` |
| Người phụ trách bảo vệ dữ liệu | `[bạn điền, tùy câu trả lời câu 6]` |
| Ngày lập | `[ngày nộp]` |

### 2. Mô tả hoạt động xử lý

| Mục | Mô tả |
|---|---|
| Sản phẩm | Ứng dụng di động Tọa Độ, mã `com.phiotron.toado`, phiên bản 1.0.0, Android (iOS chưa phát hành) |
| Chức năng | Lấy vị trí hiện tại của điện thoại, hiện kinh độ, vĩ độ dạng độ-phút-giây, tách chữ số thành cặp và tra Bảng số Thiên Cung để hiện ý nghĩa tham khảo. Người dùng cũng có thể tự nhập tọa độ |
| Kênh phân phối | Google Play, miễn phí, chỉ phát hành tại Việt Nam |
| Đối tượng | Người từ 18 tuổi, không hướng tới trẻ em |
| Ngày dự kiến bắt đầu xử lý | `[ngày chạy thử kín]`; phát hành công khai `[ngày]` |
| Quy mô dự kiến | `[ước tính số lượt cài năm đầu]` |
| Không có | Máy chủ, tài khoản, quảng cáo, công cụ phân tích, công cụ theo dõi, thanh toán, nội dung do người dùng tạo, trí tuệ nhân tạo |

### 3. Dữ liệu cá nhân được xử lý

| Dữ liệu | Loại | Nguồn | Mục đích | Thời gian tồn tại |
|---|---|---|---|---|
| Vị trí chính xác của điện thoại (kinh độ, vĩ độ) | Có thể là dữ liệu nhạy cảm, xem câu hỏi 2 | Dịch vụ định vị của hệ điều hành, chỉ khi người dùng cho phép và app đang mở trên màn hình | Hiện tọa độ, tách cặp số | Chỉ trong bộ nhớ khi app đang mở; không ghi ra bộ nhớ lưu trữ; mất khi app đóng hoặc xuống nền |
| Tọa độ người dùng nhập tay | Có thể gắn với một địa điểm người dùng quan tâm | Người dùng gõ vào | Tách cặp số | Chỉ trong bộ nhớ khi trang đang mở |
| Ngôn ngữ giao diện đã chọn | Không phải dữ liệu cá nhân nhạy cảm | Người dùng chọn | Hiện đúng ngôn ngữ | Lưu trên điện thoại tới khi gỡ app hoặc xóa dữ liệu app; không sao lưu lên đám mây |

App không thu thập họ tên, số điện thoại, email, danh bạ, hình ảnh, mã định danh thiết bị hay mã quảng cáo, và không
lưu lịch sử vị trí. Chi tiết: `ban-do-du-lieu.md`.

### 4. Căn cứ xử lý và cách lấy đồng ý

- Căn cứ: sự đồng ý của chủ thể dữ liệu (Điều 9 Luật 91/2025/QH15), chỉ cho một mục đích là hiện tọa độ và tra cặp số.
- Trước khi hệ điều hành hỏi quyền vị trí, app hiện màn hình giải thích: dùng vị trí chính xác để hiện kinh độ, vĩ độ;
  chỉ dùng khi app đang mở; chỉ xử lý trên điện thoại, không gửi đi đâu; không đồng ý vẫn nhập tay được. Người dùng phải
  bấm "Cho phép" thì hộp thoại hệ thống mới hiện.
- Im lặng không được coi là đồng ý: không bấm thì app không xin quyền và không lấy vị trí.
- Rút lại đồng ý: tắt quyền vị trí trong Cài đặt của điện thoại bất cứ lúc nào; app vẫn dùng được chức năng nhập tay.
- Chính sách quyền riêng tư công khai: https://github.com/phamphuongphuongnd/taodo/blob/master/docs/compliance/chinh-sach-quyen-rieng-tu.md, tóm tắt ngay trong app ở trang Thông tin.

### 5. Vòng đời dữ liệu

1. **Thu thập:** khi màn hình chính đang hiện và đã có quyền, app nhận số đo khoảng 1 giây một lần từ hệ điều hành.
2. **Xử lý:** làm mượt số đo, đổi sang độ-phút-giây, tách cặp số, tra bảng có sẵn trong app. Mọi bước chạy trên điện thoại.
3. **Lưu trữ:** không ghi vị trí hay tọa độ ra bộ nhớ lưu trữ. Chỉ ngôn ngữ đã chọn được lưu.
4. **Ngừng:** app ngừng nhận vị trí khi xuống nền, khi mở trang khác, và không bao giờ lấy vị trí khi đóng.
5. **Xóa:** dữ liệu trong bộ nhớ mất khi app đóng. Ngôn ngữ đã chọn mất khi gỡ app hoặc xóa dữ liệu app.

### 6. Bên nhận và chuyển dữ liệu ra nước ngoài

- Không có bên nhận. Nhà phát triển không nhận dữ liệu nào.
- Không chuyển dữ liệu ra nước ngoài. Bản phát hành không có quyền Internet nên không thể gửi dữ liệu đi.
  Vì vậy không phát sinh hồ sơ đánh giá tác động chuyển dữ liệu ra nước ngoài theo Điều 20(2) (đề nghị luật sư xác nhận).
- Giới hạn: dịch vụ định vị của hệ điều hành Android và Google Play Services có thể tự xử lý dữ liệu vị trí theo chính
  sách của nhà sản xuất điện thoại và Google. Hoạt động này nằm ngoài app, app không nhận và không kiểm soát. Chính sách
  quyền riêng tư đã nêu điều này cho người dùng.

### 7. Biện pháp bảo vệ

**Kỹ thuật**

| Biện pháp | Bằng chứng |
|---|---|
| Không có quyền Internet | `aapt2 dump permissions` trên bản build: chỉ `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION` và một quyền nội bộ của AndroidX |
| Không lấy vị trí nền | Không xin `ACCESS_BACKGROUND_LOCATION`, `FOREGROUND_SERVICE` hay `FOREGROUND_SERVICE_LOCATION` |
| Không lưu vị trí | Mã nguồn `mobile/lib/location_service.dart`; chỉ `shared_preferences` lưu ngôn ngữ |
| Tắt sao lưu | `android:allowBackup="false"` trong manifest bản release |
| Không có SDK bên thứ ba thu thập dữ liệu | Danh mục thành phần `sbom.spdx.json` (SPDX 2.3) |
| Bản phát hành ký bằng khóa riêng | Khóa do chủ app giữ, không nằm trong mã nguồn; bật Play App Signing |
| Kiểm thử | 612 test tự động; kiểm tra trên điện thoại thật Galaxy A13 |

**Tổ chức**

- Quy trình phát hành và xử lý lỗ hổng: `quy-trinh-phat-hanh.md`; kênh báo lỗ hổng công khai: `SECURITY.md`.
- Mỗi khi app thêm quyền, thêm thư viện hay đổi cách dùng dữ liệu: cập nhật bản đồ dữ liệu, chính sách quyền riêng tư,
  khai báo Data safety và đánh giá lại hồ sơ này trước khi phát hành.
- Định kỳ kiểm tra cập nhật bảo mật của thư viện (`flutter pub outdated`, SBOM).

### 8. Đánh giá rủi ro

Mức: Thấp, Trung bình, Cao. Đánh giá của nhà phát triển, cần luật sư xem lại.

| Rủi ro với chủ thể dữ liệu | Khả năng | Ảnh hưởng | Biện pháp giảm | Rủi ro còn lại |
|---|---|---|---|---|
| Vị trí bị gửi ra ngoài hoặc lộ qua mạng | Rất thấp | Cao | App không có quyền Internet; không có máy chủ | Thấp |
| Lộ lịch sử di chuyển | Rất thấp | Cao | Không lưu vị trí, không lấy vị trí nền | Thấp |
| Ứng dụng khác hoặc mã độc trên máy đọc dữ liệu của app | Thấp | Trung bình | Dữ liệu chỉ nằm trong bộ nhớ của tiến trình; không có tệp vị trí để đọc; tắt sao lưu | Thấp |
| Thư viện bên thứ ba bị chèn mã độc ở bản cập nhật sau | Thấp | Cao | Khóa phiên bản trong `pubspec.lock`; SBOM; Android chặn truy cập mạng khi thiếu quyền Internet | Thấp |
| Người dùng tự chụp màn hình có tọa độ rồi chia sẻ | Trung bình | Trung bình | Ngoài phạm vi kiểm soát của app; app không có nút chia sẻ | Chấp nhận |
| Hệ điều hành hoặc Google Play Services xử lý vị trí ngoài app | Có | Trung bình | Thông báo trong chính sách quyền riêng tư; app không gửi gì cho các dịch vụ này | Chấp nhận, ngoài phạm vi |
| Trẻ em dùng app | Thấp | Trung bình | Khai báo đối tượng 18+; không có quảng cáo, tài khoản hay trao đổi giữa người dùng | Thấp |
| Bản cập nhật sau thêm thu thập dữ liệu mà chưa đánh giá lại | Thấp | Cao | Quy trình phát hành bắt buộc cập nhật hồ sơ và khai báo trước khi nộp | Thấp |

### 9. Quyền của chủ thể dữ liệu

- Được biết: màn hình giải thích, trang Thông tin trong app, chính sách quyền riêng tư.
- Đồng ý và rút lại: cho hoặc tắt quyền vị trí trong Cài đặt.
- Truy cập, sửa, xóa, nhận bản sao: nhà phát triển không giữ dữ liệu nên không có dữ liệu để cung cấp hay xóa; người
  dùng tự xóa ngôn ngữ đã lưu bằng cách gỡ app hoặc xóa dữ liệu app.
- Liên hệ: https://github.com/phamphuongphuongnd/taodo/issues `[và email liên hệ]`.

### 10. Xử lý khi có vi phạm

- Không có máy chủ hay kho dữ liệu tập trung nên không có điểm lộ dữ liệu hàng loạt.
- Nếu phát hiện lỗ hổng làm lộ dữ liệu (ví dụ ở thư viện đi kèm): xác minh, đánh giá ảnh hưởng, phát hành bản sửa theo
  `quy-trinh-phat-hanh.md`, và nếu thuộc trường hợp Điều 23(1) thì báo cơ quan chuyên trách chậm nhất 72 giờ kể từ khi
  phát hiện.
- Người tiếp nhận và báo cáo: `[bạn điền]`.

### 11. Kết luận

Hoạt động xử lý có rủi ro còn lại ở mức **thấp**: vị trí chính xác chỉ được xử lý trên điện thoại khi người dùng đã
đồng ý và đang dùng app, không được lưu, không được gửi đi, và nhà phát triển không tiếp nhận dữ liệu.

Hồ sơ phải được đánh giá lại khi: app có quyền Internet, thêm máy chủ, tài khoản, quảng cáo, công cụ phân tích hay
SDK bên thứ ba; lấy vị trí nền; lưu lịch sử vị trí; mở rộng phát hành ngoài Việt Nam; hoặc hướng tới trẻ em.

### 12. Tài liệu kèm theo

| Tài liệu | Đường dẫn |
|---|---|
| Bản đồ dữ liệu | `docs/compliance/ban-do-du-lieu.md` |
| Chính sách quyền riêng tư | `docs/compliance/chinh-sach-quyen-rieng-tu.md` |
| Khai báo Google Play (Data safety) | `docs/compliance/khai-bao-play-console.md` |
| Danh mục thành phần phần mềm | `docs/compliance/sbom.spdx.json` |
| Quy trình phát hành và xử lý lỗ hổng | `docs/compliance/quy-trinh-phat-hanh.md` |
| Ma trận tuân thủ | `docs/compliance/ma-tran-tuan-thu.md` |
| Ảnh màn hình giải thích quyền vị trí | `[chụp từ máy thật trước khi nộp]` |

Người lập: `[họ tên, chữ ký]` — Ngày: `[ngày]`
