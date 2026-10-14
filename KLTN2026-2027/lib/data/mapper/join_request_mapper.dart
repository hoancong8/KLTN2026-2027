// lib/data/mapper/join_request_mapper.dart

import '../../domain/entities/club/join_request.dart';
import '../../domain/enums/session_enums.dart';
import '../dto/club/join_request_response_dto.dart';

class JoinRequestMapper {
  static JoinRequest toEntity(JoinRequestResponseDto dto) {
    return JoinRequest(
      id: dto.id,
      clubId: dto.clubId,
      userId: dto.userId,
      fullName: dto.fullName ?? 'Người dùng',
      email: dto.email,
      phoneNumber: dto.phoneNumber,
      avatarUrl: dto.avatarUrl,
      introduction: dto.introduction,
      status: JoinRequestStatus.fromString(dto.status),
      createdAt: DateTime.tryParse(dto.createdAt) ?? DateTime.now(),
      reviewedAt: dto.reviewedAt != null ? DateTime.tryParse(dto.reviewedAt!) : null,
      approvedBy: dto.approvedBy,
    );
  }
}
