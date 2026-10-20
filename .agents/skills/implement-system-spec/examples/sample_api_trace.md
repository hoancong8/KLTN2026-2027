# Ví Dụ Mẫu Truy Vết Đặc Tả API (Sample API Trace)

Ví dụ thực tế khi người dùng yêu cầu: *"Xây dựng màn hình hiển thị danh sách buổi sinh hoạt cầu lông và đặt chỗ"*.

---

## 1. Truy Vết Đặc Tả Bằng CLI
```powershell
python .agents/skills/implement-system-spec/scripts/trace_system_spec.py --subsystem sessions
```

## 2. Kết Quả Ánh Xạ Kiến Trúc Tương Ứng:
- **Endpoint 1:** `GET /api/v1/sessions`
  - DTO: `SessionDto` (trong `lib/data/dto/session/`)
  - Entity: `Session` (trong `lib/domain/entities/session/`)
  - Mapper: `SessionMapper.toEntity(dto)`
  - Datasource: `SessionRemoteDatasource.getSessions()`
  - Repository: `SessionRepository.getSessions()`
  - UseCase: `GetSessionsUseCase`
  - Provider: `getSessionsUseCaseProvider` (trong `lib/app/provider.dart`)
- **Endpoint 2:** `POST /api/v1/sessions/{id}/bookings`
  - DTO: `SessionBookingDto`
  - Entity: `SessionBooking`
  - Mapper: `SessionBookingMapper.toEntity(dto)`
  - UseCase: `BookSessionUseCase`
  - Provider: `bookSessionUseCaseProvider`

## 3. Triển Khai UI (Presentation):
- State: `SessionState(isLoading, sessions, myBookings, error)`
- ViewModel: `SessionViewModel` kế thừa `StateNotifier<SessionState>`
- Screen: `SessionScreen` sử dụng `ResponsiveLayout(mobile: SessionMobile(), tablet: SessionTablet())`
