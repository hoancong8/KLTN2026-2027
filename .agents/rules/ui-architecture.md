---
trigger: "lib/ui/**, lib/widget/**"
description: "Quy chuẩn tầng Presentation: ViewModel StateNotifier, ResponsiveLayout (Mobile & Tablet), Error Handling qua AppException, và Quốc tế hóa L10n context.l10n."
---

# Quy Chuẩn Tầng Giao Diện (UI Architecture & Presentation Standards)

Tài liệu định nghĩa các quy chuẩn kiến trúc bắt buộc cho tầng UI / Presentation của ứng dụng Flutter Mobile Client.

---

## 1. Ranh Giới Tầng Presentation
- Tầng UI (`lib/ui/`) chỉ giao tiếp với: ViewModels (`StateNotifier`), UseCases, và Entities.
- **Cấm kỵ:** Tuyệt đối cấm import hoặc tham chiếu tới `dio`, Remote Datasource, hoặc DTO.

---

## 2. Quản Lý Trạng Thái với Riverpod StateNotifier

Mọi màn hình hoặc luồng chức năng độc lập phải có ViewModel kế thừa `StateNotifier<TState>`.

### Invariants:
1. **State Bất Biến (@immutable):**
   - State phải là một class bất biến (`@immutable`).
   - Cung cấp phương thức `copyWith()` để cập nhật từng phần trạng thái mà không làm mất tính toàn vẹn dữ liệu.
   - Có cờ trạng thái rõ ràng: `isLoading`, `error` (`AppException?`), dữ liệu kết quả.
2. **ViewModel Tinh Gọn:**
   - ViewModel chỉ điều phối luồng: nhận action từ UI $\rightarrow$ gọi UseCase $\rightarrow$ cập nhật State.
   - Không chứa mã layout UI, không truy cập trực tiếp `BuildContext` trong logic nghiệp vụ.
   - Bắt ngoại lệ `AppException` và lưu vào `state = state.copyWith(error: appException)`.

---

## 3. Chuẩn Bố Cục Thích Ứng (ResponsiveLayout: Mobile & Tablet)

Mọi màn hình chính tại `lib/ui/screen/` bắt buộc hỗ trợ cả hai thiết bị Mobile và Tablet thông qua `ResponsiveLayout`:

```dart
class MyScreen extends ConsumerWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ResponsiveLayout(
        mobile: const MyMobileView(),
        tablet: const MyTabletView(),
      ),
    );
  }
}
```

### Quy tắc thiết kế Tablet:
- Tablet không được đơn giản là kéo dãn giao diện mobile ra toàn màn hình.
- Sử dụng bố cục 2 cột (Master-Detail, Form bên trái - Preview bên phải, hoặc Grid nhiều cột hơn) để tận dụng không gian rộng.
- Tách riêng component view: `MyMobileView` và `MyTabletView` đặt trong thư mục `widget/` của tính năng.

---

## 4. Quản Lý Lỗi Tập Trung & Đa Ngôn Ngữ (L10n)

### 4.1. Giải Quyết Thông Báo Lỗi Qua AppException
- Toàn bộ lỗi nghiệp vụ và kỹ thuật phải được bọc trong `AppException`.
- Khi hiển thị lỗi lên UI (qua SnackBar, Dialog hoặc ErrorBanner), giải quyết thông báo lỗi qua `context.l10n`:
  ```dart
  // ✅ ĐÚNG:
  final message = state.error?.getDisplayMessage(context.l10n) ?? context.l10n.unknownError;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  // ❌ SAI: Hardcode chuỗi lỗi
  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Có lỗi xảy ra!')));
  ```

### 4.2. Không Hardcode Chuỗi Ký Tự UI (Zero Hardcoded Strings)
- 100% text hiển thị trên giao diện phải đọc từ `context.l10n.<key>`.
- Mọi key mới phải được bổ sung đồng thời vào cả hai tệp:
  - `lib/l10n/app_vi.arb` (Tiếng Việt có dấu đầy đủ)
  - `lib/l10n/app_en.arb` (Tiếng Anh chuẩn)
- Cấm tình trạng lệch key giữa 2 file `.arb`.
