# Báo cáo khả năng tiếp cận

Phiên bản 1.0.0, cập nhật 01/11/2026 sau khi đổi giao diện theo `design-mobile/`. Mục tiêu thiết kế: WCAG 2.2 mức AA, theo gợi ý ở Lớp 4 của tài liệu tiêu chuẩn. Đây là tự đánh giá của nhóm phát triển, chưa có bên thứ ba kiểm định.

## Kết quả

| Tiêu chí | Cách kiểm | Kết quả |
|---|---|---|
| Nhãn cho trình đọc màn hình | Widget test | Đạt: tọa độ đọc thành lời, ví dụ "Vĩ độ 20 độ 18 phút 8 giây Bắc" |
| Nhãn 6 ô nhập, nút bán cầu, nút Thông tin, nút ngôn ngữ | Widget test | Đạt |
| Báo ô nhập sai | Widget test | Đạt: live region cho hộp lỗi, ô sai đọc thêm chữ "sai" |
| Dòng kết quả đọc gộp | Widget test | Đạt: số, nhãn cảnh báo, tên cung, ý nghĩa đọc thành một mục |
| Không dùng màu làm tín hiệu duy nhất | Đọc code, xem máy thật | Đạt: cảnh báo có chữ "CẢNH BÁO" và tam giác; ô sai có hộp lỗi; dòng thiếu dữ liệu có chữ |
| Tương phản chữ tối thiểu 4.5:1 | Test tự động trên 14 cặp màu | Đạt, xem bảng dưới |
| Vùng bấm tối thiểu | Widget test | Đạt: các nút phụ và nút bán cầu 44, nút chính 56–60 |
| Chữ phóng to 200% không vỡ giao diện | Widget test ở 390×844, 360×800, 320×568, Việt và Anh | Đạt |
| Giảm chuyển động | Widget test | Đạt: tắt toàn bộ hoạt ảnh lặp khi máy bật tùy chọn này |
| Tọa độ không bị đọc liên tục | Đọc code | Đạt: cố ý không dùng live region cho số cập nhật mỗi giây |
| Chữ số không giật khi cập nhật | Kiểm font, widget test | Đạt: bật `tnum` của Manrope |

## Độ tương phản đo được

| Cặp màu | Tỉ lệ |
|---|---|
| Chữ chính `#F5F6F8` trên nền `#050608` | 18.7:1 |
| Ý nghĩa `#B4B9C4` trên thẻ `#0E1015` | 9.7:1 |
| Cảnh báo `#FFB340` trên nền cảnh báo `#2A1C06` | 9.3:1 |
| Nhấn `#6EE7B7` trên nền `#050608` | 13.3:1 |
| Nhãn `#9BA0AB` trên nền `#050608` | 7.7:1 |
| Chữ phụ `#7D8390` trên nền `#050608` | 5.3:1 |
| Chữ nút Xem bị khóa trên `#14171D` | 4.7:1 |
| Gợi ý `0` trên ô nhập `#181B22` | 4.5:1 |

Hai điểm khác thiết kế vì khả năng tiếp cận: chữ gợi ý đổi từ `#4B505B` sang `#7D8390`; nút bán cầu tăng từ cao 40 lên 44. Các dấu `–` lúc chờ GPS có tương phản thấp nhưng chỉ để trang trí và đã ẩn khỏi trình đọc màn hình.

## Chưa kiểm

- **TalkBack trên máy thật:** cần bật trong Cài đặt nên chưa làm. Widget test chỉ chứng minh nhãn có tồn tại, chưa chứng minh trải nghiệm đọc thực tế.
- **Cỡ chữ lớn nhất trên Galaxy A13:** mới kiểm bằng widget test với font giả.
- **VoiceOver:** chưa có bản iOS.
- **Màn hình giấy phép:** là trang có sẵn của Flutter, chỉ có tiếng Anh.

Cần hoàn tất phần trên trước khi tuyên bố đạt WCAG 2.2 AA.
