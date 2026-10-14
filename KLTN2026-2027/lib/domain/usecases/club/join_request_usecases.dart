// lib/domain/usecases/club/join_request_usecases.dart

import '../../entities/club/join_request.dart';
import '../../repositories/club_repository.dart';

class CreateJoinRequestUseCase {
  final ClubRepository repository;
  CreateJoinRequestUseCase(this.repository);

  Future<String> execute(String clubId, {String? introduction}) =>
      repository.createJoinRequest(clubId: clubId, introduction: introduction);
}

class GetJoinRequestsUseCase {
  final ClubRepository repository;
  GetJoinRequestsUseCase(this.repository);

  Future<List<JoinRequest>> execute(String clubId, {String? status}) =>
      repository.getJoinRequests(clubId, status: status);
}

class ApproveJoinRequestParams {
  final String clubId;
  final String requestId;
  final String? roleId;
  final String? memberType;

  const ApproveJoinRequestParams({
    required this.clubId,
    required this.requestId,
    this.roleId,
    this.memberType,
  });
}

class ApproveJoinRequestUseCase {
  final ClubRepository repository;
  ApproveJoinRequestUseCase(this.repository);

  Future<String> execute(ApproveJoinRequestParams params) =>
      repository.approveJoinRequest(
        clubId: params.clubId,
        requestId: params.requestId,
        roleId: params.roleId,
        memberType: params.memberType,
      );
}

class RejectJoinRequestUseCase {
  final ClubRepository repository;
  RejectJoinRequestUseCase(this.repository);

  Future<bool> execute(String clubId, String requestId) =>
      repository.rejectJoinRequest(clubId: clubId, requestId: requestId);
}
