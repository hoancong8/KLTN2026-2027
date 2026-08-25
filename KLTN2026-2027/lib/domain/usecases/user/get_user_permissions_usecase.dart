import '../../../app/usecase.dart';
import '../../entities/user_permissions.dart';
import '../../repositories/user_repository.dart';

class GetUserPermissionsUseCase implements UseCase<UserPermissions> {
  final UserRepository repository;

  GetUserPermissionsUseCase(this.repository);

  @override
  Future<UserPermissions> execute() => repository.getUserPermissions();
}
