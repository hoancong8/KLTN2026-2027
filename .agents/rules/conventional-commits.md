---
trigger: model_decision
description: "Quy chuẩn thông điệp Git Commit theo Conventional Commits (v1.0.0), định dạng tiếng Việt chuẩn, phạm vi (scopes) Flutter và chính sách Zero Emoji."
---

# Chuẩn Mực Conventional Commits (v1.0.0) & Bảng Tra Cứu

Định dạng toàn bộ thông điệp Git commit tuân thủ nghiêm ngặt chuẩn Conventional Commits v1.0.0 với tiêu đề tiếng Việt tự nhiên, có dấu:

```text
<type>(<scope>): <tiêu đề ngắn gọn mô tả thay đổi bằng tiếng Việt có dấu>

[optional body - giải thích tại sao và thay đổi cái gì]

[optional footer(s) - ghi chú BREAKING CHANGE hoặc link issue]
```

---

## 1. Bảng Tra Cứu Loại (Types) & Phạm Vi (Scopes)

### Các loại commit hợp lệ (Types):
- `feat`: Thêm tính năng mới, màn hình mới, hoặc UseCase mới.
- `fix`: Sửa lỗi hiển thị UI, lỗi parser DTO, hoặc lỗi logic ViewModel.
- `refactor`: Tái cấu trúc mã nguồn mà không thay đổi hành vi nghiệp vụ.
- `perf`: Tối ưu hiệu năng, giảm số lần rebuild widget, giảm độ trễ API.
- `style`: Định dạng mã nguồn, sắp xếp lại import, xóa warning linter.
- `test`: Thêm mới hoặc cập nhật unit test, widget test, mapper test.
- `docs`: Cập nhật tài liệu kỹ thuật, hướng dẫn kiến trúc, file markdown.
- `build`: Thay đổi cấu hình build Flutter, Gradle, Podfile, `pubspec.yaml`.
- `ci`: Thay đổi pipeline GitHub Actions hoặc kịch bản tự động hóa.
- `chore`: Cập nhật cấu hình công cụ, `.gitignore`, metadata.
- `revert`: Hoàn tác một commit trước đó.

### Danh mục phạm vi (Scopes) cho dự án Flutter KLTN2026-2027:
- `auth`: Đăng nhập, đăng ký, refresh token, sinh trắc học, secure storage.
- `club`: Danh sách CLB, chi tiết CLB, thành viên, vai trò trong CLB.
- `session`: Buổi sinh hoạt cầu lông, điểm danh, tuyển quân giao lưu.
- `booking`: Đặt sân, lịch sân, bảng giá sân (`venue`, `court`).
- `profile`: Hồ sơ cá nhân, trình độ thể lực, đổi mật khẩu.
- `admin`: Phân hệ quản trị viên, duyệt duyệt CLB, quản lý người dùng.
- `ui`: Các widget dùng chung, theme màu sắc, layout responsive.
- `data`: Datasource, DTO, Mapper, Repository implementation.
- `domain`: Entity, UseCase, Repository interface, Domain Exception.
- `l10n`: File đa ngôn ngữ `.arb`, cấu hình quốc tế hóa.
- `deps`: Cập nhật phiên bản thư viện trong `pubspec.yaml` / `pubspec.lock`.
- `rules`: Thay đổi các quy chuẩn trong `.agents/rules/`, `AGENTS.md`, `GEMINI.md`.
- `skills`: Thêm hoặc nâng cấp kỹ năng tác vụ trong `.agents/skills/`.

---

## 2. Quy Tắc Bắt Buộc

1. **Tiêu đề tiếng Việt có dấu:** Bắt đầu bằng chữ thường sau dấu `: `, không kết thúc bằng dấu chấm, độ dài dòng tiêu đề không quá 72 ký tự.
   - ✅ `feat(club): thêm màn hình danh sách thành viên nhóm`
   - ✅ `fix(data): xử lý parser phòng thủ cho trường rating trong club dto`
   - ❌ `feat(club): Thêm màn hình.` (Viết hoa chữ đầu, có dấu chấm ở cuối)
   - ❌ `feat(club): add club member list screen` (Không dùng tiếng Anh khi prompt tiếng Việt)
2. **Zero Emoji Policy:** Nghiêm cấm tuyệt đối đưa bất kỳ emoji hay icon nào vào thông điệp commit.
3. **Commit Safety Guardrail:** Tuyệt đối KHÔNG BAO GIỜ tự ý chạy lệnh `git commit` mà không xuất trình thông điệp commit đề xuất và danh sách các tệp bị ảnh hưởng để người dùng xác nhận.
