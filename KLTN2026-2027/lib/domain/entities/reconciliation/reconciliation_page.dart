import 'package:equatable/equatable.dart';
import 'reconciliation_transaction.dart';

class ReconciliationPage extends Equatable {
  final List<ReconciliationTransaction> items;
  final int total;
  final int page;
  final int pageSize;

  const ReconciliationPage({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  bool get hasMore => page * pageSize < total;

  @override
  List<Object?> get props => [items, total, page, pageSize];
}
