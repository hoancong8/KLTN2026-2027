---
trigger: glob
globs: "lib/ui/**, lib/widget/**, lib/app/theme/**"
description: "Quy chuẩn bắt buộc xây dựng giao diện dựa trên Design Tokens (context.colors / AppThemeColors, AppTypography, AppSpacing, AppRadius, AppShadows, AppTheme), đồng bộ Light/Dark Theme, chuẩn UI/UX WCAG và bắt buộc sử dụng context.l10n."
---

# Quy Chuẩn Bắt Buộc Áp Dụng Design Tokens & Theming Chuẩn UI/UX

> [!IMPORTANT]
> Toàn bộ AI Agent và kỹ sư phần mềm khi xây dựng, chỉnh sửa hoặc tối ưu hóa giao diện (Screens, Widgets, Dialogs, BottomSheets, Cards) trong dự án **KLTN2026-2027** bắt buộc phải tuân thủ triệt để hệ thống **Design Tokens** tập trung tại `lib/app/theme/` (thông qua barrel `package:kltn2026_2027/app/theme/theme.dart`).
> Nghiêm cấm hoàn toàn việc tự tiện hardcode mã màu hex, dùng màu ad-hoc của Flutter (`Colors.*`), font size tự phát, khoảng cách hoặc bo góc tùy tiện, và hardcode chuỗi ngôn ngữ không thông qua `context.l10n`.

---

## 1. Bản Đồ Hệ Thống Design Tokens (`lib/app/theme/`)

```
lib/app/theme/
├── app_colors.dart       # AppColors (Brand, Neutral Slate, Sports) & AppThemeColors (ThemeExtension adaptive Light/Dark)
├── app_typography.dart   # Thang tỉ lệ font chuẩn Material 3 Display, Headline, Title, Body, Label & AppTextStyleExtension
├── app_spacing.dart      # Thang 8-point grid chuẩn, Insets, gapW*, gapH*, Icon & Component Dimensions
├── app_radius.dart       # Bo góc AppRadius (xs..full, card, dialog, bottomSheet, input, button, chip)
├── app_shadows.dart      # Đổ bóng AppShadows (sm..xl, bottomBar, primaryGlow, colored)
├── app_theme.dart        # Cấu hình Material 3 ThemeData hoàn chỉnh cho cả Light và Dark
└── theme.dart            # Barrel file export toàn bộ hệ thống Tokens
```

---

## 2. Các Điều Cấm Tuyệt Đối (Strictly Forbidden Invariants)

1. **CẤM hardcode mã màu Hex rải rác trong UI:**
   - ❌ `color: Color(0xFF3CC18E)` hoặc `backgroundColor: Color(0xFFF8FAFC)`
   - ✅ Dùng `context.colors.primary` hoặc `context.colors.background` (hoặc hằng số tĩnh `AppColors.primary` nếu là màu brand cố định).

2. **CẤM dùng màu `Colors.*` mặc định ad-hoc của framework:**
   - ❌ `Colors.white`, `Colors.black`, `Colors.transparent`, `Colors.blue`, `Colors.green`, `Colors.grey[300]`, `Colors.orange`
   - ✅ Dùng token:
     + Trong suốt: `AppColors.transparent`
     + Trắng/Đen cố định: `AppColors.white`, `AppColors.black`
     + Màu theo ngữ cảnh theme: `context.colors.surface`, `context.colors.cardBackground`, `context.colors.textPrimary`, `context.colors.border`, `context.colors.warning`, `context.colors.info`.

3. **CẤM hardcode màu tĩnh sáng trên các thành phần UI động (Gây lỗi tàng hình / chói lóa trong Dark Mode):**
   - ❌ `color: AppColors.textPrimary` (Màu tĩnh `#0F172A` - trong Dark Mode sẽ biến thành chữ đen trên nền tối khiến người dùng không đọc được!)
   - ❌ `color: AppColors.surface` (Màu tĩnh `#FFFFFF` - trong Dark Mode sẽ thành mảng trắng chói lòa phá vỡ giao diện tối!)
   - ✅ Luôn sử dụng Theme-Adaptive Tokens qua context:
     ```dart
     color: context.colors.textPrimary   // Light: Slate 900 (#0F172A) | Dark: Slate 50 (#F8FAFC)
     color: context.colors.textSecondary // Light: Slate 600 (#475569) | Dark: Slate 400 (#94A3B8)
     color: context.colors.surface       // Light: Pure White (#FFFFFF) | Dark: Slate Card (#162032)
     color: context.colors.cardBackground// Tự động thích ứng 100%
     color: context.colors.border        // Light: Slate 200 (#E2E8F0) | Dark: Slate 700 (#334155)
     ```

4. **CẤM tự tạo TextStyle với font size / font weight ngẫu nhiên:**
   - ❌ `TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)`
   - ✅ `AppTypography.titleSmall` hoặc `context.textTheme.titleSmall` kết hợp tiện ích mở rộng fluent:
     ```dart
     AppTypography.titleMedium.bold.colored(context.colors.primary)
     ```

5. **CẤM tự gõ SizedBox hoặc Padding với số liệu tùy hứng:**
   - ❌ `SizedBox(height: 16)` hoặc `SizedBox(width: 8)`
   - ✅ `AppSpacing.gapH16` hoặc `AppSpacing.gapW8`
   - ❌ `padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12)`
   - ✅ `padding: AppSpacing.horizontalBase` kết hợp `AppSpacing.verticalMd` (hoặc `AppSpacing.screen`)

6. **CẤM tự định nghĩa BorderRadius lặp lại:**
   - ❌ `borderRadius: BorderRadius.circular(16)` (cho Card)
   - ✅ `borderRadius: AppRadius.card` (hoặc `AppRadius.borderLg`)
   - ❌ `borderRadius: BorderRadius.vertical(top: Radius.circular(24))` (cho BottomSheet)
   - ✅ `borderRadius: AppRadius.bottomSheet`

7. **CẤM tự dựng BoxShadow inline thiếu chuẩn mực:**
   - ❌ `boxShadow: [BoxShadow(color: Colors.black.withAlpha(25), blurRadius: 8)]`
   - ✅ `boxShadow: AppShadows.md` (hoặc `AppShadows.primaryGlow()` cho CTA chính).

8. **CẤM hardcode chuỗi người dùng nhìn thấy trong UI (Phá vỡ tính năng Đa ngôn ngữ):**
   - ❌ `Text('Chào mừng trở lại!')` hoặc `Text('Đăng nhập thất bại')`
   - ✅ `Text(context.l10n.com_welcome_back)` hoặc `Text(context.l10n.auth_login_failed)`

---

## 3. Hệ Thống Màu Thích Ứng Light / Dark (`AppThemeColors`)

| Semantic Token | Light Mode (Trang nhã, rõ ràng) | Dark Mode (OLED Slate, chống mỏi mắt) | Chuẩn tương phản WCAG |
| :--- | :--- | :--- | :--- |
| `context.colors.background` | Slate 50 (`#F8FAFC`) | Deep Slate (`#0B1220`) | Chuẩn nền chính |
| `context.colors.surface` / `cardBackground` | Pure White (`#FFFFFF`) | Slate Card (`#162032`) | Tách lớp rõ ràng (>10% lightness) |
| `context.colors.surfaceSubtle` / `inputFill` | Slate 100 (`#F1F5F9`) | Slate Input (`#1E293B`) | Nền ô nhập, thanh tìm kiếm |
| `context.colors.textPrimary` | Slate 900 (`#0F172A`) | Slate 50 (`#F8FAFC`) | **WCAG AAA** (Contrast > 13.5:1) |
| `context.colors.textSecondary` | Slate 600 (`#475569`) | Slate 400 (`#94A3B8`) | **WCAG AAA** (Contrast > 6.8:1) |
| `context.colors.textMuted` | Slate 500 (`#64748B`) | Slate 500 (`#64748B`) | **WCAG AA** (Contrast > 3.8:1) |
| `context.colors.border` | Slate 200 (`#E2E8F0`) | Slate 700 (`#334155`) | Đường viền thanh thoát |
| `context.colors.borderSubtle` | Slate 100 (`#F1F5F9`) | Slate 800 (`#1E293B`) | Đường viền ngăn cách phụ |
| `context.colors.divider` | Slate 200 (`#EAEAEA`) | Slate 800 (`#1E293B`) | Dải phân cách |
| `context.colors.primary` | Mint Green (`#3CC18E`) | Mint Green (`#3CC18E`) | Màu nhận diện thương hiệu |
| `context.colors.primaryContainer` | Mint Subtle (`#E8F9F3`) | Deep Mint (`#0F5A40`) | Active tab, Chip đã chọn |
| `context.colors.onPrimaryContainer` | Dark Mint (`#0F5A40`) | Light Mint (`#A7F3D0`) | Chữ/icon trong container |
| `context.colors.secondary` | Ocean Sky (`#0EA5E9`) | Sky Blue (`#38BDF8`) | Nút phụ, điểm nhấn liên kết |
| `context.colors.accent` | Warm Amber (`#FFA61E`) | Amber Gold (`#FBBF24`) | MVP, điểm đánh giá, xếp hạng |
| `context.colors.success` | Emerald (`#10B981`) | Emerald Light (`#34D399`)| Trạng thái thành công |
| `context.colors.warning` | Amber (`#F59E0B`) | Amber Light (`#FBBF24`) | Cảnh báo, chờ duyệt |
| `context.colors.error` | Crimson (`#EF4444`) | Crimson Light (`#F87171`)| Báo lỗi, hủy buổi chơi |
| `context.colors.info` | Blue (`#3B82F6`) | Sky Blue (`#60A5FA`) | Thông báo, hướng dẫn |

---

## 4. Kiểu Chữ (`AppTypography` & Fluent Extension)

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
> AppTypography.titleMedium.bold.colored(context.colors.primary)
> AppTypography.bodySmall.underlined.withOpacity(0.7)
> ```

---

## 5. Khoảng Cách & Bo Góc (`AppSpacing` & `AppRadius`)

- **Thang Spacing 8-point:**
  + `xs` (4dp), `sm` (8dp), `md` (12dp), `base` (16dp), `lg` (20dp), `xl` (24dp), `xxl` (32dp), `xxxl` (40dp).
  + Gaps chiều ngang: `AppSpacing.gapW4`, `AppSpacing.gapW8`, `AppSpacing.gapW12`, `AppSpacing.gapW16`, `AppSpacing.gapW24`, `AppSpacing.gapW32`.
  + Gaps chiều dọc: `AppSpacing.gapH4`, `AppSpacing.gapH8`, `AppSpacing.gapH12`, `AppSpacing.gapH16`, `AppSpacing.gapH24`, `AppSpacing.gapH32`, `AppSpacing.gapH48`.
- **Bo góc chuẩn:**
  + Card / Container chính: `AppRadius.card` (16dp)
  + Modal Dialog: `AppRadius.dialog` (20dp)
  + BottomSheet: `AppRadius.bottomSheet` (top 24dp)
  + Button / Text Field: `AppRadius.button` / `AppRadius.input` (12dp)
  + Tag / Chip: `AppRadius.chip` (8dp)

---

## 6. Mẫu Code Chuẩn (Best Practice Template)

### Dựng Card Thông Tin Thích Ứng Cả Light & Dark Theme:
```dart
Container(
  padding: AppSpacing.card,
  decoration: BoxDecoration(
    color: context.colors.cardBackground,
    borderRadius: AppRadius.card,
    border: Border.all(color: context.colors.cardBorder),
    boxShadow: context.isDark ? AppShadows.none : AppShadows.sm,
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        context.l10n.club_sessions,
        style: AppTypography.titleMedium.copyWith(color: context.colors.textPrimary),
      ),
      AppSpacing.gapH8,
      Text(
        session.title,
        style: AppTypography.bodyMedium.copyWith(color: context.colors.textSecondary),
      ),
    ],
  ),
)
```

---

## 7. Quy Trình Kiểm Thử & Xác Minh Bắt Buộc

Trước khi hoàn thành công việc:
1. File có import chuẩn: `import 'package:kltn2026_2027/app/theme/theme.dart';`.
2. Không còn mã màu hex trực tiếp (`Color(0xFF...)`) ngoài `app_colors.dart`.
3. Không sử dụng `Colors.*` thô từ Flutter material package.
4. Chạy kiểm tra kiến trúc và Design Tokens:
   ```powershell
   python .agents/skills/verify-architecture/scripts/verify_architecture.py
   ```
5. Chạy phân tích tĩnh và unit tests:
   ```powershell
   cd KLTN2026-2027; flutter analyze
   cd KLTN2026-2027; flutter test
   ```
   Đảm bảo 100% tests pass và zero analyzer issues.
