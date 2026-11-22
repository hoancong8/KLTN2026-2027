import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/consts/app_config.dart';
import '../../../../app/consts/permissions.dart';
import '../../../../app/provider.dart';
import '../../../../app/provider/localization_provider.dart';
import '../../../../app/services/sepay_authorization_browser.dart';
import '../../../../app/theme/theme.dart';
import '../../../../domain/entities/sepay/sepay_connection.dart';
import '../../../../widget/app_status_badge.dart';
import 'club_sepay_state.dart';
import 'club_sepay_vm.dart';

class ClubSepayScreen extends ConsumerStatefulWidget {
  final String clubId;
  final String? sepayCallbackStatus;
  final String? ticket;

  const ClubSepayScreen({
    super.key,
    required this.clubId,
    this.sepayCallbackStatus,
    this.ticket,
  });

  @override
  ConsumerState<ClubSepayScreen> createState() => _ClubSepayScreenState();
}

class _ClubSepayScreenState extends ConsumerState<ClubSepayScreen> {
  AppThemeColors get colors => context.colors;
  String? _completedTicket;
  bool _openingAuthorization = false;

  String? _messageForKey(String? key) => switch (key) {
    'sepay_load_status_failed' => context.l10n.sepay_load_status_failed,
    'sepay_start_authorization_failed' =>
      context.l10n.sepay_start_authorization_failed,
    'sepay_authorization_succeeded_choose_bank' =>
      context.l10n.sepay_authorization_succeeded_choose_bank,
    'sepay_complete_authorization_failed' =>
      context.l10n.sepay_complete_authorization_failed,
    'sepay_select_matching_bank_required' =>
      context.l10n.sepay_select_matching_bank_required,
    'sepay_bank_linked_activate_next' =>
      context.l10n.sepay_bank_linked_activate_next,
    'sepay_select_bank_failed' => context.l10n.sepay_select_bank_failed,
    'sepay_activate_connection_succeeded' =>
      context.l10n.sepay_activate_connection_succeeded,
    'sepay_activate_connection_failed' =>
      context.l10n.sepay_activate_connection_failed,
    'sepay_disconnect_requested' => context.l10n.sepay_disconnect_requested,
    'sepay_disconnect_failed' => context.l10n.sepay_disconnect_failed,
    'error_system_retry' => context.l10n.error_system_retry,
    _ => null,
  };

  String _connectionStatusLabel(String status) => switch (status) {
    'CONNECTED' => context.l10n.sepay_status_connected,
    'PROVISIONING' => context.l10n.sepay_status_provisioning,
    'AUTHORIZED' => context.l10n.sepay_status_authorized,
    'BANK_REQUIRED' => context.l10n.sepay_status_bank_required,
    'DISCONNECTING' => context.l10n.sepay_status_disconnecting,
    'DISCONNECTED' => context.l10n.sepay_status_disconnected,
    _ => context.l10n.sepay_status_unknown,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkCallback();
    });
  }

  @override
  void didUpdateWidget(covariant ClubSepayScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sepayCallbackStatus != widget.sepayCallbackStatus ||
        oldWidget.ticket != widget.ticket ||
        oldWidget.clubId != widget.clubId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _checkCallback();
      });
    }
  }

  void _checkCallback() {
    if (!mounted) return;
    final status = widget.sepayCallbackStatus;
    if (status == null || status.isEmpty) return;

    final ticket = widget.ticket;
    context.replace(AppConfig.clubSepayScreenPath(widget.clubId));
    _handleAuthorizationCallback(status, ticket);
  }

  Future<void> _handleAuthorizationCallback(
    String? status,
    String? ticket,
  ) async {
    if (status == 'authorized' && ticket != null && ticket.isNotEmpty) {
      if (_completedTicket == ticket) return;
      _completedTicket = ticket;
      await ref
          .read(clubSepayViewModelProvider(widget.clubId).notifier)
          .completeOAuth(ticket);
    } else if (status == 'denied') {
      _showAuthorizationCancelled();
    } else {
      _showOpenAuthError();
    }
  }

  Future<void> _handleStartOAuth() async {
    if (_openingAuthorization) return;
    setState(() => _openingAuthorization = true);
    final clubId = widget.clubId;
    try {
      final authUrl = await ref
          .read(clubSepayViewModelProvider(clubId).notifier)
          .startOAuth();
      if (!mounted || widget.clubId != clubId || authUrl == null) return;

      final uri = Uri.tryParse(authUrl);
      if (uri == null || !isSepayAuthorizationUrl(uri)) {
        _showOpenAuthError();
        return;
      }
      if (kIsWeb) {
        await _confirmWebAuthorization(uri);
        return;
      }
      await _openAuthorization(uri, clubId);
    } finally {
      if (mounted) setState(() => _openingAuthorization = false);
    }
  }

  Future<void> _openAuthorization(Uri uri, String clubId) async {
    final result = await openSepayAuthorization(uri);
    if (!mounted || widget.clubId != clubId) return;

    switch (result.outcome) {
      case SepayBrowserOutcome.opened:
        return;
      case SepayBrowserOutcome.completed:
        final callback = result.callback;
        if (callback == null || !isSepayAppCallback(callback, clubId)) {
          _showOpenAuthError();
          return;
        }
        await _handleAuthorizationCallback(
          callback.queryParameters['sepay'],
          callback.queryParameters['ticket'],
        );
      case SepayBrowserOutcome.cancelled:
        _showAuthorizationCancelled();
      case SepayBrowserOutcome.failed:
        _showOpenAuthError();
    }
  }

  Future<void> _confirmWebAuthorization(Uri uri) => showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(context.l10n.sepay_authorization_title),
      content: Text(context.l10n.sepay_authorization_ready),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(context.l10n.com_close),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
            _openAuthorization(uri, widget.clubId);
          },
          child: Text(context.l10n.sepay_open_browser),
        ),
      ],
    ),
  );

  void _showAuthorizationCancelled() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.sepay_authorization_cancelled),
        backgroundColor: colors.warning,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showOpenAuthError() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.sepay_open_authorization_failed),
        backgroundColor: colors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showConfirmDisconnectDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: colors.error, size: 24),
            AppSpacing.gapW8,
            Text(
              context.l10n.sepay_disconnect_confirmation_title,
              style: AppTypography.titleMedium.bold.colored(colors.textPrimary),
            ),
          ],
        ),
        content: Text(
          context.l10n.sepay_disconnect_confirmation_message,
          style: AppTypography.bodySmall.colored(colors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              context.l10n.com_cancel,
              style: TextStyle(color: colors.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: AppColors.white,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              ref
                  .read(clubSepayViewModelProvider(widget.clubId).notifier)
                  .disconnectConnection();
            },
            child: Text(context.l10n.sepay_disconnect),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canManageBank = ref.hasClubPermission(ClubPermissions.bankManage);
    final state = ref.watch(clubSepayViewModelProvider(widget.clubId));

    ref.listen<ClubSepayState>(clubSepayViewModelProvider(widget.clubId), (
      prev,
      next,
    ) {
      if ((next.errorMessage != null || next.errorMessageKey != null) &&
          (next.errorMessage != prev?.errorMessage ||
              next.errorMessageKey != prev?.errorMessageKey)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              next.errorMessage ??
                  _messageForKey(next.errorMessageKey) ??
                  context.l10n.error_system_retry,
            ),
            backgroundColor: colors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      if (next.successMessageKey != null &&
          next.successMessageKey != prev?.successMessageKey) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _messageForKey(next.successMessageKey) ??
                  context.l10n.com_success,
            ),
            backgroundColor: colors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    if (!canManageBank) {
      return Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          title: Text(
            context.l10n.sepay_club_connection_title,
            style: AppTypography.titleLarge.bold.colored(colors.textPrimary),
          ),
          backgroundColor: colors.surface,
          elevation: 0.5,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_person_rounded, size: 54, color: colors.error),
                AppSpacing.gapH16,
                Text(
                  context.l10n.sepay_bank_permission_title,
                  style: AppTypography.titleMedium.bold.colored(
                    colors.textPrimary,
                  ),
                ),
                AppSpacing.gapH8,
                Text(
                  context.l10n.sepay_bank_permission_required,
                  style: AppTypography.bodySmall.colored(colors.textMuted),
                  textAlign: TextAlign.center,
                ),
                AppSpacing.gapH24,
                ElevatedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: Text(context.l10n.com_back),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: AppColors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.button,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final conn = state.connection;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          context.l10n.sepay_club_connection_page_title,
          style: AppTypography.titleLarge.bold.colored(colors.textPrimary),
        ),
        backgroundColor: colors.surface,
        foregroundColor: colors.textPrimary,
        elevation: 0.5,
        actions: [
          IconButton(
            tooltip: context.l10n.sepay_reconciliation_tooltip,
            icon: const Icon(Icons.receipt_long_rounded),
            onPressed: () =>
                context.push('/club/${widget.clubId}/reconciliations'),
          ),
          IconButton(
            tooltip: context.l10n.sepay_refresh_status,
            icon: const Icon(Icons.refresh_rounded),
            onPressed: state.isLoading
                ? null
                : () => ref
                      .read(clubSepayViewModelProvider(widget.clubId).notifier)
                      .loadStatus(),
          ),
        ],
      ),
      body: state.isLoading && conn == null
          ? Center(child: CircularProgressIndicator(color: colors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 768),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLifecycleCard(conn, state),
                      AppSpacing.gapH16,
                      if (state.accountsLoadFailed) ...[
                        _buildLoadWarning(
                          context.l10n.sepay_accounts_load_failed,
                          state.isLoading,
                        ),
                        AppSpacing.gapH16,
                      ],
                      if (state.connectionsLoadFailed) ...[
                        _buildLoadWarning(
                          context.l10n.sepay_connections_load_failed,
                          state.isLoading,
                        ),
                        AppSpacing.gapH16,
                      ],
                      if (conn != null && conn.isAuthorized) ...[
                        _buildAccountsCard(state),
                        AppSpacing.gapH16,
                      ],
                      if (state.oldConnections.isNotEmpty) ...[
                        _buildOldConnectionsCard(state),
                        AppSpacing.gapH16,
                      ],
                      _buildSecurityGuidelineCard(),
                      AppSpacing.gapH24,
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildLoadWarning(String message, bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: colors.warning, size: 20),
          AppSpacing.gapW8,
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall.colored(colors.textPrimary),
            ),
          ),
          TextButton(
            onPressed: isLoading
                ? null
                : () => ref
                      .read(clubSepayViewModelProvider(widget.clubId).notifier)
                      .loadStatus(),
            child: Text(context.l10n.com_retry),
          ),
        ],
      ),
    );
  }

  Widget _buildLifecycleCard(SepayConnection? conn, ClubSepayState state) {
    final status = conn?.status ?? 'DISCONNECTED';
    final applicationReady = conn?.applicationReady ?? false;
    final isActionInProgress = state.isActionInProgress;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: AppRadius.card,
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_balance_rounded,
                    color: colors.primary,
                    size: 24,
                  ),
                  AppSpacing.gapW8,
                  Text(
                    context.l10n.sepay_connection_status,
                    style: AppTypography.titleMedium.bold.colored(
                      colors.textPrimary,
                    ),
                  ),
                ],
              ),
              _buildConnectionBadge(status),
            ],
          ),
          AppSpacing.gapH16,
          if (status == 'BANK_REQUIRED') ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: colors.warning.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: colors.warning,
                    size: 22,
                  ),
                  AppSpacing.gapW12,
                  Expanded(
                    child: Text(
                      context.l10n.sepay_bank_configuration_required,
                      style: AppTypography.bodySmall.colored(
                        colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.gapH16,
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.settings_outlined, size: 18),
                label: Text(context.l10n.sepay_open_club_bank_settings),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.button,
                  ),
                ),
                onPressed: () =>
                    context.push('/club/${widget.clubId}/settings'),
              ),
            ),
          ] else if (status == 'DISCONNECTED') ...[
            Text(
              context.l10n.sepay_connection_not_linked,
              style: AppTypography.bodySmall.colored(colors.textMuted),
            ),
            if (!applicationReady) ...[
              AppSpacing.gapH12,
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colors.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  context.l10n.sepay_application_disabled_notice,
                  style: AppTypography.bodySmall.colored(colors.error),
                ),
              ),
            ],
            AppSpacing.gapH16,
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _openingAuthorization
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : const Icon(Icons.login_rounded, size: 18),
                label: Text(context.l10n.sepay_start_oauth_connection),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.button,
                  ),
                ),
                onPressed:
                    _openingAuthorization ||
                        isActionInProgress ||
                        !applicationReady
                    ? null
                    : _handleStartOAuth,
              ),
            ),
          ] else if (status == 'AUTHORIZED') ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.info.withValues(alpha: 0.3)),
              ),
              child: Text(
                context.l10n.sepay_oauth_approved_choose_bank,
                style: AppTypography.bodySmall.colored(colors.textPrimary),
              ),
            ),
          ] else if (status == 'PROVISIONING') ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: colors.warning.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.sepay_bank_selected_webhook_pending,
                    style: AppTypography.labelMedium.bold.colored(
                      colors.textPrimary,
                    ),
                  ),
                  AppSpacing.gapH4,
                  Text(
                    context.l10n.sepay_webhook_activation_hint,
                    style: AppTypography.bodySmall.colored(colors.textMuted),
                  ),
                ],
              ),
            ),
            AppSpacing.gapH16,
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: isActionInProgress && state.actionType == 'activate'
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : const Icon(Icons.bolt_rounded, size: 18),
                label: Text(context.l10n.sepay_activate_connection_webhook),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.success,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.button,
                  ),
                ),
                onPressed: isActionInProgress
                    ? null
                    : () => ref
                          .read(
                            clubSepayViewModelProvider(widget.clubId).notifier,
                          )
                          .activateConnection(),
              ),
            ),
          ] else if (status == 'CONNECTED') ...[
            _buildConnectedInfo(conn!),
            AppSpacing.gapH16,
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.receipt_long_rounded, size: 18),
                label: Text(context.l10n.sepay_view_reconciliations),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.button,
                  ),
                ),
                onPressed: () =>
                    context.push('/club/${widget.clubId}/reconciliations'),
              ),
            ),
            AppSpacing.gapH12,
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: isActionInProgress && state.actionType == 'disconnect'
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.link_off_rounded, size: 18),
                label: Text(context.l10n.sepay_disconnect_connection),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.error,
                  side: BorderSide(color: colors.error.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.button,
                  ),
                ),
                onPressed: isActionInProgress
                    ? null
                    : _showConfirmDisconnectDialog,
              ),
            ),
          ] else if (status == 'DISCONNECTING') ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: colors.warning.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                context.l10n.sepay_disconnect_pending_notice,
                style: AppTypography.bodySmall.colored(colors.textPrimary),
              ),
            ),
            AppSpacing.gapH16,
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: isActionInProgress
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : const Icon(Icons.refresh_rounded, size: 18),
                label: Text(context.l10n.sepay_retry_disconnect),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.warning,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.button,
                  ),
                ),
                onPressed: isActionInProgress
                    ? null
                    : () => ref
                          .read(
                            clubSepayViewModelProvider(widget.clubId).notifier,
                          )
                          .disconnectConnection(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConnectedInfo(SepayConnection conn) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.inputFill,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            label: context.l10n.sepay_gateway_bank,
            value: conn.gateway ?? context.l10n.sepay_value_unavailable,
          ),
          AppSpacing.gapH8,
          _buildInfoRow(
            label: context.l10n.sepay_company_id,
            value: conn.companyId != null
                ? '#${conn.companyId}'
                : context.l10n.sepay_value_unavailable,
          ),
          AppSpacing.gapH8,
          _buildInfoRow(
            label: context.l10n.sepay_connected_at,
            value: conn.connectedAt != null
                ? dateFormat.format(conn.connectedAt!)
                : context.l10n.sepay_value_unavailable,
          ),
          AppSpacing.gapH8,
          _buildInfoRow(
            label: context.l10n.sepay_webhook_status,
            value: conn.webhookEnabled
                ? context.l10n.sepay_webhook_active
                : context.l10n.sepay_webhook_inactive,
            valueColor: conn.webhookEnabled ? colors.success : colors.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.colored(colors.textSecondary),
        ),
        Text(
          value,
          style: AppTypography.bodySmall.bold.colored(
            valueColor ?? colors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionBadge(String status) {
    switch (status) {
      case 'CONNECTED':
        return AppStatusBadge.success(
          label: context.l10n.sepay_status_connected,
        );
      case 'PROVISIONING':
        return AppStatusBadge.warning(
          label: context.l10n.sepay_status_provisioning,
        );
      case 'AUTHORIZED':
        return AppStatusBadge.info(label: context.l10n.sepay_status_authorized);
      case 'BANK_REQUIRED':
        return AppStatusBadge.error(
          label: context.l10n.sepay_status_bank_required,
        );
      case 'DISCONNECTING':
        return AppStatusBadge.warning(
          label: context.l10n.sepay_status_disconnecting,
        );
      case 'DISCONNECTED':
      default:
        return AppStatusBadge.neutral(
          label: context.l10n.sepay_status_disconnected,
        );
    }
  }

  Widget _buildAccountsCard(ClubSepayState state) {
    final accounts = state.accounts;
    final selectedId = state.selectedProviderBankId;
    final isActionInProgress = state.isActionInProgress;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: AppRadius.card,
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.checklist_rounded, color: colors.primary, size: 22),
              AppSpacing.gapW8,
              Text(
                context.l10n.sepay_select_provider_bank_title,
                style: AppTypography.titleMedium.bold.colored(
                  colors.textPrimary,
                ),
              ),
            ],
          ),
          AppSpacing.gapH8,
          Text(
            context.l10n.sepay_select_provider_bank_help,
            style: AppTypography.bodySmall.colored(colors.textMuted),
          ),
          AppSpacing.gapH16,
          if (accounts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  context.l10n.sepay_provider_bank_empty,
                  style: AppTypography.bodySmall.colored(colors.textMuted),
                ),
              ),
            )
          else
            ...accounts.map((acc) {
              final isSelected = selectedId == acc.id;
              final isEligible = acc.isEligibleToSelect;

              return InkWell(
                onTap: isEligible
                    ? () => ref
                          .read(
                            clubSepayViewModelProvider(widget.clubId).notifier,
                          )
                          .setSelectedProviderBank(acc.id)
                    : null,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.primary.withValues(alpha: 0.08)
                        : colors.inputFill,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? colors.primary : colors.cardBorder,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Radio<int>(
                        value: acc.id,
                        groupValue: selectedId,
                        activeColor: colors.primary,
                        onChanged: isEligible
                            ? (v) {
                                if (v != null) {
                                  ref
                                      .read(
                                        clubSepayViewModelProvider(
                                          widget.clubId,
                                        ).notifier,
                                      )
                                      .setSelectedProviderBank(v);
                                }
                              }
                            : null,
                      ),
                      AppSpacing.gapW8,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${acc.gateway} - ${acc.accountNumber}',
                                  style: AppTypography.labelMedium.bold.colored(
                                    colors.textPrimary,
                                  ),
                                ),
                                AppSpacing.gapW8,
                                if (acc.matchesClubBank)
                                  AppStatusBadge.success(
                                    label: context.l10n.sepay_bank_matches_club,
                                  )
                                else
                                  AppStatusBadge.error(
                                    label:
                                        context.l10n.sepay_bank_does_not_match,
                                  ),
                              ],
                            ),
                            AppSpacing.gapH4,
                            Text(
                              context.l10n.sepay_account_holder_bin(
                                acc.accountHolder,
                                acc.bankBin,
                              ),
                              style: AppTypography.bodySmall.colored(
                                colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          AppSpacing.gapH12,
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: isActionInProgress && state.actionType == 'select'
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : const Icon(Icons.check_rounded, size: 18),
              label: Text(context.l10n.sepay_confirm_bank_selection),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.button,
                ),
              ),
              onPressed: isActionInProgress || selectedId == null
                  ? null
                  : () => ref
                        .read(
                          clubSepayViewModelProvider(widget.clubId).notifier,
                        )
                        .selectAccount(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOldConnectionsCard(ClubSepayState state) {
    final oldList = state.oldConnections;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: AppRadius.card,
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history_rounded,
                color: colors.textSecondary,
                size: 20,
              ),
              AppSpacing.gapW8,
              Text(
                context.l10n.sepay_other_connections_title,
                style: AppTypography.labelLarge.bold.colored(
                  colors.textPrimary,
                ),
              ),
            ],
          ),
          AppSpacing.gapH12,
          ...oldList.map((c) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.inputFill,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.cardBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.gateway ?? context.l10n.sepay_other_bank,
                        style: AppTypography.labelMedium.bold.colored(
                          colors.textPrimary,
                        ),
                      ),
                      AppSpacing.gapH4,
                      Text(
                        context.l10n.sepay_connection_status_value(
                          _connectionStatusLabel(c.status),
                        ),
                        style: AppTypography.bodySmall.colored(
                          colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (c.connectionId != null)
                    TextButton.icon(
                      icon: const Icon(Icons.delete_outline_rounded, size: 16),
                      label: Text(context.l10n.sepay_cleanup),
                      style: TextButton.styleFrom(
                        foregroundColor: colors.error,
                      ),
                      onPressed: state.isActionInProgress
                          ? null
                          : () => ref
                                .read(
                                  clubSepayViewModelProvider(
                                    widget.clubId,
                                  ).notifier,
                                )
                                .disconnectConnection(
                                  connectionId: c.connectionId,
                                ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSecurityGuidelineCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: AppRadius.card,
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shield_outlined,
                color: colors.textSecondary,
                size: 20,
              ),
              AppSpacing.gapW8,
              Text(
                context.l10n.sepay_security_reconciliation_title,
                style: AppTypography.labelMedium.bold.colored(
                  colors.textPrimary,
                ),
              ),
            ],
          ),
          AppSpacing.gapH8,
          Text(
            context.l10n.sepay_security_reconciliation_notes,
            style: AppTypography.bodySmall.colored(colors.textMuted),
          ),
        ],
      ),
    );
  }
}
