// lib/data/dto/session/create_court_pass_request_dto.dart

class CreateCourtPassRequestDto {
  final String? clubId;
  final String courtLocation;
  final String? address;
  final String startTime;
  final String endTime;
  final int courtCount;
  final double passPrice;
  final String? contactPhone;
  final String? note;
  final double? lat;
  final double? lng;
  final String minSkillLevel;

  CreateCourtPassRequestDto({
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

  Map<String, dynamic> toJson() => {
    if (clubId != null && clubId!.isNotEmpty) 'clubId': clubId,
    'courtLocation': courtLocation,
    if (address != null && address!.isNotEmpty) 'address': address,
    'startTime': startTime,
    'endTime': endTime,
    'courtCount': courtCount,
    'passPrice': passPrice,
    if (contactPhone != null && contactPhone!.isNotEmpty) 'contactPhone': contactPhone,
    if (note != null && note!.isNotEmpty) 'note': note,
    if (lat != null) 'lat': lat,
    if (lng != null) 'lng': lng,
    'minSkillLevel': minSkillLevel,
  };
}
