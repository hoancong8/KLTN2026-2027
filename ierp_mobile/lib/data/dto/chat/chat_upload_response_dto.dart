class ChatUploadResponseDto {
  final ChatUploadResultDto result;
  final bool success;

  ChatUploadResponseDto({required this.result, required this.success});

  factory ChatUploadResponseDto.fromJson(Map<String, dynamic> json) {
    return ChatUploadResponseDto(
      result: ChatUploadResultDto.fromJson(json['result']),
      success: json['success'],
    );
  }
}

class ChatUploadResultDto {
  final String id;
  final String name;
  final String contentType;

  ChatUploadResultDto({
    required this.id,
    required this.name,
    required this.contentType,
  });

  factory ChatUploadResultDto.fromJson(Map<String, dynamic> json) {
    return ChatUploadResultDto(
      id: json['id'],
      name: json['name'],
      contentType: json['contentType'],
    );
  }
}