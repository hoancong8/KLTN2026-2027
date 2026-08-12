import 'dart:ui';

import 'package:flutter_riverpod/legacy.dart';
import 'package:kltn2026_2027/app/consts/app_log.dart';
import 'package:kltn2026_2027/ui/screen/home/tab/chat/chat_vm/chat_vm.dart';
import '../../../../app/provider.dart';
import '../../../../domain/entities/chat_message.dart';
import '../../../../domain/services/i_signalr_service.dart';
import '../../../../domain/usecases/chat/get_chat_messages_usecase.dart';
import '../../../../domain/usecases/chat/mark_all_unread_messages_as_read_usecase.dart';
import '../../../../domain/usecases/chat/send_message_usecase.dart';
import '../../../../domain/usecases/friend/block_user_usecase.dart';
import '../../../../domain/usecases/friend/unblock_user_usecase.dart';
import '../../../../domain/usecases/chat/upload_file_usecase.dart';
import '../../../../app/utils/app_exception_handler.dart';
import '../../../../domain/exceptions/app_exception.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'chat_detail_state.dart';

/// Parameters cho ChatDetailViewModel: (friendUserId, initialIsOnline)
class ChatDetailParams {
  final int friendUserId;
  final bool initialIsOnline;
  final bool isBlocked;

  const ChatDetailParams({
    required this.friendUserId,
    required this.initialIsOnline,
    this.isBlocked = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatDetailParams &&
          runtimeType == other.runtimeType &&
          friendUserId == other.friendUserId;

  @override
  int get hashCode => friendUserId.hashCode;
}

final chatDetailViewModelProvider =
    StateNotifierProvider.family<
      ChatDetailViewModel,
      ChatDetailState,
      ChatDetailParams
    >((ref, params) {
      return ChatDetailViewModel(
        friendUserId: params.friendUserId,
        initialIsOnline: params.initialIsOnline,
        initialIsBlocked: params.isBlocked,
        getChatMessagesUseCase: ref.watch(getChatMessagesUseCaseProvider),
        sendMessageUseCase: ref.watch(sendMessageUseCaseProvider),
        markAllAsReadUseCase: ref.watch(
          markAllUnreadMessagesAsReadUseCaseProvider,
        ),
        blockUserUseCase: ref.watch(blockUserUseCaseProvider),
        unblockUserUseCase: ref.watch(unblockUserUseCaseProvider),
        uploadFileUseCase: ref.watch(uploadFileUseCaseProvider),
        signalRService: ref.watch(signalRServiceProvider),
        currentUserId: ref.watch(authTokenProvider)?.userId,
        onFriendshipChanged: () =>
            ref.read(chatViewModelProvider.notifier).loadUsers(),
      );
    });

class ChatDetailViewModel extends StateNotifier<ChatDetailState> {
  final int friendUserId;
  final int? currentUserId;
  final GetChatMessagesUseCase getChatMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final MarkAllUnreadMessagesAsReadUseCase markAllAsReadUseCase;
  final BlockUserUseCase blockUserUseCase;
  final UnblockUserUseCase unblockUserUseCase;
  final UploadFileUseCase uploadFileUseCase;

  final ISignalRService signalRService;
  final VoidCallback? onFriendshipChanged;
  final List<ChatMessage> _messageQueue = [];
  bool _isProcessingQueue = false;

  ChatDetailViewModel({
    required this.friendUserId,
    required bool initialIsOnline,
    required bool initialIsBlocked,
    required this.currentUserId,
    required this.getChatMessagesUseCase,
    required this.sendMessageUseCase,
    required this.markAllAsReadUseCase,
    required this.blockUserUseCase,
    required this.unblockUserUseCase,
    required this.uploadFileUseCase,
    required this.signalRService,
    this.onFriendshipChanged,
  }) : super(
         ChatDetailState(
           isOnline: initialIsOnline,
           isBlocked: initialIsBlocked,
         ),
       ) {
    _setupSignalRListener();
    _setupConnectionListener();
  }

  late final void Function(Map<String, dynamic>) _chatMessageHandler;
  late final void Function(Map<String, dynamic>) _connectionHandler;

  @override
  void dispose() {
    signalRService.removeChatMessageListener(_chatMessageHandler);
    signalRService.removeConnectionListener(_connectionHandler);
    super.dispose();
  }

  void _setupSignalRListener() {
    _chatMessageHandler = (data) {
      if (!mounted) return;
      final senderId = data['userId'] as int?;
      final receiverId = data['targetUserId'] as int?;

      // Kiểm tra: tin nhắn giữa mình và bạn
      final isMyMessage =
          senderId == currentUserId && receiverId == friendUserId;
      final isFriendMessage =
          senderId == friendUserId && receiverId == currentUserId;

      if (isMyMessage || isFriendMessage) {
        AppLog.info(
          '[ChatDetail] Message for this chat: sender=$senderId, receiver=$receiverId',
        );
        _addMessageToState(data);
      }
    };
    signalRService.addChatMessageListener(_chatMessageHandler);
  }

  void _setupConnectionListener() {
    _connectionHandler = (data) {
      if (!mounted) return;
      final friend = data['friend'] as Map<String, dynamic>?;
      final isConnected = data['isConnected'] as bool?;

      if (friend == null || isConnected == null) return;

      final friendId = friend['friendUserId'] as int?;
      if (friendId == friendUserId) {
        AppLog.info(
          '[ChatDetail] Friend connection changed: isOnline=$isConnected',
        );
        state = state.copyWith(isOnline: isConnected);
      }
    };
    signalRService.addConnectionListener(_connectionHandler);
  }

  void _addMessageToState(Map<String, dynamic> data) {
    if (!mounted) return;

    try {
      // Parse message data
      final newMessage = ChatMessage(
        id: data['id'] as int,
        userId: data['userId'] as int,
        tenantId: data['tenantId'] as int?,
        targetUserId: data['targetUserId'] as int,
        targetTenantId: data['targetTenantId'] as int?,
        side: data['side'] as int,
        readState: data['readState'] as int,
        receiverReadState: data['receiverReadState'] as int,
        message: data['message'] as String,
        creationTime: DateTime.parse(data['creationTime'] as String),
        sharedMessageId: data['sharedMessageId'] as String,
      );

      // Nếu tin nhắn từ friend → đánh dấu đã đọc trên server
      if (newMessage.userId == friendUserId) {
        markAllAsRead();
      }

      if (newMessage.userId != friendUserId) {
        final optimisticIndex = state.allMessages.indexWhere(
              (m) =>
          m.status == MessageStatus.sending &&
              m.message == newMessage.message &&
              m.localId != null,
        );

        if (optimisticIndex != -1) {
          final updatedAll = List<ChatMessage>.from(state.allMessages);
          updatedAll[optimisticIndex] = newMessage;

          final updatedDisplayed = List<ChatMessage>.from(state.displayedMessages);
          final dispIndex = updatedDisplayed.indexWhere((m) => m.localId == state.allMessages[optimisticIndex].localId);
          if (dispIndex != -1) {
            updatedDisplayed[dispIndex] = newMessage;
          }

          state = state.copyWith(
            allMessages: updatedAll,
            displayedMessages: updatedDisplayed,
          );
          return;
        }
      }

      // Thêm vào cuối danh sách
      state = state.copyWith(
        allMessages: [...state.allMessages, newMessage],
        displayedMessages: [...state.displayedMessages, newMessage],
      );

      AppLog.info('[ChatDetail] Message added to state');
    } catch (e) {
      AppLog.info('[ChatDetail] Error adding message: $e');
      // Nếu parse lỗi thì reload
      loadMessages();
    }
  }

  Future<void> loadMessages() async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final messages = await getChatMessagesUseCase.execute(
        userId: friendUserId,
        tenantId: null,
        minMessageId: null,
      );

      if (!mounted) return;

      // Lấy 20 tin cuối cùng (mới nhất)
      final displayed = messages.length > 20
          ? messages.sublist(messages.length - 20)
          : messages;

      state = state.copyWith(
        isLoading: false,
        allMessages: messages,
        displayedMessages: displayed,
        hasMore: messages.length >= 50,
      );
    } on AppException catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: AppExceptionHandler.handle(e),
      );
    }
  }

  Future<void> loadMoreMessages() async {
    if (!mounted || state.isLoadingMore) return;

    AppLog.info('[ChatDetail] === Load More Triggered ===');
    AppLog.info(
      '[ChatDetail] Current displayed: ${state.displayedMessages.length}',
    );
    AppLog.info('[ChatDetail] Total in buffer: ${state.allMessages.length}');

    // Tính số tin chưa hiển thị trong buffer (phần đầu)
    final undisplayedCount =
        state.allMessages.length - state.displayedMessages.length;

    // Nếu còn tin trong buffer (phần cũ hơn)
    if (undisplayedCount > 0) {
      final loadCount = undisplayedCount > 20 ? 20 : undisplayedCount;
      final startIndex =
          state.allMessages.length - state.displayedMessages.length - loadCount;
      final endIndex =
          state.allMessages.length - state.displayedMessages.length;

      AppLog.info(
        '[ChatDetail] Loading from buffer: $loadCount messages (index $startIndex to $endIndex)',
      );

      final newDisplayed = state.allMessages.sublist(startIndex, endIndex);

      state = state.copyWith(
        displayedMessages: [...newDisplayed, ...state.displayedMessages],
      );

      AppLog.info(
        '[ChatDetail] After buffer load - displayed: ${state.displayedMessages.length}',
      );
      return;
    }

    // Hết buffer, gọi API
    if (!state.hasMore) {
      AppLog.info('[ChatDetail] No more messages from API');
      return;
    }

    AppLog.info('[ChatDetail] Buffer empty, calling API...');
    state = state.copyWith(isLoadingMore: true);

    try {
      final oldestMessageId = state.allMessages.isNotEmpty
          ? state.allMessages.map((m) => m.id).reduce((a, b) => a < b ? a : b)
          : null;

      final newMessages = await getChatMessagesUseCase.execute(
        userId: friendUserId,
        tenantId: null,
        minMessageId: oldestMessageId,
      );

      if (!mounted) return;

      // Lọc bỏ tin trùng (nếu có)
      final existingIds = state.allMessages.map((m) => m.id).toSet();
      final uniqueNewMessages = newMessages
          .where((m) => !existingIds.contains(m.id))
          .toList();

      if (uniqueNewMessages.isEmpty) {
        state = state.copyWith(isLoadingMore: false, hasMore: false);
        return;
      }

      final loadCount = uniqueNewMessages.length > 20
          ? 20
          : uniqueNewMessages.length;
      final newDisplayed = uniqueNewMessages.sublist(
        uniqueNewMessages.length - loadCount,
      );

      state = state.copyWith(
        isLoadingMore: false,
        allMessages: [...uniqueNewMessages, ...state.allMessages],
        displayedMessages: [...newDisplayed, ...state.displayedMessages],
        hasMore: uniqueNewMessages.length >= 50,
      );

      AppLog.info(
        '[ChatDetail] After API load - buffer: ${state.allMessages.length}, displayed: ${state.displayedMessages.length}',
      );
    } catch (e) {
      AppLog.info('[ChatDetail] Error loading more: $e');
      if (!mounted) return;
      state = state.copyWith(
        isLoadingMore: false,
        error: AppExceptionHandler.handle(e),
      );
    }
  }

  Future<void> sendMessage(String message) async {
    final text = message.trim();
    if (text.isEmpty || !mounted) return;
    final localMsg = ChatMessage(
      id: -DateTime.now().microsecondsSinceEpoch, // ID âm tạm thời
      userId: currentUserId ?? 0,
      targetUserId: friendUserId,
      side: 1,
      readState: 1,
      receiverReadState: 1,
      message: text,
      creationTime: DateTime.now(),
      status: MessageStatus.sending,
      localId: DateTime.now().microsecondsSinceEpoch.toString(),
    );

    // 2. Cập nhật UI ngay lập tức
    state = state.copyWith(
      allMessages: [...state.allMessages, localMsg],
      displayedMessages: [...state.displayedMessages, localMsg],
    );

    // 3. Đưa vào hàng đợi và xử lý
    _messageQueue.add(localMsg);
    _processQueue();
    }

  Future<void> _processQueue() async {
    if (_isProcessingQueue || _messageQueue.isEmpty) return;
    _isProcessingQueue = true;

    while (_messageQueue.isNotEmpty) {
      final msg = _messageQueue.first;
      try {
        await sendMessageUseCase.execute(
          userId: friendUserId,
          tenantId: null,
          message: msg.message,
        );
        // Sau khi gửi thành công qua SignalR invoke,
        // SignalR sẽ tự push lại tin nhắn thật qua listener (_addMessageToState)
        // nên ta chỉ cần xóa khỏi queue.
        _messageQueue.removeAt(0);
      } catch (e) {
        AppLog.error('Error sending message: $e');
        if (!mounted) break;

        // Cập nhật trạng thái lỗi cho tin nhắn
        final updatedAll = state.allMessages.map((m) {
          if (m.localId == msg.localId) {
            return ChatMessage(
              id: m.id,
              userId: m.userId,
              targetUserId: m.targetUserId,
              side: m.side,
              readState: m.readState,
              receiverReadState: m.receiverReadState,
              message: m.message,
              creationTime: m.creationTime,
              status: MessageStatus.error,
              localId: m.localId,
            );
          }
          return m;
        }).toList();

        final updatedDisplayed = state.displayedMessages.map((m) {
          if (m.localId == msg.localId) {
            return ChatMessage(
              id: m.id,
              userId: m.userId,
              targetUserId: m.targetUserId,
              side: m.side,
              readState: m.readState,
              receiverReadState: m.receiverReadState,
              message: m.message,
              creationTime: m.creationTime,
              status: MessageStatus.error,
              localId: m.localId,
            );
          }
          return m;
        }).toList();

        state = state.copyWith(
          allMessages: updatedAll,
          displayedMessages: updatedDisplayed,
        );

        _messageQueue.removeAt(0); // Tạm thời bỏ qua tin nhắn lỗi để không kẹt queue
      }
    }

    _isProcessingQueue = false;
  }



  Future<void> markAllAsRead() async {
    if (!mounted) return;

    try {
      await markAllAsReadUseCase.execute(userId: friendUserId, tenantId: null);
      AppLog.info('[ChatDetail] Marked all messages as read');
    } catch (e) {
      AppLog.info('[ChatDetail] Error marking as read: $e');
    }
  }

  void addNewMessage(Map<String, dynamic> data) {
    // Không cần nữa vì đã có _setupSignalRListener
  }

  Future<void> blockUser() async {
    try {
      // TenantId is null because we are blocking a friend, context is implicit or we can fetch if needed.
      // But USE CASE allows null tenantId (ChatRepository handles it fallback).
      await blockUserUseCase.execute(friendUserId, null);
      if (!mounted) return;
      state = state.copyWith(isBlocked: true);
      onFriendshipChanged?.call();
    } catch (e) {
      AppLog.info('Block user failed: $e');
      if (!mounted) return;
      final ex = AppExceptionHandler.handle(e);
      state = state.copyWith(
        error: AppException(
          message: 'Chặn người dùng thất bại: ${ex.message ?? ex.toString()}',
          originalError: ex,
        ),
      );
    }
  }

  Future<void> unblockUser() async {
    try {
      await unblockUserUseCase.execute(friendUserId, null);
      if (!mounted) return;
      state = state.copyWith(isBlocked: false);
      onFriendshipChanged?.call();
    } catch (e) {
      AppLog.info('Unblock user failed: $e');
      if (!mounted) return;
      final ex = AppExceptionHandler.handle(e);
      state = state.copyWith(
        error: AppException(
          message:
              'Bỏ chặn người dùng thất bại: ${ex.message ?? ex.toString()}',
          originalError: ex,
        ),
      );
    }
  }

  Future<void> pickAndUploadImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      await _uploadAndSendMessage(
        pickedFile.path,
        pickedFile.name,
        isImage: true,
      );
    }
  }

  Future<void> pickAndUploadFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      final file = result.files.single;
      await _uploadAndSendMessage(file.path!, file.name, isImage: false);
    }
  }

  Future<void> _uploadAndSendMessage(
    String filePath,
    String fileName, {
    required bool isImage,
  }) async {
    state = state.copyWith(isSending: true);
    try {
      final uploadResult = await uploadFileUseCase.execute(filePath, fileName);

      final metadata = {
        'id': uploadResult.id,
        'name': uploadResult.name,
        'contentType': uploadResult.contentType,
      };

      final prefix = isImage ? '[image]' : '[file]';
      final messageContent = '$prefix${jsonEncode(metadata)}';

      await sendMessage(messageContent);
    } catch (e) {
      AppLog.info('Upload failed: $e');
      if (mounted) {
        final ex = AppExceptionHandler.handle(e);
        state = state.copyWith(
          isSending: false,
          error: AppException(
            message: 'Tải lên thất bại: ${ex.message ?? ex.toString()}',
            originalError: ex,
          ),
        );
      }
    }
  }
}
