---
trigger: model_decision
description: "Quy tắc an toàn khi thao tác Git Commit: luôn hỏi ý kiến người dùng, cấm commit ngầm, và định dạng đề xuất commit chuẩn xác."
---

# Quy Tắc An Toàn Git Commit (Git Commit Safety Guardrail)

> [!CAUTION]
> AI Agent tuyệt đối **KHÔNG ĐƯỢC PHÉP** tự ý thực thi lệnh `git commit` hoặc `git push` một cách âm thầm (silent commit) mà chưa có sự đồng ý tường minh từ người dùng.

---

## 1. Quy Trình Commit 4 Bước Bắt Buộc

Khi hoàn thành bất kỳ tính năng, bản sửa lỗi, hoặc tái cấu trúc nào:

1. **Bước 1 - Hoàn tất & Kiểm tra Chất lượng:**
   - Đảm bảo `flutter analyze` không có cảnh báo/lỗi (`No issues found!`).
   - Đảm bảo `flutter test` vượt qua 100%.
2. **Bước 2 - Phân tích Thay đổi (Git Diff & Status):**
   - Xác định danh sách các tệp đã chỉnh sửa và thêm mới.
   - Xác định đúng Scope phù hợp theo chuẩn Conventional Commits.
3. **Bước 3 - Xuất trình Bản Đề Xuất Cho Người Dùng:**
   - Trình bày thông điệp commit rõ ràng theo định dạng:
     ```text
     <type>(<scope>): <tiêu đề tiếng Việt có dấu>
     ```
   - Liệt kê tóm tắt danh sách tệp sẽ được stage/commit.
   - Đặt câu hỏi hỏi người dùng có muốn tiến hành commit hay không.
4. **Bước 4 - Thực thi khi có xác nhận:**
   - Chỉ khi người dùng đồng ý (ví dụ: "commit đi", "ok", "tiến hành commit"), Agent mới được chạy lệnh `git add` và `git commit`.

---

## 2. Tiêu Chuẩn Thông Điệp Đề Xuất

- **Ngắn gọn, súc tích:** Tiêu đề phản ánh đúng bản chất thay đổi kỹ thuật.
- **Tiếng Việt tự nhiên:** Dùng tiếng Việt có dấu, chuẩn ngữ pháp.
- **Zero Emoji:** Không chèn biểu tượng cảm xúc (emoji) vào thông điệp.
