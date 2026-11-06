// lib/domain/usecases/media/upload_image_usecase.dart

import '../../repositories/media_repository.dart';

class UploadImageUseCase {
  final MediaRepository repository;

  const UploadImageUseCase(this.repository);

  Future<String> execute(String filePath, {String? folder}) {
    return repository.uploadImage(filePath, folder: folder);
  }
}

