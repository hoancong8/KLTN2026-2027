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
