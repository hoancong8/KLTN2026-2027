---
trigger: model_decision
description: "Quy chuẩn thông điệp Git Commit theo Conventional Commits (v1.0.0), định dạng tiếng Việt chuẩn, phạm vi (scopes) Flutter, rào chắn an toàn và chính sách Zero Emoji."
---

# Quy Chuẩn Git Commit (Conventional Commits v1.0.0) & Rào Chắn An Toàn

Tài liệu này định nghĩa quy định bắt buộc khi tạo commit Git trong toàn bộ dự án KLTN2026-2027 Flutter Mobile Client.

> [!NOTE]
> Quy chuẩn này là sự mở rộng kỹ thuật của **Mục 2.7 (Quy Trình Git Commit Chuẩn Hóa)** trong [`AGENTS.md`](AGENTS.md).

---

## 1. Cấu Trúc Thông Điệp Commit

Mọi commit phải tuân thủ nghiêm ngặt chuẩn Conventional Commits v1.0.0 với tiêu đề tiếng Việt tự nhiên, có dấu:

```text
<type>(<scope>): <tiêu đề ngắn gọn mô tả thay đổi bằng tiếng Việt có dấu>

[optional body - giải thích tại sao và thay đổi cái gì]

[optional footer(s) - ghi chú BREAKING CHANGE hoặc link issue]
```

---

## 2. Bảng Danh Mục Types & Scopes Chuẩn Hóa

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

### Danh mục phạm vi (Scopes) cho Flutter KLTN2026-2027:
- `auth`: Đăng nhập, đăng ký, refresh token, sinh trắc học, secure storage.
- `club`: Danh sách CLB, chi tiết CLB, thành viên, vai trò trong CLB.
- `session`: Buổi sinh hoạt cầu lông, điểm danh, tuyển quân giao lưu.
- `booking`: Đặt sân, lịch sân, bảng giá sân (`venue`, `court`).
- `profile`: Hồ sơ cá nhân, trình độ thể lực, đổi mật khẩu.
- `admin`: Phân hệ quản trị viên, duyệt CLB, quản lý người dùng.
- `ui`: Các widget dùng chung, theme màu sắc, layout responsive.
- `data`: Datasource, DTO, Mapper, Repository implementation.
- `domain`: Entity, UseCase, Repository interface, Domain Exception.
- `l10n`: File đa ngôn ngữ `.arb`, cấu hình quốc tế hóa.
- `deps`: Cập nhật phiên bản thư viện trong `pubspec.yaml` / `pubspec.lock`.
- `rules`: Thay đổi các quy chuẩn trong `.agents/rules/`, `AGENTS.md`, `GEMINI.md`.
- `skills`: Thêm hoặc nâng cấp kỹ năng tác vụ trong `.agents/skills/`.

---

## 3. Rào Chắn An Toàn (Commit Safety Guardrail)

> [!CAUTION]
> AI Agent tuyệt đối **KHÔNG ĐƯỢC PHÉP** tự ý thực thi lệnh `git commit` hoặc `git push` một cách âm thầm (silent commit) mà chưa có sự đồng ý tường minh từ người dùng.

Quy trình xuất trình đề xuất:
1. **Kiểm tra chất lượng trước:** Xác nhận `flutter analyze` và `flutter test` đạt 100%.
2. **Xuất trình bản đề xuất:** Trình bày thông điệp commit đề xuất kèm danh sách file thay đổi.
3. **Chờ xác nhận:** Chỉ thực thi `git commit` khi người dùng phê duyệt rõ ràng.

---

## 4. Công Cụ Hỗ Trợ Black-Box

Khi cần gợi ý scope hoặc kiểm tra tính hợp lệ trước khi commit, sử dụng script hỗ trợ:

```powershell
python .agents/skills/conventional-commits/scripts/git_commit_helper.py --validate "<commit_message>"
```

---

## 5. Mẫu Chuẩn Commit (Good vs. Bad Patterns)

```text
// ❌ SAI: Sai scope, chứa emoji, viết hoa, có dấu chấm cuối dòng
Feat: Thêm màn hình danh sách thành viên 🚀.

// ❌ SAI: Không dùng tiếng Anh khi prompt tiếng Việt
feat(club): add club member list screen

// ✅ ĐÚNG: Chuẩn Conventional Commits v1.0.0, đúng scope, tiếng Việt có dấu
feat(club): thêm màn hình danh sách thành viên nhóm
fix(data): xử lý parser phòng thủ cho trường rating trong club dto
```
