---
title: Index — Mục lục wiki
type: index
updated: 2026-10-22
---

# Index — Mục lục LLM Wiki

> **Luôn đọc trang này đầu tiên** khi cần kiến thức project (xem `[[SCHEMA]]` → thao tác QUERY).
> Wiki vận hành theo phương pháp Karpathy "LLM Wiki". Quy tắc đầy đủ ở [[SCHEMA]].

## Tổng quan dự án
- **Tên:** Tọa Độ (`toado`, mã định danh `com.phiotron.toado`).
- **Mục đích:** đo vị trí hiện tại offline, hiện tọa độ dạng `21°01'43"N 105°48'12"E`, tách thành cặp số và tra Bảng số Thiên Cung.
- **Loại dự án:** app mobile native Android + iOS, không có server.
- **Ngôn ngữ & stack:** Dart / Flutter, `geolocator`, `shared_preferences`.
- **Thư mục chính:** `mobile/` (`mobile/lib/`, `mobile/test/`); ý nghĩa các cung sửa ở `mobile/lib/thien_cung_data.dart`.
- **Lệnh** (chạy trong `mobile/`, Flutter ở `C:\src\flutter\bin\flutter`, chưa có trong PATH): chạy `flutter run` · test `flutter test` · kiểm tra biên dịch `flutter analyze`.

## Bộ luật & nhật ký
- [[SCHEMA]] — quy ước trang + 3 thao tác Ingest / Query / Lint.
- [[log]] — nhật ký phiên (append-only).
- [[preferences]] — cách làm việc người dùng muốn tôi tuân theo.

## Modules
*(chưa có)*

## Entities
*(chưa có)*

## Concepts (pattern dùng lại được)
*(chưa có)*

## Decisions (ADR)
*(chưa có)*
