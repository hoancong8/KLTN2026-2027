---
trigger: glob
globs: "lib/ui/**, lib/widget/**, lib/app/theme/**"
description: "Quy chuẩn bắt buộc xây dựng giao diện dựa trên Design Tokens (AppColors, AppTypography, AppSpacing, AppRadius, AppShadows, AppTheme), nghiêm cấm hardcode hex colors, arbitrary text styles, paddings/gaps tùy tiện."
---

# Quy Chuẩn Bắt Buộc Áp Dụng Design Tokens & Theming

> [!IMPORTANT]
> Toàn bộ AI Agent và kỹ sư phần mềm khi xây dựng, chỉnh sửa hoặc tối ưu hóa giao diện (Screens, Widgets, Dialogs, BottomSheets, Cards) trong dự án **KLTN2026-2027** bắt buộc phải tuân thủ triệt để hệ thống **Design Tokens** tập trung tại `lib/app/theme/` (hoặc thông qua barrel `package:kltn2026_2027/app/theme/theme.dart`). Nghiêm cấm hoàn toàn việc tự tiện hardcode mã màu hex, font size tự phát, khoảng cách hoặc bo góc tùy tiện.

---

## 1. Bản Đồ Hệ Thống Design Tokens (`lib/app/theme/`)

```
lib/app/theme/
├── app_colors.dart       # Brand (Emerald #3CC18E, Sky #0EA5E9), Semantic, Neutral Slate, Badminton Domain, Gradients
├── app_typography.dart   # Tỉ lệ font chuẩn Display, Headline, Title, Body, Label & AppTextStyleExtension
├── app_spacing.dart      # Thang 8-point grid, Insets, gapW*, gapH*, Icon & Component Dimensions
├── app_radius.dart       # Bo góc AppRadius (xs..full, card, dialog, bottomSheet, input, button)
├── app_shadows.dart      # Đổ bóng AppShadows (sm..xl, bottomBar, primaryGlow, colored)
├── app_theme.dart        # Cấu hình Material 3 ThemeData (Light & Dark)
└── theme.dart            # Barrel file export toàn bộ hệ thống Tokens
```

---

## 2. Các Điều Cấm Tuyệt Đối (Strictly Forbidden)

1. **CẤM hardcode mã màu Hex rải rác trong UI:**
   - ❌ `color: Color(0xFF3CC18E)` hoặc `backgroundColor: Color(0xFFF8FAFC)`
   - ✅ `color: AppColors.primary` hoặc `backgroundColor: AppColors.background`

2. **CẤM dùng màu mặc định ad-hoc của framework khi đã có Token tương ứng:**
   - ❌ `color: Colors.blue`, `color: Colors.green`, `color: Colors.grey[300]`, `color: Colors.black87`
   - ✅ `color: AppColors.secondary`, `color: AppColors.success`, `color: AppColors.border`, `color: AppColors.textPrimary`

3. **CẤM tự tạo TextStyle với font size / font weight ngẫu nhiên:**
   - ❌ `TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)`
   - ✅ `AppTypography.titleSmall` hoặc `AppTypography.bodyMedium.semiBold.colored(AppColors.textPrimary)`

4. **CẤM tự gõ SizedBox hoặc Padding với số liệu tùy hứng:**
   - ❌ `SizedBox(height: 16)` hoặc `SizedBox(width: 8)`
   - ✅ `AppSpacing.gapH16` hoặc `AppSpacing.gapW8`
   - ❌ `padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12)`
   - ✅ `padding: AppSpacing.horizontalBase` kết hợp `AppSpacing.verticalMd` (hoặc `AppSpacing.screen`)

5. **CẤM tự định nghĩa BorderRadius lặp lại:**
   - ❌ `borderRadius: BorderRadius.circular(16)` (cho Card)
   - ✅ `borderRadius: AppRadius.card` (hoặc `AppRadius.borderLg`)
   - ❌ `borderRadius: BorderRadius.vertical(top: Radius.circular(24))` (cho BottomSheet)
   - ✅ `borderRadius: AppRadius.bottomSheet`

6. **CẤM tự dựng BoxShadow inline thiếu chuẩn mực:**
   - ❌ `boxShadow: [BoxShadow(color: Colors.black.withAlpha(25), blurRadius: 8)]`
   - ✅ `boxShadow: AppShadows.md` (hoặc `AppShadows.primaryGlow()` cho CTA chính)

---

## 3. Quy Chuẩn Sử Dụng Chi Tiết Theo Từng Token

### 3.1 Màu sắc (`AppColors` / `AppColor`)

| Mục đích | Token Chuẩn | Giá trị / Mô tả |
| :--- | :--- | :--- |
| **Màu thương hiệu chính** | `AppColors.primary` | `#3CC18E` (Mint/Emerald green) |
| **Thương hiệu đậm/nhạt** | `AppColors.primaryDark` / `primaryLight` | `#2EA578` / `#55D4A2` |
| **Container / Nền hoạt động** | `AppColors.primaryContainer` | `#E8F9F3` (Active tab, chip nền nhẹ) |
| **Màu phụ / Điểm nhấn** | `AppColors.secondary` / `accent` | `#0EA5E9` (Sky) / `#FFA61E` (Amber) |
| **Trạng thái thành công** | `AppColors.success` / `successContainer` | `#10B981` / `#ECFDF5` |
| **Trạng thái cảnh báo** | `AppColors.warning` / `warningContainer` | `#F59E0B` / `#FFFBEB` |
| **Trạng thái lỗi / Nguy hiểm** | `AppColors.error` / `errorContainer` | `#EF4444` / `#FEF2F2` |
| **Nền trang chính** | `AppColors.background` | `#F8FAFC` (Slate neutral) |
| **Màu bề mặt Card / Modal** | `AppColors.surface` | `#FFFFFF` |
| **Đường viền / Ngăn cách** | `AppColors.border` / `divider` | `#E2E8F0` / `#EAEAEA` |
| **Chữ tiêu đề chính** | `AppColors.textPrimary` | `#0F172A` (Slate 900) |
| **Chữ phụ / Mô tả** | `AppColors.textSecondary` / `textMuted` | `#475569` / `#64748B` |
| **Sân cầu lông & Match** | `AppColors.courtGreen`, `statusOngoing`... | Chuyên biệt cho domain thể thao |

### 3.2 Kiểu chữ (`AppTypography` & Fluent Extension)

| Tên Style | Size / Weight | Trường hợp sử dụng |
| :--- | :--- | :--- |
| `AppTypography.displayLarge` | 32sp / Bold (w700) | Tỷ số trận đấu lớn, số liệu thống kê Hero |
| `AppTypography.headlineLarge` | 22sp / Bold (w700) | Tiêu đề màn hình chính, Modal banner lớn |
| `AppTypography.headlineMedium` | 20sp / SemiBold (w600) | Tiêu đề phân đoạn lớn, tên CLB chi tiết |
| `AppTypography.titleLarge` | 18sp / SemiBold (w600) | AppBar title, Card header chính |
| `AppTypography.titleMedium` | 16sp / SemiBold (w600) | Tiêu đề mục trong danh sách, Section title |
| `AppTypography.titleSmall` | 14sp / SemiBold (w600) | Form label, ListTile title nhỏ |
| `AppTypography.bodyLarge` | 16sp / Regular (w400) | Nội dung bài viết, điều khoản, mô tả dài |
| `AppTypography.bodyMedium` | 14sp / Regular (w400) | Văn bản đọc chính, phụ đề, nội dung form |
| `AppTypography.bodySmall` | 12sp / Regular (w400) | Ghi chú, chú thích phụ, thời gian |
| `AppTypography.labelLarge` | 14sp / SemiBold (w600) | Nút bấm (Button text), Tabs active |
| `AppTypography.labelMedium` | 12sp / Medium (w500) | Tag, Badge, Chips trạng thái |
| `AppTypography.labelSmall` | 10sp / Medium (w500) | Timestamp, Counter badge nhỏ |

> [!TIP]
> **Fluent Chaining:** Sử dụng các tiện ích mở rộng để tinh chỉnh trực tiếp mà không cần `copyWith`:
> ```dart
> AppTypography.titleMedium.bold.colored(AppColors.primary)
> AppTypography.bodySmall.underlined.withOpacity(0.7)
> ```

### 3.3 Khoảng cách & Kích thước (`AppSpacing`)

- **Giá trị:** `xs` (4), `sm` (8), `md` (12), `base` (16), `lg` (20), `xl` (24), `xxl` (32), `xxxl` (40), `x4l` (48), `x5l` (64).
- **Spacers theo chiều ngang:** `AppSpacing.gapW4`, `AppSpacing.gapW8`, `AppSpacing.gapW12`, `AppSpacing.gapW16`, `AppSpacing.gapW20`, `AppSpacing.gapW24`, `AppSpacing.gapW32`.
- **Spacers theo chiều dọc:** `AppSpacing.gapH4`, `AppSpacing.gapH8`, `AppSpacing.gapH12`, `AppSpacing.gapH16`, `AppSpacing.gapH20`, `AppSpacing.gapH24`, `AppSpacing.gapH32`, `AppSpacing.gapH40`, `AppSpacing.gapH48`, `AppSpacing.gapH64`.
- **Padding chuẩn:** `AppSpacing.screen` (16dp đều), `AppSpacing.card` (16dp), `AppSpacing.dialog` (24dp), `AppSpacing.bottomSheet`.
- **Icon chuẩn:** `AppSpacing.iconXs` (14), `iconSm` (18), `iconMd` (24), `iconLg` (32), `iconXl` (40).

### 3.4 Bo góc (`AppRadius`)

- **Theo kích thước:** `AppRadius.borderXs` (4dp), `borderSm` (8dp), `borderMd` (12dp), `borderLg` (16dp), `borderXl` (20dp), `borderXxl` (24dp), `borderFull` (999dp).
- **Theo thành phần:**
  - Card / Panel: `AppRadius.card` (16dp)
  - Dialog / Modal: `AppRadius.dialog` (20dp)
  - BottomSheet: `AppRadius.bottomSheet` (top 24dp)
  - Button / Input: `AppRadius.button` / `AppRadius.input` (12dp)
  - Chip / Tag: `AppRadius.chip` (8dp) / `AppRadius.tag` (6dp)

### 3.5 Đổ bóng (`AppShadows`)

- Đổ bóng nhẹ: `AppShadows.sm`
- Đổ bóng thẻ Card chuẩn: `AppShadows.md`
- Đổ bóng thực đơn / Popover: `AppShadows.lg`
- Đổ bóng Modal Dialog: `AppShadows.xl`
- Đổ bóng chân trang: `AppShadows.bottomBar`
- Phát sáng nút bấm chính: `AppShadows.primaryGlow()`

---

## 4. Bảng So Sánh Mẫu Code

### Trường hợp 1: Dựng Card hiển thị thông tin CLB / Buổi chơi

**❌ Vi phạm (Hardcode ad-hoc):**
```dart
Container(
  padding: const EdgeInsets.all(16.0),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(15.0),
    border: Border.all(color: Colors.grey.shade300),
    boxShadow: [
      BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
    ],
  ),
  child: Column(
    children: [
      Text('Sân Cầu Lông Số 1', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
      SizedBox(height: 8),
      Text('18:00 - 20:00', style: TextStyle(fontSize: 12, color: Colors.grey)),
    ],
  ),
)
```

**✅ Đúng chuẩn (Sử dụng Design Tokens):**
```dart
Container(
  padding: AppSpacing.card,
  decoration: BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppRadius.card,
    border: Border.all(color: AppColors.borderSubtle),
    boxShadow: AppShadows.md,
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Sân Cầu Lông Số 1', style: AppTypography.titleMedium),
      AppSpacing.gapH8,
      Text('18:00 - 20:00', style: AppTypography.bodySmall),
    ],
  ),
)
```

### Trường hợp 2: Dựng Nút Bấm / CTA

**❌ Vi phạm:**
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xFF3CC18E),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  ),
  onPressed: () {},
  child: Text('Đặt Sân Ngay', style: TextStyle(fontSize: 14)),
)
```

**✅ Đúng chuẩn:**
```dart
AppButtonCommon(
  text: context.l10n.bookCourtNow,
  type: AppButtonType.primary,
  size: AppButtonSize.medium,
  onPressed: () async => handleBooking(),
)
```

---

## 5. Quy Trình Kiểm Thử & Xác Minh Khi Thêm Sửa UI

Mỗi khi chỉnh sửa hoặc thêm mới Widget/Screen, phải đảm bảo:
1. File có import chuẩn: `import 'package:kltn2026_2027/app/theme/theme.dart';`.
2. Không còn mã màu hex trực tiếp (`Color(0xFF...)`) trong code UI.
3. Chạy lệnh phân tích tĩnh:
   ```powershell
   cd KLTN2026-2027; flutter analyze
   ```
4. Chạy kiểm tra bộ test tokens:
   ```powershell
   cd KLTN2026-2027; flutter test test/theme/design_tokens_test.dart
   ```
