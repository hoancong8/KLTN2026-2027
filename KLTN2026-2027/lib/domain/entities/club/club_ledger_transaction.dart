enum LedgerTransactionType {
  income,
  expense,
}

enum LedgerCategory {
  courtRental('Tiền thuê sân'),
  shuttlecock('Mua cầu lông'),
  monthlyFund('Đóng quỹ tháng'),
  sessionFee('Thu tiền buổi chơi'),
  drink('Nước uống & Bổ sung'),
  party('Liên hoan & Giao lưu'),
  other('Chi phí khác');

  final String label;
  const LedgerCategory(this.label);
}

class ClubLedgerTransaction {
  final String id;
  final String clubId;
  final String title;
  final int amount; // Dương = Thu, Âm = Chi
  final LedgerTransactionType type;
  final LedgerCategory category;
  final DateTime createdAt;
  final String creatorName;
  final bool isVerified;
  final String? note;
  final String paymentMethod; // 'VIETQR' | 'CASH'

  const ClubLedgerTransaction({
    required this.id,
    required this.clubId,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.createdAt,
    required this.creatorName,
    this.isVerified = true,
    this.note,
    this.paymentMethod = 'VIETQR',
  });
}
