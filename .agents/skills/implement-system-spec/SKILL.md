---
name: implement-system-spec
description: >-
  Trace and align features against the Single Source of Truth in docs/07_THIET_KE_CLIENT_FLUTTER_MOBILE.md, docs_api_clean_arch.md, and ARCHITECTURE_RULES.md. Use whenever planning or implementing API integrations, checking endpoint contracts, DTO naming, or Riverpod Provider mapping in KLTN2026-2027.
---

# System Spec & API Alignment Tracer (Flutter Client)

## Goal (Single Responsibility)
Trace Functional Requirements (FR01 - FR23), Use Cases (UC01 - UC20), and API endpoints directly to Flutter Screens, ViewModels, Domain UseCases, and Data DTOs based on [07_THIET_KE_CLIENT_FLUTTER_MOBILE.md](file:///d:/l7TeamVN/KLTN2026-2027/docs/07_THIET_KE_CLIENT_FLUTTER_MOBILE.md).

---

## Black-Box Script Invocations

> [!IMPORTANT]
> **Use Scripts as Black Boxes:** Do NOT read or load the Python script source code into context. Run the CLI directly.

1. **Tra Cứu Chi Tiết Yêu Cầu Chức Năng (FR01 - FR23):**
   ```powershell
   python .agents/skills/implement-system-spec/scripts/trace_system_spec.py --fr {FR01..FR23}
   ```
   *(Ví dụ: `--fr FR04` cho chuyển đổi ngữ cảnh, `--fr FR09` cho đặt slot, `--fr FR12` cho điểm danh QR).*

2. **Tra Cứu Theo Use Case (UC01 - UC20):**
   ```powershell
   python .agents/skills/implement-system-spec/scripts/trace_system_spec.py --uc {UC01..UC20}
   ```
   *(Ví dụ: `--uc UC05` hoặc `--uc UC07`).*

3. **Tìm Kiếm Theo Từ Khóa Hoặc Màn Hình:**
   ```powershell
   python .agents/skills/implement-system-spec/scripts/trace_system_spec.py --search "<từ_khóa>"
   ```
   *(Ví dụ: `--search "QR"` hoặc `--search "session"`).*

4. **Liệt Kê Danh Sách Toàn Bộ 23 FR:**
   ```powershell
   python .agents/skills/implement-system-spec/scripts/trace_system_spec.py --list-fr
   ```

---

## References & Documentation
- [Thiết Kế Kiến Trúc Client Flutter Mobile](../../../docs/07_THIET_KE_CLIENT_FLUTTER_MOBILE.md)
- [Khảo Sát & 23 Yêu Cầu Chức Năng](../../../docs/02_KHAO_SAT_VA_YEU_CAU.md)
- [Phân Tích 20 Use Cases Chi Tiết](../../../docs/03_PHAN_TICH_HE_THONG_UC.md)
