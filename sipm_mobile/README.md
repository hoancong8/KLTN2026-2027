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
│   │   ├── l10n_gen/          # 🤖 Code đa ngôn ngữ tự động (Generated)
│   │   ├── paging/            # Phân trang dữ liệu
│   │   │   ├── paged_results.dart
│   │   │   └── paging_cursor.dart
│   │   ├── app_config.dart    # Cấu hình môi trường (dev/prod)
│   │   ├── app_messages.dart  # Thông báo và message
│   │   ├── app_router.dart    # Định tuyến màn hình
│   │   ├── app_theme.dart     # Theme và styling
│   │   ├── localization_provider.dart # Quản lý ngôn ngữ
│   │   ├── mapper.dart        # Base mapper
│   │   ├── my_app.dart        # Widget gốc của app
│   │   ├── provider.dart      # Base provider
│   │   └── usecase.dart       # Base usecase
│   │
│   ├── l10n/                  # 🌍 File ngôn ngữ nguồn (.arb)
│   │   ├── app_en.arb
│   │   └── app_vi.arb
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

## 🌍 Đa ngôn ngữ (Localization)

Dự án sử dụng giải pháp chính thức của Flutter (`flutter_localizations`) kết hợp với thư viện `intl` để hỗ trợ đa ngôn ngữ một cách an toàn (Type-safe).

### 1. **Cách sử dụng**

Sử dụng trực tiếp qua `BuildContext` hoặc `WidgetRef` để lấy chuỗi đã dịch với đầy đủ gợi ý code:

**Trong Widget (UI):**
```dart
Text(context.l10n.login) // Tự động gợi ý key 'login'
```

**Trong Provider/Logic:**
```dart
final text = ref.l10n.loginSuccess;
```

### 2. **Cấu trúc tệp tin**
- **File nguồn**: Nằm tại `lib/l10n/` (định dạng `.arb` - JSON). Đây là nơi bạn thêm mới các nhãn dịch.
- **File tự gen**: Nằm tại `lib/app/l10n_gen/`. Các file này được Flutter tự động tạo ra, **không sửa bằng tay**.

### 3. **Thêm ngôn ngữ/nhãn mới**
1. Thêm key và nội dung vào `lib/l10n/app_vi.arb` và `lib/l10n/app_en.arb`.
2. Lưu file (IDE sẽ tự gen code) hoặc chạy lệnh:
   ```bash
   flutter gen-l10n
   ```

### 4. **Quản lý trạng thái**
Sử dụng `localizationProvider` để thay đổi ngôn ngữ. Khi ngôn ngữ thay đổi, toàn bộ giao diện sẽ cập nhật ngay lập tức.

## 📱 Giao diện đáp ứng (Responsive Design)

Ứng dụng được thiết kế để hiển thị tối ưu trên cả điện thoại (Mobile) và máy tính bảng (Tablet).

### 1. **Cấu trúc Screen tách biệt**
Để đảm bảo code sạch và dễ bảo trì, các màn hình phức tạp được tách thành các file riêng cho từng loại thiết bị:
- `feature_screen.dart`: File điều phối chính, sử dụng `ResponsiveLayout`.
- `widgets/feature_mobile.dart`: Giao diện tối ưu cho điện thoại (thường dùng Bottom Navigation).
- `widgets/feature_tablet.dart`: Giao diện tối ưu cho máy tính bảng (thường dùng Navigation Rail hoặc Split View).
- `widgets/feature_shared.dart`: Chứa các widget hoặc hằng số dùng chung cho cả hai loại thiết bị.

### 2. **ResponsiveLayout Widget**
Sử dụng widget `ResponsiveLayout` để tự động chuyển đổi giao diện dựa trên breakpoint (mặc định là 600dp):
```dart
return ResponsiveLayout(
  mobile: FeatureMobile(...),
  tablet: FeatureTablet(...),
);
```

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


