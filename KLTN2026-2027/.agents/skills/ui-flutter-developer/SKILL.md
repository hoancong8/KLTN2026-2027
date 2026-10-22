---
name: ui-flutter-developer
description: >-
  Comprehensive UI engineering skill for KLTN2026-2027 Presentation layer: ResponsiveLayout (Mobile & Tablet), Riverpod ViewModels (StateNotifier), Design Tokens (context.colors.* via AppThemeColors), WCAG AA compliance, and full localization (context.l10n). Use whenever creating, modifying, styling, updating, or refactoring UI features ONLY within UI/Presentation (not spanning Core), or when asked to 'phát triển ui', 'tạo màn hình', 'thêm widget', 'sửa giao diện', 'update ui', 'cập nhật giao diện', 'chỉnh responsive', 'hỗ trợ tablet', 'đổi theme', 'gắn l10n', 'thêm key đa ngôn ngữ'. Do NOT use for cross-layer Core+UI tasks (use feature-lifecycle instead) or Core backend logic (use core-clean-developer instead).
---

# KLTN UI Flutter Developer — Presentation, Responsive & Design Tokens

## Goal (Single Responsibility)
Quy trình kỹ thuật toàn diện để phát triển mới, cập nhật/mở rộng, sửa lỗi, tạo kiểu và kiểm tra chất lượng giao diện người dùng trong tầng Presentation ([`lib/ui/`](lib/ui), [`lib/widget/`](lib/widget), [`lib/app/theme/`](lib/app/theme), [`lib/l10n/`](lib/l10n)) tuân thủ Clean Presentation, Riverpod StateNotifier, ResponsiveLayout (Mobile & Tablet), 100% Design Tokens và không hardcode chuỗi ký tự.

---

## Ma Trận Phân Công Subagents Trong Phân Hệ UI

| Tác Vụ Cụ Thể | Subagent Đảm Nhiệm | Rào Chắn & Trách Nhiệm Bắt Buộc |
|---|---|---|
| **Tra cứu thiết kế màn hình, wireframe tại `docs/07`** | [`system-spec-inspector`](.agents/agents/system-spec-inspector.md) | Tra cứu [`docs/07_THIET_KE_CLIENT_FLUTTER_MOBILE.md`](docs/07_THIET_KE_CLIENT_FLUTTER_MOBILE.md). |
| **Đánh giá kiến trúc UI, điều phối StateNotifier** | [`architecture-evaluator`](.agents/agents/architecture-evaluator.md) | Lập Blueprint nếu thêm màn hình mới hoặc luồng điều hướng phức tạp. |
| **Trực tiếp viết mã Screens, Widgets, ViewModels, Themes** | [`feature-engineer`](.agents/agents/feature-engineer.md) | ResponsiveLayout, StateNotifier, token context.colors.*, context.l10n. |
| **Kiểm toán chất lượng UI, Dark Mode, tokens, l10n** | [`code-integrity-auditor`](.agents/agents/code-integrity-auditor.md) | Chặn raw Colors.*, chặn hardcoded hex, chặn text không qua context.l10n. |

---

## Decision Tree: Phân Loại Tác Vụ trong Phân Hệ UI

```text
Yêu cầu tác vụ liên quan đến tầng Giao Diện (UI / Presentation)
  │
  ├── 1. Thêm màn hình chức năng mới (Screen)?
  │      ├── Tạo Screen bọc ResponsiveLayout(mobile: ..., tablet: ...) trong lib/ui/screen/<feature>/.
  │      ├── Tạo MobileView và TabletView riêng biệt trong lib/ui/screen/<feature>/widget/.
  │      ├── Tạo ViewModel kế thừa StateNotifier<TState> trong lib/ui/screen/<feature>/viewmodel/.
  │      └── Đăng ký StateNotifierProvider trong lib/app/provider.dart.
  │
  ├── 2. Cập nhật / Mở rộng màn hình hiện có (Thêm nút, form input, danh sách hiển thị)?
  │      ├── Thêm state field vào State class (bất biến, copyWith).
  │      ├── Thêm action method vào ViewModel.
  │      └── Thêm widget vào MobileView & TabletView sử dụng token context.colors.*.
  │
  ├── 3. Hỗ trợ bố cục máy tính bảng (Tablet Layout)?
  │      └── Tận dụng màn hình rộng: Áp dụng bố cục 2 cột (Master-Detail / Form-Preview) hoặc Grid mở rộng; CẤM kéo giãn giao diện mobile.
  │
  ├── 4. Sửa lỗi màu sắc / Dark Mode không hiển thị chữ / Chói lóa?
  │      ├── Xóa toàn bộ raw Flutter Colors (Colors.white, Colors.black, Colors.blue).
  │      ├── Xóa mã màu hex rải rác ngoài app_colors.dart.
  │      └── Chuyển sang dùng theme-adaptive token: context.colors.surface, context.colors.textPrimary, context.colors.cardBackground.
  │
  └── 5. Bổ sung chuỗi ngôn ngữ hoặc sửa lỗi hardcoded string?
         ├── Bổ sung key vào cả 2 file: lib/l10n/app_vi.arb và lib/l10n/app_en.arb.
         └── Sử dụng trên UI qua context.l10n.<key>.
```

---

## Rào Chắn Bất Biến (UI Invariants)

1. **Zero UI Imports to Core:** Tầng UI (`lib/ui/`) tuyệt đối cấm import hoặc tham chiếu tới `dio`, Remote Datasource, hoặc DTO.
2. **StateNotifier Architecture:** Mọi logic màn hình phải gói gọn trong ViewModel kế thừa `StateNotifier<TState>`. State bất biến (`copyWith`).
3. **ResponsiveLayout Bắt Buộc:** Mọi màn hình chính tại `lib/ui/screen/` bắt buộc bọc `ResponsiveLayout(mobile: ..., tablet: ...)`.
4. **Zero Hex Outside `app_colors.dart` & Zero Raw `Colors.*`:** 100% màu sắc sử dụng qua token `context.colors.*` (`AppThemeColors`) hoặc token hằng số `AppColors.transparent`.
5. **Zero Hardcoded Strings:** 100% text giao diện đọc qua `context.l10n.*`, đồng bộ cả `app_vi.arb` và `app_en.arb`. Lỗi ánh xạ qua `AppException`.
