---
name: add-clean-feature
description: >-
  Scaffold or implement new Clean Architecture feature slices (Domain Entities, Repositories, UseCases, Data DTOs, Datasources, Mappers, Riverpod Providers, and UI Responsive Screens/ViewModels) in the KLTN2026-2027 Flutter application. Use whenever adding new mobile screens, use cases, API integrations, or refactoring existing modules.
---

# Clean Architecture Flutter Feature Builder & Scaffolder

## Goal (Single Responsibility)
Scaffold, implement, and validate new Flutter feature slices across all 3 Clean Architecture tiers (`Domain`, `Data`, `Presentation / UI`) and Riverpod DI, ensuring 100% boundary purity, defensive parsing, and responsive layout compliance.

---

## Decision Tree: Feature Slice Construction

```text
User asks to create a new feature, screen, or API integration in Flutter
  │
  ├── 1. Tra cứu đặc tả SSOT trong docs_api_clean_arch.md & docs_api.md:
  │      ├── Xác định Endpoint API, Query params, Request body & Response JSON.
  │      ├── Xác định Domain Entity & kiểu dữ liệu cần hiển thị trên UI.
  │      └── Xác định UseCase(s) cần tạo.
  │
  ├── 2. Scaffold Bộ Khung Tính Năng Mới:
  │      └── Chạy script: python .agents/skills/add-clean-feature/scripts/scaffold_clean_feature.py --name "<FeatureName>"
  │
  ├── 3. Triển khai Logic 5 Tầng:
  │      ├── Domain: Viết Entity (pure Dart, immutable), Repo Interface, UseCase.
  │      ├── Data: Hoàn thiện DTO (Defensive Parsing), Mapper, Remote Datasource (BaseRemoteDatasource), Repo Impl.
  │      ├── App DI: Đăng ký Datasource, Repo, UseCase, ViewModel trong lib/app/provider.dart.
  │      ├── UI: Thiết kế ViewModel (StateNotifier), Screen (ResponsiveLayout), Mobile & Tablet widgets.
  │      └── L10n: Bổ sung key ngôn ngữ trong lib/l10n/app_vi.arb và app_en.arb.
  │
  └── 4. Xác thực Tuân thủ Kiến trúc & Chạy Kiểm Thử:
         ├── python .agents/skills/add-clean-feature/scripts/scaffold_clean_feature.py --validate "<feature_path>"
         ├── flutter analyze
         └── flutter test
```

---

## Black-Box Script Invocations

> [!IMPORTANT]
> **Use Scripts as Black Boxes:** Do NOT read or load the Python script source code into context. Run the CLI directly.

1. **Khởi Tạo Bộ Khung Tính Năng Mới:**
   ```powershell
   python .agents/skills/add-clean-feature/scripts/scaffold_clean_feature.py --name "<FeatureName>"
   ```
   *(Ví dụ: `--name Tournament` hoặc `--name ClubMember`).*

2. **Kiểm Tra Ranh Giới Kiến Trúc Của Feature Vừa Tạo:**
   ```powershell
   python .agents/skills/add-clean-feature/scripts/scaffold_clean_feature.py --validate "lib/ui/screen/<feature_name>"
   ```

---

## References & Examples
- [Chi Tiết Quy Chuẩn Clean Architecture](./references/clean_architecture_conventions.md)
- [Ví Dụ Mẫu Một Lát Cắt Tính Năng](./examples/sample_feature_slice.md)
