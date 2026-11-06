// lib/data/repositories/media_repository_impl.dart

import '../../domain/repositories/media_repository.dart';
import '../datasource/remote/abstract/media_remote_datasource.dart';

class MediaRepositoryImpl implements MediaRepository {
  final MediaRemoteDatasource remoteDatasource;

  const MediaRepositoryImpl(this.remoteDatasource);

  @override
  Future<String> uploadImage(String filePath, {String? folder}) async {
    final dto = await remoteDatasource.uploadImage(filePath, folder: folder);
    return dto.url;
  }
}

