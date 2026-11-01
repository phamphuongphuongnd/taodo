# Khai báo Google Play Console

Câu trả lời soạn sẵn cho phiên bản 1.0.0. Giao diện Play Console có thể đổi, nên đọc kỹ câu hỏi thật trước khi chọn. Khi app đổi hành vi, phải sửa file này trước khi nộp bản mới.

## Thông tin chung

| Mục | Khai báo |
|---|---|
| Mã app | `com.phuong.toado` |
| Loại | Ứng dụng, miễn phí |
| Danh mục gợi ý | Công cụ |
| Quảng cáo | Không |
| Quốc gia phát hành đợt đầu | Chỉ Việt Nam |
| Chính sách quyền riêng tư | https://github.com/phamphuongphuongnd/taodo/blob/master/docs/compliance/chinh-sach-quyen-rieng-tu.md |
| Email liên hệ | Bạn tự điền |

Chọn riêng Việt Nam cũng tránh được các yêu cầu theo từng nước của EU, Mỹ, Brazil và các nước bị cấm vận. Muốn mở thêm nước phải rà lại tài liệu tiêu chuẩn trước.

## Data safety

| Câu hỏi | Trả lời | Lý do |
|---|---|---|
| App có thu thập hoặc chia sẻ dữ liệu người dùng không? | Không | Vị trí chỉ xử lý trên máy, không rời khỏi máy, app không có quyền Internet |
| Dữ liệu có được mã hóa khi truyền không? | Không áp dụng | App không truyền dữ liệu |
| Người dùng có thể yêu cầu xóa dữ liệu không? | Không áp dụng | Nhà phát triển không giữ dữ liệu |

Google hướng dẫn dữ liệu xử lý hoàn toàn trên thiết bị không tính là "thu thập". Bạn nên đọc lại định nghĩa trong trang Data safety trước khi nộp.

## Đối tượng và nội dung

| Mục | Khai báo gợi ý |
|---|---|
| Đối tượng mục tiêu | 18 tuổi trở lên, không hướng tới trẻ em |
| Xếp hạng nội dung | Điền bảng câu hỏi trung thực. App không có bạo lực, nội dung người lớn, cờ bạc, mua bán hay tương tác giữa người dùng |
| Quyền truy cập cho người kiểm duyệt | Mọi chức năng dùng được không cần tài khoản |
| Dịch vụ vị trí nền | Không dùng |

## Quyền nhạy cảm

Trong mô tả cho người duyệt: app dùng vị trí chính xác khi đang mở để hiện tọa độ; đó là chức năng chính; không dùng nền; có màn hình giải thích trước hộp thoại hệ thống; từ chối vẫn dùng được Nhập tay.

## Yêu cầu trước khi mở công khai

- Tài khoản cá nhân mới phải chạy thử kín với ít nhất 12 người liên tục tối thiểu 14 ngày.
- Ký bằng khóa của bạn và nộp file `.aab`.
- Nộp theo target API đang yêu cầu; hiện app nhắm API 36.
