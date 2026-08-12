# QUY TẮC KIẾN TRÚC & PHÁT TRIỂN CHỨC NĂNG MỚI (CLEAN ARCHITECTURE GUIDELINES)

Tài liệu này cung cấp toàn bộ quy tắc code, chuẩn lấy dữ liệu API Mapper, và quy trình từng bước để phát triển 1 chức năng mới trong dự án **KLTN2026-2027**.

---

## 📚 MỤC LỤC
1. [Tổng Quan Kiến Trúc Clean Architecture](#1-tổng-quan-kiến-trúc-clean-architecture)
2. [Quy Tắc Lấy Dữ Liệu API & Mapper Pattern](#2-quy-tắc-lấy-dữ-liệu-api--mapper-pattern)
3. [Quy Trình 5 Bước Thêm 1 Chức Năng Mới (Step-by-Step)](#3-quy-trình-5-bước-thêm-1-chức-năng-mới-step-by-step)
4. [Quản Lý Trạng Thái (State Management & DI)](#4-quản-lý-trạng-thái-state-management--di)
5. [Xử Lý Lỗi Tập Trung & Đa Ngôn Ngữ](#5-xử-lý-lỗi-tập-trung--đa-ngôn-ngữ)

---

## 1. TỔNG QUAN KIẾN TRÚC CLEAN ARCHITECTURE

Dự án áp dụng mô hình **Clean Architecture 3 tầng** chuẩn mực:

```
sipm_mobile/lib/
├── domain/                    # 🧠 Tầng Nghiệp Vụ Cốt Lõi (Pure Dart)
│   ├── entities/              # Các đối tượng thực thể (Domain Models)
│   ├── repositories/          # Interface định nghĩa cách truy xuất dữ liệu (Abstract)
│   ├── usecases/              # Quy tắc xử lý nghiệp vụ (Business Rules)
│   ├── exceptions/            # Ngoại lệ nghiệp vụ thuần Dart
│   └── services/              # Interface cho các service hệ thống/nền tảng
│
├── data/                      # 💾 Tầng Dữ Liệu (Data Layer & Infrastructure)
│   ├── dto/                   # Data Transfer Objects (Request/Response DTOs từ API)
│   ├── datasource/            # Nguồn dữ liệu
│   │   └── remote/
│   │       ├── abstract/      # Remote Datasource Interfaces
│   │       ├── implement/     # Remote Datasource Impls (kế thừa BaseRemoteDatasource)
│   │       └── base_remote_datasource.dart # Bóc tách ABP Framework JSON
│   ├── mapper/                # Chuyển đổi dữ liệu DTO <-> Entity
│   └── repositories/          # Implement của Repository Interfaces từ Domain
│
├── app/                       # 🔧 Cấu Hình & Dependency Injection (DI)
│   ├── consts/                # AppConfig (Endpoints), AppColors...
│   ├── provider.dart          # Riverpod DI Container tập trung
│   ├── mapper.dart            # Interface base Mapper<I, O>
│   └── usecase.dart           # Interface base UseCase, UseCaseWithParams, PagingUseCase
│
└── ui/                        # 🎨 Tầng Giao Diện (Presentation Layer)
    └── screen/
        └── <feature_name>/    # Phân chia theo từng Feature
            ├── <feature>_screen.dart  # Screen entrypoint (Responsive layout)
            ├── <feature>_vm/          # StateNotifier ViewModel & State
            │   ├── <feature>_state.dart
            │   └── <feature>_vm.dart
            └── widgets/               # Sub-widgets (Mobile, Tablet, Shared)
```

### 🔒 Nguyên Tắc Độc Lập Phụ Thuộc (Dependency Rule):
- **Domain Layer**: Thuần Dart, **KHÔNG BAO GIỜ** import Flutter UI (`package:flutter/material.dart`), Dio, hay DTO.
- **Data Layer**: Phụ thuộc vào Domain Layer. Thực hiện giao tiếp HTTP (Dio), bóc tách JSON thành DTO, chuyển đổi DTO thành Entity qua Mapper.
- **Presentation Layer (UI)**: Giao diện và ViewModel. Chỉ làm việc với `Entity`, `UseCase` và `StateNotifier`. Không gọi trực tiếp Dio hay Datasource.

---

## 2. QUY TẮC LẤY DỮ LIỆU API & MAPPER PATTERN

### 2.1 Cấu Trúc Response API (ABP Framework Protocol)
Backend sử dụng ABP Framework, phản hồi API luôn có dạng:
- **Object đơn lẻ**: `{ "result": { ... }, "success": true, "error": null }`
- **Danh sách / Phân trang**: `{ "result": { "items": [ ... ], "totalCount": 10 }, "success": true }` hoặc `{ "result": [ ... ] }`

### 2.2 Remote DataSource (`lib/data/datasource/remote/`)
1. Class triển khai Remote DataSource **bắt buộc kế thừa `BaseRemoteDatasource`**.
2. Sử dụng hàm helper của `BaseRemoteDatasource`:
   - Phản hồi 1 Object: `handleResponse(response, (json) => Dto.fromJson(json))`
   - Phản hồi Danh sách: `handleListResponse(response, (json) => Dto.fromJson(json))`
3. Mọi exception phải được bọc trong `try-catch` và ném qua `handleError(e)`.

*Ví dụ:*
```dart
class TaskRemoteDatasourceImpl extends BaseRemoteDatasource implements TaskRemoteDatasource {
  final Dio dio;
  TaskRemoteDatasourceImpl(this.dio);

  @override
  Future<TaskResponseDto> getTaskDetail(int id) async {
    try {
      final res = await dio.get('${AppConfig.baseUrl}/api/services/app/Task/GetDetail?id=$id');
      return handleResponse(res, (json) => TaskResponseDto.fromJson(json));
    } catch (e) {
      throw handleError(e);
    }
  }
}
```

### 2.3 DTO (Data Transfer Object) (`lib/data/dto/`)
1. DTO nằm trong `lib/data/dto/<feature>/`.
2. Đặt tên: `<action>_request_dto.dart` (Gửi lên API) hoặc `<feature>_response_dto.dart` (Nhận từ API).
3. **Bắt buộc dùng Parser phòng thủ (Defensive Parsing)** để ngăn crash app khi backend trả sai kiểu dữ liệu:
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

### 2.4 Mapper Pattern (`lib/data/mapper/`)
1. Mapper chuyển đổi giữa DTO (Data Layer) và Entity (Domain Layer).
2. Tách biệt hoàn toàn model gửi/nhận từ API và model dùng trong logic app.

*Ví dụ Mapper:*
```dart
class TaskMapper {
  static Task toEntity(TaskResponseDto dto) {
    return Task(
      id: dto.id,
      title: dto.title ?? '',
      isCompleted: dto.isCompleted,
      dueDate: dto.dueDate != null ? DateTime.tryParse(dto.dueDate!) : null,
    );
  }

  static TaskRequestDto toDto(Task entity) {
    return TaskRequestDto(
      id: entity.id,
      title: entity.title,
      isCompleted: entity.isCompleted,
    );
  }
}
```

---

## 3. QUY TRÌNH 5 BƯỚC THÊM 1 CHỨC NĂNG MỚI (STEP-BY-STEP)

Giả sử cần thêm chức năng quản lý **Task (Công việc)**:

### 🔹 BƯỚC 1: Xây Dựng Tầng Domain (`lib/domain/`)
1. **Tạo Entity (`lib/domain/entities/task.dart`)**:
   ```dart
   class Task {
     final int id;
     final String title;
     final bool isCompleted;

     const Task({required this.id, required this.title, required this.isCompleted});
   }
   ```
2. **Tạo Repository Interface (`lib/domain/repositories/task_repository.dart`)**:
   ```dart
   abstract class TaskRepository {
     Future<List<Task>> getTasks();
     Future<void> createTask(String title);
   }
   ```
3. **Tạo UseCases (`lib/domain/usecases/task/get_tasks_usecase.dart`)**:
   ```dart
   class GetTasksUseCase implements UseCase<List<Task>> {
     final TaskRepository repository;
     GetTasksUseCase(this.repository);

     @override
     Future<List<Task>> execute() => repository.getTasks();
   }
   ```

### 🔹 BƯỚC 2: Xây Dựng Tầng Data (`lib/data/`)
1. **Tạo DTO**:
   - `lib/data/dto/task/task_response_dto.dart` (có parser `fromJson`)
2. **Tạo Mapper**:
   - `lib/data/mapper/task_mapper.dart` (chứa `toEntity`, `toDto`)
3. **Tạo Remote DataSource**:
   - Interface: `lib/data/datasource/remote/abstract/task_remote_datasource.dart`
   - Implementation: `lib/data/datasource/remote/implement/task_remote_datasource_impl.dart`
4. **Tạo Repository Implementation (`lib/data/repositories/task_repository_impl.dart`)**:
   ```dart
   class TaskRepositoryImpl implements TaskRepository {
     final TaskRemoteDatasource remote;
     TaskRepositoryImpl(this.remote);

     @override
     Future<List<Task>> getTasks() async {
       final dtos = await remote.getTasks();
       return dtos.map((dto) => TaskMapper.toEntity(dto)).toList();
     }

     @override
     Future<void> createTask(String title) async {
       await remote.createTask(title);
     }
   }
   ```

### 🔹 BƯỚC 3: Đăng Ký DI Trong `lib/app/provider.dart`
1. Khai báo endpoint trong `lib/app/consts/app_config.dart`.
2. Đăng ký các Provider trong `lib/app/provider.dart`:

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

### 🔹 BƯỚC 4: Xây Dựng Tầng Presentation UI (`lib/ui/screen/task/`)
Tạo thư mục `lib/ui/screen/task/`:
1. **State (`task_vm/task_state.dart`)**:
   ```dart
   class TaskState {
     final bool isLoading;
     final List<Task> tasks;
     final AppException? error;

     const TaskState({this.isLoading = false, this.tasks = const [], this.error});

     TaskState copyWith({bool? isLoading, List<Task>? tasks, AppException? error}) {
       return TaskState(
         isLoading: isLoading ?? this.isLoading,
         tasks: tasks ?? this.tasks,
         error: error,
       );
     }
   }
   ```
2. **ViewModel (`task_vm/task_vm.dart`)**:
   ```dart
   final taskViewModelProvider = StateNotifierProvider<TaskViewModel, TaskState>((ref) {
     return TaskViewModel(ref.watch(getTasksUseCaseProvider));
   });

   class TaskViewModel extends StateNotifier<TaskState> {
     final GetTasksUseCase getTasksUseCase;
     TaskViewModel(this.getTasksUseCase) : super(const TaskState());

     Future<void> loadTasks() async {
       state = state.copyWith(isLoading: true, error: null);
       try {
         final tasks = await getTasksUseCase.execute();
         state = state.copyWith(isLoading: false, tasks: tasks);
       } on AppException catch (e) {
         state = state.copyWith(isLoading: false, error: e);
       }
     }
   }
   ```
3. **Screen & Responsive Widgets**:
   - `task_screen.dart`: Sử dụng `ResponsiveLayout(mobile: TaskMobile(), tablet: TaskTablet())`.
   - `widgets/task_mobile.dart` & `widgets/task_tablet.dart`.

### 🔹 BƯỚC 5: Đa Ngôn Ngữ & Xử Lý Lỗi
1. Thêm key vào `lib/l10n/app_vi.arb` & `app_en.arb`.
2. Trên UI, hiển thị lỗi qua extension: `state.error?.getDisplayMessage(context.l10n)`.

---

## 4. QUẢN LÝ TRẠNG THÁI (STATE MANAGEMENT & DI)

- **Riverpod StateNotifier**: Dùng cho quản lý state có logic phức tạp / bất đồng bộ trong ViewModel.
- **Riverpod StateProvider**: Dùng cho state đơn giản (ví dụ: `homeTabProvider`, `authTokenProvider`).
- **Riverpod Provider**: Dùng để tiêm phụ thuộc (DI) cho Dio, DataSource, Repository, UseCase.

---

## 5. XỬ LÝ LỖI TẬP TRUNG & ĐA NGÔN NGỮ

- **`AppException`**: Ngoại lệ cơ sở trong Domain Layer, không chứa text cứng mà có phương thức `resolve(IAppMessages)`.
- **`AppExceptionHandler`**: Chuyển đổi lỗi Dio / Socket / Timeout thành `AppException` cụ thể tại DataSource.
- **`context.l10n`**: Lấy nhãn đa ngôn ngữ an toàn kiểu dữ liệu (Type-safe).
