import 'package:flutter_riverpod/legacy.dart';
import '../../../../domain/entities/club/club_ledger_transaction.dart';

class ClubLedgerState {
  final bool isLoading;
  final int balance;
  final int totalIncome;
  final int totalExpense;
  final List<ClubLedgerTransaction> transactions;
  final String filter; // 'ALL' | 'INCOME' | 'EXPENSE'
  final String? error;

  const ClubLedgerState({
    this.isLoading = false,
    this.balance = 0,
    this.totalIncome = 0,
    this.totalExpense = 0,
    this.transactions = const [],
    this.filter = 'ALL',
    this.error,
  });

  List<ClubLedgerTransaction> get filteredTransactions {
    if (filter == 'INCOME') {
      return transactions.where((t) => t.type == LedgerTransactionType.income).toList();
    }
    if (filter == 'EXPENSE') {
      return transactions.where((t) => t.type == LedgerTransactionType.expense).toList();
    }
    return transactions;
  }

  ClubLedgerState copyWith({
    bool? isLoading,
    int? balance,
    int? totalIncome,
    int? totalExpense,
    List<ClubLedgerTransaction>? transactions,
    String? filter,
    String? error,
  }) {
    return ClubLedgerState(
      isLoading: isLoading ?? this.isLoading,
      balance: balance ?? this.balance,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      transactions: transactions ?? this.transactions,
      filter: filter ?? this.filter,
      error: error,
    );
  }
}

class ClubLedgerViewModel extends StateNotifier<ClubLedgerState> {
  final String clubId;

  ClubLedgerViewModel(this.clubId) : super(const ClubLedgerState()) {
    loadLedger();
  }

  Future<void> loadLedger() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Dữ liệu mẫu chuẩn hạch toán minh bạch (FR22 / UC19)
      final now = DateTime.now();
      final mockTransactions = [
        ClubLedgerTransaction(
          id: 'tx-1',
          clubId: clubId,
          title: 'Thu tiền buổi chơi Thứ 4',
          amount: 540000,
          type: LedgerTransactionType.income,
          category: LedgerCategory.sessionFee,
          createdAt: now.subtract(const Duration(hours: 3)),
          creatorName: 'Hệ thống (VietQR)',
          isVerified: true,
          note: 'Đối soát tự động từ 9 người chơi tham gia',
          paymentMethod: 'VIETQR',
        ),
        ClubLedgerTransaction(
          id: 'tx-2',
          clubId: clubId,
          title: 'Thanh toán tiền thuê sân',
          amount: -300000,
          type: LedgerTransactionType.expense,
          category: LedgerCategory.courtRental,
          createdAt: now.subtract(const Duration(hours: 4)),
          creatorName: 'Trần Văn Host',
          isVerified: true,
          note: '2 sân x 3 giờ tại Sân Cầu Lông Kỳ Hòa',
          paymentMethod: 'VIETQR',
        ),
        ClubLedgerTransaction(
          id: 'tx-3',
          clubId: clubId,
          title: 'Mua 2 ống cầu Hải Yến',
          amount: -520000,
          type: LedgerTransactionType.expense,
          category: LedgerCategory.shuttlecock,
          createdAt: now.subtract(const Duration(days: 2)),
          creatorName: 'Lê Thủ Quỹ',
          isVerified: true,
          note: 'Hóa đơn mã HY-2026-883',
          paymentMethod: 'CASH',
        ),
        ClubLedgerTransaction(
          id: 'tx-4',
          clubId: clubId,
          title: 'Hội viên Nguyễn Văn A đóng quỹ tháng',
          amount: 500000,
          type: LedgerTransactionType.income,
          category: LedgerCategory.monthlyFund,
          createdAt: now.subtract(const Duration(days: 3)),
          creatorName: 'Hệ thống (VietQR)',
          isVerified: true,
          note: 'Quỹ hội viên trọn gói tháng',
          paymentMethod: 'VIETQR',
        ),
        ClubLedgerTransaction(
          id: 'tx-5',
          clubId: clubId,
          title: 'Hội viên Trần Thị B đóng quỹ tháng',
          amount: 500000,
          type: LedgerTransactionType.income,
          category: LedgerCategory.monthlyFund,
          createdAt: now.subtract(const Duration(days: 4)),
          creatorName: 'Hệ thống (VietQR)',
          isVerified: true,
          note: 'Quỹ hội viên trọn gói tháng',
          paymentMethod: 'VIETQR',
        ),
        ClubLedgerTransaction(
          id: 'tx-6',
          clubId: clubId,
          title: 'Mua thùng nước khoáng Revive',
          amount: -210000,
          type: LedgerTransactionType.expense,
          category: LedgerCategory.drink,
          createdAt: now.subtract(const Duration(days: 5)),
          creatorName: 'Lê Thủ Quỹ',
          isVerified: true,
          note: 'Phục vụ giải khát tại sân',
          paymentMethod: 'CASH',
        ),
      ];

      var income = 0;
      var expense = 0;
      for (final tx in mockTransactions) {
        if (tx.amount > 0) {
          income += tx.amount;
        } else {
          expense += tx.amount.abs();
        }
      }

      state = state.copyWith(
        isLoading: false,
        transactions: mockTransactions,
        totalIncome: income,
        totalExpense: expense,
        balance: income - expense,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setFilter(String filter) {
    state = state.copyWith(filter: filter);
  }

  Future<void> addTransaction({
    required String title,
    required int amount,
    required LedgerTransactionType type,
    required LedgerCategory category,
    required String creatorName,
    String? note,
    String paymentMethod = 'CASH',
  }) async {
    final finalAmount = type == LedgerTransactionType.expense ? -amount.abs() : amount.abs();
    final newTx = ClubLedgerTransaction(
      id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
      clubId: clubId,
      title: title,
      amount: finalAmount,
      type: type,
      category: category,
      createdAt: DateTime.now(),
      creatorName: creatorName,
      isVerified: true,
      note: note,
      paymentMethod: paymentMethod,
    );

    final updated = [newTx, ...state.transactions];
    var income = 0;
    var expense = 0;
    for (final tx in updated) {
      if (tx.amount > 0) {
        income += tx.amount;
      } else {
        expense += tx.amount.abs();
      }
    }

    state = state.copyWith(
      transactions: updated,
      totalIncome: income,
      totalExpense: expense,
      balance: income - expense,
    );
  }
}

final clubLedgerViewModelProvider =
    StateNotifierProvider.family<ClubLedgerViewModel, ClubLedgerState, String>((ref, clubId) {
  return ClubLedgerViewModel(clubId);
});
