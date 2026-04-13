import '../../services/i_signalr_service.dart';

class SendMessageUseCase {
  final ISignalRService signalRService;

  SendMessageUseCase(this.signalRService);

  Future<void> execute({
    required int userId,
    int? tenantId,
    required String message,
  }) {
    return signalRService.sendMessage(
      tenantId: tenantId ?? 0,
      userId: userId,
      message: message,
    );
  }
}
