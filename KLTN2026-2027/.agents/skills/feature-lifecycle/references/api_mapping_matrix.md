# Ma Trận Ánh Xạ API 2 Tầng Cốt Lõi (API Mapping Matrix)

Bảng tổng hợp nhanh các phân hệ nghiệp vụ chính từ `docs_api_clean_arch.md`:

| Phân Hệ | Subsystem Code | API Base Path | Thư Mục Domain | Thư Mục Data | Thư Mục UI |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Xác thực & Bảo mật** | `auth` | `/api/v1/auth` | `domain/entities/auth/` | `data/dto/auth/` | `ui/screen/login/` |
| **Phân quyền vai trò** | `roles` | `/api/v1/roles` | `domain/entities/app_role.dart` | `data/dto/role/` | `ui/screen/admin/` |
| **Câu lạc bộ** | `clubs` | `/api/v1/clubs` | `domain/entities/club/` | `data/dto/club/` | `ui/screen/club/` |
| **Buổi chơi & Tuyển quân**| `sessions` | `/api/v1/sessions`| `domain/entities/session/` | `data/dto/session/`| `ui/screen/home/tab/`|
| **Cụm sân & Giá vé** | `venues` | `/api/v1/venues` | `domain/entities/venue.dart` | `data/dto/venue/` | `ui/screen/my_bookings/`|
| **Hồ sơ cá nhân** | `users` | `/api/v1/users/me` | `domain/entities/user_profile.dart`| `data/dto/user/` | `ui/screen/profile/` |
