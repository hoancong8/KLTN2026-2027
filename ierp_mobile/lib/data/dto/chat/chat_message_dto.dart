class ChatMessageDto {
  final int id;
  final int userId;
  final int? tenantId;
  final int targetUserId;
  final int? targetTenantId;
  final int side;
  final int readState;
  final int receiverReadState;
  final String message;
  final String creationTime;
  final String sharedMessageId;

  ChatMessageDto({
    required this.id,
    required this.userId,
    this.tenantId,
    required this.targetUserId,
    this.targetTenantId,
    required this.side,
    required this.readState,
    required this.receiverReadState,
    required this.message,
    required this.creationTime,
    required this.sharedMessageId,
  });

  factory ChatMessageDto.fromJson(Map<String, dynamic> json) {
    return ChatMessageDto(
      id: json['id'] as int,
      userId: json['userId'] as int,
      tenantId: json['tenantId'] as int?,
      targetUserId: json['targetUserId'] as int,
      targetTenantId: json['targetTenantId'] as int?,
      side: json['side'] as int,
      readState: json['readState'] as int,
      receiverReadState: json['receiverReadState'] as int,
      message: json['message'] as String,
      creationTime: json['creationTime'] as String,
      sharedMessageId: json['sharedMessageId'] as String,
    );
  }
}