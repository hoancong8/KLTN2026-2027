---
name: conventional-commits
description: >-
  Draft, validate, and suggest Conventional Commits v1.0.0 messages with accurate Vietnamese descriptions and Flutter-specific scopes (auth, club, session, booking, profile, admin, ui, data, domain, l10n, deps, rules, test). Use whenever preparing Git commits after completing code changes.
---

# Conventional Commits Assistant & Validator

## Goal (Single Responsibility)
Khởi tạo, định dạng và thẩm định thông điệp Git commit tuân thủ nghiêm ngặt đặc tả Conventional Commits v1.0.0, danh mục scopes chuẩn Flutter, tiêu đề tiếng Việt có dấu, rào chắn an toàn (Commit Safety Guardrail) và chính sách Zero Emoji.

---

## Ma Trận Phân Công Subagents Trong Quy Trình Commit

| Tác Vụ Cụ Thể | Subagent Đảm Nhiệm | Rào Chắn & Trách Nhiệm Bắt Buộc |
|---|---|---|
| **Kiểm toán chất lượng & xác nhận test pass trước commit** | [`code-integrity-auditor`](.agents/agents/code-integrity-auditor.md) | Xác nhận verify_architecture.py, flutter analyze và flutter test đạt 100% trước khi cho phép commit. |
| **Soạn thảo thông điệp commit chuẩn Conventional Commits** | Main Agent / [`feature-engineer`](.agents/agents/feature-engineer.md) | Format `<type>(<scope>): <tiêu đề tiếng Việt có dấu>`, không emoji, không dấu chấm cuối. |
| **Phê duyệt đề xuất commit** | Người Dùng (User) | BẮT BUỘC người dùng xác nhận rõ ràng mới được chạy `git commit`. Cấm commit ngầm. |

---

## Decision Tree: Soạn Thảo & Thẩm Định Commit Message

```text
Chuẩn bị tạo commit Git cho các thay đổi vừa hoàn thành
  │
  ├── 1. Xác định Type của commit:
  │      ├── Tính năng mới / màn hình mới: feat
  │      ├── Sửa lỗi hiển thị UI / logic parser / bug: fix
  │      ├── Tái cấu trúc không đổi nghiệp vụ: refactor
  │      ├── Tối ưu hiệu năng rebuild / network: perf
  │      ├── Format code / import / linter warning: style
  │      ├── Thêm hoặc cập nhật unit / widget test: test
  │      └── Cập nhật tài liệu / markdown: docs
  │
  ├── 2. Xác định Scope cho dự án Flutter KLTN2026-2027:
  │      ├── auth, club, session, booking, profile, admin
  │      ├── ui (widgets, theme, responsive)
  │      ├── data (dto, datasource, mapper, repo impl)
  │      ├── domain (entity, usecase, repo interface)
  │      └── l10n, deps, rules, skills, test
  │
  ├── 3. Kiểm tra tính hợp lệ qua script hỗ trợ:
  │      └── Chạy: git_commit_helper.py --validate "<message>"
  │
  └── 4. Xuất trình bản đề xuất và xin xác nhận người dùng:
         ├── Liệt kê danh sách file thay đổi.
         ├── Trình bày thông điệp commit đề xuất.
         └── CHỜ người dùng phản hồi xác nhận trước khi chạy lệnh git commit.
```

---

## Bộ Công Cụ CLI Black-Box (Black-Box Tooling)

> [!IMPORTANT]
> **Sử Dụng Scripts Dạng Black-Box:** Không cần đọc mã nguồn Python vào context. Chạy trực tiếp từ CLI:

1. **Gợi Ý Commit Scope Dựa Trên Thay Đổi Git:**
   ```powershell
   python .agents/skills/conventional-commits/scripts/git_commit_helper.py --suggest
   ```

2. **Kiểm Tra Tính Hợp Lệ Của Thông Điệp Commit:**
   ```powershell
   python .agents/skills/conventional-commits/scripts/git_commit_helper.py --validate "<commit_message>"
   ```

---

## Quy Trình Thực Thi Commit An Toàn (Commit Safety Guardrail)

1. **Bước 1 - Hoàn tất & Đạt Kiểm Toán:** Đảm bảo `flutter analyze` báo `No issues found!` và `flutter test` đạt 100%.
2. **Bước 2 - Phân Tích Thay Đổi:** Chạy `git status -s` để rà soát các tệp sửa đổi.
3. **Bước 3 - Xuất Trình Đề Xuất:** Trình bày thông điệp commit đề xuất theo định dạng `<type>(<scope>): <tiêu đề tiếng Việt có dấu>` kèm danh sách tệp stage.
4. **Bước 4 - Thực Thi Khi Được Duyệt:** Chỉ chạy `git add` và `git commit` sau khi người dùng đồng ý tường minh.

---

## References & Examples
- [Các Mẫu Commit Thường Dùng](./examples/commit_examples.md)
- [Đặc Tả Kỹ Thuật Conventional Commits](./references/conventional_spec.md)
