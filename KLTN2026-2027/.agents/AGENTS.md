# Quy Tắc Kiến Trúc & Quy Trình Lập Trình (Clean Architecture Guidelines) - KLTN2026-2027

Tài liệu này định nghĩa toàn bộ quy tắc thiết kế kiến trúc, quy trình phát triển chức năng mới (Feature Workflow), và quy tắc xử lý API / Mapper cho dự án **KLTN2026-2027** (Flutter).

---

## 1. Tổng Quan Kiến Trúc Clean Architecture (3 Layers)

Dự án áp dụng mô hình **Clean Architecture 3 tầng** nguyên bản, đảm bảo nguyên tắc **Độc lập phụ thuộc (Dependency Rule)**: Phụ thuộc chỉ hướng từ ngoài vào trong (`UI` -> `Domain` <- `Data`).

```
sipm_mobile/lib/
├── domain/                    # 🧠 Tầng Nghiệp Vụ Cốt Lõi (Pure Dart - NO Flutter UI Dependencies)
│   ├── entities/              # Core business models (Thực thể nghiệp vụ)
│   ├── repositories/          # Abstract Repository Interfaces (Hợp đồng dữ liệu)
│   ├── usecases/              # Business logic execution (Quy tắc xử lý nghiệp vụ)
│   ├── exceptions/            # Custom domain exceptions (Ngoại lệ nghiệp vụ)
│   └── services/              # Domain/Platform service contracts (Interfaces)
│
├── data/                      # 💾 Tầng Dữ Liệu (Data Access & Infrastructure)
│   ├── dto/                   # Data Transfer Objects (Request/Response DTOs từ API)
│   ├── datasource/            # Data sources (Remote via Dio, Local via Storage)
│   │   └── remote/
│   │       ├── abstract/      # Remote Datasource Interfaces
│   │       ├── implement/     # Remote Datasource Impls (kế thừa BaseRemoteDatasource)
│   │       └── base_remote_datasource.dart # Bóc tách ABP Framework response & Exception handler
│   ├── mapper/                # Chuyển đổi dữ liệu (DTO <-> Entity)
│   └── repositories/          # Triển khai Repository Interfaces từ Domain
│
├── app/                       # 🔧 Cấu Hình Hệ Thống & Dependency Injection (DI)
│   ├── consts/                # AppConfig (Endpoints), AppColors, AppStyle...
│   ├── provider.dart          # Riverpod DI Container (Đăng ký Dio, Datasource, Repo, UseCase)
│   ├── mapper.dart            # Base Mapper interface generic Mapper<I, O>
│   └── usecase.dart           # Base UseCase generic UseCase<Output>, UseCaseWithParams<Output, Params>
│
└── ui/                        # 🎨 Tầng Giao Diện (Presentation Layer)
    └── screen/
        └── <feature_name>/    # Mỗi chức năng phân chia theo module riêng
            ├── <feature>_screen.dart  # Screen entrypoint (Responsive layout)
            ├── <feature>_vm/          # View Model & State (Riverpod StateNotifier)
            │   ├── <feature>_state.dart
            │   └── <feature>_vm.dart
            └── widgets/               # Components UI (FeatureMobile, FeatureTablet, Shared Widgets)
```

---

## 2. Quy Tắc Lấy Dữ Liệu API & Mapper Pattern

### 2.1 Chuẩn API Response (ABP Framework Protocol)
Hệ thống backend sử dụng **ABP Framework**, response luôn được bọc trong cấu trúc chuẩn:
- **Single Object Response**: `{ "result": { ... }, "targetUrl": null, "success": true, "error": null }`
- **Paged / List Response**: `{ "result": { "items": [ ... ], "totalCount": 100 }, "success": true }` hoặc `{ "result": [ ... ] }`

### 2.2 Quy tắc viết Remote DataSource (`lib/data/datasource/remote/`)
1. Tất cả Class Remote DataSource Implementation **bắt buộc kế thừa `BaseRemoteDatasource`**.
2. **Không tự bóc tách `res.data['result']` thủ công trong từng API call**.
3. Dùng các hàm helper từ `BaseRemoteDatasource`:
   - Lấy 1 đối tượng: `handleResponse(response, (json) => Dto.fromJson(json))`
   - Lấy danh sách đối tượng: `handleListResponse(response, (json) => Dto.fromJson(json))`
4. Bắt mọi exception bằng `try-catch` và throw qua `handleError(e)`.

*Ví dụ chuẩn DataSource Implementation:*
```dart
class TaskRemoteDatasourceImpl extends BaseRemoteDatasource implements TaskRemoteDatasource {
  final Dio dio;
  TaskRemoteDatasourceImpl(this.dio);

  @override
  Future<TaskResponseDto> getTaskById(int id) async {
    try {
      final res = await dio.get('${AppConfig.task}/$id');
      return handleResponse(res, (json) => TaskResponseDto.fromJson(json));
    } catch (e) {
      throw handleError(e);
    }
  }
}
```

### 2.3 Quy tắc viết DTO (Data Transfer Object) (`lib/data/dto/`)
1. DTO chỉ nằm trong `lib/data/dto/<feature>/`. **Tuyệt đối KHÔNG import DTO vào `domain/` hay `ui/`**.
2. Đặt tên file: `<action>_request_dto.dart` hoặc `<feature>_response_dto.dart`.
3. Bắt buộc viết Parser phòng thủ (Defensive Parsing) cho các kiểu dữ liệu primitive để tránh crash runtime do null hoặc sai kiểu từ backend:
   ```dart
   static int _parseInt(dynamic value) {
     if (value is int) return value;
     if (value is String) return int.tryParse(value) ?? 0;
     return 0;
   }

   static bool _parseBool(dynamic value) {
     if (value is bool) return value;
     if (value is String) return value.toLowerCase() == 'true';
     return false;
   }
   ```

### 2.4 Quy tắc viết Mapper (`lib/data/mapper/`)
1. Mapper chịu trách nhiệm duy nhất: Chuyển đổi qua lại giữa `DTO` (Data Layer) và `Entity` (Domain Layer).
2. Viết dưới dạng Class static helper hoặc triển khai `Mapper<I, O>`.
3. Đảm bảo parse an toàn cho `DateTime`, Enum, hoặc các kiểu dữ liệu phức tạp.

*Ví dụ chuẩn Mapper:*
```dart
class TaskMapper {
  static TaskEntity toEntity(TaskResponseDto dto) {
    return TaskEntity(
      id: dto.id,
      title: dto.title ?? '',
      createdAt: dto.createdAt != null ? DateTime.tryParse(dto.createdAt!) : null,
      isCompleted: dto.isCompleted,
    );
  }

  static TaskRequestDto toDto(TaskEntity entity) {
    return TaskRequestDto(
      id: entity.id,
      title: entity.title,
      isCompleted: entity.isCompleted,
    );
  }
}
```

---

## 3. Quy Trình 5 Bước Thêm Một Chức Năng Mới (Step-by-Step Feature Workflow)

Khi thêm một chức năng mới (ví dụ: Chức năng `Task`), thực hiện lần lượt theo 5 bước dưới đây:

### 🔹 BƯỚC 1: Tầng Domain (`lib/domain/`)
1. **Tạo Entity (`lib/domain/entities/task.dart`)**:
   Pure Dart class biểu diễn thông tin nghiệp vụ.
   ```dart
   class Task {
     final int id;
     final String title;
     final bool isCompleted;
     const Task({required this.id, required this.title, required this.isCompleted});
   }
   ```
2. **Tạo Repository Interface (`lib/domain/repositories/task_repository.dart`)**:
   Khai báo các hàm tương tác dữ liệu dạng `abstract class`.
   ```dart
   abstract class TaskRepository {
     Future<List<Task>> getTasks();
     Future<void> createTask(String title);
   }
   ```
3. **Tạo UseCase (`lib/domain/usecases/task/get_tasks_usecase.dart`)**:
   Xử lý 1 tác vụ nghiệp vụ đơn lẻ. Kế thừa `UseCase<Output>` hoặc `UseCaseWithParams<Output, Params>`.
   ```dart
   class GetTasksUseCase implements UseCase<List<Task>> {
     final TaskRepository repository;
     GetTasksUseCase(this.repository);

     @override
     Future<List<Task>> execute() => repository.getTasks();
   }
   ```

### 🔹 BƯỚC 2: Tầng Data (`lib/data/`)
1. **Tạo DTO (`lib/data/dto/task/task_response_dto.dart`)**:
   Định nghĩa dữ liệu từ API và hàm `fromJson`.
2. **Tạo Mapper (`lib/data/mapper/task_mapper.dart`)**:
   Chuyển đổi `TaskResponseDto` -> `Task` (Entity).
3. **Tạo Remote DataSource Interface & Implementation**:
   - `lib/data/datasource/remote/abstract/task_remote_datasource.dart`
   - `lib/data/datasource/remote/implement/task_remote_datasource_impl.dart` (Kế thừa `BaseRemoteDatasource`).
4. **Tạo Repository Implementation (`lib/data/repositories/task_repository_impl.dart`)**:
   Triển khai `TaskRepository`, gọi Remote Datasource và map DTO thành Entity.
   ```dart
   class TaskRepositoryImpl implements TaskRepository {
     final TaskRemoteDatasource remote;
     TaskRepositoryImpl(this.remote);

     @override
     Future<List<Task>> getTasks() async {
       final dtos = await remote.getTasks();
       return dtos.map((dto) => TaskMapper.toEntity(dto)).toList();
     }
   }
   ```

### 🔹 BƯỚC 3: Đăng Ký Dependency Injection (`lib/app/provider.dart` & `app_config.dart`)
1. Thêm API Endpoint vào `lib/app/consts/app_config.dart`.
2. Khai báo các Provider trong `lib/app/provider.dart`:
   - `taskRemoteDatasourceProvider`
   - `taskRepositoryProvider`
   - `getTasksUseCaseProvider`

```dart
final taskRemoteDatasourceProvider = Provider<TaskRemoteDatasource>((ref) {
  return TaskRemoteDatasourceImpl(ref.watch(dioProvider));
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl(ref.watch(taskRemoteDatasourceProvider));
});

final getTasksUseCaseProvider = Provider<GetTasksUseCase>((ref) {
  return GetTasksUseCase(ref.watch(taskRepositoryProvider));
});
```

### 🔹 BƯỚC 4: Tầng Presentation (`lib/ui/screen/task/`)
Tạo thư mục `lib/ui/screen/task/`:
1. **State (`task_vm/task_state.dart`)**: Class immutable lưu trạng thái UI (`isLoading`, `tasks`, `error`).
2. **ViewModel (`task_vm/task_vm.dart`)**: Kế thừa `StateNotifier<TaskState>`, quản lý logic UI và gọi UseCase.
3. **Screen (`task_screen.dart`)**: Sử dụng `ResponsiveLayout` để hỗ trợ cả Mobile và Tablet.
4. **Widgets (`widgets/task_mobile.dart`, `widgets/task_tablet.dart`)**: Dựng giao diện người dùng.

### 🔹 BƯỚC 5: Đa Ngôn Ngữ & Xử Lý Lỗi (Localization & Error Handling)
1. Khai báo nhãn hiển thị trong `lib/l10n/app_vi.arb` và `app_en.arb`.
2. Bắt lỗi trong ViewModel và gán `state = state.copyWith(error: e as AppException)`.
3. Hiển thị lỗi trên UI bằng `state.error?.getDisplayMessage(context.l10n)`.

---

## 4. Nguyên Tắc Cốt Lõi Về Clean Code & Đóng Gói (Best Practices)

1. **Strict Layer Boundary**:
   - `Domain` KHÔNG ĐƯỢC import bất kỳ thư viện Flutter UI (`package:flutter/material.dart`) hay Data (`dto`, `dio`).
   - `UI` KHÔNG ĐƯỢC gọi trực tiếp `Datasource`, `DTO` hoặc `Dio`. UI chỉ làm việc với `ViewModel`, `Entity`, và `UseCase`.
2. **State Management**:
   - Sử dụng Riverpod `StateNotifier` cho logic màn hình phức tạp.
   - Sử dụng `StateProvider` cho các biến state đơn lẻ (ví dụ tab index, input form đơn giản).
3. **Responsive Design**:
   - Mọi màn hình chính phải hỗ trợ `ResponsiveLayout` phân tách giao diện `mobile` và `tablet`.
4. **Error Handling**:
   - Tuyệt đối không dùng `try-catch` nuốt lỗi rỗng (empty catch).
   - Mọi lỗi từ Dio/Network phải qua `AppExceptionHandler` để chuyển thành `AppException`.
