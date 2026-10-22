---
trigger: model_decision
description: "Đối chiếu và bám sát tài liệu đặc tả SSOT (docs/01..07, docs_api_clean_arch.md, docs_api.md, ARCHITECTURE_RULES.md) và phân hệ chức năng KLTN2026-2027."
---

# Quy Tắc Bám Sát Đặc Tả Hệ Thống & Ánh Xạ API (System Spec Reference)

Tài liệu hướng dẫn tra cứu và đối chiếu các tài liệu **Nguồn Chân Lý Độc Nhất (Single Source of Truth - SSOT)** trước khi lập kế hoạch, thiết kế blueprint, hoặc viết code.

---

## 1. Nguồn Chân Lý Độc Nhất (SSOT)

Mọi yêu cầu chức năng, màn hình, API integration bắt buộc phải tra cứu từ 4 nguồn tài liệu chính thức:

1. **Tài Liệu Đặc Tả Yêu Cầu & Thiết Kế Hệ Thống (`docs/`):**
   - [`docs/01_TONG_QUAN_DE_TAI.md`](docs/01_TONG_QUAN_DE_TAI.md) đến [`docs/06_KIEN_TRUC_HE_THONG_TONG_THE.md`](docs/06_KIEN_TRUC_HE_THONG_TONG_THE.md): Nghiệp vụ quản lý CLB cầu lông, giải đấu, đặt sân, tìm bạn chơi.
   - [`docs/07_THIET_KE_CLIENT_FLUTTER_MOBILE.md`](docs/07_THIET_KE_CLIENT_FLUTTER_MOBILE.md): Thiết kế màn hình, wireframe, danh sách ca sử dụng UC01-UC20 và 23 yêu cầu chức năng FR01-FR23 trên mobile.
2. **Quy Tắc Kiến Trúc & Phát Triển Chuẩn:**
   - [`ARCHITECTURE_RULES.md`](ARCHITECTURE_RULES.md): Quy chuẩn 3 tầng Clean Architecture, luồng 5 bước phát triển, cấu trúc DTO/Entity/Mapper/UseCase/Provider/ViewModel.
3. **Bảng Ánh Xạ API Sang Clean Architecture:**
   - [`docs_api_clean_arch.md`](docs_api_clean_arch.md): Ma trận phân tầng từ API Endpoint $\rightarrow$ DTO $\rightarrow$ Entity $\rightarrow$ Mapper $\rightarrow$ Datasource $\rightarrow$ Repository $\rightarrow$ UseCase $\rightarrow$ Riverpod Provider.
4. **Đặc Tả Chi Tiết API Backend ABP Framework:**
   - [`docs_api.md`](docs_api.md): Schema JSON chi tiết của backend ABP Framework (`result`, `items`, `totalCount`, `error`).

---

## 2. Danh Mục Các Phân Hệ Chức Năng Chính

| Phân Hệ | Endpoint Prefix | Entity Cốt Lõi | Tài Liệu Tham Khảo |
|---|---|---|---|
| **F1. Xác thực & Tài khoản** | `/api/v1/auth` | `AuthToken`, `UserProfile`, `PlayerProfile` | `docs_api_clean_arch.md#1` |
| **F2. Quản lý Quyền & Vai trò** | `/api/v1/roles` | `AppRole`, `PermissionGroup`, `UserPermissions` | `docs_api_clean_arch.md#2` |
| **F3. Câu lạc bộ & Thành viên** | `/api/v1/clubs` | `Club`, `ClubDetail`, `ClubMember`, `ClubRoleItem` | `docs_api_clean_arch.md#3` |
| **F4. Buổi chơi & Điểm danh** | `/api/v1/sessions` | `Session`, `SessionBooking`, `GuestRecruitment` | `docs_api_clean_arch.md#4` |
| **F5. Cụm sân & Đặt chỗ** | `/api/v1/venues`, `/bookings` | `Venue`, `Court`, `CourtPricing`, `VenueSchedule` | `docs_api_clean_arch.md#5` |
| **F6. Hồ sơ cá nhân & Thể lực** | `/api/v1/users/me` | `UserProfile`, `PlayerProfile` | `docs_api_clean_arch.md#6` |

---

## 3. Bảng Kiểm Tra Truy Vết (Traceability Checklist)

Trước khi nghiệm thu bất kỳ tính năng nào, đối chiếu:
1. [ ] **Endpoint & DTO:** Có đúng HTTP Method và URL trong `AppConfig` không? Có DTO Request/Response tương ứng trong `lib/data/dto/` không?
2. [ ] **Defensive Parsing:** Các trường số (`int`, `double`), cờ `bool`, chuỗi `String` và `DateTime` trong DTO có helper parser an toàn không?
3. [ ] **Mapper:** Đã có hàm `toEntity()` và `toDto()` trong `lib/data/mapper/` chưa?
4. [ ] **Pure Domain:** Entity và Repository Interface trong `lib/domain/` có 100% độc lập với Flutter UI và Dio không?
5. [ ] **DI Registration:** Đã đăng ký đầy đủ Datasource, Repository, UseCase vào `lib/app/provider.dart` chưa?
6. [ ] **ViewModel & Screen:** ViewModel có kế thừa `StateNotifier` không? Màn hình có bọc qua `ResponsiveLayout` không?
7. [ ] **Đa ngôn ngữ & Lỗi:** Các chuỗi thông báo và mã lỗi có nằm trong file `.arb` không?
