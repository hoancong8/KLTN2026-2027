import '../../domain/entities/employee.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasource/remote/abstract/profile_remote_datasource.dart';
import '../mapper/profile_mapper.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDatasource remote;

  ProfileRepositoryImpl(this.remote);

  @override
  Future<Employee> getProfile(int employeeId) async {
    final dto = await remote.getProfile(employeeId);
    return ProfileMapper.toEntity(dto);
  }

  @override
  Future<void> changeProfile({required Employee employee}) async {
    final dto = ProfileMapper.toDto(employee);
    await remote.changeProfile(dto);
  }
}
