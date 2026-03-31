import '../../repositories/token_storage_repository.dart';

class SaveTenantIdUseCase {
  final TokenStorageRepository repository;

  SaveTenantIdUseCase(this.repository);

  Future<void> execute(int tenantId) async {
    await repository.saveTenantId(tenantId);
  }
}
