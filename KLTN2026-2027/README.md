# KLTN2026-2027

Ứng dụng di động KLTN2026-2027 được phát triển bằng Flutter.

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

## ⚠️ Xử lý lỗi (Error Handling)

Dự án sử dụng hệ thống xử lý lỗi tập trung theo chuẩn **Clean Architecture**, tách biệt hoàn toàn logic nghiệp vụ (Domain) và thông báo giao diện (UI).

### 1. Thành phần chính
- **`AppException`** (Domain Layer): Lớp ngoại lệ cơ sở thuần Dart. Nó không chứa chuỗi văn bản cứng mà sử dụng phương thức `resolve(IAppMessages)` để quyết định thông báo lỗi.
- **`IAppMessages`** (Domain Layer): Một interface định nghĩa các "hợp đồng" thông báo lỗi mà Domain cần, đảm bảo Domain không phụ thuộc vào Flutter framework.
- **`FlutterAppMessages`** (Presentation Layer): Hiện thực (Implementation) của `IAppMessages`, sử dụng `AppLocalizations` để lấy chuỗi đã dịch.
- **`AppExceptionDisplayExt`** (Presentation Utils): Extension cung cấp hàm `getDisplayMessage(l10n)` giúp UI hiển thị lỗi một cách đơn giản.
- **`AppExceptionHandler`**: Bộ điều phối trung tâm, chuyển đổi các lỗi kỹ thuật (Dio, Socket) thành các `AppException` cụ thể.

### 2. Luồng xử lý
1. **Data Layer**: API trả về lỗi -> `BaseRemoteDatasource` bắt lỗi -> `AppExceptionHandler` mapping thành một subclass của `AppException` (ví dụ: `ConnectionException`).
2. **Domain Layer**: Exception được ném đi mà không mang theo bất kỳ phụ thuộc nào của Flutter.
3. **UI Layer**: 
   - ViewModel bắt Exception và lưu vào state.
   - UI gọi `error.getDisplayMessage(context.l10n)` để hiển thị thông báo.

### 3. Cách sử dụng

**Trong ViewModel:**
```dart
try {
  await repo.login(...);
} catch (e) {
  state = state.copyWith(error: e as AppException);
}
```

**Trong UI (Hiển thị lỗi):**
```dart
if (state.error != null) {
  // Sử dụng extension để lấy thông báo đã dịch
  final message = state.error!.getDisplayMessage(context.l10n);
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
```

**Khi thêm lỗi mới:**
1. Thêm getter vào `IAppMessages`.
2. Implement getter đó trong `FlutterAppMessages`.
3. Tạo subclass của `AppException` và override hàm `resolve`.

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


