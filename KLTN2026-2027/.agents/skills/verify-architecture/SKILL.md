---
name: verify-architecture
description: >-
  Verify Clean Architecture boundaries, layer purity (Domain, Data, UI), defensive DTO parsing, zero-emoji policy, and run flutter analyze & flutter test in KLTN2026-2027. Use before completing any feature, bug fix, or refactor to guarantee full architectural compliance.
---

# Flutter Architecture & Quality Verification

## Goal (Single Responsibility)
Thực thi kiểm tra tĩnh toàn diện, thẩm định ranh giới Clean Architecture 3 tầng, rà soát defensive parsing trong DTO, quy chuẩn token màu sắc và thực thi kiểm thử tự động đảm bảo 100% tuân thủ quy chuẩn dự án trước khi commit.

---

## Ma Trận Phân Công Subagents Trong Kiểm Toán Chất Lượng

| Tác Vụ Cụ Thể | Subagent Đảm Nhiệm | Rào Chắn & Trách Nhiệm Bắt Buộc |
|---|---|---|
| **Chạy kiểm toán độc lập & rà soát vi phạm ranh giới** | [`code-integrity-auditor`](.agents/agents/code-integrity-auditor.md) | Chạy verify_architecture.py, flutter analyze, flutter test. Cấm tự ý sửa code. |
| **Tiếp nhận lỗi kiến trúc & khắc phục triệt để** | [`feature-engineer`](.agents/agents/feature-engineer.md) | Nhận báo cáo từ auditor, sửa lỗi ranh giới, sửa lỗi parser DTO, fix test failing. |
| **Đánh giá lại rủi ro nếu có thay đổi cấu trúc lớn** | [`architecture-evaluator`](.agents/agents/architecture-evaluator.md) | Thẩm định lại nếu việc sửa lỗi làm thay đổi hợp đồng abstractions giữa các tầng. |

---

## Decision Tree: Phân Loại Lỗi & Hướng Xử Lý

```text
Chạy bộ công cụ kiểm toán verify_architecture.py
  │
  ├── 1. Vi phạm ranh giới Clean Architecture (Boundary Violation)?
  │      ├── Domain import flutter/dio/dto: Chuyển class sang Data hoặc dùng package:meta.
  │      ├── UI import dio/datasource/dto: Thay bằng UseCase hoặc ViewModel StateNotifier.
  │      └── Datasource không kế thừa BaseRemoteDatasource: Kế thừa và dùng handleResponse().
  │
  ├── 2. Vi phạm Defensive Parsing trong DTO?
  │      ├── Ép kiểu thô json['key'] as int: Thay bằng helper _parseInt(json['key']).
  │      ├── DateTime.parse(...) không an toàn: Thay bằng DateTime.tryParse(...).
  │      └── Thiếu xử lý null cho List: Dùng (json['items'] as List?)?.map(...) ?? [].
  │
  ├── 3. Vi phạm Design Tokens & Theming?
  │      ├── Hardcode mã hex ngoài app_colors.dart: Chuyển mã hex vào AppColors và dùng qua AppThemeColors.
  │      ├── Dùng raw Flutter Colors.* (Colors.white, Colors.black): Thay bằng context.colors.*.
  │      └── Màn hình thiếu ResponsiveLayout: Bọc màn hình bằng ResponsiveLayout(mobile: ..., tablet: ...).
  │
  ├── 4. Lỗi Phân Tích Tĩnh (flutter analyze có cảnh báo/lỗi)?
  │      ├── Dead code, unused import: Dọn dẹp import thừa.
  │      └── Missing required parameters / type mismatch: Khắc phục theo đúng type system.
  │
  └── 5. Kiểm thử tự động thất bại (flutter test failing)?
         ├── Lỗi Mock / Provider: Cập nhật mock ProviderScope trong test.
         └── Lỗi logic nghiệp vụ: Sửa logic trong UseCase / ViewModel cho đúng spec.
```

---

## Bộ Công Cụ CLI Black-Box (Black-Box Tooling)

> [!IMPORTANT]
> **Sử Dụng Scripts Dạng Black-Box:** Không cần đọc mã nguồn Python vào context. Chạy trực tiếp từ CLI:

1. **Quét Vi Phạm Ranh Giới Kiến Trúc, DTO Parsing & Tokens:**
   ```powershell
   python .agents/skills/verify-architecture/scripts/verify_architecture.py
   ```
   *(Bao gồm: Kiểm tra Domain Purity, Data BaseRemoteDatasource, UI Isolation, Defensive DTO Parsing, Design Tokens, và Zero Emoji).*

2. **Kiểm Tra Phân Tích Tĩnh Flutter Linter:**
   ```powershell
   flutter analyze
   ```
   *(Bắt buộc đạt `No issues found!` trước khi nghiệm thu).*

3. **Chạy Toàn Bộ Unit & Widget Tests:**
   ```powershell
   flutter test
   ```
   *(Bắt buộc 100% tests passed).*

---

## Quy Trình Phối Hợp Subagents Từng Bước (Verify-Fix Loop)

1. **Bước 1:** Ủy thác [`code-integrity-auditor`](.agents/agents/code-integrity-auditor.md) chạy bộ công cụ xác thực (Script Python $\rightarrow$ `flutter analyze` $\rightarrow$ `flutter test`).
2. **Bước 2:** Nếu phát hiện lỗi `[CRITICAL RISK]` hoặc `[ARCHITECTURAL VIOLATION]`, auditor xuất trình danh sách file lỗi kèm nguyên nhân kỹ thuật chi tiết.
3. **Bước 3:** Ủy thác [`feature-engineer`](.agents/agents/feature-engineer.md) sửa chữa các tệp vi phạm.
4. **Bước 4:** Ủy thác [`code-integrity-auditor`](.agents/agents/code-integrity-auditor.md) quét lại lần 2. Tối đa 2 vòng lặp verify-fix trước khi báo cáo kết quả cho người dùng.

---

## References & Troubleshooting
- [Checklist Kiến Trúc](./references/architecture_checklist.md)
- [Hướng Dẫn Khắc Phục Lỗi Phổ Biến](./examples/troubleshooting_fixes.md)
