# Bảng Kiểm Tra Kiến Trúc Flutter Clean Architecture (Checklist)

Bảng đối soát tiêu chuẩn chất lượng và ranh giới kiến trúc cho dự án **KLTN2026-2027**:

---

## 1. Tầng Domain (`lib/domain/`)
- [ ] Không import `package:flutter/material.dart` hoặc `package:flutter/widgets.dart`.
- [ ] Không import `package:dio/dio.dart`.
- [ ] Không import bất kỳ file nào từ `lib/data/dto/`.
- [ ] Các Entity là class immutable, triển khai `props` từ `package:equatable/equatable.dart`.
- [ ] Repository interfaces khai báo phương thức trừu tượng, trả về `Future<Entity>` hoặc `Future<List<Entity>>`.
- [ ] UseCases kế thừa `UseCase<Output>` hoặc `UseCaseWithParams<Output, Params>`.

---

## 2. Tầng Data (`lib/data/`)
- [ ] Các DTO trong `lib/data/dto/` có phương thức `fromJson` với các hàm parse phòng thủ (`_parseInt`, `_parseBool`, `_parseString`).
- [ ] Mọi Remote Datasource Implementation kế thừa `BaseRemoteDatasource`.
- [ ] Datasource sử dụng `handleResponse` hoặc `handleListResponse`, và ném ngoại lệ qua `handleError(e)`.
- [ ] Mapper nằm trong `lib/data/mapper/` và xử lý chuyển đổi dữ liệu sạch sẽ giữa DTO và Entity.
- [ ] Repository Implementation phụ thuộc vào Datasource và Mapper, không chứa logic giao diện.

---

## 3. Tầng Presentation (`lib/ui/`)
- [ ] Màn hình chính sử dụng `ResponsiveLayout(mobile: ..., tablet: ...)`.
- [ ] ViewModel kế thừa `StateNotifier<State>`, không chứa tham chiếu đến `BuildContext`.
- [ ] Trạng thái màn hình (State) là immutable và có phương thức `copyWith`.
- [ ] UI không gọi trực tiếp `Dio` hoặc `Datasource`.
- [ ] Nhãn văn bản và thông báo lỗi hiển thị qua `context.l10n`.
- [ ] Không có emoji hoặc icon trang trí trong mã nguồn.
