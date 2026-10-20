---
trigger: glob
globs: "lib/data/**, lib/app/**"
description: "Chuẩn giao thức API ABP Framework, kỹ thuật Parser phòng thủ (Defensive Parsing) trong DTO, kế thừa BaseRemoteDatasource và xử lý lỗi mạng kiên cố."
---

# Giao Thức API ABP Framework & Kỹ Thuật Lập Trình Kiên Cố (Resilience)

> [!IMPORTANT]
> Backend của hệ thống xây dựng trên **ABP Framework**, trả về cấu trúc đóng gói JSON đặc thù. Client Flutter phải xử lý kiên cố (Defensive Programming), bảo vệ ứng dụng không bao giờ bị crash do sai lệch kiểu dữ liệu hoặc null bất ngờ từ backend.

---

## 1. Cấu Trúc Phản Hồi Chuẩn Của Backend ABP Framework

Backend luôn bọc phản hồi trong định dạng:

### 1.1 Phản hồi đối tượng đơn lẻ (Single Object):
```json
{
  "result": {
    "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "clubName": "CLB Cầu Lông Ba Đình",
    "isActive": true
  },
  "targetUrl": null,
  "success": true,
  "error": null,
  "unAuthorizedRequest": false,
  "__abp": true
}
```

### 1.2 Phản hồi danh sách phân trang (Paged Result):
```json
{
  "result": {
    "totalCount": 42,
    "items": [
      { "id": "uuid-1", "name": "Sân 1" },
      { "id": "uuid-2", "name": "Sân 2" }
    ]
  },
  "success": true
}
```

---

## 2. Kỹ Thuật Parser Phòng Thủ Trong DTO (Defensive Parsing)

Mọi file DTO trong `lib/data/dto/` **bắt buộc** phải triển khai các helper parser an toàn kiểu dữ liệu để tránh `TypeError: type 'Null' is not a subtype of type 'String'` hoặc `type 'String' is not a subtype of type 'int'`:

```dart
class ClubResponseDto {
  final String id;
  final String name;
  final int memberCount;
  final double rating;
  final bool isActive;
  final DateTime? createdAt;

  const ClubResponseDto({
    required this.id,
    required this.name,
    required this.memberCount,
    required this.rating,
    required this.isActive,
    this.createdAt,
  });

  factory ClubResponseDto.fromJson(Map<String, dynamic> json) {
    return ClubResponseDto(
      id: _parseString(json['id']),
      name: _parseString(json['name']),
      memberCount: _parseInt(json['memberCount']),
      rating: _parseDouble(json['rating']),
      isActive: _parseBool(json['isActive']),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }

  static String _parseString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is int) return value == 1;
    return false;
  }
}
```

---

## 3. Quy Tắc Viết Remote Datasource

1. **Bắt buộc kế thừa `BaseRemoteDatasource`:**
   Tất cả lớp Datasource Implementation tại `lib/data/datasource/remote/implement/` phải kế thừa `BaseRemoteDatasource`.
2. **Sử dụng phương thức chuẩn:**
   - Đối tượng đơn lẻ: `handleResponse(res, (json) => Dto.fromJson(json))`
   - Danh sách phân trang: `handleListResponse(res, (json) => Dto.fromJson(json))`
3. **Bọc toàn bộ trong `try-catch`:**
   ```dart
   @override
   Future<ClubDetailResponseDto> getClubDetail(String id) async {
     try {
       final res = await dio.get('${AppConfig.clubs}/$id');
       return handleResponse(res, (json) => ClubDetailResponseDto.fromJson(json));
     } catch (e) {
       throw handleError(e);
     }
   }
   ```
4. **Không khởi tạo Dio nội bộ:**
   Dio phải được inject thông qua constructor từ Riverpod DI Container (`ref.watch(dioProvider)`).

---

## 4. Quản Lý Phiên & Bảo Mật Token

1. **Lưu trữ nhạy cảm:**
   `accessToken` và `refreshToken` bắt buộc phải lưu trong `FlutterSecureStorage` (thông qua `AuthRepository` / `TokenStorageService`). Tuyệt đối không lưu token thô vào `SharedPreferences` dạng plaintext.
2. **Tự động làm mới Token (Refresh Token Interceptor):**
   Khi nhận mã lỗi `401 Unauthorized`, interceptor của Dio tự động gọi `/api/v1/auth/refresh` bằng refresh token đã lưu. Nếu làm mới thất bại, xóa token và điều hướng về màn hình Login thông qua GoRouter.
3. **Xác thực sinh trắc học:**
   Sử dụng `local_auth` để xác thực vân tay/khuôn mặt trước khi mở khóa phiên truy cập nhanh hoặc xác nhận thanh toán/đổi mật khẩu.
