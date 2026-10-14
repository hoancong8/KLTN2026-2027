// lib/domain/entities/club/join_request.dart

import '../../enums/session_enums.dart';

class JoinRequest {
  final String id;
  final String clubId;
  final String userId;
  final String fullName;
  final String? email;
  final String? phoneNumber;
  final String? avatarUrl;
  final String? introduction;
  final JoinRequestStatus status;
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final String? approvedBy;

  const JoinRequest({
    required this.id,
    required this.clubId,
    required this.userId,
    required this.fullName,
    this.email,
    this.phoneNumber,
    this.avatarUrl,
    this.introduction,
    required this.status,
    required this.createdAt,
    this.reviewedAt,
    this.approvedBy,
  });

  bool get isPending => status == JoinRequestStatus.pending;
}
