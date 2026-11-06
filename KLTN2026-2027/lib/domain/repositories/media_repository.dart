// lib/domain/repositories/media_repository.dart

abstract class MediaRepository {
  Future<String> uploadImage(String filePath, {String? folder});
}

