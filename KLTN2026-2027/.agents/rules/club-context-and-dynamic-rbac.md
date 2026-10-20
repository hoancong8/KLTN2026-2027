---
trigger: glob
globs: "lib/ui/screen/club/**, lib/domain/entities/club/**, lib/data/**/club/**"
description: "Cơ chế quản lý đa nhóm động (Contextual Multi-Club RBAC), chuyển đổi ActiveClubContext, và kiểm soát quyền hiển thị giao diện Flutter."
---

# Quản Lý Đa Nhóm Động & Phân Quyền Theo Ngữ Cảnh (Contextual Multi-Club RBAC)

> [!IMPORTANT]
> Ứng dụng di động KLTN2026-2027 hoạt động theo mô hình **Đa Nhóm Độc Lập**: Một người dùng (Player) có thể tham gia N câu lạc bộ với N vai trò và quyền hạn hoàn toàn khác nhau (ở CLB A là `HOST`, nhưng ở CLB B chỉ là `MEMBER`). AI Agent tuyệt đối không giả định người dùng chỉ có 1 quyền cố định trên toàn app.

---

## 1. Cơ Chế Chuyển Đổi Ngữ Cảnh (Active Context Switch)

Mọi thao tác quản trị nội bộ câu lạc bộ (quản lý thành viên, tạo buổi chơi, duyệt đơn, thu quỹ) bắt buộc phải diễn ra dưới một ngữ cảnh xác định:

```
[Danh Sách CLB Của Tôi] ──► Chọn CLB (clubId) ──► Gọi SwitchClubContextUseCase
                                                               │
                                                               ▼
[ActiveClubContext] ◄── Nhận JWT Context Token & Quyền ◄── POST /api/v1/clubs/{id}/switch-context
        │
        ├──> Cập nhật State: activeClubContextProvider (Riverpod)
        ├──> Cập nhật Dio Header: Authorization: Bearer <contextToken>
        └──> UI lắng nghe để render giao diện theo quyền
```

---

## 2. Quy Tắc Kiểm Soát Hiển Thị Giao Diện Dựa Trên Quyền Hạn

1. **Sử dụng mã quyền chuẩn từ `ClubRolePermission`:**
   Mọi quyền hạn phải được đối chiếu từ danh mục quyền chuẩn tại [club_role_item.dart](file:///d:/l7TeamVN/KLTN2026-2027/KLTN2026-2027/lib/domain/entities/club/club_role_item.dart):
   - Quản lý lịch sinh hoạt: `OPERATIONS.SCHEDULE.MANAGE`
   - Xem buổi sinh hoạt: `OPERATIONS.SESSION.VIEW`
   - Tạo buổi sinh hoạt: `OPERATIONS.SESSION.CREATE`
   - Cập nhật buổi sinh hoạt: `OPERATIONS.SESSION.UPDATE`
   - Quản lý đặt slot & điểm danh: `OPERATIONS.BOOKING.MANAGE`
   - Quản lý quỹ & sổ thu chi: `FINANCE.LEDGER.MANAGE`
   - Duyệt yêu cầu gia nhập: `MEMBER.JOIN_REQUEST.MANAGE`
   - Quản lý phân quyền thành viên: `MEMBER.ROLE.MANAGE`

2. **Quy tắc render thành phần UI có điều kiện:**
   Tuyệt đối không so sánh cứng tên vai trò dạng chuỗi tiếng Việt như `roleName == 'Chủ câu lạc bộ'`. Luôn kiểm tra qua cờ `isHostRole` hoặc mảng `permissions`:

   ```dart
   // ĐÚNG: Kiểm tra quyền cụ thể hoặc cờ host role
   final hasCreateSessionPerm = activeContext.permissions.contains('OPERATIONS.SESSION.CREATE') || activeContext.role == ClubRole.host;

   if (hasCreateSessionPerm) {
     ElevatedButton.icon(
       onPressed: () => _openCreateSessionDialog(context),
       label: Text(context.l10n.createSession),
     );
   }

   // SAI: Hardcode chuỗi tiếng Việt hoặc giả định vai trò duy nhất
   if (user.roleName == 'Chủ CLB') { ... }
   ```

3. **Cập nhật động khi chuyển đổi tab / CLB:**
   Khi người dùng chuyển sang một CLB khác từ menu chọn CLB nhanh, toàn bộ dữ liệu lịch, thành viên và quyền hạn trên màn hình phải được làm mới tương ứng với `clubId` mới.
