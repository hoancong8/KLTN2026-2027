---
trigger: model_decision
description: "Đối chiếu và bám sát tài liệu đặc tả API Clean Architecture (docs_api_clean_arch.md), ARCHITECTURE_RULES.md và phân hệ chức năng KLTN2026-2027."
---

# Quy Tắc Bám Sát Đặc Tả Hệ Thống & Ánh Xạ API (System Spec & API Alignment)

> [!IMPORTANT]
> Toàn bộ quá trình thêm mới màn hình, gọi API hoặc xử lý dữ liệu phải được đối chiếu trực tiếp với **Nguồn Chân Lý Độc Nhất (Single Source of Truth - SSOT)** tại `docs_api_clean_arch.md` và `ARCHITECTURE_RULES.md`.

---

## 1. Nguồn Chân Lý Độc Nhất (SSOT)

Trước khi thực hiện bất kỳ thay đổi nào liên quan đến API hoặc Use Case, bắt buộc phải tra cứu:
1. **Bảng Ánh Xạ API 2 Tầng (`docs_api_clean_arch.md`)**:
   - Xác định rõ: API Path -> DTO -> Entity -> Mapper -> Remote Datasource -> Repository -> UseCase -> Provider.
2. **Quy Tắc Kiến Trúc & Phát Triển (`ARCHITECTURE_RULES.md`)**:
   - Quy trình 5 bước phát triển chức năng chuẩn.
3. **Đặc Tả Chi Tiết API (`docs_api.md`)**:
   - Schema JSON chi tiết của backend ABP Framework.

---

## 2. Danh Mục Các Phân Hệ Chức Năng Chính

| Phân Hệ | Endpoint Prefix | Entity Cốt Lõi | Tài Liệu Tham Khảo |
| :--- | :--- | :--- | :--- |
| **F1. Xác thực & Tài khoản** | `/api/v1/auth` | `AuthToken`, `UserProfile`, `PlayerProfile` | `docs_api_clean_arch.md#1` |
| **F2. Quản lý Quyền & Vai trò** | `/api/v1/roles` | `AppRole`, `PermissionGroup`, `UserPermissions` | `docs_api_clean_arch.md#2` |
| **F3. Câu lạc bộ & Thành viên** | `/api/v1/clubs` | `Club`, `ClubDetail`, `ClubMember`, `ClubRoleItem` | `docs_api_clean_arch.md#3` |
| **F4. Buổi chơi & Điểm danh** | `/api/v1/sessions` | `Session`, `SessionBooking`, `GuestRecruitment` | `docs_api_clean_arch.md#4` |
| **F5. Cụm sân & Đặt chỗ** | `/api/v1/venues`, `/bookings` | `Venue`, `Court`, `CourtPricing`, `VenueSchedule` | `docs_api_clean_arch.md#5` |
| **F6. Hồ sơ cá nhân & Thể lực** | `/api/v1/users/me` | `UserProfile`, `PlayerProfile` | `docs_api_clean_arch.md#6` |

---

## 3. Quy Trình Truy Vết & Kiểm Soát Tính Nhất Quán (Traceability Checklist)

Khi triển khai hoặc chỉnh sửa bất kỳ luồng chức năng nào, AI Agent phải kiểm tra tính toàn vẹn qua bảng kiểm tra:

1. [ ] **Endpoint & DTO:** Có đúng HTTP Method và URL trong `AppConfig` không? Có DTO Request/Response tương ứng trong `lib/data/dto/` không?
2. [ ] **Defensive Parsing:** Các trường số (`int`, `double`), cờ `bool`, chuỗi `String` và `DateTime` trong DTO có helper parser an toàn không?
3. [ ] **Mapper:** Đã có hàm `toEntity()` và `toDto()` trong `lib/data/mapper/` chưa?
4. [ ] **Pure Domain:** Entity và Repository Interface trong `lib/domain/` có hoàn toàn độc lập với Flutter UI và Dio không?
5. [ ] **DI Registration:** Đã đăng ký đầy đủ Datasource, Repository, UseCase vào `lib/app/provider.dart` chưa?
6. [ ] **ViewModel & Screen:** ViewModel có kế thừa `StateNotifier` không? Màn hình có bọc qua `ResponsiveLayout` không?
7. [ ] **Đa ngôn ngữ & Lỗi:** Các chuỗi thông báo và mã lỗi có nằm trong `.arb` không?
