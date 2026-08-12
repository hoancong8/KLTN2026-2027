import 'package:kltn2026_2027/data/dto/profile/change_profile_request_dto.dart';
import 'package:kltn2026_2027/data/dto/profile/change_profile_response_dto.dart';

abstract class ProfileRemoteDatasource {
  Future<ChangeProfileResponseDto> getProfile(int employeeId);
  Future<void> changeProfile(ChangeProfileRequestDto request);
}
