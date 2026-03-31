import 'package:sipm_mobile/domain/entities/employee.dart';
import 'package:sipm_mobile/domain/repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository repository;

  GetProfileUseCase(this.repository);

  Future<Employee> execute(int employeeId) {
    return repository.getProfile(employeeId);
  }
}
