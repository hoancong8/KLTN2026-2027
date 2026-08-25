import '../../../app/usecase.dart';
import '../../entities/app_role.dart';
import '../../repositories/role_repository.dart';

class GetRolesUseCase implements UseCase<List<AppRole>> {
  final RoleRepository repository;

  GetRolesUseCase(this.repository);

  @override
  Future<List<AppRole>> execute() => repository.getRoles();
}
