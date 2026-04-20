import 'package:equatable/equatable.dart';

enum MessageStatus{ sending, sent, error }

class ChatMessage extends Equatable {
  final int id;
  final int userId;
  final int? tenantId;
  final int targetUserId;
  final int? targetTenantId;
  final int side; // 1=Sender, 2=Receiver
  final int readState; // 1=Unread, 2=Read
  final int receiverReadState;
  final String message;
  final DateTime creationTime;
  final String? sharedMessageId;
  final MessageStatus status;
  final String? localId;

  const ChatMessage({
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
    this.sharedMessageId,
    this.status = MessageStatus.sent,
    this.localId
  });

  bool get isMine => side == 1;

  @override
  List<Object?> get props => [
    id,
    userId,
    tenantId,
    targetUserId,
    targetTenantId,
    side,
    readState,
    receiverReadState,
    message,
    creationTime,
    sharedMessageId,
    status,
    localId
  ];
}
