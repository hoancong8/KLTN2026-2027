import '../../repositories/token_storage_repository.dart';

class GetEmployeeIdUseCase {
  final TokenStorageRepository repository;

  GetEmployeeIdUseCase(this.repository);

  Future<int?> execute() async {
    return await repository.getEmployeeId();
  }
}
