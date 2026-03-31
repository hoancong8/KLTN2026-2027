import 'package:ierp_mobile/data/dto/profile/change_profile_request_dto.dart';
import 'package:ierp_mobile/data/dto/profile/change_profile_response_dto.dart';

abstract class ProfileRemoteDatasource {
  Future<ChangeProfileResponseDto> getProfile(int employeeId);
  Future<void> changeProfile(ChangeProfileRequestDto request);
}
