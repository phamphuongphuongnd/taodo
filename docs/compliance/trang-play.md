# Nội dung trang Google Play

Bản nháp cho phiên bản 1.0.0, soạn theo những gì app đang làm (`docs/chuc-nang-va-giao-dien.md`). Khi app đổi chức năng,
sửa file này cùng `khai-bao-play-console.md` trước khi nộp bản mới.

Giới hạn của Play Console: tên app tối đa 30 ký tự, mô tả ngắn tối đa 80, mô tả đầy đủ tối đa 4000, ghi chú phát hành
tối đa 500. Chính sách siêu dữ liệu của Play cấm lời khen không kiểm chứng ("tốt nhất", "số 1"), nhận xét giả của
người dùng, nhồi từ khóa và lạm dụng chữ hoa hay biểu tượng cảm xúc; nội dung dưới đây tránh các điểm đó.

Bản tiếng Anh do Claude dịch, chưa có người bản ngữ rà soát.

## Tiếng Việt (vi-VN, ngôn ngữ mặc định)

### Tên app

```text
Tọa Độ
```

### Mô tả ngắn

```text
Xem tọa độ nơi bạn đứng và ý nghĩa theo Bảng số Thiên Cung, chạy offline.
```

### Mô tả đầy đủ

```text
Tọa Độ đo vị trí hiện tại của bạn, hiện tọa độ dạng độ-phút-giây như 21°01'43"N 105°48'12"E, rồi tách các chữ số thành từng cặp để tra trong Bảng số Thiên Cung và đưa ra ý nghĩa cho vị trí đó.

CÁCH DÙNG
• Mở app, cho phép dùng vị trí, chờ GPS hiện số rồi bấm Xem.
• Không muốn cấp quyền vị trí, hoặc muốn xem một nơi khác? Chọn Nhập tay và gõ độ, phút, giây cho vĩ độ và kinh độ.

KẾT QUẢ GỒM
• Các cặp số tách từ tọa độ, mỗi cặp kèm tên cung và ý nghĩa.
• Phần Kết luận: đánh giá chung và diễn giải ngắn cho từng cung gặp trong tọa độ.
• Lưu ý riêng khi tọa độ có cung xấu.

ĐẶC ĐIỂM
• Chạy hoàn toàn offline. App không có quyền truy cập Internet.
• Không tài khoản, không quảng cáo, không công cụ theo dõi.
• Vị trí chỉ dùng khi app đang mở, chỉ xử lý trên điện thoại và không gửi đi đâu.
• Số tọa độ được làm mượt để đứng yên khi bạn không di chuyển.
• Tiếng Việt và tiếng Anh, đổi ngay trong app.
• Hỗ trợ trình đọc màn hình và chữ phóng to.

LƯU Ý
• Tọa độ GPS có sai số, nhất là trong nhà hoặc khi tín hiệu yếu, nên kết quả có thể khác giữa các lần đo.
• Không dùng app để dẫn đường hay trong tình huống khẩn cấp.
• Nội dung Bảng số Thiên Cung chỉ mang tính tham khảo, không phải lời khuyên về tài chính, sức khỏe, pháp lý hay quyết định cá nhân.
```

### Ghi chú phát hành 1.0.0

```text
Bản phát hành đầu tiên: đo tọa độ offline, nhập tay, tra Bảng số Thiên Cung, tiếng Việt và tiếng Anh.
```

## Tiếng Anh (en-US)

### App name

```text
Toa Do
```

### Short description

```text
See your coordinates and their meaning in the Thien Cung table, fully offline.
```

### Full description

```text
Toa Do measures where you are, shows your coordinates in degrees-minutes-seconds such as 21°01'43"N 105°48'12"E, then splits the digits into pairs, looks each pair up in the Thien Cung number table and tells you what the location means.

HOW TO USE
• Open the app, allow location access, wait for the GPS reading, then tap View.
• Prefer not to share your location, or want to check another place? Tap Enter manually and type the degrees, minutes and seconds.

WHAT YOU GET
• The number pairs from your coordinates, each with its theme and meaning.
• A Conclusion with an overall reading and a short note for every theme found.
• A separate caution when the coordinates include an unfavourable theme.

FEATURES
• Works fully offline. The app has no internet access.
• No accounts, no ads, no trackers.
• Location is used only while the app is open, processed only on your phone and never sent anywhere.
• Readings are smoothed so the numbers stay still when you are not moving.
• Vietnamese and English, switchable inside the app.
• Supports screen readers and larger text.

PLEASE NOTE
• GPS coordinates are approximate, especially indoors or with a weak signal, so results can differ between readings.
• Do not use this app for navigation or in an emergency.
• The Thien Cung number table is for reference only. It is not advice about money, health, legal matters or personal decisions.
```

### Release notes 1.0.0

```text
First release: offline coordinates, manual entry, Thien Cung table lookup, Vietnamese and English.
```

## Đồ họa

Đã có sẵn ở `docs/store/`, dựng từ giao diện thật của app bằng `mobile/tool/store_assets_test.dart` với tọa độ mẫu
của bản thiết kế (không lộ vị trí của ai). Đổi giao diện thì chạy lại trong `mobile/`:
`flutter test tool/store_assets_test.dart`.

| Mục | Yêu cầu của Play | File |
|---|---|---|
| Icon | PNG 32-bit, 512×512, tối đa 1 MB | `docs/store/icon-512.png` (RGBA, 15 KB) |
| Ảnh bìa | JPEG hoặc PNG 24-bit không trong suốt, 1024×500 | `docs/store/vi/anh-bia-1024x500.png`, `docs/store/en/anh-bia-1024x500.png` |
| Ảnh chụp màn hình điện thoại | 2 đến 8 ảnh, mỗi cạnh 320–3840 px, tỷ lệ không quá 2:1, không trong suốt | 4 ảnh 1080×1920 (RGB) mỗi ngôn ngữ trong `docs/store/vi/` và `docs/store/en/`: màn hình chính, kết quả, kết luận, nhập tay |

Tải bộ `vi/` cho trang tiếng Việt và bộ `en/` cho trang en-US. Ảnh không có thanh trạng thái của điện thoại; nếu muốn
ảnh chụp từ máy thật thì thay bằng ảnh chụp ở nơi không lộ tọa độ nhà riêng.
