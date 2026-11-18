// lib/domain/entities/session/create_court_pass_params.dart

class CreateCourtPassParams {
  final String? clubId;
  final String courtLocation;
  final String? address;
  final DateTime startTime;
  final DateTime endTime;
  final int courtCount;
  final double passPrice;
  final String? contactPhone;
  final String? note;
  final double? lat;
  final double? lng;
  final String minSkillLevel;

  const CreateCourtPassParams({
    this.clubId,
    required this.courtLocation,
    this.address,
    required this.startTime,
    required this.endTime,
    this.courtCount = 1,
    this.passPrice = 0.0,
    this.contactPhone,
    this.note,
    this.lat,
    this.lng,
    this.minSkillLevel = 'NB',
  });
}
