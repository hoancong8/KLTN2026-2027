class SessionAdvance {
  const SessionAdvance({
    required this.id,
    required this.sessionId,
    required this.title,
    required this.status,
    required this.amount,
    required this.received,
    required this.applied,
    required this.refundDue,
    required this.canPrepare,
    required this.canHandle,
    required this.refundClaimed,
    this.qrPayload,
    this.code,
    this.reason,
    this.bank,
    this.account,
    this.holder,
    this.reference,
    this.reviewTransactionId,
    this.reviewAmount,
    this.reviewReference,
    this.payerName,
  });

  final String? id,
      qrPayload,
      code,
      reason,
      bank,
      account,
      holder,
      reference,
      reviewTransactionId;
  final String sessionId, title, status;
  final String? payerName, reviewReference;
  final num? reviewAmount;
  final num amount, received, applied, refundDue;
  final bool canPrepare, canHandle, refundClaimed;
}
