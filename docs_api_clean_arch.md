# Tài Liệu Bảng Ánh Xạ API 2 Tầng Domain & Data (Clean Architecture)

Tài liệu này tổng hợp toàn bộ các API Endpoints trong hệ thống **Badminton Club**, mô tả chi tiết luồng dữ liệu từ **Data Layer** (DTO, Datasource, Mapper) đến **Domain Layer** (Entity, Repository, UseCase) và **Dependency Injection (Riverpod Providers)**.

---

## 📌 Tổng Quan Cấu Trúc Luồng Dữ Liệu (Clean Architecture Flow)

```
[ UI Layer ] 
    │
    ▼
[ UseCase ] (lib/domain/usecases/)
    │
    ▼
[ Repository Interface ] (lib/domain/repositories/)
    │
    ▼
[ Repository Implementation ] (lib/data/repositories/)
    │
    ├──> [ Mapper ] (lib/data/mapper/) <── (Chuyển đổi DTO <-> Entity)
    │
    ▼
[ Remote Datasource ] (lib/data/datasource/remote/)
    │
    ▼
[ ABP Framework Backend API ]
```

---

## 1. Phân Hệ Xác Thực (`/api/v1/auth`)

| API Endpoint | Mô tả | DTO (Data Layer) | Entity (Domain Layer) | Mapper | Remote Datasource | Repository | UseCase & Provider |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `POST /api/v1/auth/register` | Đăng ký tài khoản | `RegisterRequestDto` | N/A | Direct | `AuthRemoteDatasource.register()` | `AuthRepository.register()` | `RegisterUseCase` (`registerUseCaseProvider`) |
| `POST /api/v1/auth/login` | Đăng nhập hệ thống | `LoginRequestDto`<br>`LoginResponseDto` | `TokenEntity` | Direct | `AuthRemoteDatasource.login()` | `AuthRepository.login()` | `LoginUseCase` (`loginUseCaseProvider`) |
| `POST /api/v1/auth/refresh` | Làm mới Token | `LoginResponseDto` | `TokenEntity` | Direct | `AuthRemoteDatasource.refreshToken()` | `AuthRepository.refreshToken()` | `RefreshTokenUseCase` (`refreshTokenUseCaseProvider`) |
| `POST /api/v1/auth/logout` | Đăng xuất | N/A | N/A | N/A | `AuthRemoteDatasource.logout()` | `AuthRepository.logout()` | `LogoutUseCase` (`logoutUseCaseProvider`) |
| `POST /api/services/app/Profile/ChangePassword` | Đổi mật khẩu | `ChangePasswordRequestDto` | N/A | Direct | `AuthRemoteDatasource.changePassword()` | `AuthRepository.changePassword()` | `ChangePasswordUseCase` (`changePasswordUseCaseProvider`) |

---

## 2. Phân Hệ Quản Lý Vai Trò / Nhóm Người Dùng (`/api/v1/roles`)

| API Endpoint | Mô tả & Quyền | DTO (Data Layer) | Entity (Domain Layer) | Mapper | Remote Datasource | Repository | UseCase & Provider |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `GET /api/v1/roles` | Danh sách vai trò & Cây quyền (`Roles.Read`) | `RoleResponseDto` | `AppRole` | `RoleMapper` | `RoleRemoteDatasource.getRoles()` | `RoleRepository.getRoles()` | `GetRolesUseCase` (`getRolesUseCaseProvider`) |
| `POST /api/v1/roles` | Tạo vai trò mới (`Roles.Create`) | `RoleCreateUpdateRequestDto` | N/A | Direct | `RoleRemoteDatasource.createRole()` | `RoleRepository.createRole()` | `ManageRoleUseCase.createRole()` (`manageRoleUseCaseProvider`) |
| `PUT /api/v1/roles/{id}` | Cập nhật vai trò (`Roles.Update`) | `RoleCreateUpdateRequestDto` | N/A | Direct | `RoleRemoteDatasource.updateRole()` | `RoleRepository.updateRole()` | `ManageRoleUseCase.updateRole()` (`manageRoleUseCaseProvider`) |
| `DELETE /api/v1/roles/{id}` | Xóa vai trò (`Roles.Delete`) | N/A | N/A | N/A | `RoleRemoteDatasource.deleteRole()` | `RoleRepository.deleteRole()` | `ManageRoleUseCase.deleteRole()` (`manageRoleUseCaseProvider`) |
| `PUT /api/v1/roles/{id}/permissions` | Gán quyền cho vai trò (`Roles.AssignPermissions`) | `AssignRolePermissionsRequestDto` | N/A | Direct | `RoleRemoteDatasource.assignRolePermissions()` | `RoleRepository.assignRolePermissions()` | `ManageRoleUseCase.assignRolePermissions()` (`manageRoleUseCaseProvider`) |

---

## 3. Phân Hệ Quản Lý Tài Khoản / Người Dùng (`/api/v1/user`)

| API Endpoint | Mô tả & Quyền | DTO (Data Layer) | Entity (Domain Layer) | Mapper | Remote Datasource | Repository | UseCase & Provider |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `GET /api/v1/user/me` | Thông tin cá nhân đang login | `UserResponseDto` | `UserProfile` | `UserMapper` | `UserRemoteDatasource.getUserMe()` | `UserRepository.getUserMe()` | `GetUserMeUseCase` (`getUserMeUseCaseProvider`) |
| `GET /api/v1/user/permissions` | Quyền & Cây phân quyền cá nhân | `UserPermissionsResponseDto` | `UserPermissions` | `UserPermissionsMapper` | `UserRemoteDatasource.getUserPermissions()` | `UserRepository.getUserPermissions()` | `GetUserPermissionsUseCase` (`getUserPermissionsUseCaseProvider`) |
| `GET /api/v1/user/all-permissions` | Toàn bộ danh mục quyền hệ thống (`Users.Read`) | `PermissionGroupResponseDto` | `PermissionGroup` | `PermissionGroupMapper` | `UserRemoteDatasource.getAllPermissions()` | `UserRepository.getAllPermissions()` | `GetAllPermissionsUseCase` (`getAllPermissionsUseCaseProvider`) |
| `GET /api/v1/user` | Danh sách tài khoản phân trang (`Users.Read`) | `PagedResultDto<UserResponseDto>` | `PagedResponse<UserProfile>` | `UserMapper` | `UserRemoteDatasource.getUsers()` | `UserRepository.getUsers()` | `GetUsersUseCase` (`getUsersUseCaseProvider`) |
| `GET /api/v1/user/{id}` | Chi tiết tài khoản theo ID (`Users.Read`) | `UserResponseDto` | `UserProfile` | `UserMapper` | `UserRemoteDatasource.getUserById()` | `UserRepository.getUserById()` | `GetUserByIdUseCase` (`getUserByIdUseCaseProvider`) |
| `POST /api/v1/user` | Tạo tài khoản mới (`Users.Create`) | `CreateUserRequestDto` | N/A | Direct | `UserRemoteDatasource.createUser()` | `UserRepository.createUser()` | `ManageUserUseCase.createUser()` (`manageUserUseCaseProvider`) |
| `PUT /api/v1/user/{id}` | Cập nhật thông tin tài khoản (`Users.Update`) | `UpdateUserRequestDto` | N/A | Direct | `UserRemoteDatasource.updateUser()` | `UserRepository.updateUser()` | `ManageUserUseCase.updateUser()` (`manageUserUseCaseProvider`) |
| `DELETE /api/v1/user/{id}` | Xóa tài khoản (`Users.Delete`) | N/A | N/A | N/A | `UserRemoteDatasource.deleteUser()` | `UserRepository.deleteUser()` | `ManageUserUseCase.deleteUser()` (`manageUserUseCaseProvider`) |
| `PUT /api/v1/user/{id}/lock` | Khóa / Mở khóa tài khoản (`Users.Lock`) | `UserLockRequestDto` | N/A | Direct | `UserRemoteDatasource.lockUser()` | `UserRepository.lockUser()` | `LockUserUseCase` (`lockUserUseCaseProvider`) |
| `PUT /api/v1/user/{id}/roles` | Gán vai trò cho tài khoản (`Users.AssignRoles`) | `UserRolesRequestDto` | N/A | Direct | `UserRemoteDatasource.updateUserRoles()` | `UserRepository.updateUserRoles()` | `UpdateUserRolesUseCase` (`updateUserRolesUseCaseProvider`) |
| `POST /api/v1/user/{id}/reset-password` | Đặt lại mật khẩu (`Users.ResetPassword`) | `ResetPasswordRequestDto` | N/A | Direct | `UserRemoteDatasource.resetPassword()` | `UserRepository.resetPassword()` | `ManageUserUseCase.resetPassword()` (`manageUserUseCaseProvider`) |

---

## 4. Phân Hệ Quản Lý Cụm Sân (`/api/v1/venues`)

| API Endpoint | Mô tả & Quyền | DTO (Data Layer) | Entity (Domain Layer) | Mapper | Remote Datasource | Repository | UseCase & Provider |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `GET /api/v1/venues` | Danh sách cụm sân phân trang (`Venues.Read`) | `PagedResultDto<VenueResponseDto>` | `PagedResponse<Venue>` | `VenueMapper` | `VenueRemoteDatasource.getVenues()` | `VenueRepository.getVenues()` | `GetVenuesUseCase` (`getVenuesUseCaseProvider`) |
| `GET /api/v1/venues/{id}` | Chi tiết cụm sân theo ID (`Venues.Read`) | `VenueResponseDto` | `Venue` | `VenueMapper` | `VenueRemoteDatasource.getVenueById()` | `VenueRepository.getVenueById()` | `GetVenueByIdUseCase` |
| `POST /api/v1/venues` | Tạo cụm sân mới (`Venues.Create`) | `VenueRequestDto` | N/A | Direct | `VenueRemoteDatasource.createVenue()` | `VenueRepository.createVenue()` | `ManageVenueUseCase.createVenue()` (`manageVenueUseCaseProvider`) |
| `PUT /api/v1/venues/{id}` | Cập nhật cụm sân (`Venues.Update`) | `VenueRequestDto` | N/A | Direct | `VenueRemoteDatasource.updateVenue()` | `VenueRepository.updateVenue()` | `ManageVenueUseCase.updateVenue()` (`manageVenueUseCaseProvider`) |
| `DELETE /api/v1/venues/{id}` | Xóa cụm sân (`Venues.Delete`) | N/A | N/A | N/A | `VenueRemoteDatasource.deleteVenue()` | `VenueRepository.deleteVenue()` | `ManageVenueUseCase.deleteVenue()` (`manageVenueUseCaseProvider`) |

---

## 5. Phân Hệ Lịch Hoạt Động Cụm Sân (`/api/v1/venue-schedules`)

| API Endpoint | Mô tả & Quyền | DTO (Data Layer) | Entity (Domain Layer) | Mapper | Remote Datasource | Repository | UseCase & Provider |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `GET /api/v1/venue-schedules` | Danh sách lịch mở cửa (`VenueSchedules.Read`) | `PagedResultDto<VenueScheduleResponseDto>` | `PagedResponse<VenueSchedule>` | `VenueScheduleMapper` | `VenueScheduleRemoteDatasource.getVenueSchedules()` | `VenueScheduleRepository.getVenueSchedules()` | `GetVenueSchedulesUseCase` (`getVenueSchedulesUseCaseProvider`) |
| `POST /api/v1/venue-schedules` | Tạo lịch mở cửa (`VenueSchedules.Create`) | `VenueScheduleCreateRequestDto` | N/A | Direct | `VenueScheduleRemoteDatasource.createVenueSchedule()` | `VenueScheduleRepository.createVenueSchedule()` | `ManageVenueScheduleUseCase.createVenueSchedule()` (`manageVenueScheduleUseCaseProvider`) |
| `PUT /api/v1/venue-schedules/{id}` | Cập nhật lịch mở cửa (`VenueSchedules.Update`) | `VenueScheduleUpdateRequestDto` | N/A | Direct | `VenueScheduleRemoteDatasource.updateVenueSchedule()` | `VenueScheduleRepository.updateVenueSchedule()` | `ManageVenueScheduleUseCase.updateVenueSchedule()` (`manageVenueScheduleUseCaseProvider`) |
| `DELETE /api/v1/venue-schedules/{id}` | Xóa lịch mở cửa (`VenueSchedules.Delete`) | N/A | N/A | N/A | `VenueScheduleRemoteDatasource.deleteVenueSchedule()` | `VenueScheduleRepository.deleteVenueSchedule()` | `ManageVenueScheduleUseCase.deleteVenueSchedule()` (`manageVenueScheduleUseCaseProvider`) |

---

## 6. Phân Hệ Quản Lý Sân Cầu Lông (`/api/v1/courts`)

| API Endpoint | Mô tả & Quyền | DTO (Data Layer) | Entity (Domain Layer) | Mapper | Remote Datasource | Repository | UseCase & Provider |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `GET /api/v1/courts` | Danh sách sân phân trang (`Courts.Read`) | `PagedResultDto<CourtResponseDto>` | `PagedResponse<Court>` | `CourtMapper` | `CourtRemoteDatasource.getCourts()` | `CourtRepository.getCourts()` | `GetCourtsUseCase` (`getCourtsUseCaseProvider`) |
| `POST /api/v1/courts` | Tạo sân mới (`Courts.Create`) | `CourtCreateRequestDto` | N/A | Direct | `CourtRemoteDatasource.createCourt()` | `CourtRepository.createCourt()` | `ManageCourtUseCase.createCourt()` (`manageCourtUseCaseProvider`) |
| `PUT /api/v1/courts/{id}` | Cập nhật sân (`Courts.Update`) | `CourtUpdateRequestDto` | N/A | Direct | `CourtRemoteDatasource.updateCourt()` | `CourtRepository.updateCourt()` | `ManageCourtUseCase.updateCourt()` (`manageCourtUseCaseProvider`) |
| `DELETE /api/v1/courts/{id}` | Xóa sân (`Courts.Delete`) | N/A | N/A | N/A | `CourtRemoteDatasource.deleteCourt()` | `CourtRepository.deleteCourt()` | `ManageCourtUseCase.deleteCourt()` (`manageCourtUseCaseProvider`) |

---

## 7. Phân Hệ Bảng Giá Sân Theo Giờ (`/api/v1/court-pricings`)

| API Endpoint | Mô tả & Quyền | DTO (Data Layer) | Entity (Domain Layer) | Mapper | Remote Datasource | Repository | UseCase & Provider |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `GET /api/v1/court-pricings` | Danh sách bảng giá (`CourtPricings.Read`) | `PagedResultDto<CourtPricingResponseDto>` | `PagedResponse<CourtPricing>` | `CourtPricingMapper` | `CourtPricingRemoteDatasource.getCourtPricings()` | `CourtPricingRepository.getCourtPricings()` | `GetCourtPricingsUseCase` (`getCourtPricingsUseCaseProvider`) |
| `POST /api/v1/court-pricings` | Tạo quy tắc giá (`CourtPricings.Create`) | `CourtPricingCreateRequestDto` | N/A | Direct | `CourtPricingRemoteDatasource.createCourtPricing()` | `CourtPricingRepository.createCourtPricing()` | `ManageCourtPricingUseCase.createCourtPricing()` (`manageCourtPricingUseCaseProvider`) |
| `PUT /api/v1/court-pricings/{id}` | Cập nhật quy tắc giá (`CourtPricings.Update`) | `CourtPricingUpdateRequestDto` | N/A | Direct | `CourtPricingRemoteDatasource.updateCourtPricing()` | `CourtPricingRepository.updateCourtPricing()` | `ManageCourtPricingUseCase.updateCourtPricing()` (`manageCourtPricingUseCaseProvider`) |
| `DELETE /api/v1/court-pricings/{id}` | Xóa quy tắc giá (`CourtPricings.Delete`) | N/A | N/A | N/A | `CourtPricingRemoteDatasource.deleteCourtPricing()` | `CourtPricingRepository.deleteCourtPricing()` | `ManageCourtPricingUseCase.deleteCourtPricing()` (`manageCourtPricingUseCaseProvider`) |

---

## 💻 Danh Sách Tệp Tương Ứng Đã Khai Báo Trong Dự Án

### 📂 1. Tầng Data Layer (`lib/data/`)
- **DTOs (`lib/data/dto/`)**:
  - `auth/`: `login_request_dto.dart`, `login_response_dto.dart`, `register_request_dto.dart`, `change_password_request_dto.dart`
  - `role/`: `role_response_dto.dart`, `role_request_dto.dart`
  - `user/`: `user_response_dto.dart`, `user_permissions_response_dto.dart`, `permission_group_response_dto.dart`, `user_lock_request_dto.dart`, `user_roles_request_dto.dart`, `user_management_request_dto.dart`
  - `venue/`: `venue_response_dto.dart`, `venue_request_dto.dart`
  - `venue_schedule/`: `venue_schedule_response_dto.dart`, `venue_schedule_request_dto.dart`
  - `court/`: `court_response_dto.dart`, `court_request_dto.dart`
  - `court_pricing/`: `court_pricing_response_dto.dart`, `court_pricing_request_dto.dart`
- **Mappers (`lib/data/mapper/`)**:
  - `user_mapper.dart`, `user_permissions_mapper.dart`, `permission_group_mapper.dart`, `role_mapper.dart`, `venue_mapper.dart`, `venue_schedule_mapper.dart`, `court_mapper.dart`, `court_pricing_mapper.dart`
- **Remote Datasources (`lib/data/datasource/remote/`)**:
  - `abstract/`: `auth_remote_datasource.dart`, `role_remote_datasource.dart`, `user_remote_datasource.dart`, `venue_remote_datasource.dart`, `venue_schedule_remote_datasource.dart`, `court_remote_datasource.dart`, `court_pricing_remote_datasource.dart`
  - `implement/`: `auth_remote_datasource_impl.dart`, `role_remote_datasource_impl.dart`, `user_remote_datasource_impl.dart`, `venue_remote_datasource_impl.dart`, `venue_schedule_remote_datasource_impl.dart`, `court_remote_datasource_impl.dart`, `court_pricing_remote_datasource_impl.dart`
- **Repositories Implementation (`lib/data/repositories/`)**:
  - `auth_repository_impl.dart`, `role_repository_impl.dart`, `user_repository_impl.dart`, `venue_repository_impl.dart`, `venue_schedule_repository_impl.dart`, `court_repository_impl.dart`, `court_pricing_repository_impl.dart`

### 🧠 2. Tầng Domain Layer (`lib/domain/`)
- **Entities (`lib/domain/entities/`)**:
  - `user_profile.dart`, `user_permissions.dart`, `permission_group.dart`, `app_role.dart`, `venue.dart`, `venue_schedule.dart`, `court.dart`, `court_pricing.dart`, `paged_response.dart`
- **Repositories Interface (`lib/domain/repositories/`)**:
  - `auth_repository.dart`, `role_repository.dart`, `user_repository.dart`, `venue_repository.dart`, `venue_schedule_repository.dart`, `court_repository.dart`, `court_pricing_repository.dart`
- **UseCases (`lib/domain/usecases/`)**:
  - `auth/`: `login_usecase.dart`, `register_usecase.dart`, `logout_usecase.dart`, `refresh_token_usecase.dart`, `change_password_usecase.dart`
  - `role/`: `get_roles_usecase.dart`, `manage_role_usecase.dart`
  - `user/`: `get_user_me_usecase.dart`, `get_user_permissions_usecase.dart`, `get_all_permissions_usecase.dart`, `get_users_usecase.dart`, `lock_user_usecase.dart`, `update_user_roles_usecase.dart`, `manage_user_usecase.dart`
  - `venue/`: `get_venues_usecase.dart`, `manage_venue_usecase.dart`
  - `venue_schedule/`: `get_venue_schedules_usecase.dart`, `manage_venue_schedule_usecase.dart`
  - `court/`: `get_courts_usecase.dart`, `manage_court_usecase.dart`
  - `court_pricing/`: `get_court_pricings_usecase.dart`, `manage_court_pricing_usecase.dart`

### 🔧 3. Dependency Injection Container (`lib/app/provider.dart`)
- **App Configuration**: `AppConfig` (`lib/app/consts/app_config.dart`)
- **Permission Constants**: `Permissions` (`lib/app/consts/permissions.dart`)

---

## 🛡️ Hướng Dẫn Sử Dụng Phân Quyền Trong Dự Án (RBAC & Permissions Guide)

Hệ thống áp dụng mô hình **Role-Based Access Control (RBAC)** kết hợp **Fine-grained Claims-based Permissions** (Phân quyền chi tiết theo từng chức năng).

```
[ Backend API ] ──(Đăng nhập / JWT Token)──> [ /api/v1/user/me ]
                                                      │
                                                      ▼
                                       [ currentUserProfileProvider ]
                                                      │
                       ┌──────────────────────────────┴─────────────────────────────┐
                       ▼                                                            ▼
         [ hasPermissionProvider(Perm) ]                             [ isAdminUserProvider ]
                       │                                                            │
                       ▼                                                            ▼
         [ UI Guard: Menu / Buttons ]                                 [ Admin Bypass / Dashboard ]
```

---

### 1. Danh Mục Hằng Số Quyền (`lib/app/consts/permissions.dart`)

Tất cả các chuỗi quyền **bắt buộc sử dụng qua hằng số `Permissions`**, tuyệt đối không hardcode chuỗi string trong UI:

| Phân hệ | Hằng số `Permissions` | Tên quyền Backend | Ý nghĩa |
| :--- | :--- | :--- | :--- |
| **Hệ thống** | `Permissions.systemAdministrator` | `System.Administrator` | Toàn quyền quản trị tối cao |
| **Vai trò** | `Permissions.rolesRead` | `Roles.Read` | Xem danh sách vai trò & nhóm quyền |
| | `Permissions.rolesCreate` | `Roles.Create` | Tạo vai trò mới |
| | `Permissions.rolesUpdate` | `Roles.Update` | Chỉnh sửa tên, mô tả vai trò |
| | `Permissions.rolesDelete` | `Roles.Delete` | Xóa vai trò |
| | `Permissions.rolesAssignPermissions` | `Roles.AssignPermissions` | Gán/cập nhật cây quyền cho vai trò |
| **Người dùng** | `Permissions.usersRead` | `Users.Read` | Xem danh sách tài khoản & chi tiết |
| | `Permissions.usersCreate` | `Users.Create` | Tạo tài khoản người dùng mới |
| | `Permissions.usersUpdate` | `Users.Update` | Cập nhật thông tin tài khoản |
| | `Permissions.usersDelete` | `Users.Delete` | Xóa tài khoản |
| | `Permissions.usersLock` | `Users.Lock` | Khóa / Mở khóa tài khoản |
| | `Permissions.usersAssignRoles` | `Users.AssignRoles` | Gán danh sách vai trò cho tài khoản |
| | `Permissions.usersResetPassword` | `Users.ResetPassword` | Đặt lại mật khẩu tài khoản |
| **Cụm sân** | `Permissions.venuesRead` | `Venues.Read` | Xem danh sách cụm sân |
| | `Permissions.venuesCreate` | `Venues.Create` | Tạo cụm sân mới |
| | `Permissions.venuesUpdate` | `Venues.Update` | Cập nhật thông tin cụm sân |
| | `Permissions.venuesDelete` | `Venues.Delete` | Xóa cụm sân |
| **Sân cầu lông**| `Permissions.courtsRead` | `Courts.Read` | Xem danh sách sân |
| | `Permissions.courtsCreate` | `Courts.Create` | Tạo sân mới |
| | `Permissions.courtsUpdate` | `Courts.Update` | Chỉnh sửa thông tin sân |
| | `Permissions.courtsDelete` | `Courts.Delete` | Xóa sân |
| **Lịch hoạt động**| `Permissions.venueSchedulesRead` | `VenueSchedules.Read` | Xem lịch mở/đóng cửa |
| | `Permissions.venueSchedulesCreate` | `VenueSchedules.Create` | Tạo cấu hình lịch mở cửa |
| | `Permissions.venueSchedulesUpdate` | `VenueSchedules.Update` | Sửa lịch mở cửa |
| | `Permissions.venueSchedulesDelete` | `VenueSchedules.Delete` | Xóa lịch mở cửa |
| **Bảng giá sân**| `Permissions.courtPricingsRead` | `CourtPricings.Read` | Xem cấu hình bảng giá |
| | `Permissions.courtPricingsCreate` | `CourtPricings.Create` | Tạo quy tắc tính giá |
| | `Permissions.courtPricingsUpdate` | `CourtPricings.Update` | Sửa quy tắc tính giá |
| | `Permissions.courtPricingsDelete` | `CourtPricings.Delete` | Xóa quy tắc tính giá |
| **Dashboard** | `Permissions.dashboardView` | `Dashboard.View` | Xem tổng quan báo cáo thống kê |

---

### 2. Các Riverpod Providers Hỗ Trợ Kiểm Tra Quyền (`lib/app/provider.dart`)

Hệ thống cung cấp sẵn các Provider tiện ích giúp kiểm tra quyền dễ dàng:

```dart
// 1. Lấy toàn bộ UserProfile (bao gồm danh sách roles và permissions)
final userProfile = ref.watch(currentUserProfileProvider);

// 2. Lấy danh sách tên quyền dạng List<String>
final permissions = ref.watch(userPermissionsProvider);

// 3. Kiểm tra xem user có quyền cụ thể hay không (Tự động bypass nếu là Admin)
final canCreateUser = ref.watch(hasPermissionProvider(Permissions.usersCreate));

// 4. Kiểm tra user có phải là Quản trị viên (Admin) hay không
final isAdmin = ref.watch(isAdminUserProvider);
```

> [!TIP]
> `hasPermissionProvider` đã được tích hợp cơ chế **Admin Bypass**: Nếu tài khoản có vai trò `Admin` hoặc quyền `System.Administrator`, Provider sẽ luôn trả về `true` cho mọi quyền.

---

### 3. Hướng Dẫn Sử Dụng Cụ Thể Trong Từng Trường Hợp

#### 🔹 Trường hợp 1: Lọc Menu Navigation (Sidebar / Bottom Navigation)
Khi hiển thị danh sách mục Menu, ta gắn `permission` tương ứng vào từng item và dùng `where` để chỉ hiển thị các mục người dùng có quyền:

```dart
class MyNavigationItem {
  final String title;
  final IconData icon;
  final String? permission; // null = công khai, hoặc chuỗi Permissions.xxx
  final Widget page;

  const MyNavigationItem({
    required this.title,
    required this.icon,
    this.permission,
    required this.page,
  });
}

// Trong Widget Build:
final userPerms = ref.watch(userPermissionsProvider);
final isAdmin = ref.watch(isAdminUserProvider);

final allMenuItems = [
  const MyNavigationItem(
    title: 'Quản lý Người dùng',
    icon: Icons.people_outline,
    permission: Permissions.usersRead,
    page: UserManagementScreen(),
  ),
  const MyNavigationItem(
    title: 'Quản lý vai trò',
    icon: Icons.shield_outlined,
    permission: Permissions.rolesRead,
    page: RoleManagementScreen(),
  ),
  const MyNavigationItem(
    title: 'Cài đặt cá nhân',
    icon: Icons.settings_outlined,
    permission: null, // Mọi người dùng đều thấy
    page: SettingsPage(),
  ),
];

// Lọc danh sách menu hợp lệ:
final visibleItems = allMenuItems.where((item) {
  if (item.permission == null) return true;
  if (isAdmin) return true;
  return userPerms.contains(item.permission);
}).toList();
```

---

#### 🔹 Trường hợp 2: Ẩn / Hiện Nút Thao Tác (Button / Widget Guards)

Dự án cung cấp Widget chuyên dụng **`HasPermission`** (`lib/widget/has_permission.dart`) giúp bọc và bảo vệ các thành phần UI một cách trực quan, sạch sẽ và tự động kích hoạt Admin Bypass:

##### Cách 1: Dùng Widget `<HasPermission>` (Khuyên dùng - Declarative UI)
```dart
import 'package:kltn2026_2027/app/consts/permissions.dart';
import 'package:kltn2026_2027/widget/has_permission.dart';

// 1. Bảo vệ Nút Thêm (Ẩn đi nếu không có quyền Venues.Create)
HasPermission(
  permission: Permissions.venuesCreate,
  child: ElevatedButton.icon(
    onPressed: () => _openCreateDialog(context),
    icon: const Icon(Icons.add),
    label: const Text('Thêm sân mới'),
  ),
)

// 2. Bảo vệ Nút Sửa & Nút Xóa trong thẻ Card/Danh sách
Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    // Chỉ hiển thị nút Sửa nếu có quyền Venues.Update
    HasPermission(
      permission: Permissions.venuesUpdate,
      child: IconButton(
        icon: const Icon(Icons.edit, color: Colors.blue),
        onPressed: () => _openEditDialog(venue),
      ),
    ),
    // Chỉ hiển thị nút Xóa nếu có quyền Venues.Delete (hoặc hiển thị widget fallback nếu cần)
    HasPermission(
      permission: Permissions.venuesDelete,
      child: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () => _confirmDelete(venue),
      ),
    ),
  ],
)
```

##### Cách 2: Dùng `ref.watch(hasPermissionProvider(...))` khi cần xử lý logic điều kiện trong code
```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final canCreate = ref.watch(hasPermissionProvider(Permissions.venuesCreate));
  final canEdit = ref.watch(hasPermissionProvider(Permissions.venuesUpdate));

  if (!canCreate && !canEdit) {
    return const Center(child: Text('Bạn chỉ có quyền xem dữ liệu (Read-only)'));
  }

  return ...;
}
```

---

#### 🔹 Trường hợp 3: Bảo Vệ Điều Hướng / Router Guards
Khi người dùng truy cập trực tiếp bằng URL trên Web, có thể kiểm tra quyền tại `GoRoute.redirect`:

```dart
GoRoute(
  path: AppConfig.adminUsersPath,
  builder: (_, __) => const UserManagementScreen(),
  redirect: (context, state) {
    final container = ProviderScope.containerOf(context);
    final hasPerm = container.read(hasPermissionProvider(Permissions.usersRead));
    if (!hasPerm) {
      return AppConfig.homePath; // Chặn truy cập và chuyển về trang Home
    }
    return null;
  },
),
```

---

#### 🔹 Trường hợp 4: Xử Lý Lỗi Phân Quyền Từ Backend (`403 Forbidden`)
Dù UI đã ẩn nút bấm, backend vẫn kiểm tra quyền tại tầng API. Nếu tài khoản bị thu hồi quyền đột ngột, Dio sẽ quăng mã lỗi `403`. 
Hệ thống chuyển đổi lỗi này thành `ForbiddenException` qua [`AppExceptionHandler`](file:///c:/code/base_fe/KLTN2026-2027/KLTN2026-2027/lib/app/utils/app_exception_handler.dart):

```dart
try {
  await manageUserUseCase.deleteUser(id);
} on ForbiddenException catch (e) {
  // Hiển thị thông báo khi bị từ chối truy cập:
  state = state.copyWith(errorMessage: 'Bạn không có quyền thực hiện thao tác này');
} on AppException catch (e) {
  state = state.copyWith(errorMessage: e.message);
}
```

---

### 4. Quy Tắc Khi Bổ Sung Chức Năng Mới Có Phân Quyền
1. **Bước 1**: Khai báo hằng số mới trong [`lib/app/consts/permissions.dart`](file:///c:/code/base_fe/KLTN2026-2027/KLTN2026-2027/lib/app/consts/permissions.dart) khớp chính xác với backend `AppPermissions.cs`.
2. **Bước 2**: Đặt quyền vào menu navigation trong `HomeTablet` / `HomeMobile`.
3. **Bước 3**: Dùng `ref.watch(hasPermissionProvider(Permissions.xxx))` tại các nút thao tác UI.
4. **Bước 4**: Thêm UseCase và DataSource tương ứng theo đúng 3 tầng Clean Architecture.

