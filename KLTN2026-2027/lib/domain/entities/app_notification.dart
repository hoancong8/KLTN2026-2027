import 'package:equatable/equatable.dart';

class AppNotification extends Equatable {
  final String id;
  final String title;
  final String content;
  final String type;
  final String? referenceType;
  final String? referenceId;
  final String? groupId;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    this.referenceType,
    this.referenceId,
    this.groupId,
    this.isRead = false,
    required this.createdAt,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? content,
    String? type,
    String? referenceType,
    String? referenceId,
    String? groupId,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      referenceType: referenceType ?? this.referenceType,
      referenceId: referenceId ?? this.referenceId,
      groupId: groupId ?? this.groupId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    content,
    type,
    referenceType,
    referenceId,
    groupId,
    isRead,
    createdAt,
  ];
}

