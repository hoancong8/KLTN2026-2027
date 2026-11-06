// lib/domain/usecases/media/upload_image_usecase.dart

import '../../repositories/media_repository.dart';

class UploadImageUseCase {
  final MediaRepository repository;

  const UploadImageUseCase(this.repository);

  Future<String> execute({
    required List<int> bytes,
    required String fileName,
    String? folder,
  }) {
    return repository.uploadImage(
      bytes: bytes,
      fileName: fileName,
      folder: folder,
    );
  }
}

