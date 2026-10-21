import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kltn2026_2027/app/theme/theme.dart';

class AppEditText extends StatefulWidget {
  // Controller
  final TextEditingController? controller;

  // Styling
  final String? hintText;
  final String? labelText;
  final String? helperText;
  final String? errorText;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final double borderRadius;
  final EdgeInsetsGeometry? contentPadding;

  // Input Configuration
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final bool obscureText;
  final bool autocorrect;
  final bool enableSuggestions;
  final double? width;
  final double? height;

  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Widget? prefix;
  final Widget? suffix;
  final String? prefixText;
  final String? suffixText;

  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;

  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final void Function()? onTap;
  final void Function()? onEditingComplete;
  final FocusNode? focusNode;

  const AppEditText({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.helperText,
    this.errorText,
    this.textStyle,
    this.hintStyle,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.borderRadius = AppRadius.md,
    this.contentPadding,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.obscureText = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.prefixIcon,
    this.suffixIcon,
    this.prefix,
    this.suffix,
    this.prefixText,
    this.suffixText,
    this.validator,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.onEditingComplete,
    this.focusNode,
    this.width,
    this.height,
  });

  @override
  State<AppEditText> createState() => _AppEditTextState();
}

class _AppEditTextState extends State<AppEditText> {
  late FocusNode focusNode;
  bool isFocused = false;
  bool obscurePassword = true;

  @override
  void initState() {
    super.initState();
    focusNode = widget.focusNode ?? FocusNode();
    focusNode.addListener(onFocusChange);
    obscurePassword = widget.obscureText;
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void onFocusChange() {
    setState(() {
      isFocused = focusNode.hasFocus;
    });
  }

  void togglePasswordVisibility() {
    setState(() {
      obscurePassword = !obscurePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: AppTypography.titleSmall.copyWith(
              color: widget.errorText != null
                  ? (widget.errorBorderColor ?? colors.error)
                  : colors.textPrimary,
            ),
          ),
          AppSpacing.gapH8,
        ],

        SizedBox(
          width: widget.width,
          height: widget.height,
          child: TextFormField(
            controller: widget.controller,
            focusNode: focusNode,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            autofocus: widget.autofocus,
            obscureText: obscurePassword,
            autocorrect: widget.autocorrect,
            enableSuggestions: widget.enableSuggestions,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            textCapitalization: widget.textCapitalization,
            maxLines: widget.obscureText ? 1 : widget.maxLines,
            minLines: widget.minLines,
            maxLength: widget.maxLength,
            inputFormatters: widget.inputFormatters,
            validator: widget.validator,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onSubmitted,
            onTap: widget.onTap,
            onEditingComplete: widget.onEditingComplete,
            style: widget.textStyle ??
                AppTypography.bodyMedium.copyWith(color: colors.textPrimary),
            decoration: InputDecoration(
              isDense: true,
              hintText: widget.hintText,
              hintStyle: widget.hintStyle ??
                  AppTypography.bodyMedium.copyWith(
                    color: colors.textPlaceholder,
                  ),
              helperText: widget.helperText,
              errorText: widget.errorText,
              filled: true,
              fillColor: widget.enabled
                  ? (widget.fillColor ?? colors.inputFill)
                  : (context.isDark ? AppColors.neutral800 : AppColors.neutral200),
              contentPadding: widget.contentPadding ??
                  const EdgeInsets.symmetric(
                    horizontal: AppSpacing.base,
                    vertical: AppSpacing.md + 2,
                  ),

              prefixIcon: widget.prefixIcon,
              prefix: widget.prefix,
              prefixText: widget.prefixText,
              prefixStyle: AppTypography.bodyMedium.copyWith(color: colors.textSecondary),

              suffixIcon: widget.obscureText
                  ? IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: colors.textSecondary,
                        size: AppSpacing.iconMd,
                      ),
                      onPressed: togglePasswordVisibility,
                    )
                  : widget.suffixIcon,
              suffix: widget.suffix,
              suffixText: widget.suffixText,
              suffixStyle: AppTypography.bodyMedium.copyWith(color: colors.textSecondary),

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(
                  color: widget.borderColor ?? colors.inputBorder,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(
                  color: widget.focusedBorderColor ?? colors.primary,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(
                  color: widget.errorBorderColor ?? colors.error,
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(
                  color: widget.errorBorderColor ?? colors.error,
                  width: 1.5,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(color: colors.borderSubtle, width: 1),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
