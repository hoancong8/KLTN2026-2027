// lib/data/datasource/remote/abstract/media_remote_datasource.dart

import '../../../dto/media/upload_image_response_dto.dart';

abstract class MediaRemoteDatasource {
  Future<UploadImageResponseDto> uploadImage({
    required List<int> bytes,
    required String fileName,
    String? folder,
  });
}

