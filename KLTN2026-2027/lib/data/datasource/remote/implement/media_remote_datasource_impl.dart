// lib/data/datasource/remote/implement/media_remote_datasource_impl.dart

import 'package:dio/dio.dart';
import '../../../../app/consts/app_config.dart';
import '../../../dto/media/upload_image_response_dto.dart';
import '../abstract/media_remote_datasource.dart';
import '../base_remote_datasource.dart';

class MediaRemoteDatasourceImpl extends BaseRemoteDatasource implements MediaRemoteDatasource {
  final Dio dio;

  MediaRemoteDatasourceImpl(this.dio);

  @override
  Future<UploadImageResponseDto> uploadImage({
    required List<int> bytes,
    required String fileName,
    String? folder,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: fileName),
        if (folder != null && folder.isNotEmpty) 'folder': folder,
      });

      final response = await dio.post(
        AppConfig.mediaUploadPath,
        data: formData,
      );

      return handleResponse(response, (data) => UploadImageResponseDto.fromJson(data));
    } catch (e) {
      throw handleError(e);
    }
  }
}

