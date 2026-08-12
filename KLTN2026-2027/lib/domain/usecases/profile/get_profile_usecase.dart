import 'package:kltn2026_2027/domain/entities/employee.dart';
import 'package:kltn2026_2027/domain/repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository repository;

  GetProfileUseCase(this.repository);

  Future<Employee> execute(int employeeId) {
    return repository.getProfile(employeeId);
  }
}
