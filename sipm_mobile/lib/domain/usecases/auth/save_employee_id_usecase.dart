import '../../repositories/token_storage_repository.dart';

class SaveEmployeeIdUseCase {
  final TokenStorageRepository repository;

  SaveEmployeeIdUseCase(this.repository);

  Future<void> execute(int employeeId) async {
    await repository.saveEmployeeId(employeeId);
  }
}
