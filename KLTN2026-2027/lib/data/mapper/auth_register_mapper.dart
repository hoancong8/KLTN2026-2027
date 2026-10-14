// lib/data/mapper/auth_register_mapper.dart

import '../../domain/entities/auth_register_result.dart';
import '../dto/auth/register_response_dto.dart';

class AuthRegisterMapper {
  static AuthRegisterResult toEntity(RegisterResponseDto dto) {
    return AuthRegisterResult(
      userId: dto.userId,
      fullName: dto.fullName,
      email: dto.email,
      phoneNumber: dto.phoneNumber,
      gender: dto.gender,
      skillLevel: dto.skillLevel,
      reputationScore: dto.reputationScore,
      accessToken: dto.accessToken,
      refreshToken: dto.refreshToken,
      refreshTokenExpiryTime: DateTime.tryParse(dto.refreshTokenExpiryTime) ??
          DateTime.now().add(const Duration(days: 7)),
    );
  }
}
