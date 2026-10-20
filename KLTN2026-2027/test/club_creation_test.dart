// test/club_creation_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:kltn2026_2027/data/dto/club/create_club_request_dto.dart';
import 'package:kltn2026_2027/data/dto/club/update_club_schedules_request_dto.dart';
import 'package:kltn2026_2027/domain/usecases/club/create_club_usecase.dart';

void main() {
  group('Club Creation Verification', () {
    test('CreateClubRequestDto serializes full club group payload correctly', () {
      final schedule1 = ClubScheduleItemRequestDto(
        dayOfWeek: 3, // Thứ 4
        startTime: '19:00',
        endTime: '21:00',
      );

      final schedule2 = ClubScheduleItemRequestDto(
        dayOfWeek: 6, // Thứ 7
        startTime: '14:00',
        endTime: '17:00',
      );

      final requestDto = CreateClubRequestDto(
        name: 'CLB Cầu Lông Chiến Binh',
        description: 'CLB giao lưu phong trào mỗi tuần',
        avatarUrl: 'https://example.com/avatar.png',
        fixedVenueName: 'Sân Cầu Lông Kỳ Hòa',
        fixedAddress: '238 Đường 3/2, Quận 10',
        lat: 10.7712,
        lng: 106.6685,
        minSkillLevel: 1,
        maxSkillLevel: 5,
        schedules: [schedule1, schedule2],
      );

      final json = requestDto.toJson();

      expect(json['name'], 'CLB Cầu Lông Chiến Binh');
      expect(json['description'], 'CLB giao lưu phong trào mỗi tuần');
      expect(json['avatarUrl'], 'https://example.com/avatar.png');
      expect(json['fixedVenueName'], 'Sân Cầu Lông Kỳ Hòa');
      expect(json['fixedAddress'], '238 Đường 3/2, Quận 10');
      expect(json['lat'], 10.7712);
      expect(json['lng'], 106.6685);
      expect(json['minSkillLevel'], 1);
      expect(json['maxSkillLevel'], 5);
      expect(json['schedules'], isA<List>());
      expect((json['schedules'] as List).length, 2);

      final s0 = (json['schedules'] as List)[0];
      expect(s0['dayOfWeek'], 3);
      expect(s0['startTime'], '19:00');
      expect(s0['endTime'], '21:00');
    });

    test('CreateClubRequestDto omits null optional fields cleanly', () {
      const minimalDto = CreateClubRequestDto(
        name: 'CLB Phong Trào Cơ Bản',
      );

      final json = minimalDto.toJson();

      expect(json['name'], 'CLB Phong Trào Cơ Bản');
      expect(json.containsKey('description'), isFalse);
      expect(json.containsKey('avatarUrl'), isFalse);
      expect(json.containsKey('fixedVenueName'), isFalse);
      expect(json.containsKey('schedules'), isFalse);
    });

    test('CreateClubParams holds parameters properly for domain usecase', () {
      const params = CreateClubParams(
        name: 'CLB Test',
        description: 'Test Desc',
        minSkillLevel: 2,
        maxSkillLevel: 4,
      );

      expect(params.name, 'CLB Test');
      expect(params.description, 'Test Desc');
      expect(params.minSkillLevel, 2);
      expect(params.maxSkillLevel, 4);
    });
  });
}
