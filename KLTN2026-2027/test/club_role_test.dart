// test/club_role_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:kltn2026_2027/data/dto/club/club_role_response_dto.dart';
import 'package:kltn2026_2027/data/mapper/club_role_mapper.dart';
import 'package:kltn2026_2027/domain/entities/club/club_role_item.dart';

void main() {
  group('ClubRole & Permission Tests', () {
    test('ClubRolePermission fallback description operates properly', () {
      const permWithDesc = ClubRolePermission(
        id: '1',
        code: 'OPERATIONS.SCHEDULE.MANAGE',
        name: 'Quản lý lịch',
        moduleGroup: 'OPERATIONS',
        description: 'Tùy chỉnh mô tả',
      );
      expect(permWithDesc.displayDescription, 'Tùy chỉnh mô tả');

      const permWithoutDesc = ClubRolePermission(
        id: '2',
        code: 'OPERATIONS.SCHEDULE.MANAGE',
        name: 'Quản lý lịch',
        moduleGroup: 'OPERATIONS',
      );
      expect(
        permWithoutDesc.displayDescription,
        'Tạo, sửa và xóa lịch sinh hoạt lặp lại hàng tuần của nhóm.',
      );
    });

    test('ClubRoleResponseDto and ClubRoleMapper map permissions correctly', () {
      final json = {
        'id': 'role-1',
        'clubId': 'club-1',
        'roleName': 'Phó nhóm',
        'description': 'Hỗ trợ Host',
        'isDefault': false,
        'isHostRole': false,
        'createdAt': '2026-10-16T10:00:00Z',
        'permissions': [
          {
            'id': 'perm-1',
            'code': 'OPERATIONS.SESSION.VIEW',
            'name': 'Xem buổi sinh hoạt',
            'moduleGroup': 'OPERATIONS',
            'description': 'Xem danh sách buổi sinh hoạt'
          }
        ]
      };

      final dto = ClubRoleResponseDto.fromJson(json);
      expect(dto.roleName, 'Phó nhóm');
      expect(dto.permissions.length, 1);
      expect(dto.permissions.first.description, 'Xem danh sách buổi sinh hoạt');

      final entity = ClubRoleMapper.toEntity(dto);
      expect(entity.id, 'role-1');
      expect(entity.permissions.first.code, 'OPERATIONS.SESSION.VIEW');
      expect(entity.permissions.first.displayDescription, 'Xem danh sách buổi sinh hoạt');
    });
  });
}
