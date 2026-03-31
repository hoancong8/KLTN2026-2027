import 'package:flutter/material.dart';

class SimpleCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? label;

  const SimpleCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    const double size = 20;

    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: () => onChanged(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: value ? const Color(0xFF2ACB8B) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: const Color(0xFF2ACB8B),
                width: 2,
              ),
            ),
            child: value
                ? const Icon(
              Icons.check,
              size: 14,
              color: Colors.white,
            )
                : null,
          ),
          if (label != null) ...[
            const SizedBox(width: 8),
            Text(
              label!,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ],
      ),
    );
  }
}
