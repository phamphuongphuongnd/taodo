# Thiết kế app Tọa Độ

Giao diện theo `design-mobile/screens/`. Tài liệu này mô tả hành vi; màu, cỡ chữ và bố cục nằm ở thiết kế đó.

App Flutter native cho Android và iOS. Đo vị trí bằng GPS của máy, chạy offline, không có server.

## Màn hình chính

- Nền đen, chữ trắng, dùng `CupertinoApp`, thiết kế chuẩn 390×844, tự co theo màn hình.
- Hiện tọa độ dạng `21°01'43"N 105°48'12"E`, cập nhật liên tục.
- Độ, phút và giây đều đủ ít nhất 2 chữ số, ví dụ `08°46'12"N`; giây cắt bỏ phần lẻ, không làm tròn lên.
- Nút "Xem" chỉ bấm được khi đã có tọa độ. Góc màn hình có nút chọn ngôn ngữ.
- Khi chưa có tọa độ: đang chờ tín hiệu GPS, chưa cấp quyền, hoặc định vị đang tắt (hai trạng thái sau có nút mở Cài đặt).

## Nhập tay

Nút "Nhập tay" luôn bấm được. Trang nhập có 6 ô số độ, phút, giây kèm chọn N/S và E/W; ô trống tính là 0; phút và giây
phải dưới 60, vĩ độ không quá 90°, kinh độ không quá 180°. Bấm "Xem" mở trang kết quả với tọa độ đã đưa về đúng định
dạng.

## Trang kết quả

- Lấy tọa độ tại lúc bấm "Xem" và giữ nguyên.
- Tách số: lấy toàn bộ chữ số, tách cặp từ phải sang trái, cặp cuối lẻ thì thêm `0` phía trước.
  `21°01'43"N 105°48'12"E` → `12, 48, 05, 31, 14, 10, 02`.
- Tra từng cặp trong Bảng số Thiên Cung (`mobile/lib/thien_cung_data.dart`). Số thuộc nhiều cung thì hiện đủ, số không
  có trong bảng thì ẩn.

## Kết luận

1. Đếm số lần mỗi cung xuất hiện; một số thuộc nhiều cung thì tính cho từng cung.
2. Câu chính nêu cung xuất hiện nhiều nhất; bằng nhau thì nêu tất cả theo thứ tự trong bảng.
3. Có Cung Tai Họa hoặc nhóm Tai họa của Đào Hoa thì thêm câu lưu ý, kể cả khi không phải cung nhiều nhất.
4. Không có số nào trong bảng thì chỉ hiện câu "Tọa độ này không có số nào trong bảng".
5. Dòng chưa có dữ liệu vẫn hiện trong danh sách với chữ "Chưa có dữ liệu" nhưng không tính vào Kết luận. Nếu chỉ có
   các dòng như vậy thì phần Kết luận ghi "Chưa có dữ liệu để kết luận".

## Ngôn ngữ

Tiếng Việt và tiếng Anh, người dùng tự chọn trong app, lựa chọn được lưu trên máy. Lần mở đầu theo ngôn ngữ điện
thoại: máy tiếng Việt ra tiếng Việt, ngôn ngữ khác ra tiếng Anh. Số tọa độ và chữ N/S/E/W không đổi.

## Giới hạn đã chốt

- Không làm: sao chép, chia sẻ, đổi định dạng, ±mét, bản đồ, lịch sử, tài khoản, đo nền.
- Android dùng `forceLocationManager` để không phụ thuộc Google Play Services.
- Ý nghĩa tiếng Việt do người dùng cung cấp; bản tiếng Anh được dịch từ đó.
- iPhone cần Apple Developer trả phí để cài lâu dài; bản iOS không build được trên Windows.
