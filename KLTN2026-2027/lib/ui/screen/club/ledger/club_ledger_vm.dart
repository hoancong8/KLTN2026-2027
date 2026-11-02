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
      state = state.copyWith(
        isLoading: false,
        transactions: const [],
        totalIncome: 0,
        totalExpense: 0,
        balance: 0,
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
