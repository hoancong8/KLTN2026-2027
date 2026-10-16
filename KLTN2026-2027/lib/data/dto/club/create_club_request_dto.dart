import 'update_club_schedules_request_dto.dart';

class CreateClubRequestDto {
  final String name;
  final String? description;
  final String? avatarUrl;
  final String? fixedVenueName;
  final String? fixedAddress;
  final double? lat;
  final double? lng;
  final int? minSkillLevel;
  final int? maxSkillLevel;
  final List<ClubScheduleItemRequestDto>? schedules;

  const CreateClubRequestDto({
    required this.name,
    this.description,
    this.avatarUrl,
    this.fixedVenueName,
    this.fixedAddress,
    this.lat,
    this.lng,
    this.minSkillLevel,
    this.maxSkillLevel,
    this.schedules,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null) 'description': description,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (fixedVenueName != null) 'fixedVenueName': fixedVenueName,
      if (fixedAddress != null) 'fixedAddress': fixedAddress,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (minSkillLevel != null) 'minSkillLevel': minSkillLevel,
      if (maxSkillLevel != null) 'maxSkillLevel': maxSkillLevel,
      if (schedules != null && schedules!.isNotEmpty)
        'schedules': schedules!.map((s) => s.toJson()).toList(),
    };
  }
}
