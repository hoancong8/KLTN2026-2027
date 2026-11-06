// lib/domain/repositories/media_repository.dart

abstract class MediaRepository {
  Future<String> uploadImage({
    required List<int> bytes,
    required String fileName,
    String? folder,
  });
}

