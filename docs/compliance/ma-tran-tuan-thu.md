# Ma trận tuân thủ

Đối chiếu app Tọa Độ 1.0.0 với tài liệu `tieu-chuan-ban-app-toan-cau.md` (cập nhật 28/10/2026). Phạm vi: Google Play, miễn phí, chủ yếu Việt Nam, tài khoản cá nhân. Ngày rà: 01/11/2026.

Đây là tự đánh giá kỹ thuật, không phải chứng nhận và không phải tư vấn pháp lý.

Ký hiệu: **Đạt** có bằng chứng. **Một phần** làm xong phần của code, còn việc khác. **Bạn làm** chỉ chủ app làm được. **Luật sư** cần xác nhận pháp lý.

## Yêu cầu áp dụng

| Lớp | Yêu cầu | Trạng thái | Bằng chứng hoặc việc còn lại |
|---|---|---|---|
| 1 | Kiểm thử có quy trình | Đạt | 309 test tự động, `flutter analyze` sạch; `quy-trinh-phat-hanh.md` |
| 1 | Tài liệu yêu cầu và thiết kế | Đạt | `docs/superpowers/specs/2026-10-31-toado-design.md`, thiết kế giao diện ở `design-mobile/` |
| 2 | Kênh tiếp nhận lỗ hổng | Một phần | `SECURITY.md`. Bạn cần theo dõi trang issues |
| 2 | SBOM và kiểm kê giấy phép | Đạt | `sbom.spdx.json`, SPDX 2.3, 78 gói và font Manrope (OFL-1.1); `mobile/tool/generate_sbom.dart` |
| 2 | Giấy phép nguồn mở trong app | Đạt | Trang Thông tin, đã mở trên Galaxy A13, có cả Manrope |
| 2 | Lưu trữ tối thiểu | Đạt | Chỉ lưu ngôn ngữ; `allowBackup=false` trong bản release |
| 2 | Không có đường truyền mạng | Đạt | Bản release không có quyền Internet (`aapt`) |
| 2 | Bản phát hành không dùng khóa debug | **Bạn làm** | `build.gradle.kts` đã sẵn sàng; bạn tạo keystore theo `quy-trinh-phat-hanh.md` |
| 3 | Bản đồ dữ liệu | Đạt | `ban-do-du-lieu.md` |
| 3 | Chính sách quyền riêng tư | Một phần | `chinh-sach-quyen-rieng-tu.md`, tóm tắt trong app. Bạn dán link vào Play Console |
| 3 | Đồng ý theo mục đích, không ép bật quyền | Đạt | Màn hình giải thích trước hộp thoại; từ chối vẫn dùng Nhập tay. Đã test cả 2 nhánh trên Galaxy A13 |
| 3 | Đánh giá tác động tại Việt Nam, Điều 21 Luật 91/2025/QH15 | **Luật sư** | Dữ liệu không rời khỏi máy, nhưng vị trí chính xác là loại rủi ro cao |
| 3 | Bộ phận bảo vệ dữ liệu, Điều 33(2) | **Luật sư** | Cần xác nhận có áp dụng với cá nhân không tiếp nhận dữ liệu không |
| 3 | Kịch bản xử lý vi phạm | Đạt ở mức app | Không có máy chủ hay dữ liệu tập trung; quy trình lỗ hổng trong `quy-trinh-phat-hanh.md` |
| 4 | Khả năng tiếp cận | Một phần | `bao-cao-tiep-can.md`. Còn TalkBack trên máy thật |
| 4 | Thông báo giới hạn sử dụng | Đạt | Trang Thông tin: sai số, không dẫn đường, nội dung tham khảo |
| 5 | Target API 36 | Đạt | `aapt` trên bản build |
| 5 | Hỗ trợ trang bộ nhớ 16 KB | Đạt | `zipalign -c -P 16` đạt; thư viện native arm64 và x86_64 căn tối thiểu 16384 |
| 5 | Công bố nổi bật kèm đồng ý | Đạt | Màn hình giải thích, kiểm trên máy thật |
| 5 | Data safety, xếp hạng nội dung, đối tượng | **Bạn làm** | Câu trả lời soạn sẵn ở `khai-bao-play-console.md` |
| 5 | Chạy thử kín 12 người trong 14 ngày | **Bạn làm** | Bắt buộc với tài khoản cá nhân mới |
| 5 | Xác minh nhà phát triển | **Bạn làm** | Thực hiện trong Play Console |
| 5 | App hoàn thiện, không có phần dở dang | **Bạn làm** | 6 nhóm còn "Chưa có dữ liệu" có thể bị đánh giá là chưa hoàn thiện |
| 6 | Trừng phạt | Đạt theo phạm vi | Đợt đầu chỉ chọn Việt Nam trong Play Console |
| 6 | Bản địa hóa | Đạt | Việt và Anh; định dạng tọa độ không đổi theo ngôn ngữ |
| 6 | Quyền với nội dung | **Bạn làm** | Xác nhận quyền dùng Bảng số Thiên Cung và tên hiển thị; cân nhắc đăng ký nhãn hiệu |

## Không áp dụng trong phạm vi này

| Hạng mục | Lý do | Xem lại khi |
|---|---|---|
| ISO 27001, 9001, SOC 2, CSA STAR, FedRAMP | Không bắt buộc để bán app | Bán cho doanh nghiệp hoặc cơ quan |
| PCI DSS, Play Billing, thuế, nút rút lui EU, ROSCA | Miễn phí, không thanh toán | Bắt đầu thu tiền |
| Xóa tài khoản, OAuth, passkey | Không có tài khoản | Thêm tài khoản |
| Nền tảng quản lý đồng ý, hợp đồng xử lý dữ liệu | Không có bên xử lý dữ liệu | Thêm SDK hoặc máy chủ |
| AI Act và quy định ngành | Không dùng AI, không thuộc ngành có quy định riêng | Thêm tính năng AI |
| Tín hiệu tuổi | App không hướng tới trẻ em, không có nội dung giới hạn tuổi | Đổi đối tượng hoặc mở Texas, Brazil |
| Đại diện EU/Anh, EAA, CRA đầy đủ | Không bán tại EU và Anh | Mở các thị trường này |
| App Store, `PrivacyInfo.xcprivacy`, khai báo mã hóa | Làm sau | Phát hành iOS |

## Rủi ro đã biết

- **Kết quả cung nhạy với sai số GPS:** lệch 1 giây tọa độ có thể đổi cặp số; trang Thông tin nêu tọa độ có sai số.
- **Định vị trên máy có Google Play Services:** trên Galaxy A13, nhà cung cấp `fused` do Play Services phục vụ. Hành vi trên máy không có dịch vụ này chưa được test.
- **Thời hạn 60 giây mất tín hiệu** là lựa chọn của nhóm phát triển, đã test tự động nhưng chưa test bằng cách chặn tín hiệu thật.
- **Bản tiếng Anh** do Claude dịch, chưa có người bản ngữ rà soát.
