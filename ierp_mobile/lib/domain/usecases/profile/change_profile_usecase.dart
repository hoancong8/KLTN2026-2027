import 'package:ierp_mobile/domain/entities/employee.dart';
import 'package:ierp_mobile/domain/repositories/profile_repository.dart';

class ChangeProfileUseCase {
  final ProfileRepository repository;

  ChangeProfileUseCase(this.repository);

  Future<void> execute({required Employee employee}) {
    return repository.changeProfile(employee: employee);
  }
}
