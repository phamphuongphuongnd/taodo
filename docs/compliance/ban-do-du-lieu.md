# Bản đồ dữ liệu của app Tọa Độ

Cập nhật: 01/11/2026, áp dụng cho phiên bản 1.0.0. Nguồn yêu cầu: Lớp 3, mục "Nền chung", ý 1 của tài liệu tiêu chuẩn.

| Dữ liệu | Mục đích | Cơ sở | Nơi xử lý | Thời gian giữ | Bên nhận | Rời khỏi máy |
|---|---|---|---|---|---|---|
| Vị trí chính xác | Hiện tọa độ, tách cặp số | Người dùng cho phép qua màn hình giải thích và hộp thoại hệ thống | Bộ nhớ của app trên điện thoại | Tới khi đóng app, không ghi ra đĩa | Không có | Không |
| Tọa độ nhập tay | Tách cặp số | Người dùng tự nhập | Bộ nhớ của app trên điện thoại | Tới khi rời trang | Không có | Không |
| Ngôn ngữ đã chọn | Hiện đúng ngôn ngữ | Người dùng tự chọn | `shared_preferences` trên điện thoại | Tới khi gỡ app hoặc xóa dữ liệu | Không có | Không, `allowBackup` đã tắt |

## Bằng chứng kỹ thuật

- Bản release chỉ có quyền `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION` và một quyền nội bộ do AndroidX sinh. Không có `INTERNET` (đo bằng `aapt dump permissions`).
- Manifest bản release có `allowBackup=false` (đo bằng `aapt dump xmltree`).
- Không có SDK quảng cáo, analytics hay đăng nhập; xem `sbom.spdx.json`.

## Giới hạn

Bản đồ này chỉ mô tả app. Dịch vụ định vị của Android có thể tự xử lý dữ liệu ngoài app. Trên máy có Google Play Services, nhà cung cấp `fused` do dịch vụ đó phục vụ; khi có mạng, hệ điều hành có thể dùng dữ liệu mạng để định vị. App không gửi gì trong quá trình này.

## Việc chưa kết luận

Vị trí chính xác là loại xử lý rủi ro cao trong tài liệu tiêu chuẩn. Nhận định kỹ thuật ở đây là nhà phát triển không tiếp nhận dữ liệu, nhưng việc có cần hồ sơ đánh giá tác động theo Điều 21 Luật 91/2025/QH15 hay không cần luật sư xác nhận.
