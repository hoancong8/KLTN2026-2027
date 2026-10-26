// lib/data/dto/session/create_recruitment_request_dto.dart

class CreateRecruitmentRequestDto {
  final int slotsNeeded;
  final String minSkillLevel;
  final double sharedCost;
  final double scanRadiusKm;
  final bool hidePlayerList;
  final double? femaleDiscount;
  final double? femaleSharedCost;

  CreateRecruitmentRequestDto({
    required this.slotsNeeded,
    this.minSkillLevel = 'NB',
    this.sharedCost = 0.0,
    this.scanRadiusKm = 5.0,
    this.hidePlayerList = false,
    this.femaleDiscount,
    this.femaleSharedCost,
  });

  Map<String, dynamic> toJson() => {
    'slotsNeeded': slotsNeeded,
    'minSkillLevel': minSkillLevel,
    'sharedCost': sharedCost,
    'scanRadiusKm': scanRadiusKm,
    'hidePlayerList': hidePlayerList,
    if (femaleDiscount != null) 'femaleDiscount': femaleDiscount,
    if (femaleSharedCost != null) 'femaleSharedCost': femaleSharedCost,
  };
}
