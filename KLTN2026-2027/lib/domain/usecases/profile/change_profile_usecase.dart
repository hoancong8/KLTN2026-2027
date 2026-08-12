import 'package:kltn2026_2027/domain/entities/employee.dart';
import 'package:kltn2026_2027/domain/repositories/profile_repository.dart';

class ChangeProfileUseCase {
  final ProfileRepository repository;

  ChangeProfileUseCase(this.repository);

  Future<void> execute({required Employee employee}) {
    return repository.changeProfile(employee: employee);
  }
}
