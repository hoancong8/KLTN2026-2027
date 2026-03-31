import '../../../app/services/signalr_service.dart';

class SendMessageUseCase {
  final SignalRService signalRService;

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