# Quy trình phát hành

Áp dụng cho mỗi bản đưa lên Google Play.

## Trước khi build

1. Xem lại hạn chót Google Play. Mốc đã biết: bản cập nhật phải hỗ trợ trang 16 KB từ 01/02/2027; các quy định mới về vị trí có hạn 27/01/2027.
2. Tăng `version` trong `mobile/pubspec.yaml` và `appVersion` trong `mobile/lib/about_screen.dart`. Có test kiểm tra hai số khớp nhau.
3. Nếu thay đổi dữ liệu hay quyền, sửa `ban-do-du-lieu.md`, `chinh-sach-quyen-rieng-tu.md`, `khai-bao-play-console.md`.

## Kiểm tra

Chạy trong `mobile/`, Flutter ở `C:\src\flutter\bin`:

```bash
flutter analyze
```

```bash
flutter test
```

```bash
dart run tool/generate_sbom.dart
```

```bash
flutter build appbundle --release
```

File ra ở `mobile/build/app/outputs/bundle/release/app-release.aab`. Nếu máy thiếu `cmdline-tools` của Android SDK,
Flutter báo "failed to strip debug symbols" dù file vẫn được tạo. Lần build ngày 03/11/2026 đã kiểm bằng `llvm-readelf`:
mọi `.so` trong `base/lib/` đều không có `.symtab` hay `.debug_*`, căn trang tối thiểu 16 KB; ký hiệu debug nằm trong
`BUNDLE-METADATA/` để Play giải mã báo cáo crash, không tải về máy người dùng. Cài `cmdline-tools` trong SDK Manager của
Android Studio thì hết báo.

Sau đó test trên máy thật: gỡ app rồi cài lại, xem màn hình giải thích, từ chối quyền, cấp quyền, Nhập tay, Thông tin, đổi ngôn ngữ, đo khi không có mạng.

## Tạo khóa ký

Chỉ làm một lần, do chủ app tự làm. Giữ bản sao khóa và mật khẩu ở nơi an toàn: mất khóa thì không cập nhật được app, trừ khi đã bật Play App Signing và làm thủ tục đổi khóa.

```bash
keytool -genkey -v -keystore toado-release.jks -keyalg RSA -keysize 4096 -validity 10000 -alias toado
```

Đặt file vào `mobile/android/` rồi tạo `mobile/android/key.properties`:

```text
storeFile=../toado-release.jks
storePassword=mật khẩu của bạn
keyAlias=toado
keyPassword=mật khẩu của bạn
```

`key.properties`, `*.jks` và `*.keystore` đã được bỏ qua trong git. Không có `key.properties` thì bản build dùng khóa debug và không nộp lên Play được.

## Xử lý lỗ hổng

1. Nhận báo cáo qua kênh trong `SECURITY.md`, ghi ngày nhận.
2. Xác minh và đánh giá ảnh hưởng. App không có máy chủ nên rủi ro chủ yếu ở thư viện đi kèm.
3. Sửa, chạy lại toàn bộ kiểm tra, phát hành bản mới, ghi lại trong nhật ký phát hành.

Định kỳ chạy `flutter pub outdated` và đọc thông báo bảo mật của các thư viện trong `sbom.spdx.json`.

## Thời hạn hỗ trợ

Chỉ bản mới nhất trên Google Play được hỗ trợ. Bạn tự quyết định cam kết thời gian cụ thể nếu mở rộng sang EU, vì khi đó Cyber Resilience Act yêu cầu công bố thời hạn hỗ trợ.

## Khi mở thêm thị trường

Làm lại phần tương ứng trong tài liệu tiêu chuẩn. Riêng EU cần xem lại EAA, CRA và đại diện tại EU trước khi chọn quốc gia trong Play Console.
