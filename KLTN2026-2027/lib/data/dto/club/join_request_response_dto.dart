// lib/data/dto/club/join_request_response_dto.dart

class JoinRequestResponseDto {
  final String id;
  final String clubId;
  final String userId;
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final String? avatarUrl;
  final String? introduction;
  final String status;
  final String createdAt;
  final String? reviewedAt;
  final String? approvedBy;

  JoinRequestResponseDto({
    required this.id,
    required this.clubId,
    required this.userId,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.avatarUrl,
    this.introduction,
    required this.status,
    required this.createdAt,
    this.reviewedAt,
    this.approvedBy,
  });

  factory JoinRequestResponseDto.fromJson(Map<String, dynamic> json) {
    return JoinRequestResponseDto(
      id: json['id']?.toString() ?? '',
      clubId: json['clubId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      fullName: json['fullName']?.toString(),
      email: json['email']?.toString(),
      phoneNumber: json['phoneNumber']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      introduction: json['introduction']?.toString(),
      status: json['status']?.toString() ?? '1',
      createdAt: json['createdAt']?.toString() ?? '',
      reviewedAt: json['reviewedAt']?.toString(),
      approvedBy: json['approvedBy']?.toString(),
    );
  }
}
