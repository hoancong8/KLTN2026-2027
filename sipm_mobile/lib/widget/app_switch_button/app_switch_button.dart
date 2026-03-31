import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppSwitchButton extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final double width;
  final double height;
  final Color activeColor;
  final Color inactiveColor;
  final Color thumbColor;
  final Color borderColor;
  final bool shadow;
  final Duration duration;
  final EdgeInsetsGeometry padding;
  final FocusNode? focusNode;
  final String? semanticsLabel;

  const AppSwitchButton({
    super.key,
    required this.value,
    required this.onChanged,
    this.width = 52,
    this.height = 32,
    this.activeColor = const Color(0xFF26A65B),
    this.inactiveColor = const Color(0xFFE6E8EB),
    this.thumbColor = Colors.white,
    this.borderColor = const Color(0xFF26A65B),
    this.shadow = true,
    this.duration = const Duration(milliseconds: 160),
    this.padding = const EdgeInsets.all(3),
    this.focusNode,
    this.semanticsLabel,
  });

  @override
  State<AppSwitchButton> createState() => AppSwitchButtonState();
}

class AppSwitchButtonState extends State<AppSwitchButton> {
  bool pressed = false;

  void toggle() {
    widget.onChanged(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final double radius = widget.height / 2;
    final double thumbSize = widget.height - (widget.padding.vertical);
    final Alignment alignment = widget.value ? Alignment.centerRight : Alignment.centerLeft;

    return Focus(
      focusNode: widget.focusNode,
      canRequestFocus: true,
      onKeyEvent: (node, event) {
        if (event.logicalKey.keyLabel == ' ' || event.logicalKey.keyLabel == 'Enter') {
          if (event is KeyUpEvent) toggle();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Semantics(
        label: widget.semanticsLabel ?? 'Switch',
        button: true,
        toggled: widget.value,
        onTap: toggle,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => setState(() => pressed = true),
          onTapCancel: () => setState(() => pressed = false),
          onTapUp: (_) => setState(() => pressed = false),
          onTap: toggle,
          child: AnimatedContainer(
            duration: widget.duration,
            curve: Curves.easeOut,
            width: widget.width,
            height: widget.height,
            padding: widget.padding,
            decoration: BoxDecoration(
              color: widget.value ? widget.activeColor : widget.inactiveColor,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: widget.borderColor.withOpacity(widget.value ? 1 : 0), width: widget.value ? 1 : 0),
            ),
            child: AnimatedAlign(
              duration: widget.duration,
              alignment: alignment,
              curve: Curves.easeOut,
              child: AnimatedContainer(
                duration: widget.duration,
                curve: Curves.easeOut,
                width: thumbSize,
                height: thumbSize,
                decoration: BoxDecoration(
                  color: widget.thumbColor,
                  shape: BoxShape.circle,
                  boxShadow: widget.shadow
                      ? [
                    BoxShadow(
                      blurRadius: pressed ? 2 : 4,
                      spreadRadius: 0,
                      offset: Offset(0, pressed ? 0.5 : 1.5),
                      color: Colors.black.withOpacity(0.18),
                    ),
                  ]
                      : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
