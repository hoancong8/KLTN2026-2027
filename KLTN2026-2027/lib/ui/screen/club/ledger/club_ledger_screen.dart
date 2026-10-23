import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../app/provider.dart';
import '../../../../app/theme/theme.dart';
import '../../../../domain/entities/club/club_ledger_transaction.dart';
import '../../../../domain/enums/club_role.dart';
import 'club_ledger_vm.dart';

class ClubLedgerScreen extends ConsumerStatefulWidget {
  final String clubId;

  const ClubLedgerScreen({super.key, required this.clubId});

  @override
  ConsumerState<ClubLedgerScreen> createState() => _ClubLedgerScreenState();
}

class _ClubLedgerScreenState extends ConsumerState<ClubLedgerScreen> {
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
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.cardBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sổ Quỹ Mở Minh Bạch',
              style: AppTypography.titleMedium.bold.colored(colors.textPrimary),
            ),
            Text(
              'Toàn bộ hội viên theo dõi thời gian thực',
              style: AppTypography.labelSmall.colored(colors.textMuted),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: colors.primary),
            tooltip: 'Làm mới sổ quỹ',
            onPressed: () => vm.loadLedger(),
          ),
        ],
      ),
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
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: state.isLoading
                ? Center(child: CircularProgressIndicator(color: colors.primary))
                : RefreshIndicator(
                    onRefresh: () => vm.loadLedger(),
                    color: colors.primary,
                    child: ListView(
                      padding: AppSpacing.screen,
                      children: [
                        // 1. Balance Summary Card
                        _buildBalanceCard(state),
                        AppSpacing.gapH16,

                        // 2. Filter Bar
                        _buildFilterBar(state, vm),
                        AppSpacing.gapH16,

                        // 3. Transactions Section
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

                        // 4. List of Transactions
                        if (state.filteredTransactions.isEmpty)
                          _buildEmptyState()
                        else
                          ...state.filteredTransactions.map((tx) => _buildTransactionCard(tx)),
                        AppSpacing.gapH48,
                      ],
                    ),
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
          const Divider(height: 1),
          AppSpacing.gapH16,
          Row(
            children: [
              // Total Income
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
              // Total Expense
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
          ChoiceChip(
            label: const Text('Tất cả'),
            selected: state.filter == 'ALL',
            onSelected: (_) => vm.setFilter('ALL'),
            selectedColor: colors.primary,
            labelStyle: AppTypography.labelMedium.copyWith(
              color: state.filter == 'ALL' ? AppColors.white : colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            backgroundColor: colors.cardBackground,
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.tag),
          ),
          AppSpacing.gapW8,
          ChoiceChip(
            label: const Text('Khoản Thu (+)'),
            selected: state.filter == 'INCOME',
            onSelected: (_) => vm.setFilter('INCOME'),
            selectedColor: colors.success,
            labelStyle: AppTypography.labelMedium.copyWith(
              color: state.filter == 'INCOME' ? AppColors.white : colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            backgroundColor: colors.cardBackground,
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.tag),
          ),
          AppSpacing.gapW8,
          ChoiceChip(
            label: const Text('Khoản Chi (-)'),
            selected: state.filter == 'EXPENSE',
            onSelected: (_) => vm.setFilter('EXPENSE'),
            selectedColor: colors.error,
            labelStyle: AppTypography.labelMedium.copyWith(
              color: state.filter == 'EXPENSE' ? AppColors.white : colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            backgroundColor: colors.cardBackground,
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.tag),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(ClubLedgerTransaction tx) {
    final isIncome = tx.type == LedgerTransactionType.income;
    final currencyFormat = NumberFormat('#,###');
    final amountText = '${isIncome ? '+' : ''}${currencyFormat.format(tx.amount)} đ';
    final amountColor = isIncome ? colors.success : colors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
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
                  color: isIncome ? colors.success.withValues(alpha: 0.12) : colors.error.withValues(alpha: 0.12),
                  borderRadius: AppRadius.borderSm,
                ),
                child: Center(
                  child: Icon(
                    _getCategoryIcon(tx.category),
                    color: isIncome ? colors.success : colors.error,
                    size: 20,
                  ),
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
                tx.note!,
                style: AppTypography.bodySmall.colored(colors.textSecondary),
              ),
            ),
          ],
          AppSpacing.gapH8,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Thực hiện: ${tx.creatorName}',
                style: AppTypography.labelSmall.colored(colors.textMuted),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded, size: 12, color: colors.success),
                  AppSpacing.gapW4,
                  Text(
                    'Đã đối soát',
                    style: AppTypography.labelSmall.bold.colored(colors.success),
                  ),
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
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: AppRadius.card,
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined, size: 48, color: colors.textMuted),
          AppSpacing.gapH12,
          Text(
            'Chưa có giao dịch nào',
            style: AppTypography.titleSmall.bold.colored(colors.textPrimary),
          ),
          AppSpacing.gapH4,
          Text(
            'Các khoản thu chi của câu lạc bộ sẽ hiển thị công khai tại đây',
            style: AppTypography.bodySmall.colored(colors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(LedgerCategory category) {
    switch (category) {
      case LedgerCategory.courtRental:
        return Icons.sports_tennis_rounded;
      case LedgerCategory.shuttlecock:
        return Icons.shopping_bag_outlined;
      case LedgerCategory.monthlyFund:
        return Icons.savings_outlined;
      case LedgerCategory.sessionFee:
        return Icons.payments_outlined;
      case LedgerCategory.drink:
        return Icons.local_drink_outlined;
      case LedgerCategory.party:
        return Icons.celebration_outlined;
      case LedgerCategory.other:
        return Icons.receipt_outlined;
    }
  }

  void _showCreateTransactionSheet(BuildContext context, ClubLedgerViewModel vm, String creatorName) {
    final titleCtl = TextEditingController();
    final amountCtl = TextEditingController();
    final noteCtl = TextEditingController();
    var selectedType = LedgerTransactionType.expense;
    var selectedCategory = LedgerCategory.shuttlecock;
    var paymentMethod = 'VIETQR';
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.cardBackground,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.bottomSheet),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(color: colors.borderStrong, borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    AppSpacing.gapH16,
                    Row(
                      children: [
                        Icon(Icons.note_add_rounded, color: colors.primary, size: 24),
                        AppSpacing.gapW8,
                        Text(
                          'Tạo Phiếu Thu / Chi Quỹ',
                          style: AppTypography.titleMedium.bold.colored(colors.textPrimary),
                        ),
                      ],
                    ),
                    AppSpacing.gapH8,
                    Text(
                      'Ghi nhận minh bạch khoản thu chi mới vào sổ quỹ mở của nhóm.',
                      style: AppTypography.bodySmall.colored(colors.textMuted),
                    ),
                    AppSpacing.gapH16,

                    // Type selection
                    Text('Loại phiếu', style: AppTypography.labelMedium.bold.colored(colors.textPrimary)),
                    AppSpacing.gapH8,
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Chi Quỹ (-)')),
                            selected: selectedType == LedgerTransactionType.expense,
                            selectedColor: colors.error,
                            labelStyle: AppTypography.bodyMedium.copyWith(
                              color: selectedType == LedgerTransactionType.expense ? AppColors.white : colors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                            backgroundColor: colors.surfaceSubtle,
                            shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                            onSelected: (_) => setModalState(() {
                              selectedType = LedgerTransactionType.expense;
                              selectedCategory = LedgerCategory.shuttlecock;
                            }),
                          ),
                        ),
                        AppSpacing.gapW12,
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Thu Tiền (+)')),
                            selected: selectedType == LedgerTransactionType.income,
                            selectedColor: colors.success,
                            labelStyle: AppTypography.bodyMedium.copyWith(
                              color: selectedType == LedgerTransactionType.income ? AppColors.white : colors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                            backgroundColor: colors.surfaceSubtle,
                            shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                            onSelected: (_) => setModalState(() {
                              selectedType = LedgerTransactionType.income;
                              selectedCategory = LedgerCategory.monthlyFund;
                            }),
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.gapH16,

                    // Category selection
                    Text('Danh mục', style: AppTypography.labelMedium.bold.colored(colors.textPrimary)),
                    AppSpacing.gapH8,
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: LedgerCategory.values.map((cat) {
                        final isSelected = selectedCategory == cat;
                        return ChoiceChip(
                          label: Text(cat.label),
                          selected: isSelected,
                          selectedColor: colors.primary,
                          labelStyle: AppTypography.labelSmall.copyWith(
                            color: isSelected ? AppColors.white : colors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          backgroundColor: colors.surfaceSubtle,
                          shape: const RoundedRectangleBorder(borderRadius: AppRadius.tag),
                          onSelected: (_) => setModalState(() => selectedCategory = cat),
                        );
                      }).toList(),
                    ),
                    AppSpacing.gapH16,

                    // Amount input
                    Text('Số tiền (VNĐ)', style: AppTypography.labelMedium.bold.colored(colors.textPrimary)),
                    AppSpacing.gapH4,
                    TextFormField(
                      controller: amountCtl,
                      keyboardType: TextInputType.number,
                      style: AppTypography.bodyMedium.colored(colors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Ví dụ: 300000',
                        suffixText: 'đ',
                        filled: true,
                        fillColor: colors.inputFill,
                        border: OutlineInputBorder(borderRadius: AppRadius.input, borderSide: BorderSide(color: colors.inputBorder)),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Vui lòng nhập số tiền';
                        final parsed = int.tryParse(val.replaceAll(RegExp(r'[^0-9]'), ''));
                        if (parsed == null || parsed <= 0) return 'Số tiền không hợp lệ';
                        return null;
                      },
                    ),
                    AppSpacing.gapH12,

                    // Title input
                    Text('Nội dung / Lý do thu chi', style: AppTypography.labelMedium.bold.colored(colors.textPrimary)),
                    AppSpacing.gapH4,
                    TextFormField(
                      controller: titleCtl,
                      style: AppTypography.bodyMedium.colored(colors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Ví dụ: Mua 2 ống cầu Hải Yến buổi thứ 4',
                        filled: true,
                        fillColor: colors.inputFill,
                        border: OutlineInputBorder(borderRadius: AppRadius.input, borderSide: BorderSide(color: colors.inputBorder)),
                      ),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Vui lòng nhập nội dung' : null,
                    ),
                    AppSpacing.gapH12,

                    // Note input
                    Text('Ghi chú hóa đơn (Không bắt buộc)', style: AppTypography.labelMedium.bold.colored(colors.textPrimary)),
                    AppSpacing.gapH4,
                    TextFormField(
                      controller: noteCtl,
                      style: AppTypography.bodyMedium.colored(colors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Ví dụ: Hóa đơn #1234, chuyển khoản MoMo...',
                        filled: true,
                        fillColor: colors.inputFill,
                        border: OutlineInputBorder(borderRadius: AppRadius.input, borderSide: BorderSide(color: colors.inputBorder)),
                      ),
                    ),
                    AppSpacing.gapH16,

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                        ),
                        onPressed: () {
                          if (!formKey.currentState!.validate()) return;
                          final amount = int.parse(amountCtl.text.replaceAll(RegExp(r'[^0-9]'), ''));
                          vm.addTransaction(
                            title: titleCtl.text.trim(),
                            amount: amount,
                            type: selectedType,
                            category: selectedCategory,
                            creatorName: creatorName,
                            note: noteCtl.text.trim().isNotEmpty ? noteCtl.text.trim() : null,
                            paymentMethod: paymentMethod,
                          );
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Đã ghi nhận phiếu vào sổ quỹ mở!'),
                              backgroundColor: colors.success,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Text('Lưu Vào Sổ Quỹ Mở', style: AppTypography.titleSmall.bold.colored(AppColors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
