import '../../../app/usecase.dart';
import '../../entities/permission_group.dart';
import '../../repositories/user_repository.dart';

class GetAllPermissionsUseCase implements UseCase<List<PermissionGroup>> {
  final UserRepository repository;

  GetAllPermissionsUseCase(this.repository);

  @override
  Future<List<PermissionGroup>> execute() => repository.getAllPermissions();
}
