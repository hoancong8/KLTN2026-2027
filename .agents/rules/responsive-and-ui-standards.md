---
trigger: glob
globs: "lib/ui/**"
description: "Quy chuẩn kiến trúc Presentation Layer, cấu trúc ResponsiveLayout (Mobile & Tablet), StateNotifier ViewModel, đa ngôn ngữ l10n và cấm hardcode UI."
---

# Quy Chuẩn Tầng Giao Diện (Presentation Layer) & Responsive Design

> [!IMPORTANT]
> Toàn bộ các màn hình chính trong ứng dụng di động KLTN2026-2027 phải hỗ trợ mượt mà cả hai kích thước hiển thị: **Điện thoại (Mobile)** và **Máy tính bảng (Tablet)**, đồng thời tuân thủ triệt để mô hình quản lý trạng thái bằng Riverpod `StateNotifier`.

---

## 1. Cấu Trúc Thư Mục Chuẩn Cho Một Feature Màn Hình

Mỗi màn hình nằm trong `lib/ui/screen/<feature_name>/` theo cấu trúc:

```
lib/ui/screen/<feature_name>/
├── <feature>_screen.dart          # Entrypoint màn hình, định tuyến GoRouter, ResponsiveLayout
├── <feature>_vm/
│   ├── <feature>_state.dart       # State class immutable, copyWith, AppException? error
│   └── <feature>_vm.dart          # StateNotifier ViewModel, tương tác UseCase
└── widgets/
    ├── <feature>_mobile.dart      # Layout tối ưu cho màn hình điện thoại
    ├── <feature>_tablet.dart      # Layout tối ưu cho màn hình máy tính bảng (chia 2 cột, master-detail)
    └── <feature>_card.dart        # Các thành phần con dùng chung
```

---

## 2. Chuẩn Mực ResponsiveLayout

Màn hình entrypoint bắt buộc dùng `ResponsiveLayout` để phân tách giao diện Mobile và Tablet:

```dart
class ClubDetailScreen extends ConsumerWidget {
  final String clubId;
  const ClubDetailScreen({super.key, required this.clubId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ResponsiveLayout(
      mobile: ClubDetailMobile(clubId: clubId),
      tablet: ClubDetailTablet(clubId: clubId),
    );
  }
}
```

- **Quy tắc Tablet:** Tận dụng không gian rộng để hiển thị song song danh sách và chi tiết (Master-Detail) hoặc chia lưới Grid nhiều cột thay vì chỉ phóng to giao diện Mobile.
- **Quy tắc Mobile:** Danh sách cuộn dọc, BottomSheet hoặc điều hướng Route mới cho chi tiết.

---

## 3. Quy Tắc Viết State & ViewModel (Riverpod StateNotifier)

### 3.1 State Class (`<feature>_state.dart`):
1. Bắt buộc là class **Immutable** với hàm khởi tạo `const`.
2. Có hàm `copyWith` để cập nhật trạng thái an toàn.
3. Luôn có các trường trạng thái cơ bản: `bool isLoading`, `AppException? error`.

```dart
class ClubListState {
  final bool isLoading;
  final List<Club> clubs;
  final AppException? error;

  const ClubListState({
    this.isLoading = false,
    this.clubs = const [],
    this.error,
  });

  ClubListState copyWith({
    bool? isLoading,
    List<Club>? clubs,
    AppException? error,
  }) {
    return ClubListState(
      isLoading: isLoading ?? this.isLoading,
      clubs: clubs ?? this.clubs,
      error: error,
    );
  }
}
```

### 3.2 ViewModel Class (`<feature>_vm.dart`):
1. Kế thừa `StateNotifier<State>`.
2. **CẤM nhận `BuildContext` vào ViewModel**. ViewModel phải độc lập với vòng đời UI của Flutter để dễ dàng viết unit test.
3. Nhận UseCases qua constructor từ Riverpod DI:

```dart
final clubListViewModelProvider =
    StateNotifierProvider.autoDispose<ClubListViewModel, ClubListState>((ref) {
  return ClubListViewModel(ref.watch(getClubsUseCaseProvider));
});

class ClubListViewModel extends StateNotifier<ClubListState> {
  final GetClubsUseCase _getClubsUseCase;

  ClubListViewModel(this._getClubsUseCase) : super(const ClubListState()) {
    loadClubs();
  }

  Future<void> loadClubs() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final items = await _getClubsUseCase.execute();
      state = state.copyWith(isLoading: false, clubs: items);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: UnknownAppException(e.toString()));
    }
  }
}
```

---

## 4. Quy Chuẩn Đa Ngôn Ngữ & Hiển Thị Lỗi

1. **CẤM hardcode chuỗi hiển thị tiếng Việt / tiếng Anh trực tiếp trong Widget**:
   - ❌ `Text('Chào mừng bạn đến với CLB Cầu Lông');`
   - ✅ `Text(context.l10n.welcomeMessage);`
2. **Hiển thị lỗi thông qua `AppException`:**
   - ❌ `Text(state.error.toString());`
   - ✅ `Text(state.error?.getDisplayMessage(context.l10n) ?? context.l10n.unknownError);`
3. **Màu sắc và Kiểu dáng:**
   - Sử dụng màu tập trung từ `AppColors` (hoặc `Theme.of(context)`). Không sử dụng mã màu hex tùy tiện rải rác trong code.
