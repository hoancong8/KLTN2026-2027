---
trigger: glob
globs: "lib/**, test/**"
description: "Phân định ranh giới 3 tầng Clean Architecture trong Flutter, cấm rò rỉ phụ thuộc giữa Domain, Data và UI, chuẩn hóa Mapper và Riverpod DI."
---

# Phân Định Trách Nhiệm 3 Tầng Clean Architecture (Domain vs Data vs UI)

> [!IMPORTANT]
> Ngăn chặn triệt để tình trạng "Rò rỉ ranh giới phân tầng" (Boundary Leakage) và "Vi phạm nguyên tắc độc lập phụ thuộc" (Dependency Rule). Toàn bộ AI Agent và kỹ sư phần mềm khi viết code trong dự án **KLTN2026-2027** bắt buộc phải tuân thủ nghiêm ngặt ma trận và các quy tắc dưới đây.

---

## 1. Bản Đồ Ranh Giới & Chiều Phụ Thuộc (Dependency Direction)

```
[Presentation / UI] ────────► [Domain Layer (Core)] ◄──────── [Data Layer (Infra)]
  - Screen Entrypoint           - Pure Dart Business Logic     - DTOs (Request / Response)
  - Responsive Layout            - Entities (Immutable)         - Remote Datasource (Dio)
  - ViewModel (StateNotifier)    - Repository Contracts         - BaseRemoteDatasource (ABP)
  - State (copyWith)             - UseCases (Single Action)     - Mapper (DTO <-> Entity)
  - Mobile & Tablet Widgets      - Domain Exceptions            - Repository Implementation
  - Localization (context.l10n)  - Platform Service Contracts   - Local Storage / Cache
```

**Nguyên Tắc Bất Biến Về Phụ Thuộc:**
- `Domain Layer` nằm ở trung tâm và **hoàn toàn độc lập**. Tuyệt đối không phụ thuộc vào UI (`flutter/material.dart`, `widgets.dart`), không phụ thuộc vào Data (`dio`, DTOs, datasource).
- `Data Layer` phụ thuộc vào `Domain Layer` (để triển khai các Repository interface và chuyển đổi DTO sang Entity).
- `UI Layer` phụ thuộc vào `Domain Layer` (sử dụng Entity và gọi UseCase qua ViewModel). Tuyệt đối không gọi trực tiếp Data Layer (Dio, Datasource, DTO).

---

## 2. Bảng Ma Trận: "Logic Này Phải Đặt Ở Đâu?"

| Loại Logic / Thành Phần | Tầng Trách Nhiệm | Thư Mục / File Chuẩn | Giải Thích Chi Tiết |
| :--- | :---: | :--- | :--- |
| **Thực thể dữ liệu nghiệp vụ (Core Entity)** | **Domain** | `lib/domain/entities/` | Pure Dart class. Chứa dữ liệu hiển thị và logic nghiệp vụ cốt lõi, không chứa parser JSON `fromJson`/`toJson`. |
| **Hợp đồng truy xuất dữ liệu (Repo Contract)** | **Domain** | `lib/domain/repositories/` | `abstract class` định nghĩa các phương thức trả về `Future<Entity>` hoặc `Future<List<Entity>>`. |
| **Quy tắc thực thi ca sử dụng (UseCase)** | **Domain** | `lib/domain/usecases/` | Thực thi một tác vụ đơn lẻ (`execute`). Triển khai `UseCase<Output>` hoặc `UseCaseWithParams<Output, Params>`. |
| **Ngoại lệ nghiệp vụ thuần túy** | **Domain** | `lib/domain/exceptions/` | Kế thừa `AppException`. Không hardcode chuỗi hiển thị, cung cấp hàm `getDisplayMessage(IAppMessages)`. |
| **Cấu trúc dữ liệu API (Request/Response DTO)** | **Data** | `lib/data/dto/<feature>/` | Ánh xạ cấu trúc JSON từ backend ABP Framework. Bắt buộc có parser phòng thủ (`_parseInt`, `_parseBool`). |
| **Gọi API mạng (HTTP / REST / Dio)** | **Data** | `lib/data/datasource/remote/` | Kế thừa `BaseRemoteDatasource`. Dùng `handleResponse`, `handleListResponse`, `handleError`. |
| **Ánh xạ dữ liệu (DTO <-> Entity)** | **Data** | `lib/data/mapper/` | Hàm static `toEntity(dto)` và `toDto(entity)`. Cô lập hoàn toàn thay đổi schema API khỏi Domain. |
| **Triển khai Repository (Repo Implementation)** | **Data** | `lib/data/repositories/` | Triển khai interface từ Domain. Gọi Datasource, chuyển đổi qua Mapper, trả về Entity sạch. |
| **Đăng ký Dependency Injection (DI)** | **App** | `lib/app/provider.dart` | Khai báo tập trung các `Provider` cho Dio, Datasource, Repository, UseCase và `StateNotifierProvider`. |
| **Quản lý trạng thái màn hình (ViewModel)** | **UI** | `lib/ui/screen/<f>/<f>_vm/` | Kế thừa `StateNotifier<State>`. Quản lý `isLoading`, `data`, `error`. Gọi UseCase và gán state. |
| **Giao diện người dùng & Widget** | **UI** | `lib/ui/screen/<f>/widgets/` | Dựng layout giao diện, chia tách Mobile / Tablet qua `ResponsiveLayout`. Đọc state qua Riverpod `ref.watch`. |
| **Đa ngôn ngữ & Nhãn giao diện** | **L10n** | `lib/l10n/` | Tệp `.arb`. UI đọc qua `context.l10n.<key>`. Tuyệt đối không hardcode text tiếng Việt trong UI code. |

---

## 3. Các Anti-Pattern Nghiêm Cấm Tuyệt Đối (Architectural Violations)

1. **CẤM import UI vào Domain:**
   - ❌ `import 'package:flutter/material.dart';` trong `lib/domain/**`.
   - ❌ Sử dụng `BuildContext`, `Color`, `Widget` trong Entity hoặc UseCase.
2. **CẤM import Network / DTO vào Domain:**
   - ❌ `import 'package:dio/dio.dart';` trong `lib/domain/**`.
   - ❌ `import 'package:.../data/dto/...';` trong `lib/domain/**`.
3. **CẤM rò rỉ Data Layer vào UI Layer:**
   - ❌ Import hoặc khởi tạo `*RemoteDatasource` trực tiếp trong Widget hoặc Screen.
   - ❌ Dùng `*ResponseDto` làm kiểu dữ liệu của biến state trong ViewModel.
   - ❌ Gọi trực tiếp API HTTP bằng `Dio` từ trong Widget / ViewModel.
4. **CẤM bóc tách JSON thủ công trong Datasource:**
   - ❌ `final data = res.data['result']['items'];` trong từng phương thức Datasource.
   - ✅ Phải kế thừa `BaseRemoteDatasource` và dùng `handleResponse`/`handleListResponse`.
5. **CẤM nuốt ngoại lệ rỗng (Silent Exception Swallowing):**
   - ❌ `catch (e) { }` hoặc `catch (e) { print(e); }`.
   - ✅ Mọi lỗi tại Datasource phải ném qua `handleError(e)`, và ViewModel bắt `on AppException catch (e)`.
