---
trigger: "lib/domain/**, lib/data/**, lib/app/provider.dart"
description: "Quy chuẩn tầng lõi Core (Domain + Data + DI): Pure Dart Domain, DTO Defensive Parsing, BaseRemoteDatasource, ABP Protocol Resilience, và Contextual Multi-Club Dynamic RBAC."
---

# Quy Chuẩn Tầng Lõi Hệ Thống (Core Architecture: Domain, Data & RBAC)

Tài liệu định nghĩa các quy chuẩn bắt buộc khi làm việc trong phân hệ Core: tầng Domain (nghiệp vụ), tầng Data (giao thức API, phòng thủ DTO) và cơ chế phân quyền đa câu lạc bộ (Multi-Club Dynamic RBAC).

---

## 1. Tầng Domain (Business Core) - Pure Dart 100%

Tầng Domain là hạt nhân nghiệp vụ của ứng dụng, hoàn toàn độc lập với công nghệ bên ngoài.

### Invariants:
1. **Zero Flutter UI:** Không import bất kỳ package nào thuộc `package:flutter/*`. Chỉ dùng `package:meta/meta.dart` cho `@immutable`.
2. **Zero HTTP Client:** Không import `package:dio/*`.
3. **Zero DTO References:** Không import hoặc tham chiếu tới bất kỳ tệp nào trong `lib/data/dto/`.
4. **Cấu trúc thành phần:**
   - **Entity (`lib/domain/entities/`):** Pure Dart model, bất biến, triển khai `copyWith`, `operator ==` và `hashCode`.
   - **Repository Interface (`lib/domain/repositories/`):** `abstract class` định nghĩa hợp đồng nghiệp vụ, trả về `Future<Entity>` hoặc `Future<List<Entity>>`. Không trả về DTO hay `Response`.
   - **UseCase (`lib/domain/usecases/`):** Mỗi UseCase đại diện cho MỘT hành động nghiệp vụ duy nhất. Kế thừa `UseCase<Type>` hoặc `UseCaseWithParams<Type, Params>`.

---

## 2. Tầng Data (Infrastructure & Network Resilience)

Tầng Data chịu trách nhiệm tương tác với backend ABP Framework qua REST API, phòng thủ kiểu dữ liệu và chuyển đổi sang Entity.

### 2.1. Kỹ Thuật Phòng Thủ Dữ Liệu DTO (Defensive Parsing)
Backend có thể trả về `null`, sai kiểu dữ liệu nguyên thủy (số dưới dạng chuỗi, cờ boolean dưới dạng số). 100% DTO tại `lib/data/dto/` bắt buộc phải sử dụng các helper an toàn:

```dart
// Helper phòng thủ chuẩn trong DTO
int _parseInt(dynamic value, {int defaultValue = 0}) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? defaultValue;
  if (value is num) return value.toInt();
  return defaultValue;
}

double _parseDouble(dynamic value, {double defaultValue = 0.0}) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? defaultValue;
  return defaultValue;
}

bool _parseBool(dynamic value, {bool defaultValue = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final lower = value.toLowerCase().trim();
    if (lower == 'true' || lower == '1') return true;
    if (lower == 'false' || lower == '0') return false;
  }
  return defaultValue;
}

String _parseString(dynamic value, {String defaultValue = ''}) {
  if (value == null) return defaultValue;
  return value.toString();
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}
```

- **Cấm kỵ:** Cấm ép kiểu thô `json['field'] as int`, `json['field'] as String` hoặc `DateTime.parse(json['date'])` gây crash `TypeError` khi runtime.
- **Danh sách an toàn:** Với các trường danh sách: `(json['items'] as List?)?.map(...).toList() ?? []`.

### 2.2. BaseRemoteDatasource & ABP Wrapper Unpacking
Toàn bộ phản hồi backend được bọc trong ABP Framework wrapper:
```json
{
  "result": { ... },
  "items": [ ... ],
  "totalCount": 100,
  "error": null
}
```

- 100% implementation của Remote Datasource tại `lib/data/datasource/remote/implement/` bắt buộc kế thừa `BaseRemoteDatasource`.
- Bắt buộc dùng `handleResponse(response)` hoặc `handleListResponse(response)`. Cấm unwrap thủ công `res.data['result']`.
- Mọi network call phải được bọc trong `try-catch` và ném `handleError(e)` để ánh xạ chính xác thành `AppException`.

### 2.3. Mapper Chuyên Biệt (lib/data/mapper/)
- Dữ liệu giữa DTO và Entity bắt buộc biến đổi qua Mapper chuyên biệt.
- Cung cấp phương thức tĩnh `toEntity(dto)` và `toDto(entity)`.
- Không nhét logic nghiệp vụ vào Mapper.

---

## 3. Contextual Multi-Club Dynamic RBAC & Active Context

Ứng dụng hoạt động theo hệ sinh thái đa CLB (1 User $\rightarrow$ N Clubs $\rightarrow$ N Roles).

### Invariants:
1. **Chuyển Đổi Ngữ Cảnh Tường Minh:**
   - Mọi hoạt động quản trị hoặc vận hành CLB phải thực hiện trong một ngữ cảnh hoạt động xác định (`ActiveClubContext`).
   - Chuyển đổi ngữ cảnh qua `SwitchClubContextUseCase` gọi API `/api/v1/auth/switch-context/{clubId}`.
2. **Kiểm Tra Quyền Động (Dynamic Permission Checking):**
   - Kiểm tra quyền hạn dựa trên danh sách quyền được cấp trong `activeContext.permissions` hoặc thông qua enum `ClubRolePermission`.
   - **CẤM HARDCODE TÊN ROLE DẠNG CHUỖI:** Tuyệt đối không kiểm tra kiểu `user.role == "ADMIN"` hay `user.role == "HOST"`.
   ```dart
   // ✅ ĐÚNG: Kiểm tra quyền động từ Active Context
   if (activeContext.hasPermission(ClubRolePermission.sessionCreate)) { ... }

   // ❌ SAI: Hardcode chuỗi role
   if (user.role == 'ADMIN') { ... }
   ```
3. **Độc Lập Ngữ Cảnh:** Dữ liệu cache hoặc state của CLB A tuyệt đối không được hiển thị nhầm sang CLB B sau khi chuyển ngữ cảnh.
