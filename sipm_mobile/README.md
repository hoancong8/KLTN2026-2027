# SIPM Mobile

Ứng dụng di động SIPM được phát triển bằng Flutter.

## 📋 Yêu cầu hệ thống

- Flutter SDK >= 3.10.7
- Dart SDK >= 3.10.7
- Android Studio / VS Code
- Git

## 🚀 Cài đặt và chạy dự án

### 1. Clone dự án
```bash
git clone <repository-url>
cd sipm_mobile
```

### 2. Cài đặt dependencies
```bash
flutter pub get
```

### 3. Chạy ứng dụng

**Development:**
```bash
flutter run
```

**Production:**
```bash
flutter run --dart-define=ENV=prod
```

### 4. Build ứng dụng

**Android APK:**
```bash
flutter build apk --dart-define=ENV=prod
```

**iOS:**
```bash
flutter build ios --dart-define=ENV=prod
```

## 🏗️ Cấu trúc dự án

```
sipm_mobile/
├── lib/
│   ├── app/                    # 🔧 Cấu hình ứng dụng
│   │   ├── paging/            # Phân trang dữ liệu
│   │   │   ├── paged_results.dart
│   │   │   └── paging_cursor.dart
│   │   ├── app_config.dart    # Cấu hình môi trường (dev/prod)
│   │   ├── app_messages.dart  # Thông báo và message
│   │   ├── app_router.dart    # Định tuyến màn hình
│   │   ├── app_theme.dart     # Theme và styling
│   │   ├── mapper.dart        # Base mapper
│   │   ├── my_app.dart        # Widget gốc của app
│   │   ├── provider.dart      # Base provider
│   │   └── usecase.dart       # Base usecase
│   │
│   ├── data/                   # 💾 Tầng dữ liệu
│   │   ├── datasource/        # Nguồn dữ liệu
│   │   │   ├── local/         # Local storage (SharedPrefs, SQLite)
│   │   │   └── remote/        # API calls (Dio)
│   │   ├── dto/               # Data Transfer Objects
│   │   │   └── auth/          # DTO cho authentication
│   │   ├── mapper/            # Chuyển đổi DTO <-> Entity
│   │   │   └── auth_mapper.dart
│   │   └── repositories/      # Triển khai repository pattern
│   │       └── auth_repository_impl.dart
│   │
│   ├── domain/                 # 🧠 Tầng business logic
│   │   ├── entities/          # Thực thể nghiệp vụ
│   │   │   └── auth_token.dart
│   │   ├── exceptions/        # Custom exceptions
│   │   │   └── auth_exceptions.dart
│   │   ├── repositories/      # Interface repository
│   │   │   └── auth_repository.dart
│   │   └── usecases/          # Use cases (business rules)
│   │       ├── login_usecase.dart
│   │       └── login_with_otp_usecase.dart
│   │
│   ├── ui/                     # 🎨 Giao diện người dùng
│   │   └── screen/            # Các màn hình
│   │       ├── home/          # Màn hình chính
│   │       ├── login/         # Đăng nhập
│   │       └── otp/           # Xác thực OTP
│   │
│   └── main.dart              # Entry point của ứng dụng
│
├── assets/
│   └── images/                # Hình ảnh, icon
│
├── android/                   # Cấu hình Android
├── ios/                       # Cấu hình iOS
├── web/                       # Cấu hình Web
├── test/                      # Unit tests
└── pubspec.yaml              # Dependencies và metadata
```

## 🏛️ Kiến trúc Clean Architecture

Dự án áp dụng Clean Architecture với 3 tầng chính:

### 1. **Domain Layer** (Tầng nghiệp vụ)
- **Entities**: Các đối tượng nghiệp vụ cốt lõi
- **Use Cases**: Logic nghiệp vụ, quy tắc xử lý
- **Repository Interfaces**: Định nghĩa cách truy xuất dữ liệu
- **Exceptions**: Các ngoại lệ tùy chỉnh

### 2. **Data Layer** (Tầng dữ liệu)
- **Data Sources**: 
  - Remote: API calls qua Dio
  - Local: SharedPreferences, SQLite
- **DTOs**: Đối tượng truyền dữ liệu từ API
- **Mappers**: Chuyển đổi giữa DTO và Entity
- **Repository Implementations**: Triển khai repository interfaces

### 3. **UI Layer** (Tầng giao diện)
- **Screens**: Các màn hình của ứng dụng
- **Widgets**: Components tái sử dụng
- **Providers**: Quản lý state với Riverpod

## 📦 Dependencies chính

| Package | Mục đích | Version |
|---------|----------|---------|
| `flutter_riverpod` | State management | ^3.2.0 |
| `riverpod_annotation` | Code generation cho Riverpod | ^4.0.1 |
| `dio` | HTTP client cho API calls | ^5.9.0 |
| `go_router` | Navigation và routing | ^14.0.0 |
| `cupertino_icons` | iOS style icons | ^1.0.8 |

## 🔧 Quy tắc phát triển

### 1. **Naming Convention**
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/Functions: `camelCase`
- Constants: `UPPER_SNAKE_CASE`

### 2. **Folder Structure**
- Mỗi feature tạo folder riêng trong `ui/screen/`
- Mỗi screen có thể chứa: `screen.dart`, `provider.dart`, `widgets/`

### 3. **State Management**
- Sử dụng Riverpod cho state management
- Provider nên đặt trong file riêng `*_provider.dart`
- Sử dụng `riverpod_annotation` để generate code

### 4. **API Integration**
- Tất cả API calls phải qua Data Layer
- Sử dụng Dio interceptors cho logging và error handling
- DTOs phải có `fromJson()` và `toJson()`


