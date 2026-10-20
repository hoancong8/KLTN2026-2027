---
name: conventional-commits
description: >-
  Draft, validate, and suggest Conventional Commits v1.0.0 messages with accurate Vietnamese descriptions and Flutter-specific scopes (auth, club, session, booking, profile, admin, ui, data, domain, l10n, deps, rules, test). Use whenever preparing Git commits after completing code changes.
---

# Conventional Commits Assistant & Validator

## Goal (Single Responsibility)
Generate, validate, and check Git commit messages adhering strictly to the Conventional Commits v1.0.0 specification, project-specific scopes, accented Vietnamese formatting, and the Zero Emoji Policy.

---

## Black-Box Script Invocations

> [!IMPORTANT]
> **Use Scripts as Black Boxes:** Do NOT read or load the Python script source code into context. Run the CLI directly.

1. **Gợi Ý Commit Scope Dựa Trên Thay Đổi Git:**
   ```powershell
   python .agents/skills/conventional-commits/scripts/git_commit_helper.py --suggest
   ```

2. **Kiểm Tra Tính Hợp Lệ Của Thông Điệp Commit:**
   ```powershell
   python .agents/skills/conventional-commits/scripts/git_commit_helper.py --validate "<commit_message>"
   ```

---

## References & Examples
- [Các Mẫu Commit Thường Dùng](./examples/commit_examples.md)
- [Đặc Tả Kỹ Thuật Conventional Commits](./references/conventional_spec.md)
