# 📘 Tài Liệu Kỹ Thuật API - LegendsTeamVN BadmintonClub

Tài liệu chi tiết về tất cả các API đang hoạt động trên hệ thống Backend (`/api/v1`), bao gồm phương thức HTTP, endpoint, quyền truy cập (Permissions), tham số truyền vào và cấu trúc Response trả về.

---

## 📌 1. Cấu Trúc Response Chung (Standard Response Conventions)

Hệ thống sử dụng **Result Pattern** và **Custom ProblemDetails Standard**:

### 🟢 1.1. Thành công (Success Response)
* **Status 200 OK**: Trả về Object JSON hoặc `PagedResult<T>` khi truy vấn dữ liệu.
* **Status 201 Created**: Trả về khi tạo mới thành công tài nguyên (Response chứa ID hoặc thông điệp).
* **Status 204 No Content**: Trả về khi cập nhật (PUT) hoặc xóa (DELETE) thành công.

### 🔴 1.2. Thất bại / Lỗi (Error Response Structure)
Khi có lỗi xảy ra (Validation, Unauthorized, NotFound, Server Error), API trả về định dạng chuẩn:

```json
{
  "type": "https://tools.ietf.org/html/rfc7231#section-6.5.4",
  "title": "Resource Not Found",
  "status": 404,
  "detail": "A user with specified Id was not found.",
  "errors": [
    {
      "code": "User.NotFound",
      "description": "User with specified Id was not found."
    }
  ]
}
```

### 📄 1.3. Cấu trúc Phân trang (`PagedResult<T>`)
Tất cả các API lấy danh sách (`GET`) hỗ trợ phân trang sẽ trả về cấu trúc sau:

```json
{
  "items": [ ... ],
  "totalCount": 100,
  "pageNumber": 1,
  "pageSize": 10,
  "totalPages": 10,
  "hasPreviousPage": false,
  "hasNextPage": true
}
```

---

## 🔐 2. Phân Hệ Xác Thực & Tài Khoản (`/api/v1/auth`)

### 2.1. Đăng ký tài khoản (`POST /api/v1/auth/register`)
* **Mô tả**: Tạo tài khoản người dùng mới.
* **Xác thực**: Không yêu cầu (`Public`).
* **Request Body**:
  ```json
  {
    "email": "user@example.com",
    "password": "Password123@",
    "confirmPassword": "Password123@"
  }
  ```
* **Response Status**: `200 OK`
* **Response Body**:
  ```json
  {
    "userId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "message": "User created successfully."
  }
  ```

---

### 2.2. Đăng nhập (`POST /api/v1/auth/login`)
* **Mô tả**: Đăng nhập vào hệ thống, trả về JWT Access Token và thiết lập Refresh Token trong HTTP-Only Cookie.
* **Xác thực**: Không yêu cầu (`Public`).
* **Request Body**:
  ```json
  {
    "email": "admin", 
    "password": "admin"
  }
  ```
  *(Lưu ý: Trường `email` có thể nhận Email hoặc Username, ví dụ `admin` / `admin`).*
* **Response Status**: `200 OK`
* **Response Body**:
  ```json
  {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
  ```
* **Header Response**: Gửi kèm Cookie `refreshToken` (HttpOnly, Secure, SameSite=Strict).

---

### 2.3. Làm mới Access Token (`POST /api/v1/auth/refresh`)
* **Mô tả**: Sử dụng Refresh Token từ Cookie để cấp lại Access Token mới.
* **Xác thực**: Gửi kèm `Authorization: Bearer <accessToken_cũ>` và Cookie `refreshToken`.
* **Response Status**: `200 OK`
* **Response Body**:
  ```json
  {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
  ```

---

### 2.4. Đăng xuất (`POST /api/v1/auth/logout`)
* **Mô tả**: Đăng xuất khỏi hệ thống, hủy phiên làm việc và xóa Cookie Refresh Token.
* **Xác thực**: Yêu cầu Bearer Token (`RequireAuthorization`).
* **Response Status**: `200 OK`
* **Response Body**:
  ```json
  {
    "message": "Logged out successfully."
  }
  ```

---

## 👥 3. Phân Hệ Quản Lý Người Dùng (`/api/v1/user`)

### 3.1. Lấy thông tin cá nhân (`GET /api/v1/user/me`)
* **Mô tả**: Trả về thông tin chi tiết và danh sách quyền của người dùng đang đăng nhập.
* **Xác thực**: Bearer Token (`RequireAuthorization`).
* **Response Status**: `200 OK`
* **Response Body**:
  ```json
  {
    "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "email": "admin@admin.com",
    "userName": "admin",
    "phoneNumber": null,
    "isLocked": false,
    "lockoutEnd": null,
    "roles": ["Admin"],
    "permissions": ["System.Administrator", "Venues.Read", "Venues.Create"]
  }
  ```

---

### 3.2. Lấy danh sách người dùng (`GET /api/v1/user`)
* **Mô tả**: Truy vấn danh sách người dùng toàn hệ thống có phân trang và lọc.
* **Xác thực**: Quyền `System.Administrator`.
* **Query Parameters**:
  * `pageNumber` (int, default: 1)
  * `pageSize` (int, default: 10)
  * `searchTerm` (string, optional - tìm theo Email/Username)
* **Response Status**: `200 OK`
* **Response Body**: Trả về `PagedResult<UserResponse>`
  ```json
  {
    "items": [
      {
        "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
        "email": "admin@admin.com",
        "userName": "admin",
        "phoneNumber": null,
        "isLocked": false,
        "lockoutEnd": null,
        "roles": ["Admin"],
        "permissions": ["System.Administrator"]
      }
    ],
    "totalCount": 1,
    "pageNumber": 1,
    "pageSize": 10,
    "totalPages": 1,
    "hasPreviousPage": false,
    "hasNextPage": false
  }
  ```

---

### 3.3. Lấy thông tin người dùng theo ID (`GET /api/v1/user/{id}`)
* **Mô tả**: Lấy chi tiết thông tin 1 người dùng theo ID.
* **Xác thực**: Quyền `System.Administrator`.
* **Path Parameter**: `id` (Guid).
* **Response Status**: `200 OK` / `404 Not Found`.
* **Response Body**:
  ```json
  {
    "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "email": "user@gmail.com",
    "userName": "user123",
    "phoneNumber": "0987654321",
    "isLocked": false,
    "lockoutEnd": null,
    "roles": ["User"],
    "permissions": ["Courts.Read"]
  }
  ```

---

### 3.4. Khóa / Mở khóa tài khoản (`PUT /api/v1/user/{id}/lock`)
* **Mô tả**: Thay đổi trạng thái khóa/mở khóa tài khoản người dùng.
* **Xác thực**: Quyền `System.Administrator`.
* **Path Parameter**: `id` (Guid).
* **Request Body**:
  ```json
  {
    "isLocked": true,
    "lockoutEnd": "2026-12-31T23:59:59Z"
  }
  ```
  *(Nếu `isLocked = false`, tài khoản sẽ được mở khóa ngay lập tức).*
* **Response Status**: `200 OK`
* **Response Body**:
  ```json
  {
    "message": "User locked successfully."
  }
  ```

---

### 3.5. Cập nhật Role người dùng (`PUT /api/v1/user/{id}/roles`)
* **Mô tả**: Cập nhật danh sách Vai trò (Roles) gán cho người dùng.
* **Xác thực**: Quyền `System.Administrator`.
* **Path Parameter**: `id` (Guid).
* **Request Body**:
  ```json
  {
    "roles": ["Admin", "Manager"]
  }
  ```
* **Response Status**: `200 OK`
* **Response Body**:
  ```json
  {
    "message": "User roles updated successfully."
  }
  ```

---

## 🏢 4. Phân Hệ Quản Lý Cơ Sở / Sân Bóng (`/api/v1/venues`)

### 4.1. Lấy danh sách cơ sở (`GET /api/v1/venues`)
* **Mô tả**: Lấy danh sách các cơ sở cầu lông (Venues) có phân trang & bộ lọc.
* **Xác thực**: Quyền `Venues.Read`.
* **Query Parameters**: `pageNumber`, `pageSize`, `searchTerm` (tìm tên/địa chỉ), `isActive` (bool?).
* **Response Status**: `200 OK`
* **Response Body**: Trả về `PagedResult<VenueResponse>`
  ```json
  {
    "items": [
      {
        "id": "e5b88237-7729-455b-8012-9c123456789a",
        "name": "Sân cầu lông Legends Bình Thạnh",
        "description": "Sân chuẩn quốc tế, có thảm thảm Yonex",
        "address": "123 Điện Biên Phủ, P.25, Bình Thạnh, TP.HCM",
        "latitude": 10.8012,
        "longitude": 106.7112,
        "openTime": "06:00:00",
        "closeTime": "22:00:00",
        "isActive": true
      }
    ],
    "totalCount": 1,
    "pageNumber": 1,
    "pageSize": 10
  }
  ```

---

### 4.2. Lấy chi tiết cơ sở theo ID (`GET /api/v1/venues/{id}`)
* **Mô tả**: Lấy thông tin chi tiết của 1 cơ sở theo ID.
* **Xác thực**: Quyền `Venues.Read`.
* **Path Parameter**: `id` (Guid).
* **Response Status**: `200 OK` / `404 Not Found`.

---

### 4.3. Tạo cơ sở mới (`POST /api/v1/venues`)
* **Mô tả**: Thêm mới một cơ sở cầu lông.
* **Xác thực**: Quyền `Venues.Create`.
* **Request Body**:
  ```json
  {
    "name": "Sân Cầu Lông Legends Q7",
    "description": "Hệ thống 10 sân thảm Yonex cao cấp",
    "address": "456 Nguyễn Thị Thập, Q.7, TP.HCM",
    "latitude": 10.7411,
    "longitude": 106.7022,
    "openTime": "05:00:00",
    "closeTime": "23:00:00"
  }
  ```
* **Response Status**: `201 Created`
* **Response Body**: Trả về `Guid` đại diện cho `id` cơ sở mới tạo.

---

### 4.4. Cập nhật cơ sở (`PUT /api/v1/venues/{id}`)
* **Mô tả**: Cập nhật thông tin chi tiết của cơ sở.
* **Xác thực**: Quyền `Venues.Update`.
* **Path Parameter**: `id` (Guid).
* **Request Body**: Tương tự như `POST /api/v1/venues`.
* **Response Status**: `204 No Content`.

---

### 4.5. Xóa cơ sở (`DELETE /api/v1/venues/{id}`)
* **Mô tả**: Xóa (Soft Delete) một cơ sở khỏi hệ thống.
* **Xác thực**: Quyền `Venues.Delete`.
* **Path Parameter**: `id` (Guid).
* **Response Status**: `204 No Content`.

---

## 📅 5. Phân Hệ Khung Giờ Hoạt Động Cơ Sở (`/api/v1/venue-schedules`)

### 5.1. Lấy danh sách khung giờ (`GET /api/v1/venue-schedules`)
* **Mô tả**: Lấy danh sách lịch mở cửa theo các ngày trong tuần của cơ sở.
* **Xác thực**: Quyền `VenueSchedules.Read`.
* **Query Parameters**: `venueId` (Guid?), `pageNumber`, `pageSize`.
* **Response Status**: `200 OK`

---

### 5.2. Tạo khung giờ hoạt động (`POST /api/v1/venue-schedules`)
* **Mô tả**: Cấu hình giờ mở/đóng cửa hoặc báo nghỉ theo ngày trong tuần (`DayOfWeek`: 0=Sunday, 1=Monday,...).
* **Xác thực**: Quyền `VenueSchedules.Create`.
* **Request Body**:
  ```json
  {
    "venueId": "e5b88237-7729-455b-8012-9c123456789a",
    "dayOfWeek": 1,
    "openTime": "06:00:00",
    "closeTime": "22:00:00",
    "isClosed": false
  }
  ```
* **Response Status**: `201 Created`

---

### 5.3. Cập nhật khung giờ (`PUT /api/v1/venue-schedules/{id}`)
* **Xác thực**: Quyền `VenueSchedules.Update`.
* **Request Body**:
  ```json
  {
    "openTime": "07:00:00",
    "closeTime": "23:00:00",
    "isClosed": false
  }
  ```
* **Response Status**: `204 No Content`

---

### 5.4. Xóa khung giờ (`DELETE /api/v1/venue-schedules/{id}`)
* **Xác thực**: Quyền `VenueSchedules.Delete`.
* **Response Status**: `204 No Content`

---

## 🏸 6. Phân Hệ Quản Lý Sân Cầu Lông (`/api/v1/courts`)

### 6.1. Lấy danh sách sân (`GET /api/v1/courts`)
* **Mô tả**: Lấy danh sách sân cầu lông có phân trang và lọc.
* **Xác thực**: Quyền `Courts.Read`.
* **Query Parameters**: `venueId` (Guid?), `isAvailable` (bool?), `pageNumber`, `pageSize`.
* **Response Status**: `200 OK`
* **Response Body**: Trả về `PagedResult<CourtResponse>`
  ```json
  {
    "items": [
      {
        "id": "7a9f1122-3344-5566-7788-99aabbccdd11",
        "name": "Sân số 1 (Thảm VIP)",
        "description": "Sân chuẩn thi đấu",
        "pricePerHour": 100000,
        "isAvailable": true
      }
    ],
    "totalCount": 1
  }
  ```

---

### 6.2. Tạo sân mới (`POST /api/v1/courts`)
* **Mô tả**: Tạo mới sân trong cơ sở.
* **Xác thực**: Quyền `Courts.Create`.
* **Request Body**:
  ```json
  {
    "name": "Sân số 2",
    "description": "Sân thảm tiêu chuẩn",
    "pricePerHour": 90000
  }
  ```
* **Response Status**: `201 Created`

---

### 6.3. Cập nhật sân (`PUT /api/v1/courts/{id}`)
* **Xác thực**: Quyền `Courts.Update`.
* **Request Body**:
  ```json
  {
    "name": "Sân số 2 - Đã nâng cấp",
    "description": "Nâng cấp thảm mới",
    "pricePerHour": 110000,
    "isAvailable": true
  }
  ```
* **Response Status**: `204 No Content`

---

### 6.4. Xóa sân (`DELETE /api/v1/courts/{id}`)
* **Xác thực**: Quyền `Courts.Delete`.
* **Response Status**: `204 No Content`

---

## 💰 7. Phân Hệ Bảng Giá Sân Theo Giờ / Cao Điểm (`/api/v1/court-pricings`)

### 7.1. Lấy danh sách bảng giá (`GET /api/v1/court-pricings`)
* **Mô tả**: Lấy danh sách các quy tắc giá theo khung giờ (ví dụ: Giờ vàng, Giờ cao điểm, Cuối tuần).
* **Xác thực**: Quyền `CourtPricings.Read`.
* **Query Parameters**: `venueId` (Guid?), `pageNumber`, `pageSize`.
* **Response Status**: `200 OK`

---

### 7.2. Tạo quy tắc giá mới (`POST /api/v1/court-pricings`)
* **Mô tả**: Tạo giá theo khung giờ cụ thể trong ngày.
* **Xác thực**: Quyền `CourtPricings.Create`.
* **Request Body**:
  ```json
  {
    "venueId": "e5b88237-7729-455b-8012-9c123456789a",
    "startTime": "17:00:00",
    "endTime": "21:00:00",
    "pricePerHour": 150000,
    "dayOfWeek": 6,
    "isPeakHour": true
  }
  ```
* **Response Status**: `201 Created`

---

### 7.3. Cập nhật quy tắc giá (`PUT /api/v1/court-pricings/{id}`)
* **Xác thực**: Quyền `CourtPricings.Update`.
* **Request Body**:
  ```json
  {
    "startTime": "18:00:00",
    "endTime": "22:00:00",
    "pricePerHour": 160000,
    "dayOfWeek": 6,
    "isPeakHour": true
  }
  ```
* **Response Status**: `204 No Content`

---

### 7.4. Xóa quy tắc giá (`DELETE /api/v1/court-pricings/{id}`)
* **Xác thực**: Quyền `CourtPricings.Delete`.
* **Response Status**: `204 No Content`
