import '../../repositories/chat_repository.dart';
import '../../entities/chat_upload_result.dart';

class UploadFileUseCase {
  final ChatRepository repository;

  UploadFileUseCase(this.repository);

  Future<ChatUploadResult> execute(String filePath, String fileName) async {
    return await repository.uploadFile(filePath, fileName);
  }
}