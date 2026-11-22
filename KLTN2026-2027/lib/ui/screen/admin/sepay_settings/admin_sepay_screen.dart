import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/consts/app_config.dart';
import '../../../../app/consts/permissions.dart';
import '../../../../app/provider.dart';
import '../../../../app/provider/localization_provider.dart';
import '../../../../app/theme/theme.dart';
import '../../../../domain/entities/sepay/sepay_application.dart';
import '../../../../widget/app_status_badge.dart';
import 'admin_sepay_state.dart';
import 'admin_sepay_vm.dart';

class AdminSepayScreen extends ConsumerStatefulWidget {
  const AdminSepayScreen({super.key});

  @override
  ConsumerState<AdminSepayScreen> createState() => _AdminSepayScreenState();
}

class _AdminSepayScreenState extends ConsumerState<AdminSepayScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _clientIdController;
  late final TextEditingController _clientSecretController;
  late final TextEditingController _frontendUrlController;

  bool _enabled = true;
  bool _obscureSecret = true;
  bool _isPopulated = false;

  AppThemeColors get colors => context.colors;

  String? _messageForKey(String? key) => switch (key) {
    'sepay_load_configuration_failed' =>
      context.l10n.sepay_load_configuration_failed,
    'sepay_save_configuration_succeeded' =>
      context.l10n.sepay_save_configuration_succeeded,
    'sepay_save_configuration_failed' =>
      context.l10n.sepay_save_configuration_failed,
    'error_system_retry' => context.l10n.error_system_retry,
    _ => null,
  };

  @override
  void initState() {
    super.initState();
    _clientIdController = TextEditingController();
    _clientSecretController = TextEditingController();
    _frontendUrlController = TextEditingController();
  }

  @override
  void dispose() {
    _clientIdController.dispose();
    _clientSecretController.dispose();
    _frontendUrlController.dispose();
    super.dispose();
  }

  void _populateForm(AdminSepayState state) {
    final app = state.application;
    if (app == null) {
      _isPopulated = false;
      _clientIdController.clear();
      _clientSecretController.clear();
      _frontendUrlController.clear();
      return;
    }
    if (!_isPopulated) {
      _clientIdController.text = app.clientId;
      _frontendUrlController.text = app.frontendBaseUrl;
      _enabled = app.enabled;
      _clientSecretController.clear();
      _isPopulated = true;
    }
  }

  void _copyToClipboard(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: colors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    final vm = ref.read(adminSepayViewModelProvider.notifier);
    final savedFrontendUrl = ref
        .read(adminSepayViewModelProvider)
        .application
        ?.frontendBaseUrl;
    final success = await vm.saveApplication(
      clientId: _clientIdController.text,
      clientSecret: _clientSecretController.text,
      publicApiBaseUrl: AppConfig.baseUrl,
      frontendBaseUrl: kIsWeb
          ? _frontendUrlController.text
          : (savedFrontendUrl != null && savedFrontendUrl.isNotEmpty
                ? savedFrontendUrl
                : AppConfig.baseUrl),
      enabled: _enabled,
    );
    if (success && mounted) {
      _clientSecretController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final canManage = ref.hasPermission(Permissions.integrationsSepayManage);
    final state = ref.watch(adminSepayViewModelProvider);

    _populateForm(state);

    ref.listen<AdminSepayState>(adminSepayViewModelProvider, (prev, next) {
      if (next.isRevisionConflict && prev?.isRevisionConflict != true) {
        final message = next.application != null
            ? context.l10n.sepay_config_conflict_reloaded
            : context.l10n.sepay_config_conflict_reload_failed;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: colors.warning,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if ((next.errorMessage != null || next.errorMessageKey != null) &&
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

    if (!canManage) {
      return Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          title: Text(
            context.l10n.sepay_admin_system_title,
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
                  context.l10n.auth_forbidden,
                  style: AppTypography.titleMedium.bold.colored(
                    colors.textPrimary,
                  ),
                ),
                AppSpacing.gapH8,
                Text(
                  context.l10n.sepay_admin_permission_required,
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

    final app = state.application;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          context.l10n.sepay_admin_system_title,
          style: AppTypography.titleLarge.bold.colored(colors.textPrimary),
        ),
        backgroundColor: colors.surface,
        foregroundColor: colors.textPrimary,
        elevation: 0.5,
        actions: [
          IconButton(
            tooltip: context.l10n.sepay_refresh_configuration,
            icon: const Icon(Icons.refresh_rounded),
            onPressed: state.isLoading
                ? null
                : () {
                    ref
                        .read(adminSepayViewModelProvider.notifier)
                        .loadApplication();
                  },
          ),
          if (app != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                tooltip: context.l10n.sepay_save_changes,
                icon: state.isSaving
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.primary,
                        ),
                      )
                    : Icon(Icons.check_rounded, color: colors.primary),
                onPressed: state.isSaving ? null : _handleSave,
              ),
            ),
        ],
      ),
      bottomNavigationBar: (app != null)
          ? SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: colors.surface,
                  border: Border(top: BorderSide(color: colors.cardBorder)),
                ),
                child: Center(
                  heightFactor: 1.0,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 768),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: const RoundedRectangleBorder(
                            borderRadius: AppRadius.button,
                          ),
                          elevation: 0,
                        ),
                        icon: state.isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.white,
                                ),
                              )
                            : const Icon(Icons.save_rounded, size: 20),
                        label: Text(
                          state.isSaving
                              ? context.l10n.sepay_saving_configuration
                              : context.l10n.sepay_save_configuration,
                          style: AppTypography.labelLarge.bold,
                        ),
                        onPressed: state.isSaving ? null : _handleSave,
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
      body: state.isLoading && app == null
          ? Center(child: CircularProgressIndicator(color: colors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 768),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatusCard(app),
                        AppSpacing.gapH16,
                        _buildFormCard(app),
                        AppSpacing.gapH24,
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildStatusCard(SepayApplication? app) {
    final hasSecret = app?.hasClientSecret ?? false;
    final isEnabled = app?.enabled ?? false;
    final webhookEnabled = app?.webhookEnabled ?? false;
    final statusTiles = <Widget>[
      _buildStatusTile(
        title: context.l10n.sepay_application,
        subtitle: isEnabled
            ? context.l10n.sepay_enabled
            : context.l10n.sepay_disabled,
        badge: isEnabled
            ? AppStatusBadge.success(label: context.l10n.sepay_enabled)
            : AppStatusBadge.neutral(label: context.l10n.sepay_disabled),
      ),
      _buildStatusTile(
        title: context.l10n.sepay_client_secret_label,
        subtitle: hasSecret
            ? context.l10n.sepay_secret_saved
            : context.l10n.sepay_secret_missing,
        badge: hasSecret
            ? AppStatusBadge.success(label: context.l10n.sepay_badge_saved)
            : AppStatusBadge.warning(
                label: context.l10n.sepay_badge_not_configured,
              ),
      ),
      _buildStatusTile(
        title: context.l10n.sepay_webhook_system,
        subtitle: webhookEnabled
            ? context.l10n.sepay_webhook_receiving
            : context.l10n.sepay_webhook_paused,
        badge: webhookEnabled
            ? AppStatusBadge.success(label: context.l10n.sepay_webhook_active)
            : AppStatusBadge.neutral(
                label: context.l10n.sepay_webhook_inactive,
              ),
      ),
    ];

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
              Icon(Icons.hub_outlined, color: colors.primary, size: 22),
              AppSpacing.gapW8,
              Text(
                context.l10n.sepay_integration_status,
                style: AppTypography.titleMedium.bold.colored(
                  colors.textPrimary,
                ),
              ),
            ],
          ),
          AppSpacing.gapH16,
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 560) {
                return Column(
                  children: [
                    for (
                      var index = 0;
                      index < statusTiles.length;
                      index++
                    ) ...[
                      if (index > 0) AppSpacing.gapH8,
                      SizedBox(
                        width: double.infinity,
                        child: statusTiles[index],
                      ),
                    ],
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(child: statusTiles[0]),
                      AppSpacing.gapW12,
                      Expanded(child: statusTiles[1]),
                    ],
                  ),
                  AppSpacing.gapH12,
                  statusTiles[2],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTile({
    required String title,
    required String subtitle,
    required Widget badge,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.inputFill,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.labelSmall.bold.colored(
                    colors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppSpacing.gapW8,
              badge,
            ],
          ),
          AppSpacing.gapH4,
          Text(
            subtitle,
            style: AppTypography.bodySmall.colored(colors.textPrimary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFieldHelper(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              Icons.info_outline_rounded,
              size: 14,
              color: colors.textMuted,
            ),
          ),
          AppSpacing.gapW8,
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySmall
                  .colored(colors.textMuted)
                  .copyWith(height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(SepayApplication? app) {
    final hasSecret = app?.hasClientSecret ?? false;

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
              Icon(Icons.tune_rounded, color: colors.primary, size: 22),
              AppSpacing.gapW8,
              Text(
                context.l10n.sepay_application_configuration,
                style: AppTypography.titleMedium.bold.colored(
                  colors.textPrimary,
                ),
              ),
            ],
          ),
          AppSpacing.gapH16,
          _buildInstructions(),
          AppSpacing.gapH16,
          Text(
            context.l10n.sepay_client_id_label,
            style: AppTypography.labelMedium.bold.colored(colors.textPrimary),
          ),
          AppSpacing.gapH4,
          TextFormField(
            controller: _clientIdController,
            decoration: InputDecoration(
              hintText: context.l10n.sepay_client_id_hint,
              filled: true,
              fillColor: colors.inputFill,
              border: OutlineInputBorder(
                borderRadius: AppRadius.input,
                borderSide: BorderSide(color: colors.inputBorder),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return context.l10n.sepay_client_id_required;
              }
              return null;
            },
          ),
          AppSpacing.gapH4,
          _buildFieldHelper(context.l10n.sepay_client_id_helper),
          AppSpacing.gapH16,
          Text(
            context.l10n.sepay_client_secret_label,
            style: AppTypography.labelMedium.bold.colored(colors.textPrimary),
          ),
          AppSpacing.gapH4,
          TextFormField(
            controller: _clientSecretController,
            obscureText: _obscureSecret,
            decoration: InputDecoration(
              hintText: hasSecret
                  ? context.l10n.sepay_client_secret_existing_hint
                  : context.l10n.sepay_client_secret_hint,
              filled: true,
              fillColor: colors.inputFill,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureSecret
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                  color: colors.textMuted,
                ),
                onPressed: () {
                  setState(() => _obscureSecret = !_obscureSecret);
                },
              ),
              border: OutlineInputBorder(
                borderRadius: AppRadius.input,
                borderSide: BorderSide(color: colors.inputBorder),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
            validator: (v) {
              if (!hasSecret && (v == null || v.trim().isEmpty)) {
                return context.l10n.sepay_client_secret_required;
              }
              return null;
            },
          ),
          AppSpacing.gapH4,
          _buildFieldHelper(
            hasSecret
                ? context.l10n.sepay_client_secret_existing_helper
                : context.l10n.sepay_client_secret_new_helper,
          ),
          if (kIsWeb) ...[
            AppSpacing.gapH16,
            Text(
              context.l10n.sepay_frontend_url_label,
              style: AppTypography.labelMedium.bold.colored(colors.textPrimary),
            ),
            AppSpacing.gapH4,
            TextFormField(
              controller: _frontendUrlController,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                hintText: context.l10n.sepay_frontend_url_hint,
                filled: true,
                fillColor: colors.inputFill,
                border: OutlineInputBorder(
                  borderRadius: AppRadius.input,
                  borderSide: BorderSide(color: colors.inputBorder),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return context.l10n.sepay_frontend_url_required;
                }
                if (!v.trim().startsWith('http://') &&
                    !v.trim().startsWith('https://')) {
                  return context.l10n.sepay_url_invalid;
                }
                return null;
              },
            ),
            AppSpacing.gapH4,
            _buildFieldHelper(context.l10n.sepay_frontend_url_helper),
          ] else ...[
            AppSpacing.gapH16,
            _buildFieldHelper(context.l10n.sepay_mobile_return_helper),
          ],
          AppSpacing.gapH16,
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _enabled
                  ? colors.primary.withValues(alpha: 0.07)
                  : colors.inputFill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _enabled
                    ? colors.primary.withValues(alpha: 0.42)
                    : colors.cardBorder,
              ),
            ),
            child: MergeSemantics(
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _enabled
                          ? colors.primary.withValues(alpha: 0.14)
                          : colors.cardBackground,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.account_balance_rounded,
                      size: 21,
                      color: _enabled ? colors.primary : colors.textMuted,
                    ),
                  ),
                  AppSpacing.gapW12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.sepay_enable_integration,
                          style: AppTypography.labelMedium.bold.colored(
                            colors.textPrimary,
                          ),
                        ),
                        AppSpacing.gapH4,
                        Text(
                          _enabled
                              ? context.l10n.sepay_enable_integration_helper
                              : context
                                    .l10n
                                    .sepay_enable_integration_off_helper,
                          style: AppTypography.bodySmall.colored(
                            colors.textMuted,
                          ),
                        ),
                        AppSpacing.gapH8,
                        _enabled
                            ? AppStatusBadge.success(
                                label: context.l10n.sepay_integration_toggle_on,
                                icon: Icons.check_circle_outline_rounded,
                              )
                            : AppStatusBadge.neutral(
                                label:
                                    context.l10n.sepay_integration_toggle_off,
                                icon: Icons.pause_circle_outline_rounded,
                              ),
                      ],
                    ),
                  ),
                  AppSpacing.gapW8,
                  Switch(
                    value: _enabled,
                    activeThumbColor: colors.primary,
                    activeTrackColor: colors.primary.withValues(alpha: 0.32),
                    inactiveThumbColor: colors.textMuted,
                    inactiveTrackColor: colors.cardBorder,
                    trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((
                      states,
                    ) {
                      if (states.contains(WidgetState.selected)) {
                        return colors.primary.withValues(alpha: 0.65);
                      }
                      return colors.borderStrong;
                    }),
                    onChanged: (value) {
                      setState(() => _enabled = value);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    final apiBaseUrl = AppConfig.baseUrl.trim().replaceFirst(
      RegExp(r'/+$'),
      '',
    );
    final parsedApiBaseUrl = Uri.tryParse(apiBaseUrl);
    final callbackUrl =
        parsedApiBaseUrl != null &&
            parsedApiBaseUrl.scheme == 'https' &&
            parsedApiBaseUrl.host.isNotEmpty
        ? '$apiBaseUrl/api/v1/sepay/oauth/callback'
        : null;

    final scopesText = context.l10n.sepay_developer_setup_scopes;
    final scopePattern = RegExp(
      r'bank-account:read|webhook:read|webhook:write|webhook:delete|company',
    );
    final scopeSpans = <TextSpan>[];
    var cursor = 0;
    for (final match in scopePattern.allMatches(scopesText)) {
      scopeSpans.add(TextSpan(text: scopesText.substring(cursor, match.start)));
      scopeSpans.add(TextSpan(
        text: match.group(0),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ));
      cursor = match.end;
    }
    scopeSpans.add(TextSpan(text: scopesText.substring(cursor)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: colors.textSecondary,
              size: 20,
            ),
            AppSpacing.gapW8,
            Expanded(
              child: Text(
                context.l10n.sepay_developer_setup_title,
                style: AppTypography.labelMedium.bold.colored(
                  colors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        AppSpacing.gapH12,
        Text(
          context.l10n.sepay_developer_setup_steps,
          style: AppTypography.bodySmall.colored(colors.textMuted),
        ),
        AppSpacing.gapH12,
        Text(
          context.l10n.sepay_callback_url_label,
          style: AppTypography.labelMedium.bold.colored(colors.textPrimary),
        ),
        AppSpacing.gapH8,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colors.inputFill,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colors.cardBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: callbackUrl == null
                    ? Text(
                        context.l10n.sepay_callback_url_missing,
                        style: AppTypography.bodySmall.colored(
                          colors.textMuted,
                        ),
                      )
                    : SelectableText(
                        callbackUrl,
                        style: AppTypography.bodySmall.colored(
                          colors.textPrimary,
                        ),
                      ),
              ),
              if (callbackUrl != null) ...[
                AppSpacing.gapW4,
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  tooltip: context.l10n.sepay_callback_url_tooltip,
                  onPressed: () =>
                      _copyToClipboard(callbackUrl, context.l10n.com_copied),
                ),
              ],
            ],
          ),
        ),
        AppSpacing.gapH8,
        Text(
          context.l10n.sepay_callback_url_description,
          style: AppTypography.bodySmall.colored(colors.textMuted),
        ),
        AppSpacing.gapH12,
        Text.rich(
          TextSpan(children: scopeSpans),
          style: AppTypography.bodySmall.colored(colors.textMuted),
        ),
      ],
    );
  }
}
