import 'package:flutter/material.dart';
import '../../../../app/provider/localization_provider.dart';
import '../../../../app/theme/theme.dart';

class SessionAdvanceSettings extends StatelessWidget {
  const SessionAdvanceSettings({
    super.key,
    required this.enabled,
    required this.dynamicFee,
    required this.initialAmount,
    required this.onEnabled,
    required this.onAmount,
  });

  final bool enabled, dynamicFee;
  final int? initialAmount;
  final ValueChanged<bool> onEnabled;
  final ValueChanged<int?> onAmount;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          value: enabled,
          title: Text(l10n.advance_enable),
          subtitle: Text(l10n.advance_optional),
          onChanged: onEnabled,
        ),
        if (enabled && dynamicFee) ...[
          AppSpacing.gapH8,
          TextFormField(
            initialValue: initialAmount?.toString(),
            decoration: InputDecoration(labelText: l10n.advance_amount),
            keyboardType: TextInputType.number,
            onChanged: (value) => onAmount(int.tryParse(value.trim())),
            validator: (value) {
              final amount = int.tryParse(value?.trim() ?? '');
              return amount == null || amount <= 0 || amount > 9999999999999
                  ? l10n.advance_valid_amount
                  : null;
            },
          ),
        ],
      ],
    );
  }
}
