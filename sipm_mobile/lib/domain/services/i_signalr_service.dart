abstract class ISignalRService {
  Future<void> connect(
      String accessToken, {
        Function(Map<String, dynamic>)? onMessageReceived,
        Function(Map<String, dynamic>)? onUserConnectionChange,
        Function(Map<String, dynamic>)? onAllUnreadMessagesRead,
        String? Function()? tokenGetter,
      });

  Future<void> disconnect({bool clear = false});

  void addChatMessageListener(Function(Map<String, dynamic>) listener);
  void removeChatMessageListener(Function(Map<String, dynamic>) listener);

  void addConnectionListener(Function(Map<String, dynamic>) listener);
  void removeConnectionListener(Function(Map<String, dynamic>) listener);

  void updateToken(String newToken);

  Future<void> sendMessage({
    required int tenantId,
    required int userId,
    required String message,
  });

  bool get isConnected;
}