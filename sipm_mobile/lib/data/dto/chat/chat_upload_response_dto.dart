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
      id: json['id'] as String,
      name: json['name'] as String,
      contentType: json['contentType'] as String,
    );
  }
}