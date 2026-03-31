import '../../../../domain/entities/chat_message.dart';

class ChatDetailState {
  final bool isLoading;
  final bool isLoadingMore;
  final bool isSending;
  final String? error;
  final List<ChatMessage> allMessages; // Buffer chứa tất cả tin từ API
  final List<ChatMessage> displayedMessages; // Tin đang hiển thị
  final bool hasMore;
  final bool isOnline; // Trạng thái online của bạn bè
  final bool isBlocked; // NEW

  const ChatDetailState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isSending = false,
    this.error,
    this.allMessages = const [],
    this.displayedMessages = const [],
    this.hasMore = true,
    this.isOnline = false,
    this.isBlocked = false,
  });

  ChatDetailState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    bool? isSending,
    String? error,
    List<ChatMessage>? allMessages,
    List<ChatMessage>? displayedMessages,
    bool? hasMore,
    bool? isOnline,
    bool? isBlocked, // NEW
  }) {
    return ChatDetailState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSending: isSending ?? this.isSending,
      error: error,
      allMessages: allMessages ?? this.allMessages,
      displayedMessages: displayedMessages ?? this.displayedMessages,
      hasMore: hasMore ?? this.hasMore,
      isOnline: isOnline ?? this.isOnline,
      isBlocked: isBlocked ?? this.isBlocked, // NEW
    );
  }
}