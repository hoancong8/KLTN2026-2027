// lib/data/repositories/media_repository_impl.dart

import '../../domain/repositories/media_repository.dart';
import '../datasource/remote/abstract/media_remote_datasource.dart';

class MediaRepositoryImpl implements MediaRepository {
  final MediaRemoteDatasource remoteDatasource;

  const MediaRepositoryImpl(this.remoteDatasource);

  @override
  Future<String> uploadImage({
    required List<int> bytes,
    required String fileName,
    String? folder,
  }) async {
    final dto = await remoteDatasource.uploadImage(
      bytes: bytes,
      fileName: fileName,
      folder: folder,
    );
    return dto.url;
  }
}

