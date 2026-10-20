# Ví Dụ Mẫu Conventional Commits Cho Flutter KLTN2026-2027

Tập hợp các mẫu commit chuẩn theo từng phân hệ chức năng:

---

## 1. Phân Hệ Xác Thực & Tài Khoản (`auth`, `profile`)
- `feat(auth): thêm tích hợp sinh trắc học vân tay khi đăng nhập`
- `feat(auth): bổ sung cơ chế tự động refresh token khi gặp mã lỗi 401`
- `fix(auth): sửa lỗi không xóa token trong secure storage khi logout`
- `feat(profile): thêm chức năng cập nhật trình độ thể lực người chơi`

---

## 2. Phân Hệ Câu Lạc Bộ & Thành Viên (`club`)
- `feat(club): thêm màn hình danh sách thành viên nhóm và phân vai trò`
- `fix(club): sửa lỗi hiển thị sai trạng thái yêu cầu gia nhập clb`
- `refactor(club): tái cấu trúc viewmodel quản lý clb sang riverpod notifier`

---

## 3. Phân Hệ Buổi Chơi & Điểm Danh (`session`, `booking`)
- `feat(session): thêm chức năng điểm danh và chia đội tự động`
- `feat(booking): tích hợp api tra cứu bảng giá sân theo khung giờ vàng`
- `fix(session): xử lý hàng đợi waiting list khi buổi chơi đã đủ người`

---

## 4. Tầng Dữ Liệu & Kiến Trúc (`data`, `domain`, `ui`, `rules`)
- `fix(data): bổ sung parser phòng thủ cho dto phản hồi từ abp framework`
- `refactor(domain): chuyển đổi các entity sang kế thừa equatable`
- `feat(ui): tối ưu giao diện responsive layout cho máy tính bảng`
- `docs(rules): cập nhật quy chuẩn 3 tầng clean architecture cho flutter`
