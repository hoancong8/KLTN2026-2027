// test/auth_context_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kltn2026_2027/app/consts/permissions.dart';
import 'package:kltn2026_2027/app/provider.dart';
import 'package:kltn2026_2027/data/dto/club/my_club_response_dto.dart';
import 'package:kltn2026_2027/data/mapper/club_mapper.dart';
import 'package:kltn2026_2027/domain/entities/auth_token.dart';
import 'package:kltn2026_2027/domain/entities/club/active_club_context.dart';
import 'package:kltn2026_2027/domain/entities/club/my_club.dart';
import 'package:kltn2026_2027/domain/entities/user_profile.dart';
import 'package:kltn2026_2027/domain/enums/club_member_status.dart';
import 'package:kltn2026_2027/domain/enums/club_role.dart';

void main() {
  group('Authentication & Authorization (X-Group-Id Context) Tests', () {
    test('MyClubResponseDto parses backend JSON with permissions defensively', () {
      final json = {
        'clubId': 'b86fa2e7-03b6-4299-923c-a93108ce8968',
        'clubName': 'CLB Cầu Lông Ba Đình',
        'clubCode': 'CLB-BD01',
        'description': 'Sân sinh hoạt 158 Hoàng Hoa Thám',
        'avatarUrl': 'https://example.com/avatar1.png',
        'roleId': 'e1586a65-1d02-4fc5-9118-28308bc25752',
        'roleName': 'Host',
        'role': 0,
        'status': 'ACTIVE',
        'joinedAt': '2026-10-12T07:00:00Z',
        'permissions': [
          'OPERATIONS.SESSION.VIEW',
          'OPERATIONS.SESSION.CREATE',
          'OPERATIONS.SESSION.UPDATE',
          'OPERATIONS.SCHEDULE.MANAGE',
          'FINANCE.LEDGER.VIEW',
          'MEMBER.INFO.UPDATE',
        ],
      };

      final dto = MyClubResponseDto.fromJson(json);

      expect(dto.clubId, 'b86fa2e7-03b6-4299-923c-a93108ce8968');
      expect(dto.clubName, 'CLB Cầu Lông Ba Đình');
      expect(dto.roleName, 'Host');
      expect(dto.permissions.length, 6);
      expect(dto.permissions, contains(ClubPermissions.sessionCreate));
      expect(dto.permissions, contains(ClubPermissions.scheduleManage));
      expect(dto.permissions, contains(ClubPermissions.ledgerView));
    });

    test('MyClubResponseDto handles null or corrupted permissions safely', () {
      final json = {
        'clubId': 'test-id',
        'clubName': 'Test Club',
        'permissions': null,
      };

      final dto = MyClubResponseDto.fromJson(json);
      expect(dto.permissions, isEmpty);

      final nonMapDto = MyClubResponseDto.fromJson('invalid_json');
      expect(nonMapDto.permissions, isEmpty);
      expect(nonMapDto.clubId, isEmpty);
    });

    test('ClubMapper maps DTO to MyClub entity and preserves permissions', () {
      final dto = MyClubResponseDto(
        clubId: 'c1',
        clubName: 'Club Alpha',
        clubCode: 'CA-01',
        role: 0,
        roleName: 'Host',
        status: 'ACTIVE',
        permissions: const [
          ClubPermissions.sessionCreate,
          ClubPermissions.scheduleManage,
        ],
      );

      final club = ClubMapper.toMyClubEntity(dto);

      expect(club.clubId, 'c1');
      expect(club.clubName, 'Club Alpha');
      expect(club.role, ClubRole.host);
      expect(club.hasPermission(ClubPermissions.sessionCreate), isTrue);
      expect(club.hasPermission(ClubPermissions.matchManage), isFalse);
      expect(
        club.hasAnyPermission([
          ClubPermissions.matchManage,
          ClubPermissions.scheduleManage,
        ]),
        isTrue,
      );
    });

    test('ClubMapper.fromMyClub converts MyClub to ActiveClubContext cleanly', () {
      const club = MyClub(
        clubId: 'c2',
        clubName: 'Club Beta',
        clubCode: 'CB-02',
        role: ClubRole.treasurer,
        roleName: 'Thủ quỹ',
        status: ClubMemberStatus.active,
        permissions: [
          ClubPermissions.ledgerView,
          ClubPermissions.ledgerManage,
          ClubPermissions.feeView,
        ],
      );

      final activeContext = ClubMapper.fromMyClub(club);

      expect(activeContext.clubId, 'c2');
      expect(activeContext.clubName, 'Club Beta');
      expect(activeContext.role, ClubRole.treasurer);
      expect(activeContext.hasPermission(ClubPermissions.ledgerView), isTrue);
      expect(activeContext.hasPermission(ClubPermissions.sessionCreate), isFalse);
    });

    test('hasPermissionProvider verifies Contextual RBAC without changing AuthToken', () {
      final container = ProviderContainer(
        overrides: [
          // 1. Token toàn cục được định danh khi Login
          authTokenProvider.overrideWith(
            (ref) => AuthToken(
              accessToken: 'GLOBAL_JWT_TOKEN',
              refreshToken: 'REFRESH_TOKEN',
              userId: 'user-123',
            ),
          ),
          // 2. UserProfile thông thường (không phải Admin)
          currentUserProfileProvider.overrideWith(
            () => CurrentUserProfileNotifier(
              const UserProfile(
                id: 'user-123',
                email: 'user@test.com',
                userName: 'PlayerOne',
                isLocked: false,
                roles: ['User'],
                permissions: ['Users.Read'],
              ),
            ),
          ),
          // 3. Active Context được chuyển sang CLB Ba Đình
          activeClubContextProvider.overrideWith(
            (ref) => const ActiveClubContext(
              clubId: 'club-ba-dinh',
              clubName: 'CLB Ba Đình',
              role: ClubRole.host,
              permissions: [
                ClubPermissions.sessionCreate,
                ClubPermissions.scheduleManage,
              ],
            ),
          ),
        ],
      );

      // Verify Auth Token giữ nguyên
      final currentToken = container.read(authTokenProvider);
      expect(currentToken?.accessToken, 'GLOBAL_JWT_TOKEN');

      // Verify Active Club ID provider phản ánh đúng X-Group-Id
      expect(container.read(activeClubIdProvider), 'club-ba-dinh');

      // Verify HasPermission kiểm tra đúng quyền CLB
      expect(
        container.read(hasPermissionProvider(ClubPermissions.sessionCreate)),
        isTrue,
      );
      expect(
        container.read(hasClubPermissionProvider(ClubPermissions.scheduleManage)),
        isTrue,
      );
      // Quyền không có trong CLB và không có trong Profile
      expect(
        container.read(hasPermissionProvider(ClubPermissions.bankManage)),
        isFalse,
      );
      // Quyền hệ thống từ UserProfile vẫn hoạt động
      expect(
        container.read(hasPermissionProvider('Users.Read')),
        isTrue,
      );

      // Giả lập chuyển sang CLB Tân Bình (Thành viên - chỉ có quyền xem buổi tập)
      container.read(activeClubContextProvider.notifier).state =
          const ActiveClubContext(
        clubId: 'club-tan-binh',
        clubName: 'CLB Tân Bình',
        role: ClubRole.member,
        permissions: [ClubPermissions.sessionView],
      );

      // Auth Token toàn cục VẪN giữ nguyên hoàn toàn!
      expect(
        container.read(authTokenProvider)?.accessToken,
        'GLOBAL_JWT_TOKEN',
      );

      // Header X-Group-Id tự động cập nhật
      expect(container.read(activeClubIdProvider), 'club-tan-binh');

      // Quyền tạo buổi tập giờ đây bị từ chối
      expect(
        container.read(hasPermissionProvider(ClubPermissions.sessionCreate)),
        isFalse,
      );
      // Quyền xem buổi tập được chấp thuận
      expect(
        container.read(hasPermissionProvider(ClubPermissions.sessionView)),
        isTrue,
      );

      container.dispose();
    });

    test('Admin user bypasses all permissions', () {
      final container = ProviderContainer(
        overrides: [
          currentUserProfileProvider.overrideWith(
            () => CurrentUserProfileNotifier(
              const UserProfile(
                id: 'admin-id',
                email: 'admin@test.com',
                userName: 'Admin',
                isLocked: false,
                roles: ['Admin'],
                permissions: ['System.Administrator'],
              ),
            ),
          ),
        ],
      );

      expect(container.read(isAdminUserProvider), isTrue);
      expect(
        container.read(hasPermissionProvider(ClubPermissions.sessionDelete)),
        isTrue,
      );
      expect(
        container.read(hasPermissionProvider(ClubPermissions.bankManage)),
        isTrue,
      );

      container.dispose();
    });
  });
}
