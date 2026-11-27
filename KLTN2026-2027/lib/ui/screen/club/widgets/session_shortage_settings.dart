import 'package:flutter/material.dart';
import '../../../../app/provider/localization_provider.dart';

class SessionShortageSettings extends StatelessWidget {
  const SessionShortageSettings({
    super.key,
    required this.capacity,
    required this.minimumPlayers,
    required this.checkMinutes,
    required this.onMinimumChanged,
    required this.onCheckChanged,
  });

  final int capacity;
  final int minimumPlayers;
  final int checkMinutes;
  final ValueChanged<int> onMinimumChanged;
  final ValueChanged<int> onCheckChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.session_shortage_settings),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: minimumPlayers.toString(),
          decoration: InputDecoration(labelText: l10n.session_shortage_minimum),
          keyboardType: TextInputType.number,
          onChanged: (text) => onMinimumChanged(int.tryParse(text) ?? 0),
          validator: (text) {
            final count = int.tryParse(text ?? '');
            return count == null || count < 4 || count > capacity
                ? l10n.session_shortage_invalid_minimum
                : null;
          },
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: checkMinutes.toString(),
          decoration: InputDecoration(labelText: l10n.session_shortage_lead),
          keyboardType: TextInputType.number,
          onChanged: (text) => onCheckChanged(int.tryParse(text) ?? 0),
          validator: (text) {
            final minutes = int.tryParse(text ?? '');
            return minutes == null || minutes < 1 || minutes > 2147483647
                ? l10n.session_shortage_invalid_lead
                : null;
          },
        ),
      ],
    );
  }
}
