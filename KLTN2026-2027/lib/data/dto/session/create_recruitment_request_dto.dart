// lib/data/dto/session/create_recruitment_request_dto.dart

class CreateRecruitmentRequestDto {
  final int slotsNeeded;
  final String minSkillLevel;
  final double sharedCost;
  final double scanRadiusKm;

  CreateRecruitmentRequestDto({
    required this.slotsNeeded,
    this.minSkillLevel = 'NB',
    this.sharedCost = 0.0,
    this.scanRadiusKm = 5.0,
  });

  Map<String, dynamic> toJson() => {
    'slotsNeeded': slotsNeeded,
    'minSkillLevel': minSkillLevel,
    'sharedCost': sharedCost,
    'scanRadiusKm': scanRadiusKm,
  };
}
