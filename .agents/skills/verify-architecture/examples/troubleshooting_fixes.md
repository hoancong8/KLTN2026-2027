# Hướng Dẫn Sửa Lỗi Kiến Trúc Thường Gặp (Troubleshooting Fixes)

Các giải pháp chuẩn cho các lỗi kiến trúc thường gặp được phát hiện bởi `verify_architecture.py`:

---

## 1. Lỗi: `DOMAIN_IMPORTS_FLUTTER`
**Mô tả:** Tầng Domain import thư viện giao diện Flutter (`package:flutter/material.dart`).
**Cách sửa:**
- Xóa bỏ `import 'package:flutter/material.dart';`.
- Nếu dùng `@immutable`, thay thế bằng `import 'package:meta/meta.dart';`.
- Nếu so sánh thực thể, dùng `import 'package:equatable/equatable.dart';`.

---

## 2. Lỗi: `DOMAIN_IMPORTS_DTO`
**Mô tả:** UseCase hoặc Entity import trực tiếp `*ResponseDto`.
**Cách sửa:**
- Trả về Domain Entity thay vì DTO từ Repository.
- Đảm bảo Repository Implementation ở tầng Data dùng Mapper để biến đổi DTO thành Entity trước khi trả về.

---

## 3. Lỗi: `UI_IMPORTS_DATASOURCE`
**Mô tả:** Widget hoặc ViewModel import trực tiếp `*RemoteDatasource`.
**Cách sửa:**
- ViewModel chỉ nhận UseCase qua constructor.
- UI chỉ giao tiếp với ViewModel qua `ref.watch(viewModelProvider)` và `ref.read(viewModelProvider.notifier)`.

---

## 4. Lỗi: `DATASOURCE_MISSING_BASE`
**Mô tả:** Remote Datasource Implementation không kế thừa `BaseRemoteDatasource`.
**Cách sửa:**
```dart
// Trước khi sửa (SAI):
class ClubRemoteDatasourceImpl implements ClubRemoteDatasource { ... }

// Sau khi sửa (ĐÚNG):
class ClubRemoteDatasourceImpl extends BaseRemoteDatasource implements ClubRemoteDatasource { ... }
```

---

## 5. Lỗi: `ZERO_EMOJI_VIOLATION`
**Mô tả:** Có ký tự emoji trong source code, comment, hoặc log.
**Cách sửa:**
- Thay các emoji như 🎉, 🚀, ⚠️, ❌ bằng ASCII markers chuẩn: `[OK]`, `[INFO]`, `[WARN]`, `[ERROR]`.
