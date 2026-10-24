// lib/ui/screen/home/tab/club/widgets/club_ledger_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../../app/provider.dart';
import '../../../../../../app/theme/theme.dart';
import '../../../../../../domain/entities/club/club_ledger_transaction.dart';
import '../../../../../../domain/enums/club_role.dart';
import '../../../../club/ledger/club_ledger_vm.dart';

class ClubLedgerTab extends ConsumerStatefulWidget {
  final String clubId;

  const ClubLedgerTab({super.key, required this.clubId});

  @override
  ConsumerState<ClubLedgerTab> createState() => _ClubLedgerTabState();
}

class _ClubLedgerTabState extends ConsumerState<ClubLedgerTab> {
  AppThemeColors get colors => context.colors;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(clubLedgerViewModelProvider(widget.clubId));
    final vm = ref.read(clubLedgerViewModelProvider(widget.clubId).notifier);
    final activeContext = ref.watch(activeClubContextProvider);
    final currentProfile = ref.watch(currentUserProfileProvider);

    final isSameClub = activeContext?.clubId == widget.clubId;
    final isHost = isSameClub && activeContext?.role == ClubRole.host;
    final isTreasurer = isSameClub && activeContext?.role == ClubRole.treasurer;
    final canManageFinance = isHost || isTreasurer || (isSameClub && ref.hasClubPermission('FINANCE.MANAGE'));

    return Scaffold(
      backgroundColor: AppColors.transparent,
      floatingActionButton: canManageFinance
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateTransactionSheet(context, vm, currentProfile?.userName ?? 'Thủ quỹ'),
              backgroundColor: colors.primary,
              foregroundColor: AppColors.white,
              elevation: 2,
              icon: const Icon(Icons.add_card_rounded),
              label: Text('Tạo phiếu thu/chi', style: AppTypography.labelLarge.bold.colored(AppColors.white)),
            )
          : null,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: state.isLoading
              ? Center(child: CircularProgressIndicator(color: colors.primary))
              : RefreshIndicator(
                  onRefresh: () => vm.loadLedger(),
                  color: colors.primary,
                  child: ListView(
                    padding: AppSpacing.allBase,
                    children: [
                      _buildBalanceCard(state),
                      AppSpacing.gapH16,
                      _buildFilterBar(state, vm),
                      AppSpacing.gapH16,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Lịch sử biến động quỹ (${state.filteredTransactions.length})',
                            style: AppTypography.titleSmall.bold.colored(colors.textPrimary),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: colors.success.withValues(alpha: 0.12),
                              borderRadius: AppRadius.tag,
                              border: Border.all(color: colors.success.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified_rounded, size: 12, color: colors.success),
                                AppSpacing.gapW4,
                                Text(
                                  '100% Minh Bạch',
                                  style: AppTypography.labelSmall.bold.colored(colors.success),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.gapH12,
                      if (state.filteredTransactions.isEmpty)
                        _buildEmptyState()
                      else
                        ...state.filteredTransactions.map((tx) => _buildTransactionCard(tx)),
                      AppSpacing.gapH32,
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(ClubLedgerState state) {
    final currencyFormat = NumberFormat('#,###');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: AppRadius.card,
        border: Border.all(color: colors.cardBorder),
        boxShadow: context.isDark ? AppShadows.none : AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Số dư khả dụng hiện tại',
                style: AppTypography.labelMedium.colored(colors.textMuted),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  borderRadius: AppRadius.tag,
                ),
                child: Text(
                  'Quỹ nhóm',
                  style: AppTypography.labelSmall.bold.colored(colors.primary),
                ),
              ),
            ],
          ),
          AppSpacing.gapH8,
          Text(
            '${currencyFormat.format(state.balance)} đ',
            style: AppTypography.headlineMedium.copyWith(
              color: state.balance >= 0 ? colors.textPrimary : colors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.gapH16,
          Divider(height: 1, color: colors.cardBorder),
          AppSpacing.gapH16,
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.success.withValues(alpha: 0.08),
                    borderRadius: AppRadius.borderSm,
                    border: Border.all(color: colors.success.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.arrow_downward_rounded, size: 16, color: colors.success),
                          AppSpacing.gapW4,
                          Text('Tổng thu', style: AppTypography.labelSmall.colored(colors.success)),
                        ],
                      ),
                      AppSpacing.gapH4,
                      Text(
                        '+${currencyFormat.format(state.totalIncome)} đ',
                        style: AppTypography.titleSmall.bold.colored(colors.success),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              AppSpacing.gapW12,
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.error.withValues(alpha: 0.08),
                    borderRadius: AppRadius.borderSm,
                    border: Border.all(color: colors.error.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.arrow_upward_rounded, size: 16, color: colors.error),
                          AppSpacing.gapW4,
                          Text('Tổng chi', style: AppTypography.labelSmall.colored(colors.error)),
                        ],
                      ),
                      AppSpacing.gapH4,
                      Text(
                        '-${currencyFormat.format(state.totalExpense)} đ',
                        style: AppTypography.titleSmall.bold.colored(colors.error),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(ClubLedgerState state, ClubLedgerViewModel vm) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('Tất cả', state.filter == 'ALL', () => vm.setFilter('ALL')),
          AppSpacing.gapW8,
          _buildFilterChip('Tiền thu (+)', state.filter == 'INCOME', () => vm.setFilter('INCOME')),
          AppSpacing.gapW8,
          _buildFilterChip('Tiền chi (-)', state.filter == 'EXPENSE', () => vm.setFilter('EXPENSE')),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.tag,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : colors.cardBackground,
          borderRadius: AppRadius.tag,
          border: Border.all(
            color: isSelected ? colors.primary : colors.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected ? AppColors.white : colors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(ClubLedgerTransaction tx) {
    final currencyFormat = NumberFormat('#,###');
    final isIncome = tx.type == LedgerTransactionType.income;
    final amountColor = isIncome ? colors.success : colors.error;
    final amountText = '${isIncome ? '+' : '-'}${currencyFormat.format(tx.amount.abs())} đ';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: AppRadius.card,
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (isIncome ? colors.success : colors.error).withValues(alpha: 0.1),
                  borderRadius: AppRadius.borderSm,
                ),
                child: Icon(
                  _getCategoryIcon(tx.category),
                  color: isIncome ? colors.success : colors.error,
                  size: 20,
                ),
              ),
              AppSpacing.gapW12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.title,
                      style: AppTypography.titleSmall.bold.colored(colors.textPrimary),
                    ),
                    AppSpacing.gapH4,
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.surfaceSubtle,
                            borderRadius: AppRadius.tag,
                            border: Border.all(color: colors.cardBorder),
                          ),
                          child: Text(
                            tx.category.label,
                            style: AppTypography.labelSmall.copyWith(color: colors.textSecondary),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.1),
                            borderRadius: AppRadius.tag,
                          ),
                          child: Text(
                            tx.paymentMethod,
                            style: AppTypography.labelSmall.bold.colored(colors.primary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              AppSpacing.gapW8,
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amountText,
                    style: AppTypography.titleSmall.bold.colored(amountColor),
                  ),
                  AppSpacing.gapH4,
                  Text(
                    DateFormat('HH:mm, dd/MM').format(tx.createdAt),
                    style: AppTypography.labelSmall.colored(colors.textMuted),
                  ),
                ],
              ),
            ],
          ),
          if (tx.note != null && tx.note!.isNotEmpty) ...[
            AppSpacing.gapH8,
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: colors.surfaceSubtle,
                borderRadius: AppRadius.borderXs,
              ),
              child: Text(
                'Ghi chú: ${tx.note}',
                style: AppTypography.labelSmall.colored(colors.textMuted),
              ),
            ),
          ],
          AppSpacing.gapH8,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Người lập: ${tx.creatorName}',
                style: AppTypography.labelSmall.colored(colors.textMuted),
              ),
              if (tx.isVerified)
                Row(
                  children: [
                    Icon(Icons.check_circle_rounded, size: 13, color: colors.success),
                    AppSpacing.gapW4,
                    Text('Đã đối soát', style: AppTypography.labelSmall.bold.colored(colors.success)),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined, size: 48, color: colors.textMuted),
          AppSpacing.gapH12,
          Text(
            'Chưa có giao dịch quỹ nào',
            style: AppTypography.titleSmall.bold.colored(colors.textSecondary),
          ),
          AppSpacing.gapH4,
          Text(
            'Mọi biến động thu chi quỹ sẽ được ghi nhận minh bạch tại đây.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.colored(colors.textMuted),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(LedgerCategory category) {
    switch (category) {
      case LedgerCategory.courtRental:
        return Icons.stadium_rounded;
      case LedgerCategory.shuttlecock:
        return Icons.sports_tennis_rounded;
      case LedgerCategory.monthlyFund:
        return Icons.card_membership_rounded;
      case LedgerCategory.sessionFee:
        return Icons.payments_rounded;
      case LedgerCategory.drink:
        return Icons.local_drink_rounded;
      case LedgerCategory.party:
        return Icons.celebration_rounded;
      case LedgerCategory.other:
        return Icons.receipt_rounded;
    }
  }

  void _showCreateTransactionSheet(BuildContext context, ClubLedgerViewModel vm, String creatorName) {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    var selectedType = LedgerTransactionType.expense;
    var selectedCategory = LedgerCategory.shuttlecock;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tạo Phiếu Thu / Chi Quỹ',
                      style: AppTypography.titleMedium.bold.colored(colors.textPrimary),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                AppSpacing.gapH12,
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Phiếu Chi (-)')),
                        selected: selectedType == LedgerTransactionType.expense,
                        selectedColor: colors.error,
                        labelStyle: TextStyle(
                          color: selectedType == LedgerTransactionType.expense ? AppColors.white : colors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (val) {
                          if (val) {
                            setSheetState(() {
                              selectedType = LedgerTransactionType.expense;
                              selectedCategory = LedgerCategory.shuttlecock;
                            });
                          }
                        },
                      ),
                    ),
                    AppSpacing.gapW12,
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Phiếu Thu (+)')),
                        selected: selectedType == LedgerTransactionType.income,
                        selectedColor: colors.success,
                        labelStyle: TextStyle(
                          color: selectedType == LedgerTransactionType.income ? AppColors.white : colors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (val) {
                          if (val) {
                            setSheetState(() {
                              selectedType = LedgerTransactionType.income;
                              selectedCategory = LedgerCategory.monthlyFund;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                AppSpacing.gapH12,
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nội dung giao dịch *',
                    hintText: selectedType == LedgerTransactionType.expense ? 'Ví dụ: Mua 2 ống cầu rồng đỏ' : 'Ví dụ: Thu quỹ tháng 10 hội viên',
                    filled: true,
                    fillColor: colors.inputFill,
                    border: OutlineInputBorder(borderRadius: AppRadius.borderSm),
                  ),
                ),
                AppSpacing.gapH12,
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Số tiền (VNĐ) *',
                    hintText: 'Ví dụ: 300000',
                    prefixText: selectedType == LedgerTransactionType.expense ? '- ' : '+ ',
                    filled: true,
                    fillColor: colors.inputFill,
                    border: OutlineInputBorder(borderRadius: AppRadius.borderSm),
                  ),
                ),
                AppSpacing.gapH12,
                Text('Hạng mục quỹ', style: AppTypography.labelMedium.bold.colored(colors.textSecondary)),
                AppSpacing.gapH8,
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: LedgerCategory.values.map((cat) {
                      final isSelected = selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(cat.label),
                          selected: isSelected,
                          selectedColor: colors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.white : colors.textPrimary,
                            fontSize: 12,
                          ),
                          onSelected: (val) {
                            if (val) setSheetState(() => selectedCategory = cat);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                AppSpacing.gapH12,
                TextField(
                  controller: noteCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Ghi chú / Chứng từ đính kèm',
                    hintText: 'Nhập số hóa đơn hoặc thông tin chi tiết...',
                    filled: true,
                    fillColor: colors.inputFill,
                    border: OutlineInputBorder(borderRadius: AppRadius.borderSm),
                  ),
                ),
                AppSpacing.gapH16,
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: AppColors.white,
                      shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                    ),
                    onPressed: () {
                      final title = titleCtrl.text.trim();
                      final amount = int.tryParse(amountCtrl.text.trim());
                      if (title.isEmpty || amount == null || amount <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Vui lòng nhập đầy đủ tiêu đề và số tiền hợp lệ.')),
                        );
                        return;
                      }

                      vm.addTransaction(
                        title: title,
                        amount: amount,
                        type: selectedType,
                        category: selectedCategory,
                        creatorName: creatorName,
                        note: noteCtrl.text.trim().isNotEmpty ? noteCtrl.text.trim() : null,
                      );

                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Đã ghi nhận phiếu ${selectedType == LedgerTransactionType.expense ? "chi" : "thu"} thành công!'),
                          backgroundColor: colors.success,
                        ),
                      );
                    },
                    child: Text('Lưu Phiếu Giao Dịch', style: AppTypography.labelLarge.bold.colored(AppColors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
