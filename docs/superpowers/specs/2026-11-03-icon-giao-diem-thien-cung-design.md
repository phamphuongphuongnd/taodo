# Icon "Giao điểm Thiên Cung" — thiết kế

Ngày: 03/11/2026. Người dùng chọn phương án A trong 3 phương án và yêu cầu đổi cả biểu tượng trong app.

## Mục tiêu

Thay icon la bàn (hình phổ biến, hơi giống ý tưởng la bàn của Safari) bằng một dấu hiệu riêng nói được hai vế của app:
tọa độ (kinh tuyến, vĩ tuyến) và Thiên Cung (cung tròn, ngôi sao). Icon phải rõ ở 48 px và ở chế độ icon đơn sắc.

## Hình vẽ

Tọa độ tính trên khung vuông cạnh 108 đơn vị (khung icon thích ứng Android), tâm (54, 54). Mọi nét nằm trong vùng an
toàn hình tròn bán kính 33 quanh tâm.

| Thành phần | Hình học | Màu |
|---|---|---|
| Nền (chỉ ở icon có nền) | Phủ kín | `#050608` (`AppColors.screen`) |
| Vĩ tuyến | Đoạn ngang y = 54, x từ 23 đến 85, nét 3, đầu bo tròn | `#F5F6F8` (`AppColors.text`) |
| Kinh tuyến | Đoạn dọc x = 54, y từ 23 đến 85, nét 3, đầu bo tròn | `#F5F6F8` |
| Cung trên-trái | Cung tròn tâm (54, 54) bán kính 25, từ góc 180° đến 270° (trái lên trên), nét 4.5, đầu bo tròn | `#6EE7B7` (`AppColors.accent`) |
| Cung dưới-phải | Đối xứng tâm với cung trên-trái (0° đến 90°) | `#6EE7B7` |
| Ngôi sao 4 cánh | Tâm (54, 54), đỉnh cánh cách tâm 15, eo cách tâm 4, có viền màu nền dày 2.5 để tách khỏi hai đường kẻ | `#6EE7B7` |

Số đo nét là điểm khởi đầu; được phép chỉnh tối đa ±30% sau khi xem ảnh 48 px, miễn giữ đúng bố cục trên. Số cuối cùng
ghi trong code.

Biến thể trong app (thanh trên màn hình chính): cùng hình, không nền, viền sao lấy màu nền màn hình, cỡ 24 thay cho
`Icon(CupertinoIcons.compass, size: 24)` ở `mobile/lib/location_screen.dart`. Là hình trang trí, không có nhãn đọc màn hình
(giống `Icon` hiện tại).

## Thành phần code

| Đơn vị | Việc | Dùng bởi |
|---|---|---|
| `mobile/lib/app_mark.dart` | `AppMarkPainter` (vẽ hình trên khung 108 co giãn theo kích thước, tùy chọn có nền) và widget `AppMark(size)` | Thanh trên màn hình chính; tool xuất icon |
| `mobile/tool/png_writer.dart` | Hàm ghi PNG RGB/RGBA tách từ `store_assets_test.dart` | `store_assets_test.dart`, tool xuất icon |
| `mobile/tool/app_icon_test.dart` | Vẽ `AppMarkPainter` ra PNG: `assets/icon/icon.png` 1024 RGB có nền; `ic_launcher_foreground.png` 5 mật độ (108, 162, 216, 324, 432) RGBA nền trong suốt | Chạy tay khi đổi icon |

`flutter_launcher_icons` (cấu hình hiện có, không bật adaptive) sinh lại `ic_launcher.png` 5 mật độ và bộ icon iOS từ
`icon.png`. `mipmap-anydpi-v26/ic_launcher.xml` giữ nguyên: nền `@color/splash_background`, lớp trước và lớp đơn sắc là
`ic_launcher_foreground`. Sau đó chạy lại `tool/store_assets_test.dart` để có `docs/store/icon-512.png`, ảnh bìa và ảnh chụp
màn hình có biểu tượng mới.

## Không làm

Không đổi màu, font hay bố cục khác của app; không đổi màn hình mở app (đang chỉ có nền tối); không thêm thư viện.

## Kiểm tra

- Xem ảnh 1024 px và bản thu 48 px; xem lớp trước bị cắt tròn vẫn đủ nét.
- Test widget: thanh trên màn hình chính có `AppMark`, không còn `CupertinoIcons.compass`.
- `flutter analyze` sạch, toàn bộ test đạt.
- Build `.aab`, dùng `aapt2` kiểm tra icon trong bản build; tùy người dùng, cài thử lên máy thật.
- Cập nhật `docs/chuc-nang-va-giao-dien.md` (mục icon app) và `docs/compliance/trang-play.md` nếu mô tả icon.
