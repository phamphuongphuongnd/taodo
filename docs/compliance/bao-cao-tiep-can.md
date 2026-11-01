# Báo cáo khả năng tiếp cận

Phiên bản 1.0.0, ngày 01/11/2026. Mục tiêu thiết kế: WCAG 2.2 mức AA, theo gợi ý ở Lớp 4 của tài liệu tiêu chuẩn. Đây là tự đánh giá của nhóm phát triển, chưa có bên thứ ba kiểm định.

## Kết quả

| Tiêu chí | Cách kiểm | Kết quả |
|---|---|---|
| Nhãn cho trình đọc màn hình | Widget test | Đạt: tọa độ đọc thành lời, ví dụ "Vĩ độ 20 độ 18 phút 8 giây Bắc" |
| Nhãn 6 ô nhập và nút N/S, E/W | Widget test | Đạt |
| Thông báo lỗi nhập | Widget test: live region | Đạt |
| Không dùng màu làm tín hiệu duy nhất | Đọc code | Đạt: nhóm xấu có chữ "Tai họa", câu lưu ý có chữ "Lưu ý" |
| Tương phản chữ thường tối thiểu 4.5:1 | Tính từ mã màu trên nền đen | Đạt: `#8E8E93` khoảng 6.4:1, `#AEAEB2` khoảng 9.5:1, `#FF9F0A` khoảng 10.2:1 |
| Vùng bấm tối thiểu 24 CSS px | Đọc code, đo trên ảnh chụp máy thật | Đạt: nút phụ 44, nút N/S khoảng 32 |
| Chữ phóng to 200% không vỡ giao diện | Widget test 390×844 và 320×568, Việt và Anh | Đạt |
| Tọa độ không bị đọc liên tục | Đọc code | Đạt: cố ý không dùng live region cho số cập nhật mỗi giây |

## Chưa kiểm

- **TalkBack trên máy thật:** cần bật trong Cài đặt nên chưa làm. Widget test chỉ chứng minh nhãn có tồn tại, chưa chứng minh trải nghiệm đọc thực tế.
- **Cỡ chữ lớn nhất trên Galaxy A13:** mới kiểm bằng widget test với font giả.
- **VoiceOver:** chưa có bản iOS.
- **Thứ tự di chuyển bằng trình đọc màn hình** và màn hình giấy phép, là trang có sẵn của Flutter và chỉ có tiếng Anh.

Cần hoàn tất bảng trên trước khi tuyên bố đạt WCAG 2.2 AA.
