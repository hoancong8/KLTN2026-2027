// lib/data/dto/media/upload_image_response_dto.dart

class UploadImageResponseDto {
  final String url;

  const UploadImageResponseDto({required this.url});

  factory UploadImageResponseDto.fromJson(dynamic rawJson) {
    if (rawJson is! Map) {
      return const UploadImageResponseDto(url: '');
    }

    final url = (rawJson['url'] ?? rawJson['secure_url'] ?? rawJson['secureUrl'])?.toString() ?? '';
    return UploadImageResponseDto(url: url);
  }
}

